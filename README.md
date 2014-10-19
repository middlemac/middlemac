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



Introduction

    Getting Started
            Install XCode
            Install bundler
            Install the middlemac project template
            Update gems
            If gem install fails on Mac OS X because of json problems
            Start the _Middleman_ server
            Open the site in your browser

    Basics and First Steps
        1 Middlemac workflow
        2 Technology and Skills Overview
        3 Configure your help project (config.rb overview)
        4 File types basics
            ERB
            HAML
            MD
        5 Middleman basics
        6 Middlemac command-line tool overview
        7 Targets overview
        8 Features overview
        9 Groups overview
        10 Built-in Features
            1 Templates and content
            2 CSS (and images_css)
            3 Breadcrumbs
            4 Navigator
            5 markdown-links and markdown-images 
            6 Helpers overview
            7 Partials overview
        
    Reference and Conventions
        1 Directory, filename, and image organization conventions
        2 Paths conventions (relative, root, etc.)
        3 Layout and template conventions
        4 Middlemac command-line tool reference
        5 config.rb reference
        6 Frontmatter keys
        7 Excluding and Including targets and features
        8 Partials Reference
        9 Helpers reference
            1 Middleman
            2 Middlemac
        10 Apple .help setup
        11 Using local data
    
    Acknowledgement and Licenses
    
    
    
    
    
    
Customize
    Page titles






_Middlemac_ uses tools you may already know, or may not know: 

- _Middleman_ is a static HTML site generator, and is the heart of _Middlemac_’s
  abilities, as well as an inspiration for the name.
- Ruby is language that _Middlemac_, _Middlemac_, and much of the others tools
  are written with. _You do not have to learn Ruby to take advantage of
  *Middlemac*_.
- helpbook.rb is the extension to _Middleman_ that makes it effortlessly build
  Apple HelpBooks. It’s also the command-line tool that makes it easier to work
  with Middleman.
- HTML is the markup language that Apple requires for HelpBooks. But _Middlemac_
  promises to make things easy for you, and so…
- Markdown is the text-based, human-readable, easy to use format that will
  make writing your documentation a real pleasure. This file is written using
  Markup.


Middlemac workflow
------------------

The _Middlemac_ workflow is what makes it easy to build Apple HelpBooks compared
to traditional methods.

# Setup your help project

All of the setup required takes place in a single section of a single Ruby
script. Don’t worry! You don’t have to know Ruby. If you’re a software developer
already it will be painless for you to configure _Middlemac_ to your
applications’ exact specifications.

You will find that most of _Middlemac_’s ease-of-use comes from the conventions
you will follow.

# Develop your help content

Following _Middlemac_’s conventions will make sections, tables of contents, and
navigation effortless to implement. Simply put some types of files where
_Middlemac_ expects to find them, and the build system will take care of the
rest. All you have to do is write some HTML, or better yet, Markdown.

# Build your HelpBook

From your help project directory, a single Terminal command can build one, more
or all of your targets, with as much or little on-screen feedback as you want.
In a matter of seconds to minutes (based on your project size), _Middlemac_ will
build your targets anywhere you’ve setup. If you target your application’s
XCode project directory (and have already configured XCode to use your `.help`
bundle, then all that’s left is to…

# Build your application

And then run it. And start your help. It’s that easy.


Getting Started
---------------


Groups
------

- A GROUP is a bunch of files in a directory at a single level.
- A GROUP landing-page should begin with 000_
- Using the table_contents partial will include a TOC for all files at this
  group level except for 000_ files.
- Can include another group's toc by specifying a :group in locals, where the
  GROUP is really just the directory name.
- WANT to include a gather_toc, which looks in the top level of all of the
  directories at the current level to look for 000_ files. Build a list with
  blurbs. 
  

  
Applicable Frontmatter Keys
---------------------------

You can add your own, but Middlemac will use these:

- title
- blurb
- layout
- order
- xhtml

Frontmatter must use HTML; cannot use MD.


Helpful Helpers
---------------
cfBundleIdentifier
cfBundleName
product_name
product_uri
target_name
target_name?
target_feature?
page_name
page_group
current_group_pages
related_pages
pages_related_to
legitimate_children

Helpful Partials
----------------
legitimate_children
table_contents
markdown_images
markdown_links


CSS
---
normalize
github
image_widths
apple_helpbook
style


Link to your site
-----------------
middlemac.webloc (works on Linux?)
Why not document root?

Conventions
-----------
Directory Layout


Getting Started
---------------








About Layouts
=============

This directory contains layouts and templates for your Apple HelpBook
project. Adhering to the following conventions will make things very
easy for you.

Files
-----

None of these files become standalone HTML documents, and as such should have
a single `.erb` or `.haml` extension.

For organization, the convention is to name HTML containers with a `layout`
prefix and visual templates with a `template` prefix.

 - `layout-html4.haml` - This is just an HTML 4.01 wrapper template and if you
   follow all of the conventions there's nothing you should have to change
   here.

 - `layout-xhtml.haml` - Apple's help landing page (the main page) is
   supposed to be an XHTML 1.0 Strict document. If you follow all of the
   conventions there's nothing you should have to change here.

 - `template-logo-large.haml` - This visual template is suitable for “main”-like
   pages. If you follow conventions you should not have to change anything here.

 - `template-logo-medium.erb`  and `template-logo-small.erb` are other
    additional visual templates. If you follow the image conventions there is
    no reason you should have to modify these templates.


“Absolute” Paths
----------------

When using Middleman's helpers, absolute paths will be converted to relative
paths during the build. Absolute paths are relative to the `Contents (source)`
directory and _not_ the filesystem root.

In general it’s _not_ recommended to use absolute paths unless you need assets
outside of Middleman's configuration. Middleman will automatically build the
correct path using only the asset name when you use its helpers, if the assets
are in the correct directories (e.g., images in `images`).

However you will use absolute paths to refer to items in the `shared` directory
since this it outside of Middleman's normal search scope. The view templates
use this approach, for example.
