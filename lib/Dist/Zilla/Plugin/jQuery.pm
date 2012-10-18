package Dist::Zilla::Plugin::jQuery;

# TODO: option to include MIT license information
#       in COPYRIGHT AND LICENSE section

use strict;
use warnings;
use v5.10;
use Moose;
use Resource::Pack::jQuery;
use File::Temp qw( tempdir );
use Path::Class qw( dir );
use Moose::Util::TypeConstraints qw( enum );
with 'Dist::Zilla::Role::FileGatherer';

use namespace::autoclean;

# ABSTRACT: Include jQuery in your distribution
# VERSION

=head1 SYNOPSIS

 [jQuery]
 use_bundled = 1

=head1 DESCRIPTION

This plugin fetches jQuery from the Internet (or a bundled version)
using L<Resource::Pack::jQuery> and includes it into your distribution.

=head1 ATTRIBUTES

=head2 use_bundled

Use the version of jQuery bundled with L<Resource::Pack::jQuery>.

=cut

has use_bundled => (
  is      => 'ro',
  isa     => 'Bool',
  default => 1,
);

=head2 version

The jQuery version to download.  Only used if use_bundled is false.

=cut

has version => (
  is  => 'ro',
  isa => 'Str',
);

=head2 minified

Whether or not the JavaScript should be minified.  Defaults to true.
Only used if use_bundled is false.

=cut

has minified => (
  is      => 'ro',
  isa     => 'Bool',
  default => 1,
);

=head2 dir

Which directory to put jQuery into.

=cut

has dir => (
  is      => 'ro',
  isa     => 'Str',
  default => sub { dir('')->stringify },
);

=head2 location

Where to put jQuery.  Choices are:

=over 4

=item build

This puts jQuery in the directory where the dist is currently
being built, where it will be incorporated into the dist.

=item root

This puts jQuery in the root directory (The same directory
that contains F<dist.ini>).  It will also be included in the
built distribution.

=back

=cut

has location => (
  is      => 'ro',
  isa     => enum([qw(build root)]),
  default => 'build',
);

=head1 METHODS

=head2 $plugin-E<gt>gather_files

This method places the fetched jQuery sources into your distribution.

=cut

sub _install_temp
{
  my($self) = @_;
  my $dir = dir( tempdir( CLEANUP => 1) );
  
  my %args = ( install_to => $dir->stringify );
  if($self->use_bundled)
  {
    $args{use_bundled} = 1;
  }
  else
  {
    $args{version} = $self->version;
    $args{minified} = $self->minified;
  }

  Resource::Pack::jQuery->new(%args)->install;
  return $dir;
}

sub gather_files
{
  my($self, $arg) = @_;
  
  my $temp = $self->_install_temp;
  
  foreach my $child ($temp->children(no_hidden => 1))
  {
    $self->log("adding " . $child->basename . " to " . $self->dir );
    if($self->location eq 'build')
    {
      $self->add_file(
        Dist::Zilla::File::InMemory->new(
          content => scalar $child->slurp,
          name    => dir( $self->dir )->file( $child->basename )->stringify,
        ),
      );
    }
    else
    {
      my $file = $self->zilla->root->file( $self->dir, $child->basename );
      $file->parent->mkpath(0, 0755);
      $file->spew( scalar $child->slurp );
    }
  }
  return;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 SEE ALSO

L<Resource::Pack::jQuery>

=cut
