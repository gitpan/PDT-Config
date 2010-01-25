#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 45;
use Test::Exception;

my $CLASS = 'PDT::Config';

use_ok( $CLASS );

is_deeply(
    $CLASS->defaults,
    {},
    "default"
);

is_deeply(
    $CLASS->configs,
    [],
    "Configs is an empty array"
);

is_deeply(
    $CLASS->params,
    [],
    "Params is an empty array"
);

my $one = $CLASS->new( file => 't/res/conf.yaml', a => 1, b => 1, c => 0, d => 0 );
is_deeply(
    $one,
    {
        file => 't/res/conf.yaml',
        overrides => { a => 1, b => 1, c => 0, d => 0 }
    },
    "Object constucted properly"
);

is_deeply(
    $one->_read_config,
    {
        a => 1,
        b => 1,
        c => 1,
        d => 1,
        e => 1,
        f => 1,
        g => 'blah',
    },
    "Read Config"
);

ok( $one->{ config }, "Config stored" );
is( $one->config, $one->{ config }, "Config cached" );

dies_ok {
    local $one->{ file } = "FAKEFAKEFAKEFAKE";
    $one->_read_config;
} "Cannot load invalid config";
like( $@, qr/Invalid config file: FAKEFAKEFAKEFAKE/, "Good error message" );

is( $one->param( 'a' ), 1 );
is( $one->param( 'b' ), 1 );
is( $one->param( 'c' ), 0 );
is( $one->param( 'd' ), 0 );
is( $one->param( 'e' ), 1 );
is( $one->param( 'f' ), 1 );
is( $one->param( 'g' ), 'blah' );
is( $one->param( 'h' ), undef );

is( $one->param( 'g', "new" ), "new", "Change value" );
is( $one->param( 'g' ), "new", "Value Changed" );
is( $one->param( 'g', undef ), 'blah', "Override removed, config value restored" );
is( $one->param( 'g' ), 'blah' );

is_deeply(
    $one->overrides,
    { a => 1, b => 1, c => 0, d => 0, g => undef },
    "overrides"
);

is_deeply(
    $one->config,
    {
        a => 1,
        b => 1,
        c => 1,
        d => 1,
        e => 1,
        f => 1,
        g => 'blah',
    },
    "Config"
);
delete $one->{ config };
is_deeply(
    $one->config,
    {
        a => 1,
        b => 1,
        c => 1,
        d => 1,
        e => 1,
        f => 1,
        g => 'blah',
    },
    "Config re-read"
);

{
    package Test::Config;
    use strict;
    use warnings;

    use base 'PDT::Config';

    our %DEFAULTS = ( a => 'default', x => 'default', y => 'default' );
    our @CONFIGS = ( qw{ fake fake2 t/res/conf.yaml res/conf.yaml } );
    our @PARAMS = ( 'a' .. 'f', 'x', 'y' );

    sub defaults { \%DEFAULTS }
    sub configs { \@CONFIGS }
    sub params { \@PARAMS }

    sub f { 'Not Overriden' }

    __PACKAGE__->subclass;
    1;
}

can_ok( 'Test::Config', 'a' .. 'f' );

is( Test::Config->f, 'Not Overriden', "Do not replace subs" );

$one = Test::Config->new( a => 1, b => 1, c => 0, d => 0 );

isa_ok( $one, 'Test::Config' );
isa_ok( $one, 'PDT::Config' );

is( $one->param( 'a' ), 1 );
is( $one->param( 'b' ), 1 );
is( $one->param( 'c' ), 0 );
is( $one->param( 'd' ), 0 );
is( $one->param( 'e' ), 1 );
is( $one->param( 'f' ), 1 );
is( $one->param( 'g' ), 'blah' );
is( $one->param( 'h' ), undef );

is( $one->param( 'g', "new" ), "new", "Change value" );
is( $one->param( 'g' ), "new", "Value Changed" );
is( $one->param( 'g', undef ), 'blah', "Override removed, config value restored" );
is( $one->param( 'g' ), 'blah' );

is( $one->x, 'default' );
is( $one->y, 'default' );

@Test::Config::CONFIGS = ( qw/fake/ );

$one = Test::Config->new( );
lives_ok{ $one->param( 'z' )};
is_deeply( $one->config, {}, "No config file" );
