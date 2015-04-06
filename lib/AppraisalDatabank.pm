package AppraisalDatabank;
use Mojo::Base 'Mojolicious';

our $VERSION = '0.00';

use Mojo::mysql;
use Mojo::Redis2;

use SQL::Abstract;
use Email::Valid;
use Number::Phone;

# This method will run once at server start
sub startup {
  my $app = shift;

  my $config = $app->plugin('Config');

  $app->plugin('AssetPack');
  $app->plugin(PayPal => $app->config->{paypal});

  $app->helper('is_current' => sub { q(class="current") if $_[0]->current_route eq $_[1] });
  $app->helper('mysql' => sub { Mojo::mysql->new($config->{mysql}) });
  $app->helper('sql' => sub { SQL::Abstract->new });
  $app->helper('redis => sub { Mojo::Redis2->new($config->{redis}) });
  $app->helper('form_row' => \&_form_row);
  $app->helper('reply.document' => \&_reply_document);

  $app->mysql->migrations->from_data->migrate;

  $app->defaults(results => Mojo::Collection->new);
  $app->session(cart => []) unless $app->session('cart');

  $app->_add_validations;
  $app->_add_conditions;
  $app->_add_assets;
  $app->_add_routes;
}

sub _add_assets {
  my $app = shift;
  $app->asset('adb.css' =>
    '/css/adb.css',
    '/css/normalize.css',
    '/css/main.css',
    'http://fonts.googleapis.com/css?family=EB+Garamond',
  );
}

sub _add_routes {
  my $app = shift;

  my $r = $app->routes;

  # Normal route to controller
  $app->routes->get('/')->name('home');

  my $about = $app->routes->under('/about');
  $about->get('/learn-more')->name('about/learn-more');
  $about->get('/find')->name('about/find');
  $about->get('/sell')->name('about/sell');
  $about->get('/us')->name('about/us');
  $about->get('/contact')->name('about/contact');
  $about->get('/tos')->name('about/tos');

  my $admin = $app->routes->under('/admin')->over(admin=>1);
  $admin->get('/')->to('admin#home')->name('admin');

  my $user = $app->routes->under('/user');
  $user->get('/register')->over(user=>0)->to('user#profile'); # if logged in, redirect to home
  $user->post('/register')->over(user=>0)->to('user#profile'); # if logged in, redirect to home
  $user->get('/login')->over(user=>0)->to('user#login'); # if logged in, redirect to home
  $user->post('/login')->over(user=>0)->to('user#login'); # if logged in, redirect to home
  $user->get('/logout')->to('user#logout'); # if not logged in, redirect to home
  $user->get('/profile')->over(user=>1)->to('user#profile'); # e.g. change password, change email and change all DB references
  $user->post('/profile')->over(user=>1)->to('user#profile'); # e.g. change password, change email and change all DB references
  $user->get('/purchases')->over(user=>1)->to('user#purchases'); # e.g. past purchases

  my $documents = $app->routes->under('/documents')->over(user=>1)->to('user#prereq');
  $documents->get('/')->to('documents#search')->name('search');
  $documents->post('/')->to('documents#search')->name('search');
  $documents->get('/upload')->to('documents#upload');
  $documents->post('/upload')->to('documents#upload');
  $documents->get('/download/:zip/:filename')->to('documents#download')->name('download');
  $documents->get('/flag/:filename')->to('documents#flag')->name('flag');
  $documents->get('/review')->over(admin=>1)->to('documents#review'); # review flagged docs
  $documents->get('/verify/:verify/:filename' => [verify => [qw/complete incomplete/]])->over(admin=>1)->to('documents#verify')->name('verify');

  my $cart = $app->routes->under('/cart')->over(user=>1)->to('user#prereq');
  $cart->get('/add/:filename')->to('cart#additem')->name('add_to_cart');
  $cart->get('/')->to('cart#view')->name('cart');
  $cart->get('/remove/:filename')->to('cart#removeitem')->name('remove_from_cart');
  $cart->get('/checkout')->to('cart#checkout');
}

sub _add_validations {
  my $app = shift;
  $app->validator->add_check(not_exists => sub {
    $app->mysql->db->query('select 1 from users where email = ?', $_[2])->rows;
  });
  $app->validator->add_check(password => sub { $_[2] =~ /^.{1,64}$/ ? 0 : 1 });
  $app->validator->add_check(state => sub { $_[2] =~ /^[A-Za-z]{2}$/ ? 0 : 1 });
  $app->validator->add_check(zip => sub { $_[2] =~ /^\d{5}(-\d{4})?$/ ? 0 : 1 });
  $app->validator->add_check(email => sub { Email::Valid->address($_[2]) ? 0 : 1 });
  $app->validator->add_check(phone => sub { ref Number::Phone->new('US', $_[2]) ? 0 : 1 });
}

sub _add_conditions {
  my ($app) = @_;
  my $r = $app->routes;
  $app->routes->add_condition(xhr => sub {
    my ($route, $c, $captures, $want) = @_;
    $c->req->is_xhr == $want
  });
  $app->routes->add_condition(user => sub {
    my ($route, $c, $captures, $want) = @_;
    defined $c->session('user') == $want
  });
  $app->routes->add_condition(admin => sub {
    my ($route, $c, $captures, $want) = @_;
    defined $c->session('user')->{admin} == $want
  });
}

sub _form_row {
  my ($c, $name, $model, $label, $field) = @_;

  return $c->tag(div => class => 'form-row', sub {
    return join('',
      $c->tag(label => for => "form_$name", sub { $label }),
      $field || $c->text_field($name, $model ? $model->$name : '', id => "form_$name"),
    );
  });
}

sub _reply_document {
  my ($c, $zip, $document) = @_;
  $c->res->headers->content_disposition("attachment; filename=$document.pdf;");
  if ( $document = Mojo::Asset::File->new(path => $c->app->home->rel_file("documents/$zip/$document")) ) {
    $c->reply->asset($document);
  } else {
    $c->reply->not_found;
  }
}

1;

__DATA__

@@ migrations
-- 1 up
CREATE TABLE IF NOT EXISTS `users` ( `id` int(11) NOT NULL AUTO_INCREMENT, `admin` int(1) DEFAULT NULL, `email` varchar(255) NOT NULL, `password` varchar(64) NOT NULL, `disabled` datetime DEFAULT NULL, `firstname` varchar(255) DEFAULT NULL, `lastname` varchar(255) DEFAULT NULL, `slid` varchar(16) NOT NULL, `taxid` varchar(15) NOT NULL, `address` varchar(255) DEFAULT NULL, `city` varchar(255) DEFAULT NULL, `state` varchar(2) DEFAULT NULL, `zip` varchar(10) DEFAULT NULL, `phone` varchar(15) DEFAULT NULL, `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `tos` text, verified_at datetime, PRIMARY KEY (`id`), UNIQUE KEY `email` (`email`)) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS `documents` ( `id` int(11) NOT NULL AUTO_INCREMENT, `user_id` int(11) NOT NULL, `filename` varchar(64) NOT NULL, `mls` varchar(32) DEFAULT NULL, `address` varchar(255) DEFAULT NULL, `city` varchar(32) DEFAULT NULL, `county` varchar(32) DEFAULT NULL, `state` varchar(2) DEFAULT NULL, `zip` varchar(10) NOT NULL, `inspection_date` date NOT NULL, `uploaded` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `complete` datetime DEFAULT NULL, `incomplete` datetime DEFAULT NULL, `flagged_by` int(11) DEFAULT NULL, `flagged_at` datetime DEFAULT NULL, `flagged_reasons` set('pictures','information','sketch') DEFAULT NULL, `flagged_comments` tinytext, PRIMARY KEY (`id`), UNIQUE KEY `filename` (`filename`)) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS `transactions` ( `id` int(11) NOT NULL AUTO_INCREMENT, `transaction` varchar(16) NOT NULL, `filename` varchar(64) NOT NULL, `user_id` int(11) NOT NULL, `purchased_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, `last_downloaded` datetime DEFAULT NULL, `downloaded` int(11) DEFAULT '0', `refunded_at` datetime DEFAULT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS `searches` ( `id` int(11) NOT NULL AUTO_INCREMENT, `user_id` int(11) NOT NULL, searched_at timestamp, `zip` VARCHAR(10) NOT NULL, `mls` varchar(32) DEFAULT NULL, `address` varchar(255) DEFAULT NULL, results smallint, PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS `zips` ( `zip` VARCHAR(5) NOT NULL, `lat` FLOAT NOT NULL, `lng` FLOAT NOT NULL, PRIMARY KEY (`zip`)) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
