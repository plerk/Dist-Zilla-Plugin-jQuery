package Dist::Zilla::Plugin::jQuery;

use strict;
use warnings;
use v5.10;
use Moose;
use Resource::Pack::jQuery;
use File::Temp qw( tempdir );
use Path::Class qw( file dir );
use Moose::Util::TypeConstraints qw( enum );
use File::HomeDir;

with 'Dist::Zilla::Role::FileGatherer';

use namespace::autoclean;

# ABSTRACT: Include jQuery in your distribution
# VERSION

=head1 SYNOPSIS

 [jQuery]
 version = 1.8.2
 minified = both

=head1 DESCRIPTION

This plugin fetches jQuery from the Internet
using L<Resource::Pack::jQuery> and includes it into your distribution.

=head1 ATTRIBUTES

=head2 version

The jQuery version to download.  Defaults to 1.8.2 (the default may
change in the future).

=cut

has version => (
  is      => 'ro',
  isa     => 'Str',
  default => '1.8.2',
);

=head2 minified

Whether or not the JavaScript should be minified.  Defaults to both.
Possible values.

=over 4

=item * yes

=item * no

=item * both

=back

=cut

has minified => (
  is      => 'ro',
  isa     => enum([qw(yes no both)]),
  default => 'both',
);

=head2 dir

Which directory to put jQuery into.  Defaults to public/js under
the same location of your main module, so if your module is 
Foo::Bar (lib/Foo/Bar.pm), then the default dir will be 
lib/Foo/Bar/public/js.

=cut

has dir => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub {
    my $self = shift;
    my $main_module = file( $self->zilla->main_module->name );
    (my $base = $main_module->basename) =~ s/\.pm//;
    my $dir = $main_module->dir->subdir($base, 'public', 'js')->stringify;
    $self->log("using default dir $dir");
    $dir;
  },
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

=head2 cache

Cache the results so that the Internet is required less frequently.
Defaults to 0.

=cut

has cache => (
  is      => 'ro',
  isa     => 'Bool',
  default => 0,
);

has _cache_dir => (
  is      => 'ro',
  isa     => 'Path::Class::Dir',
  lazy    => 1,
  default => sub {
    my $self = shift;
    if(!$self->cache)
    {
      return dir( tempdir( CLEANUP => 1) );
    }
    else
    {
      my $dir = dir( File::HomeDir->my_dist_data("Dist-Zilla-Plugin-jQuery", { create => 1 }) );
      $dir = $dir->subdir( $self->version, $self->minified );
      unless(-d $dir)
      {
        $dir->mkpath(0, 0755);
      }
      return $dir;
    }
  },
);

=head1 METHODS

=head2 $plugin-E<gt>gather_files

This method places the fetched jQuery sources into your distribution.

=cut

sub _install_temp
{
  my($self) = @_;
  my $dir = $self->_cache_dir;
  
  # keep caches around for at least 30 days
  my $timestamp = $dir->file('.timestamp');
  if(-e $timestamp && time < $timestamp->slurp + 60*60*24*30)
  {
    return $dir;
  }
  
  unlink $_->stringify for $dir->children(no_hidden => 1);
  
  my %args = ( 
    install_to => $dir->stringify,
    version    => $self->version,
  );

  if($self->minified =~ /^(yes|both)$/i)
  { Resource::Pack::jQuery->new(%args, minified => 1)->install }
  if($self->minified =~ /^(no|both)$/i)
  { Resource::Pack::jQuery->new(%args, minified => 0)->install }
  $timestamp->spew(time);
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
          content => scalar $child->slurp(iomode => '<:encoding(UTF-8)'),
          name    => dir( $self->dir )->file( $child->basename )->stringify,
        ),
      );
    }
    else
    {
      my $file = $self->zilla->root->file( $self->dir, $child->basename );
      $file->parent->mkpath(0, 0755);
      $file->spew( iomode => '>:encoding(UTF-8)', scalar $child->slurp(iomode => '<:encoding(UTF-8)') );
    }
  }
  return;
}

__PACKAGE__->meta->make_immutable;

1;

=head1 CAVEATS

If you bundle jQuery into your distribution, you should update the copyright
section to include a notice that bundled copy of jQuery is copyright
the jQuery Project and is licensed under either the MIT or GPLv2 license.
This module does not bundle jQuery, but its dependency L<Resource::Pack::jQuery>
does.

=head1 SEE ALSO

L<Resource::Pack::jQuery>

=cut
