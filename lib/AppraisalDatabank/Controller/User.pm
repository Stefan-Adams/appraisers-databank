package AppraisalDatabank::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Util qw/slurp md5_sum/;

use File::Path;
use File::Basename;

sub register {
  my $c = shift;

  # Check if parameters have been submitted
  my $validation = $c->validation;
  return $c->render unless $validation->has_data;

  # Validate parameters ("pass_again" depends on "password")
  $validation->required('email')->email->not_exists;
  $validation->required('pass_again')->equal_to('password') and delete $validation->output->{pass_again}
    if $validation->required('password')->size(1, 64)->is_valid;
  $validation->required('slid');
  $validation->required('taxid');
  $validation->required('firstname');
  $validation->required('lastname');
  $validation->required('address');
  $validation->required('city');
  $validation->required('state')->like(qr/^[A-Za-z]{2}$/);
  $validation->required('zip')->like(qr/^(\d{5}|\d{5}-\d{4})$/);
  $validation->required('phone')->phone;
  $validation->required('tos');

  # Re-render if validation was unsuccessful
  return $c->render if $validation->has_error;

  # Check file size
  return $c->render(text => 'File is too big.', status => 200)
    if $c->req->is_limit_exceeded;

  # Process uploaded file
  return $c->render unless my $w9 = $c->param('w9');
  my $size = $w9->size;
  my $name = $w9->filename;
  my $filename = $c->app->home->rel_file('w9/'.$validation->output->{'state'}.'/'.$validation->output->{'slid'});
  mkpath dirname $filename;
  # TODO: Insert file system hashing function here
  $w9->move_to($filename);
  if ( -e $filename && -s _ == $size ) {
    $c->render_later;
    $c->mysql->db->query($c->sql->insert('users', $validation->output) => sub {
      my ($db, $err, $results) = @_;
      if ( $err ) {
        # Remove file
        $c->reply->exception($err);
      } else {
        $c->app->log->info("uploaded $name to $filename");
        $c->stash(success => "Thanks for registering.");
        $c->redirect_to('home');
      }
    });
  } else {
    # Remove file
    $c->reply->exception('Something went wrong saving your upload!');
  }
}

sub login {
  my $c = shift;

  # Check if parameters have been submitted
  my $validation = $c->validation;
  return $c->render unless $validation->has_data;

  # Validate that username and password work
  $validation->required('email')->email;
  $validation->required('password');

  # Re-render if validation was unsuccessful
  return $c->render if $validation->has_error;
  
  $c->render_later;
  $c->mysql->db->query('select * from users where email = ? and password = ?', $validation->param([qw/email password/]) => sub {
    my ($db, $err, $results) = @_;
    if ( $err ) {
      $c->reply->exception('Something went wrong with your login!');
    } else {
      if ( $results->rows ) {
        $c->session(user => $results->hash);
        $c->redirect_to('home');
      } else {
        $c->render;
      }
    }
  });
}

sub logout {
  my $c = shift;
  $c->session(user => undef);
  $c->redirect_to('home');
}

sub profile {
  my $c = shift;
  $c->render(text => 'profile');
}

sub purchases {
  my $c = shift;
  $c->render(text => 'purchases');
}

1;