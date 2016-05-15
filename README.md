Middlemac, the Middleman Build System for Mac OS X Help Projects
================================================================
[![Gem Version](https://badge.fury.io/rb/middlemac.svg)](https://badge.fury.io/rb/middlemac)


_Middlemac_

This gem provides a complete solution to generating help documentation for
Mac OS X applications in the form of Help Books, using Middleman and a
selection of custom extensions to provide everything a developer needs.

Using this Apple Help Book building system leverages the tools of _Middleman_ to
make building end-user documentation for your Mac OS X applications a snap.
Whether you are targeting multiple versions of your application or a single
version, once properly configured, _Middlemac_ will take all of the pain out of
building help files.


Simple README
-------------
Jump to the [verbose README](#verbose-readme) and instructions below, otherwise…


Install the Gem
---------------

Install the gem in your preferred way, typically:

~~~ bash
gem install middlemac
~~~

From git source:

~~~ bash
rake install
~~~


Documentation
-------------

The complete documentation leverages the features of this gem in order to better
document them. Having installed the gem, read the full documentation in your
web browser:

~~~ bash
middlemac documentation
cd middlemac-docs/
bundle install
bundle exec middleman server
~~~
   
And then open your web browser to the address specified (typically
`localhost:4567`).


License
-------

MIT. See `LICENSE.md`.


Changelog
---------

See `CHANGELOG.md` for point changes, or simply have a look at the commit
history for non-version changes (such as readme updates).


Verbose README
==============

About
-----

_Middlemac_ makes it simple to do this in Terminal…

`bundle exec middleman build_all`

…and end up with versions of your helpbooks with all of the Apple-required files
in the Apple-required formats in the correct locations of your XCode build
directory. Simply build your help target, run your application, and find that
it just works!

At its simplest _Middlemac_ offers:

- Write your help files with plain text using the **Markdown** format (if you
  are reading this file in a text editor, this is an example of Markdown).
- Single or multiple build **targets**, e.g., your `pro` target can include
  content specific to the professional version of your application.
- **Features** support for each build target, e.g. each of your build targets
  can specify whether or not they support specific features, and this content
  will be included or excluded as your needs require.
- A low learning curve if you’re a developer.
- A set of conventions and tools that make automatic tables of contents,
  automatic sections, and automatic behavior effortless to implement.
- A basic, Apple-like CSS stylesheet and set of templates that can be used as-is
  or easily tweaked to suit your needs.


**Please note that _Middlemac_ is not associated in any way with the team at
_Middleman_.**  


Documentation
-------------

_Middlemac_’s documentation is included in the starter project (and more than
likely at [http://www.balthisar.com/manuals](http://www.balthisar.com/manuals)).
There are multiple ways you could be reading this content now, but for now we
will assume that you have not yet installed _Middlemac_ and its dependencies.

To get started and read the full documentation, make sure that your system has
[Ruby](https://www.ruby-lang.org/) installed (it comes pre-installed on Mac OS X
and some Linuxes), and follow these steps below. 

We now recommend the use of the Ruby Version Manager [(RVM)](https://rvm.io/).
While installation and setup of RVM is entirely outside the scope of this
tutorial, it avoids the use of `sudo` and the occasional hassles involved with
using the built in version of Ruby.

Note that depending on your system’s setup you might have to prefix some of the
commands below with `sudo`. For example if the instruction is given as
`gem install bundler` and a permissions error is reported, you may probably
have to use `sudo gem install bundler` instead.

If you’re behind a proxy and haven’t already setup an `http-proxy` environment
variable, then that previous clause is a good hint and Google is your friend.


Installation
------------

### Install XCode

If you’re on a Mac you’ll have to install XCode first, or at least the XCode
command line tools. You can _try_ just installing the tools first:

~~~ bash
xcode-select --install
~~~

If that fails or the rest of the installation fails, then install all of XCode.
It’s available in the App Store. It’s free of charge. And you’re using this
project to develop help for Mac OS X applications that you’re developing using
XCode anyway. Install it, already!

Dependencies on Linux are left up to you. Most modern Linuxes will prompt you to
install packages that are missing.
 
_Middlemac_ works quite well on Linux, but keep in mind that Linux doesn’t have
the help indexing tool that’s required in order to build a proper helpbook.
Other than for generating your final helpbook, Linux makes a fine development
environment.


### Install _Middlemac_

~~~ bash
gem install middlemac
~~~

### Install the documentation project

~~~ bash
middleman documentation
~~~

This will install _Middlemac_’s documentation project into a new directory
`middlemac-docs`.


### Go into the documentation directory

~~~ bash
cd middlemac-docs
~~~


### Install bundler (if not already installed)

~~~ bash
gem install bundler
~~~

Bundler is the most common Ruby package management system, and it will be used
to ensure that all of _Middlemac_’s dependencies are present.


### Make sure all of the project dependencies are met

~~~ bash
bundle install
~~~

This tells bundler to install the remaining gems that _Middlemac_ requires to
function.


### Start the _Middleman_ server

_Middleman_ comes with its own HTTP server and requires no configuration. It
simply works, serving your helpbook as a website.

~~~ bash
bundle exec middleman --target free
~~~

This will start the server using our `:free` target.


### Open the site in your browser

Simply open the `middlemac.webloc` file from Finder to view the project results
in your default browser.

Or can open the bookmark file from Terminal with `open middleman.webloc`.

Or you prefer to open the help site manually, or if the .webloc file doesn’t
work on your Linux distro, you can usually go to
[http://localhost:4567/Resources/Base.lproj/](http://localhost:4567/Resources/Base.lproj/).
If you have setup a custom hostname, then `localhost` may not work for you.

See also the [change log](CHANGELOG.md) and the [license](LICENSE.md).
