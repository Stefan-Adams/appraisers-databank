package AppraisalDatabank::Controller::About;
use Mojo::Base 'Mojolicious::Controller';

sub adb {
  my $c = shift;
  $c->render;
}

1;