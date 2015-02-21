use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('AppraisalDatabank');
$t->get_ok('/')->status_is(302)->header_is(Location => '/user/login');
$t->get_ok('/user/login')->status_is(200)->content_like(qr/Register/);
$t->get_ok('/user/login' => form => {email => 'm@m.com', password => 'm'})->status_is(302)->header_is(Location => '/');
$t->get_ok('/')->content_like(qr/Welcome, m/);
$t->get_ok('/' => form => {zip => '1234'})->content_like(qr/field-with-error/);
$t->get_ok('/' => form => {zip => '12345'})->content_like(qr/Too many/);
$t->get_ok('/' => form => {zip => '12345', address => '111'})->content_like(qr/No results/);
$t->get_ok('/' => form => {zip => '12345', address => '1111'})->content_like(qr/1111 east third/);
done_testing();
