package AppraisalDatabank::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Util qw/slurp md5_sum/;

use File::Path;
use File::Basename;

sub prereq {
  my $c = shift;
  unless ( $c->mysql->db->query('select tos from users where id=?', $c->session('user')->{id})->array->[0] ) {
    $c->stash(tos_missing => 'You must agree to the TOS');
    $c->redirect_to('profile');
  }
  my @w9 = glob($c->app->home->rel_file('w9/'.$c->session('user')->{'state'}.'/'.$c->session('user')->{'slid'}.'-*'));
  unless ( $#w9+1 ) {
    $c->stash(w9_missing => 'You must provide an updated W9');
    $c->redirect_to('profile');
  }
  return 1;
}

sub profile {
  my $c = shift;
  my $register = $c->session('user') ? 0 : 1;
  $c->stash(register => $register);

  # Check if parameters have been submitted
  my $validation = $c->validation;
  return $c->render unless $validation->has_data;

  if ( $register ) {
    # Validate parameters ("pass_again" depends on "password")
    $validation->required('email')->email->not_exists;
    $validation->required('pass_again')->equal_to('password') and delete $validation->output->{pass_again}
      if $validation->required('password')->password->is_valid;
    $validation->required('slid');
    $validation->required('taxid');
    #$validation->required('w9'); # Possible bug?
    $validation->required('firstname');
    $validation->required('lastname');
    $validation->required('address');
    $validation->required('city');
    $validation->required('state')->state;
    $validation->required('zip')->zip;
    $validation->required('phone')->phone;
    $validation->required('tos');
  } else {
    if ( $c->stash('tos_missing') ) {
      $c->validation->required('tos');
    }
    if ( $c->stash('w9_missing') ) {
      #$c->validation->required('w9'); # Possible bug?
    }
  }

  # Re-render if validation was unsuccessful
  return $c->render if $validation->has_error;
  return $c->render(error => 'File is too big.') if $c->req->is_limit_exceeded;

  # Process uploaded file
  if ( my $w9 = $c->param('w9') ) {
    my $name = $w9->filename;
    my $filename = $c->app->home->rel_file('w9/'.$validation->output->{'state'}.'/'.$validation->output->{'slid'}.'-'.$name);
    mkpath dirname $filename unless -d dirname $filename;
    $w9->move_to($filename);
    if ( -e $filename && -s _ == $w9->size ) {
      $c->app->log->info("uploaded $name to $filename");
    } else {
      unlink $filename;
      $c->render(error => 'Something went wrong saving your upload!');
    }
  }

  if ( $register ) {
    $c->render_later;
    $c->mysql->db->query($c->sql->insert('users', $validation->output) => sub {
      my ($db, $err, $results) = @_;
      if ( $err ) {
        $c->render(error => $err);
      } else {
        $c->flash(f_success => "Thanks for registering.");
        $c->redirect_to('login');
      }
    });
  } else {
    $c->render_later;
    $c->mysql->db->query($c->sql->update('users', $validation->output) => sub {
      my ($db, $err, $results) = @_;
      if ( $err ) {
        $c->render(error => $err);
      } else {
        $c->render(success => "Updated profile.");
      }
    });
  }
}

sub login {
  my $c = shift;

  # Check if parameters have been submitted
  my $validation = $c->validation;
  return $c->render unless $validation->has_data;

  # Validate that username and password work
  $validation->required('email')->email;
  $validation->required('password')->password;

  # Re-render if validation was unsuccessful
  return $c->render if $validation->has_error;
  
  $c->render_later;
  $c->mysql->db->query('select * from users where email = ? and password = ?', $validation->param([qw/email password/]) => sub {
    my ($db, $err, $results) = @_;
    if ( $err ) {
      $c->render(error => 'Something went wrong with your login!');
    } else {
      if ( $results->rows ) {
        $c->session(user => $results->hash);
        $c->redirect_to('search');
      } else {
        $c->render(error => 'Something went wrong with your login!');
      }
    }
  });
}

sub logout {
  my $c = shift;
  $c->session(user => undef);
  $c->redirect_to('adb');
}

sub purchases {
  my $c = shift;
  $c->render(text => 'purchases');
}

1;