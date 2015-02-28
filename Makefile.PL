use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION   => '0.00',
  PREREQ_PM => {
    'Mojolicious' => '5.82',
    'Mojo::mysql' => '0.06',
    'Mojo::Redis2' => '0.17',
    'SQL::Abstract' => '0',
    'Email::Valid' => '0',
    'Number::Phone' => '0',
  },
  test      => {TESTS => 't/*.t'}
);