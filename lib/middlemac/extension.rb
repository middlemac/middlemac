require 'middleman-core'


################################################################################
# **Middlemac** (an extension to **Middleman**) is a tool to build Mac OS X
# application help book files from simple source documents. It handles all of
# the esoteric details for you, and provides easy-to-use helpers for working
# with multiple versions of your application (e.g., pro and free versions)
# while minimizing source code.
# @author Jim Derry <balthisar@gmail.com>
################################################################################
class Middlemac < ::Middleman::Extension


  ############################################################
  # Define the options that are to be set within `config.rb`
  # as extension options.
  ############################################################
  option :Help_Output_Location, nil, 'Directory to place the built helpbook.'
  option :Breadcrumbs, 'breadcrumbs', 'The name of the breadcrumbs helper to use for breadcrumbs.'
  option :partials_dir, 'Resources/Base.lproj/assets/partials', 'A convenient shortcut to common partials.'


  # @!group Extension Configuration

  # @!attribute [rw] options[:Help_Output_Location]=
  # Specifies the directory where the finished `.help` bundle should go. It
  # must be relative to your `config.rb` file, or set it to `nil` to leave the
  # output in the default location (in the help project directory). The *actual*
  # output directory will be an Apple Help bundle at this location named in the
  # form `#{CFBundleName} (target).help`. By targeting the `Resources` directory
  # of your XCode project with this option, it’s possible to ensure that an
  # Xcode project is automatically up to date every time a help project is
  # built.
  # @param [String] value The directory where the final help bundle will be
  #   built.
  # @return [String] Returns the current value of this option.

  # @!attribute [rw] options[:Breadcrumbs]=
  # Indicates the name of the breadcrumbs helper to use for breadcrumbs.
  # Built-in breadcrumbs are "nav_breadcrumbs" and "nav_breadcrumbs_alt".
  # Change to `nil` to disable breadcrumbs completely. Breadcrumbs helpers are
  # part of the `middleman-pagegroups` extension (which is a component of this
  # extension).
  # @param [String] value The name of the breadcrumbs helper to use.
  # @return [String] Returns the current value of this option.

  # @!attribute [rw] options[:partials_dir]=
  # Specifies the default location for partials. Prior to **Middleman** 4.0,
  # all partials were kept in a common directory. **Middlemac** restores this
  # previous behavior by allowing all partials to be grouped in a common
  # directory. When using the `partial` helper, this directory will be checked
  # first for the existence of a partial; if not found then the default, built
  # in behavior will take over.
  # @param [String] value The directory to search for partials.
  # @return [String] Returns the current value of this option.

  # @!endgroup


  ############################################################
  # initialize
  # @visibility private
  ############################################################
  def initialize(app, options_hash={}, &block)

    super

  end # initialize


  ############################################################
  # after_configuration
  #  Callback occurs before `before_build`.
  # @visibility private
  #############################################################
  def after_configuration

    # Set the correct :build_dir based on the options.

    dir = options[:Help_Output_Location] || File.expand_path('./')
    cf_bundle_name = app.config[:targets][app.config[:target]][:CFBundleName]
    target = app.config[:target]

    app.config[:build_dir] = File.join(dir, "#{cf_bundle_name} (#{target}).help", 'Contents')

  end


  ############################################################
  # after_build
  #  Callback occurs one time after the build.
  # @visibility private
  ############################################################
  def after_build(builder)

    run_help_indexer

  end # after_build


  ############################################################
  #  Helpers
  #    Methods defined in this helpers block are available in
  #    templates.
  ############################################################

  helpers do

    #--------------------------------------------------------
    # This helper returns the name of the breadcrumbs
    # partial configured to be used in your project, i.e.,
    # the value of `options[:Breadcrumbs]`.
    # @return [String] The name of the configured breadcrumbs
    #   partial.
    #--------------------------------------------------------
    def breadcrumbs
      extensions[:Middlemac].options[:Breadcrumbs]
    end


    #--------------------------------------------------------
    # Returns the name of the configured partials directory
    # to use by default with the `partials` helper, i.e., the
    # value of `options[:partials_dir]`.
    # @return [String] The path of the configured default
    #   partials directory.
    #--------------------------------------------------------
    def partials_dir
      extensions[:Middlemac].options[:partials_dir]
    end


    #--------------------------------------------------------
    # Returns the product `CFBundleIdentifier` for the
    # current target as configured in your `config.rb`.
    # @return [String] The `cfBundleIdentifier`.
    #--------------------------------------------------------
    def cfBundleIdentifier
      config[:targets][config[:target]][:CFBundleID]
    end


    #--------------------------------------------------------
    # Returns the product `CFBundleName` for the current
    # target as configured in your `config.rb`.
    # @return [String] The `CFBundleName`.
    #--------------------------------------------------------
    def cfBundleName
      config[:targets][config[:target]][:CFBundleName]
    end


    #--------------------------------------------------------
    # Returns the `ProductName` for the current target
    # as configured in your `config.rb`.
    # @return [String] The `ProductName`.
    #--------------------------------------------------------
    def product_name
      config[:targets][config[:target]][:ProductName]
    end


    #--------------------------------------------------------
    # Returns the `ProductVersion` for the current target
    # as configured in your `config.rb`.
    # @return [String] The `ProductVersion`.
    #--------------------------------------------------------
    def product_version
      config[:targets][config[:target]][:ProductVersion]
    end


    #--------------------------------------------------------
    # Returns the `ProductURI` for the current target
    # as configured in your `config.rb`.
    # @return [String] The `ProductURI`.
    #--------------------------------------------------------
    def product_uri
      config[:targets][config[:target]][:ProductURI]
    end


    #--------------------------------------------------------
    # Extends the built-in `partials` helper to allow the
    # use of a default partials directory as configured with
    # `options[:partials_dir]`. Middleman 4.0 removed the
    # option `partials_dir` which increased flexibility a 
    # lot, but hurt backwards compatibility. When used the
    # default location will be searched first for the
    # specified partial; if not found then the built-in
    # behavior will be used.
    # @param [String] template The partial file to use.
    # @param [Hash] opts Options to use for the partial.
    #   Consult **Middleman**’s documentation for possible
    #   options.
    # @param [Block] &block An option block as per the
    #   default implementation by **Middleman**.
    # @group Extended Helpers
    #--------------------------------------------------------
    def partial(template, opts={}, &block)
      file_check = File.join(extensions[:Middlemac].options[:partials_dir], "_#{template}")
      if ::Middleman::TemplateRenderer.resolve_template( @app, file_check)
        super(file_check, opts, &block)
      else
        super(template, opts, &block)
        end
    end


  end #helpers


  ############################################################
  # Instance Methods
  # @!group Instance Methods
  ############################################################


  #########################################################
  # Runs Apple’s the help indexer if it is available on
  # the system.
  # @return [Void]
  #########################################################
  def run_help_indexer

    cf_bundle_name = app.config[:targets][app.config[:target]][:CFBundleName]
    target = app.config[:target]

    # see whether a help indexer is available.
    `command -v hiutil > /dev/null`
    if $?.success?

      index_dir = File.expand_path(File.join(app.config[:build_dir], 'Resources/', 'Base.lproj/'))
      index_dst = File.expand_path(File.join(index_dir, "#{cf_bundle_name}.helpindex"))

      say "'…#{index_dir.split(//).last(60).join}' (indexing)", :cyan
      say "'…#{index_dst.split(//).last(60).join}' (final file)", :cyan

      `hiutil -Cf "#{index_dst}" "#{index_dir}"`
    else
      say "NOTE: `hiutil` is not found, so no index will exist for target '#{target}'.", :red
    end

  end #run_help_indexer


  #########################################################
  # Output colored messages using ANSI codes.
  # @param [String] message The message to output to the
  #   console.
  # @param [Symbol] color The color in which to display
  #   the message.
  # @returns [Void]
  # @!visibility private
  #########################################################
  def say(message = '', color = :reset)
    colors = { :blue   => "\033[34m",
               :cyan   => "\033[36m",
               :green  => "\033[32m",
               :red    => "\033[31m",
               :yellow => "\033[33m",
               :reset  => "\033[0m",
    }

    if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
      puts message
    else
      puts colors[color] + message + colors[:reset]
    end
  end # say


end # class MiddlemacExtras
