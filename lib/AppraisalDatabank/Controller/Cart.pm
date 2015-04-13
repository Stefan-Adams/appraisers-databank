package AppraisalDatabank::Controller::Cart;
use Mojo::Base 'Mojolicious::Controller';

sub additem {
  my $c = shift;
  my $cart = $c->session('cart') || [];
  push @$cart, $c->param('filename');
  $c->session(cart => $cart);
  $c->redirect_to('search');
}

sub view {
  my $c = shift->render_later;
  my $cart = $c->session('cart') || [];
  $c->mysql->db->query($c->sql->select('documents', '*', {filename => {'-in' => $cart}}) => sub {
    my ($db, $err, $results) = @_;
    $c->render(cart => $results->hashes);
  });
}

sub removeitem {
  my $c = shift;
  my $cart = $c->session('cart') || [];
  $c->session(cart => [grep { $_ ne $c->param('filename') } @$cart]);
  $c->redirect_to('cart');
}

sub purchase {
  my $c = shift;

  my $validation = $c->validation;

  $validation->required($_) for qw(amount stripeToken);
  $validation->has_error and return $c->render(text => 'There was some missing values in the checkout form. Please try again.');

  my $cart = $c->session('cart') || [];

  $c->delay(
    sub { $c->stripe->create_charge({}, shift->begin) },
    sub {
      my ($delay, $err, $res) = @_;
      #warn $c->dumper($res);
      return $c->reply->exception($err) if $err;
      $c->session(cart => []);
      foreach my $doc ( @$cart ) {
        my $purchase = {
          transaction => $res->{id},
          filename => $doc,
          user_id => $c->session('user')->{id},
        };
        $c->mysql->db->query($c->sql->insert('transactions', $purchase));
      }
      $c->mysql->db->query($c->sql->select('documents', '*', {filename => {'-in' => $cart}}) => $delay->begin);
    },
    sub {
      my ($delay, $err, $results) = @_;
      $c->render(cart => $results->hashes);
    },
  );
}

1;
