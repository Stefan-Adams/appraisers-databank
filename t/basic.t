use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $users = [
    {
      email => 'test0@test0.test0',
      password => 'test0',
      pass_again => 'test0',
      slid => '1230',
      taxid => '1230',
      w9 => {filename => 'w9.pdf'},
      firstname => 'test0',
      lastname => 'test0',
      address => '123 test0',
      city => 'test0',
      state => 'zz',
      zip => '12345',
      phone => '3145551230',
      tos => 'ok',
    },
    {
      email => 'test1@test1.test1',
      password => 'test1',
      pass_again => 'test1',
      slid => '1231',
      taxid => '1231',
      w9 => {filename => 'w9.pdf'},
      firstname => 'test1',
      lastname => 'test1',
      address => '123 test1',
      city => 'test1',
      state => 'zz',
      zip => '12345',
      phone => '3145551231',
      tos => 'ok',
    },
    {
      email => 'test2@test2.test2',
      password => 'test2',
      pass_again => 'test2',
      slid => '1232',
      taxid => '1232',
      w9 => {filename => 'w9.pdf'},
      firstname => 'test2',
      lastname => 'test2',
      address => '234 test2',
      city => 'test2',
      state => 'zz',
      zip => '12345',
      phone => '3145551232',
      tos => 'ok',
    },
    {
      email => 'test3@test3.test3',
      password => 'test3',
      pass_again => 'test3',
      slid => '1233',
      taxid => '1233',
      w9 => {filename => 'w9.pdf'},
      firstname => 'test3',
      lastname => 'test3',
      address => '345 test3',
      city => 'test3',
      state => 'zz',
      zip => '12333',
      phone => '3145551233',
      tos => 'ok',
    },
];

my $docs = [
    [
        {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-01',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
         {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-02',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
    ],
    [
        {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-03',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
         {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-01',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
    ],
    [
        {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-01',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
         {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-01',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
    ],
    [
        {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-01',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
         {
          doc => {filename => 'appraisal.pdf', 'Content-Type' => 'application/pdf'},
          inspection_date => '1972-01-01',
          mls => '000',
          address => '000 test',
          city => 'test',
          county => 'test',
          state => 'zz',
          zip => '12345',
         },
    ],
];

my @t;
push @t, Test::Mojo->new('AppraisalDatabank') for 0..$#$users;

my $_users = 0; #$#$users;
foreach my $u ( 0..$_users ) {
    diag "Registering user $users->[$u]->{email} ($u)";
    $t[$u]->get_ok('/')->status_is(200)->content_like(qr/Welcome to Appraiser's DataBank/);
    $t[$u]->get_ok('/user/login')->status_is(200)->content_like(qr/Register/);
    $t[$u]->get_ok('/user/register')->status_is(200)->content_like(qr/Register/);
    $t[$u]->post_ok('/user/register' => form => $users->[$u])->status_is(302)->header_is(Location => '/user/login')
        ->get_ok('/user/login')->status_is(200)->content_like(qr/Thanks for registering/);
    $t[$u]->post_ok('/user/register' => form => $users->[$u])->status_is(200)->content_like(qr/field-with-error/);
}
foreach my $u ( 0..$_users ) {
    diag "Login user $users->[$u]->{email} ($u)";
    $t[$u]->get_ok('/user/login' => form => {email => $users->[$u]->{email}, password => $users->[$u]->{password}})->status_is(302)->header_is(Location => '/documents')
        ->get_ok('/documents')->content_like(qr/Welcome, $users->[$u]->{firstname}/);
};
foreach my $u ( 0..$_users ) {
    diag "Uploading documents from user $users->[$u]->{email} ($u)";
    $t[$u]->get_ok('/user/login')->status_is(404);
    $t[$u]->get_ok('/user/register')->status_is(404);
    $t[$u]->get_ok('/documents/upload');
    $t[$u]->post_ok('/documents/upload' => form => $docs->[$u]->[$_]) for 0..$#{$docs->[$u]};
}

diag "Testing functions";
$t[0]->get_ok('/documents' => form => {zip => '1234'})->content_like(qr/field-with-error/);
$t[0]->get_ok('/documents' => form => {zip => '12345'})->content_like(qr/Too many/);
$t[0]->get_ok('/documents' => form => {zip => '12345', mls => '1'})->content_like(qr/<!-- 3 documents -->/);
$t[0]->get_ok('/documents' => form => {zip => '12345', address => '1'})->content_like(qr/No results/);
$t[0]->get_ok('/documents' => form => {zip => '12345', mls => '1', address => '1'})->content_like(qr/<!-- 3 documents -->/);
$t[0]->get_ok('/documents' => form => {zip => '12345', mls => '000'})->content_like(qr/<!-- 4 documents -->/);
$t[0]->get_ok('/documents' => form => {zip => '12345', address => '000 test'})->content_like(qr/<!-- 1 documents -->/);
$t[0]->get_ok('/documents' => form => {zip => '12345', mls => '000', address => '000 test'})->content_like(qr/<!-- 4 documents -->/);

# Search for your own by ZIP/MLS, ZIP/Address, ZIP/MLS/Address -> Download your own, Add to Cart all others
# Search for others by ZIP/MLS, ZIP/Address, ZIP/MLS/Address -> Add to Cart
# View cart and see the number added
# Remove 1 from cart
# Checkout with PayPal, Cancel
# Checkout with PayPal, Continue
# Download all
# Re-search others' docs and can download but not add to cart

foreach my $u ( 0..$_users ) {
    diag "Logout user $users->[$u]->{email} ($u)";
    $t[$u]->get_ok('/user/logout')->status_is(302)->header_is(Location => '/')
        ->get_ok('/documents')->status_is(404);
}

done_testing();

# Delete test data
$ENV{NO_DELETE} and exit;
diag "Clearing all test data";
my $t = Test::Mojo->new('AppraisalDatabank');
diag sprintf "\ndelete from documents where inspection_date < '1980-01-01' and uploaded > date_add(now(), interval -1 hour) limit %s", 1+$#{[map { @$_ } @$docs]};
$t->app->mysql->db->query('delete from documents where inspection_date < "1980-01-01" and uploaded > date_add(now(), interval -1 hour) limit ?', 1+$#{[map { @$_ } @$docs]});
$t->app->mysql->db->query('alter table documents auto_increment='.$t->app->mysql->db->query('select id+1 as ai from documents order by id desc limit 1')->hash->{'ai'});
diag sprintf "delete from users where email like 'test_\@test_.test_' and created_at > date_add(now(), interval -1 hour) limit %s", 1+$#$users;
$t->app->mysql->db->query('delete from users where email like "test_@test_.test_" and created_at > date_add(now(), interval -1 hour) limit ?', 1+$#$users);
$t->app->mysql->db->query('alter table users auto_increment='.$t->app->mysql->db->query('select id+1 as ai from users order by id desc limit 1')->hash->{'ai'});
my $home = $t->app->home;
diag "rm -rf $home/w9/zz";
-d "$home/w9/zz" and qx(rm -rf $home/w9/zz);
diag "rm -rf $home/documents/123??";
glob("$home/documents/123??") and qx(rm -rf $home/documents/123??);