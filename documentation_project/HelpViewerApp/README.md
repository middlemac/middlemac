HelpViewApp README
==================

This simple app can display the sample `documentation_project` in Apple’s Help
Viewer application, and demonstrates how you might integrate **Middlemac** with
your Xcode project.

It consists of the following four targets:

`Help (free)` 

  : This is an external build system target that uses **Middlemac** to generate
    the help files for the `HelpViewerApp (free)` target.
  
`Help (pro)`

  : This is an external build system target that uses **Middlemac** to generate
    the help files for the `HelpViewerApp (pro)` target.

`HelpViewerApp (free)`

  : The “free” version of this application will display the `:free` target in
    the Help Viewer. It uses the target `Help (free)` as a build dependency.

`HelpViewerApp (pro)`

  : The “pro” version of this application will display the `:pro` target in the
    Help Viewer.  It uses the target `Help (pro)` as a build dependency.


## The Help file “build system”

The build system is a bash script that executes the default version of
**Middleman** on your system. In order to prevent re-building the help file
every time you run the HelpViewerApp it tries to remember that it was already
built using a marker file in the Xcode build directory.

It's a simple script and doesn’t try at all to know whether or not you’ve made
changes to the source. If you want to rebuild the help files using the build
command in Xcode, then perform **Clean**, which will remove this marker file.

Xcode’s **Clean** will _not_ remove the built help book using this script; you
are free to make the script do so if you want, however.
