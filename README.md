# Dist::Zilla::Plugin::jQuery [![Build Status](https://secure.travis-ci.org/plicease/Dist-Zilla-Plugin-jQuery.png)](http://travis-ci.org/plicease/Dist-Zilla-Plugin-jQuery)

Include jQuery in your distribution

# SYNOPSIS

    [jQuery]
    version = 1.8.2
    minified = both

# DESCRIPTION

This plugin fetches jQuery from the Internet
using [Resource::Pack::jQuery](https://metacpan.org/pod/Resource::Pack::jQuery) and includes it into your distribution.

# ATTRIBUTES

## version

The jQuery version to download.  Defaults to 1.8.2 (the default may
change in the future).

## minified

Whether or not the JavaScript should be minified.  Defaults to both.
Possible values.

- yes
- no
- both

## dir

Which directory to put jQuery into.  Defaults to public/js under
the same location of your main module, so if your module is 
Foo::Bar (lib/Foo/Bar.pm), then the default dir will be 
lib/Foo/Bar/public/js.

## location

Where to put jQuery.  Choices are:

- build

    This puts jQuery in the directory where the dist is currently
    being built, where it will be incorporated into the dist.

- root

    This puts jQuery in the root directory (The same directory
    that contains `dist.ini`).  It will also be included in the
    built distribution.

## cache

Cache the results so that the Internet is required less frequently.
Defaults to 0.

# METHODS

## $plugin->gather\_files

This method places the fetched jQuery sources into your distribution.

# CAVEATS

If you bundle jQuery into your distribution, you should update the copyright
section to include a notice that bundled copy of jQuery is copyright
the jQuery Project and is licensed under either the MIT or GPLv2 license.
This module does not bundle jQuery, but its dependency [Resource::Pack::jQuery](https://metacpan.org/pod/Resource::Pack::jQuery)
does.

# SEE ALSO

[Resource::Pack::jQuery](https://metacpan.org/pod/Resource::Pack::jQuery)

# AUTHOR

Graham Ollis &lt;perl@wdlabs.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
