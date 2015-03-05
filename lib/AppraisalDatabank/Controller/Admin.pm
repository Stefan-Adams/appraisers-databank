package AppraisalDatabank::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';

sub home {
  my $c = shift;
  $c->render;
}

1;