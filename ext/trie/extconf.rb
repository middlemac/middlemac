require 'mkmf'

##
## Avoid warnings, since newer versions of Xcode by default try to make more and more
## warnings.
##
append_cflags("-Wno-missing-noreturn")
append_cflags("-Wno-shorten-64-to-32")
append_cflags("-Wno-return-type")
append_cflags("-Wno-sign-compare")
append_cflags("-Wno-unused-function")
append_cflags("-Wno-incompatible-pointer-types")
puts "=-=-=-=-=-=-"
puts $CFLAGS
puts "=-=-=-=-=-=-"


##
## If we want it to be installed in lib/trie, then we have to create the makefile
## in this nested format, too, otherwise lib_dir works for rake compile, but not
## for rake install.
##
create_makefile 'trie/trie'
