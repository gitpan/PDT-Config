#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'PDT::Config',
    license     => 'perl',
    dist_author => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires    => {
        'Exporter' => 0,
    },
    build_requires => {
        'Test::Exception' => 0,
        'Test::More' => 0,
        'Test::Simple' => 0,
    },
);

$build->create_build_script;
