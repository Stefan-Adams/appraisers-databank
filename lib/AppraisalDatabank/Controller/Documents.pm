package AppraisalDatabank::Controller::Documents;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Util qw/slurp md5_sum/;

use File::Path;
use File::Basename;

sub search {
  my $c = shift;

  return $c->redirect_to('login') unless $c->session('user');

  # Check if parameters have been submitted
  my $validation = $c->validation;
  return $c->render unless $validation->has_data;

  # Validate that username and password work
  $validation->required('zip')->zip;
  $validation->optional('mls');#->like(qr/^\w+$/);
  $validation->optional('address');#->like(/^\d+$/);

  # Re-render if validation was unsuccessful
  return $c->render if $validation->has_error;

  my ($search, $sql, @bind) = $c->_search($validation);
  defined $sql or return $c->render(error => 'Too many results, please refine your search');

  $c->delay(
    sub { # Search
      $c->mysql->db->query($sql, @bind => shift->begin);
    },
    sub { # Check results
      my ($delay, $err, $results) = @_;
      if ( $err ) {
        $c->stash(error => $err);
      } else {
        if ( $results->rows ) {
          $search->{results} = $results->rows;
          $c->stash(results => $results->hashes);
        } else {
          $c->stash(error => 'No results, please refine your search');
        }
      }
      $c->mysql->db->query($c->sql->insert('searches', $search) => $delay->begin);
    },
    sub { # Render
      $c->render;
    }
  );
}

sub upload {
  my $c = shift;

  # Check if parameters have been submitted
  my $validation = $c->validation;
  return $c->render unless $validation->has_data;

  # Validate parameters
  #$validation->required('doc'); # Doesn't seem to work by Mojolicious...
  $validation->required('inspection_date')->like(qr/^\d{4}-\d{2}-\d{2}$/);
  $validation->optional('mls');
  $validation->optional('address');
  $validation->optional('city');
  $validation->optional('county');
  $validation->optional('state')->state;
  $validation->required('zip')->zip;
  $validation->output->{user_id} = $c->session('user')->{id};

  # Re-render if validation was unsuccessful
  return $c->render if $validation->has_error;
  return $c->render(error => 'Sorry, that file is too big.') if $c->req->is_limit_exceeded;

  # Process uploaded file
  return $c->render unless my $doc = $c->param('doc');
  my $name = $doc->filename;
  unless ( $doc->headers->content_type eq 'application/pdf' ) {
    return $c->render(error => 'Whoops, your document must be a PDF. Please try again.');
  }
  #my $filename = $validation->output->{filename} = md5_sum($name.time.$c->session('user')->{email});
  my $filename = join('-', $validation->output->{zip}, $validation->output->{mls}, $validation->output->{address});
  $filename =~ s/\W/_/g;
  my $docdir = $c->app->home->rel_file('documents/'.$validation->output->{zip});
  mkpath $docdir unless -d $docdir;
  $doc->move_to("$docdir/$filename");
  unless ( -e "$docdir/$filename" && -s _ == $doc->size ) {
    unlink "$docdir/$filename";
    $c->render(error => "Uh oh, something went wrong saving your upload. Let's try this again.");
  }
  $c->delay(
    sub {
      $c->mysql->db->query($c->sql->insert('documents', $validation->output) => shift->begin);
    },
    sub {
      my ($delay, $err, $results) = @_;
      if ( $err ) {
        unlink "$docdir/$filename";
        $c->render(error => $err);
      } else {
        $c->app->log->info("uploaded $name to $filename");
        $c->render(success => "Great! You've uploaded file $name (confirmation: $filename).");
      }
    }
  );
}

sub download {
  my $c = shift->render_later;
  my $zip = $c->param('zip');
  my $filename = $c->param('filename');
  if ( $c->session('user')->{admin} ) {
    $c->reply->document($zip, $filename);
  } else {
    my $owner = $c->mysql->db->query('select 1 from documents where filename=? and user_id=?', $filename, $c->session('user')->{id});
    if ( $owner->rows ) {
      $c->reply->document($zip, $filename);
    } else {
      $c->mysql->db->query('update transactions set last_downloaded=now(),downloaded=downloaded+1 where filename=? and user_id=?', $filename, $c->session('user')->{id} => sub {
        my ($db, $err, $results) = @_;
        if ( $results->rows ) {
          $c->reply->document($zip, $filename);
        } else {
          $c->reply->not_found;
        }
      });
    }
  }
}

sub flag {
  my $c = shift;
  my $query = $c->mysql->db->query('update documents set flagged_by=?,flagged_at=now() where filename=?', $c->session('user')->{user_id}, $c->param('filename'));
  if ( $query->rows ) {
    $c->stash(success => 'Flagged');
  } else {
    $c->stash(error => 'Could not flag');
  }
}

sub verify {
  my $c = shift;
  if ( $c->param('verify') eq 'complete' ) {
    my $query = $c->mysql->db->query('update documents set complete=now(),incomplete=null where filename=?', $c->param('filename'));
    if ( $query->rows ) {
      $c->stash(success => 'Marked as complete');
    } else {
      $c->stash(error => 'Could not mark as complete');
    }
  } elsif ( $c->param('verify') eq 'incomplete' ) {
    my $query = $c->mysql->db->query('update documents set incomplete=now(),complete=null where filename=?', $c->param('filename'));
    if ( $query->rows ) {
      $c->stash(success => 'Marked as incomplete');
    } else {
      $c->stash(error => 'Could not mark as incomplete');
    }
  }
}

sub _search {
  my ($c, $validation) = @_;

  my $user = $c->session('user')->{id};
  my $admin = $c->session('user')->{admin};
  my ($zip, $mls, $address) = map { $validation->output->{$_} } qw/zip mls address/;

  my $search = {
    user_id => $user,
    zip => $zip,
    mls => $mls,
    address => $address,
  };

  my $select = 'select documents.*,if(documents.user_id=? or (transactions.user_id=? and refunded_at is null) or ?,1,0) can_download from documents';
  my $join_transactions = 'left join transactions on documents.filename=transactions.filename and transactions.user_id=?';
  my $complete_or_not_flagged = 'and ((flagged_at is null and incomplete is null) or complete is not null)';
  my $order = 'order by inspection_date desc, uploaded desc';

  my ($sql, @bind);
  if ( $mls && $address && $address =~ /^(\d+)/ ) {
    $sql = <<SQL;
    $select $join_transactions where zip=? and mls=? $complete_or_not_flagged limit 1
      union distinct
    $select $join_transactions where zip=? and mls is null $complete_or_not_flagged
      union distinct
    $select $join_transactions where zip=? and (address=? or address like ?) $complete_or_not_flagged $order
SQL
    @bind = ($user, $user, $admin, $user, $zip, $mls, $user, $user, $admin, $user, $zip, $user, $user, $admin, $user, $zip, $1, "$1 %");
  } elsif ( $mls ) {
    $sql = <<SQL;
    $select $join_transactions where zip=? and mls=? $complete_or_not_flagged limit 1
      union distinct
    $select $join_transactions where zip=? and mls is null $complete_or_not_flagged $order
SQL
    @bind = ($user, $user, $admin, $user, $zip, $mls, $user, $user, $admin, $user, $zip);
  } elsif ( $address && $address =~ /^(\d+)/) {
    $sql = "$select $join_transactions where zip=? and (address=? or address like ?) $complete_or_not_flagged $order";
    @bind = ($user, $user, $admin, $user, $zip, $1, "$1 %");
  }
  return $search, $sql, @bind;
}

1;