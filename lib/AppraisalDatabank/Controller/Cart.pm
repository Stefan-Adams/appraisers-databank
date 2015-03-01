package AppraisalDatabank::Controller::Cart;
use Mojo::Base 'Mojolicious::Controller';

sub additem {
  my $c = shift;
  my $cart = $c->session('cart') || [];
  push @$cart, $c->param('filename');
  $c->session(cart => $cart);
  $c->redirect_to('home');
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

sub checkout {
  my $c = shift->render_later;
  warn Data::Dumper::Dumper($c->req->params->to_hash);
  $c->paypal->transaction_id_mapper(sub {
    my ($self, $token, $transaction_id, $cb) = @_;
    if($transaction_id) {
      #warn "STORE $token => $transaction_id";
      eval { $c->redis->setex($token => 600 => $transaction_id) };
      $self->$cb($@, $transaction_id);
    }
    else {
      my $transaction_id = eval { $c->redis->get($token) };
      #warn "GET $transaction_id <= $token";
      $self->$cb($@, $transaction_id);
    }
  });
  if ( $c->param('return_url') && $c->param('PayerID') && $c->param('paymentId') ) {
    $c->delay(
      sub {
        my ($delay) = @_;
        $c->paypal(process => {}, $delay->begin);
      },
      sub {
        my ($delay, $res) = @_;
        return $c->reply->exception($res->code.': \''.$res->param('message').'\'') unless $res->code == 200;
        my $cart = $c->session('cart') || [];
        $c->session(cart => []);
        foreach my $doc ( @$cart ) {
          my $purchase = {
            transaction => $c->param('paymentId'),
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
  } elsif ( $c->param('return_url') ) {
    $c->flash(error => 'Purchase Cancelled!');
    $c->redirect_to('cart')
  } else {
    my $cart = $c->session('cart') || [];
    my $amount = ($#$cart+1)*8;
    my %payment = (
      amount => $amount,
      description => join("\n", join("\n", map { "\$8 - $_" } @$cart), "Total: $amount"),
    );
    $c->delay(
      sub {
        my ($delay) = @_;
        $c->paypal(register => \%payment, $delay->begin);
      },
      sub {
        my ($delay, $res) = @_;
        return $c->reply->exception($res->code.': \''.$res->error->{message}.'\'') unless $res->code == 302;
        $c->redirect_to($res->headers->location);
      },
    );
  }
}

1;
