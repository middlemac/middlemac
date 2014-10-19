Middlemac, the Middleman Build System for Mac OS X Help Projects (README)
=========================================================================

version 1.0, 2014-October-20
----------------------------

_Middlemac_ is the specialized Apple HelpBook building system that uses the
tools of _Middleman_ to make building Apple HelpBooks for your Mac OS X
applications a snap. Whether you are targeting multiple versions of your
application or a single version, once properly (simply!) configured, _Middlemac_
will take all of the pain out of building Help files.

_Middlemac_ makes it simple to do this in Terminal…

`./middlemac target1 target2 target3`

…and end up with versions of your HelpBooks with all of the Apple-required files
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


**Please note that _Middlemac_ is not associated in any way with the the team at
_Middleman_.**  


Getting Started
---------------

_Middlemac_’s documentation is included in the starter project (and more than
likely at [http://www.balthisar.com/manuals](http://www.balthisar.com/manuals)).

To get started and read the full documentation, make sure that your system has
Ruby installed (it comes pre-installed on Mac OS X and some Linuxes), and follow
these steps below. 

Note that this is untested on Windows.

Note that depending on your system’s setup you might have to prefix some of the
commands below with `sudo`. For example if the instruction is given as
`gem install bundler` and a permissions error is reported, you may probably
have to use `sudo gem install bundler` instead.

If you’re behind a proxy and haven’t already setup an `http-proxy` environment
variable, then that previous clause is a good hint and Google is your friend.


### Install XCode

If you’re on a Mac, you’ll have to install XCode. It’s available in the App
Store. XCode provides dependencies that Ruby and several of its gems require.
It will also ensure that Apple’s help indexer is installed, which is required if
you want to produce proper help files.

Dependencies on Linux are left up to you. Most modern Linuxes will prompt you to
install packages that are missing. And, yes, _Middlemac_ works quite well on
Linux. The only thing that won’t work is generating the required help index
file. Linux is still perfectly suited for development of your help books,
though.


### Install bundler

From your terminal, type:

`gem install bundler`

Ruby will download and install bundler.


### Install the middlemac project template

Although _Middlemac_ is a _Middleman_ extension, it’s mostly a project template
and distributed as such. Installation is as easy as:

`git clone http://github.com/balthisar/middlemac.git my_new_project`

Then `cd` into the `my_new_project` folder, and:


### Update gems (including _Middleman_ if needed)

Gems are Ruby programs and extensions. From within your project direct, simply:

`bundle install`

This will cause several Ruby gems to begin downloading and install.


### If gem install fails on Mac OS X because of json problems

Try repeating the above using this command, instead:

`ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future bundle install`

The reasons are complex but if you really want to know, remember: Google is your
friend.


### Start the _Middleman_ server

From the terminal, use _Middlemac_ to start the _Middleman_ server using our
`free` target:

`./middlemac.rb --server free`


### Open the site in your browser

Simply open the `middlemac.webloc` file from Finder to view the project results
in your default browser.

Or you prefer to open the help site manually, you can go to
[http://localhost:4567/Resources/Base.lproj/](http://localhost:4567/Resources/Base.lproj/)


Read More and Learn to Use _Middlemac_
--------------------------------------

The rest of the documentation is the _Middlemac_ project itself. Read it in your
browser as described in the last step above. If you’re ready to start creating
your own help books, simply start deleting the content you don’t want.
