package JSON::ReadPath;
$JSON::ReadPath::VERSION = '1';
use strict;
use warnings;
use JSON::XS qw( decode_json );
use Mouse;
use Template;

=head1 NAME

JSON::ReadPath - In Jenkins grep payload json data and assign to an environment
variable.

=head1 USAGE

Let's say Bitbucket pushed a payload '{"commits":{ "branch": "FooBar" }}'

And we want to grab the branch name from the payload.

 BRANCH=$(read_json.pl --env payload --path commits.branch)

=cut

has file => (
    is  => "ro",
    isa => "Str",
);

has string => (
    is  => "ro",
    isa => "Str",
);

has config => (
    is         => "ro",
    isa        => "HashRef",
    lazy_build => 1,
);

sub _build_config {
    my $self = shift;
    my $json_str = $self->from_file || $self->string
      or die "No data";
    return decode_json($json_str);
}

sub from_file {
    my $self = shift;
    my $file = $self->file
      or return;
    return if !-f $file;
    open my $FH, "<", $file
      or return;
    local $/;
    my $string = <$FH>;
    close $FH;
    return $string;
}

sub get {
    my $self   = shift;
    my $config = $self->config;
    my $path   = shift
      or return $config;
    my $tt    = Template->new;
    my $value = q{};
    $tt->process( \"[%$path%]", $config, \$value );
    return $value;
}

1;
