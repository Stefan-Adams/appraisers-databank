# appraisal-databank
sudo apt-get install cpanminus
cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
echo 'cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)' >> ~/.bashrc
cpanm Mojolicious Mojo::mysql Mojo::Redis2 Mojolicious::Plugin::AssetPack EV IO::Socket::Socks IO::Socket::SSL SQL::Abstract Email::Valid Number::Phone

mysql> create table users (username varchar(32) primary key, password varchar(64), disabled datetime, firstname varchar(255), lastname varchar(255), appraiser_id varchar(64), address varchar(255), city varchar(255), state varchar(2), zip varchar(10), phone varchar(15), created_at timestamp);
mysql> create table documents (id int primary key auto_increment, username varchar(32), spid varchar(16), address varchar(255), state varchar(2), county varchar(32), inspection_date date, uploaded timestamp, verified_at datetime, flagged_by varchar(32), flagged_at datetime);
mysql> create table purchases (id int primary key auto_increment, transaction_id varchar(16), document_id int, user_id int, purchased_at timestamp, refunded_at datetime);