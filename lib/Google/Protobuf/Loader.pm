package Google::Protobuf::Loader;

use strict;
use warnings;
use utf8;

use Carp;
use File::Spec::Functions 'catfile';
use Google::ProtocolBuffers::Dynamic;

our $VERSION = '0.01';

# use Proto::Foo::Bar will search for lib/Foo/Bar.proto
# package "foo.bar_baz" in proto will give Proto::Foo::BarBaz in Perl
# import "Foo/Bar.proto" will search for lib/Foo/Bar.proto

sub import {
  push @INC, \&use_proto_file_hook;
  return;
}

# Search for the given proto file if the @INC dirs and load it if found.
sub use_proto_file_hook {
  # The first arg is ourselves, this is the calling convention for references
  # added to @INC.
  my (undef, $module_name) = @_;
  return unless $module_name =~ s{^Proto/(.+)\.pm$}{$1.proto};
  return search_and_include($module_name);
}

my %SEARCH_PROTO;
my %INC_PROTO;
sub search_and_include {
  my ($file_name) = @_;
  return \'1;' if $INC_PROTO{$file_name};
  croak "Infinite loop while loading ${file_name}" if exists $SEARCH_PROTO{$file_name};
  $SEARCH_PROTO{$file_name} = 1;
  for my $inc (@INC) {
    next if (!defined $inc || ref $inc);
    my $test_file_path = catfile($inc, $file_name);
    next unless -f $test_file_path;
    load_proto_file($test_file_path, $file_name);
    $INC_PROTO{$file_name} = 1;
    delete $SEARCH_PROTO{$file_name};
    return \'1;';
  }
  return;
}

# Load one proto file, following the convention of the @INC processing. See the
# reference in: https://perldoc.perl.org/functions/require
#
# Succeeds (and returns nothing) or dies.
my $dyn_pb = Google::ProtocolBuffers::Dynamic->new();
sub load_proto_file {
  my ($full_file_name, $rel_file_name) = @_;
  my $content = read_file($full_file_name);
  # Unfortunately, the Google::ProtocolBuffers::Dynamic module does not support
  # using the root package.
  die "No package definition in '${rel_file_name}'" unless $content =~ m/^\s*package ([a-zA-Z0-9._]+)\s*;/m;
  my $package = $1;
  while ($content =~ m{^\s*import\s*"([a-zA-Z0-9._/]+)"\s*;}mg) {
    search_and_include($1);
  }
  $dyn_pb->load_string($rel_file_name, $content);
  my $prefix = $package =~ s/(^|\.|_)(.)/($1 eq '.' ? '::' : '').uc($2)/egr;
  $dyn_pb->map({ package => $package, prefix => "Proto::${prefix}" });
  return;
}

sub read_file {
  my ($file) = @_;
  open my $fh, "<:encoding(UTF-8)", $file or die "Cannot open file '${file}' for reading: $!\n";
  my $data;
  {
    local $/ = undef;
    $data = <$fh>;
  }
  close $fh or die "Cannot close file '${file}' after read: $!\n";
  return $data;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Google::Protobuf::Loader

=head1 SYNOPSIS

=cut
