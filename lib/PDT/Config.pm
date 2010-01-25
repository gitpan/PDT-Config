package PDT::Config;
use strict;
use warnings;

#{{{ POD

=head1 NAME

PDT::Config - Base class for PDT configuration objects.

=head1 *EARLY STAGE WARNING*

This module is currently in the early stages. For the latest please check the
github page at L<http://github.com/exodist/PDT>

=head1 DESCRIPTION

The base class for all PDT configuration objects.

=head1 SYNOPSYS

    package App::PDT::MyClass::Config;
    use strict;
    use warnings;

    use base 'PDT::Config';

    sub defaults {{ key => 'value' }}
    sub configs {[ '/path/to/config.yaml', ... ]}
    sub params {[qw/ param1 param2 ... /]}

    __PACKAGE__->subclass;

    1;

=cut

#}}}

our $VERSION = "0.001";

use YAML::Syck qw/LoadFile/;

=item OVERRIDABLE CLASS METHODS

These are class methods you usually want to override.

=over 4

=item $class->defaults()

Returns a hash with key value pairs to act as default config options.

=item $class->configs()

Returns a list of default locations for config files.

=item $class->params()

Returns a list fo all params recognised by this config class.

=cut

sub defaults {{}}
sub configs {[]}
sub params {[]}

=back

=head1 SPECIAL CLASS METHODS

=over 4

=item __PACKAGE__->subclass()

Should always be called using your subclass. This method will create accessor
methods for all parameters spefied in your overriden params() method.

=cut

sub subclass {
    my $class = shift;
    for my $param ( @{ $class->params }) {
        # Put these here so that they don't fall under no strict 'refs'
        my $ref = $class . '::' . $param;
        my $sub = sub {
            my $self = shift;
            return $self->param( $param, @_ );
        };

        no strict 'refs';
        next if defined( &$ref ); #Do not override a pre-existing method.
        *$ref = $sub;
    }
}

=back

=head1 CONSTRUCTOR

=over 4

=item $class->new( %overrides, file => 'path/to/config.yaml' )

Create a new instance. Parameters should be key => 'value'. A config file can
be specified using the 'file' key.

=cut

sub new {
    my $class = shift;
    my %overrides = @_;
    my $file = delete $overrides{ file };
    return bless( { overrides => \%overrides, file => $file }, $class );
}

=back

=head1 OBJECT METHODS

=over 4

=item $obj->param( $name, $value )

Get/Override the value of the parameter.

$name is mandatory, $value is optional.

Sources values in this order, if a source is 'undef' it will move on to the next.

1. overrides   2. config file   3. defaults

=cut

sub param {
    my $self = shift;
    my $param = shift;

    # Override a config value.
    $self->overrides->{ $param } = shift( @_ ) if @_;

    return $self->overrides->{ $param } if defined( $self->overrides->{ $param });
    return $self->config->{ $param } if defined( $self->config->{ $param });
    return $self->defaults->{ $param } if defined( $self->defaults->{ $param });
    return;
}

=item $obj->overrides()

Returns the overrides hash.

=cut

sub overrides {
    return $_[0]->{ overrides };
}

=item $obj->config()

Returns the hash read from the config file.

=cut

sub config {
    my $self = shift;
    $self->_read_config unless $self->{ config };
    return $self->{ config };
}

sub _read_config {
    my $self = shift;
    my $file = $self->{ file };
    die( "Invalid config file: $file\n" ) if $file and ! -f $file;

    unless ( $file ) {
        for my $conf ( @{ $self->configs }) {
            $file = $conf if -f $conf;
            last if $file;
        }
    }

    return $self->{ config } = $file ? LoadFile( $file ) : {};
}


__PACKAGE__->subclass();

1;

__END__

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

PDT-Config is free software; Standard perl licence.

PDT-Config is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
