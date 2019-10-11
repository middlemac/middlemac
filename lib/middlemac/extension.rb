require 'middleman-core'
require 'fastimage'
require 'pathname'
require 'json'
require 'nokogiri'
require 'words_counted'
require 'trie'

################################################################################
# **Middlemac** is a tool to build macOS application help book files from 
# simple source documents. It handles all of the esoteric details for you, 
# and provides easy-to-use helpers for working with multiple versions of 
# your application (e.g., pro and free) while minimizing source code.
# @author Jim Derry <balthisar@gmail.com>
################################################################################

class Middlemac < ::Middleman::Extension


  ############################################################
  # Define additional Middleman settings.
  ############################################################
  define_setting :assets_dir, 'Resources/SharedGlobalAssets', 'The assets base directory. All other assets are relative to this.'
  define_setting :convention_dir, 'convention', 'The directory for Middlemac conventions items.'
  define_setting :partials_dir, '_partials', 'A convenient shortcut to common partials.'

  # @!group Middleman Configuration

  # @!attribute [rw] config[:assets_dir]=
  # Specifies the high-level, shared assets root directory.
  # @return [String] The shared assets root directory.
  # @note This is a Middleman application level config option.

  # @!attribute [rw] config[:convention_dir]=
  # Specifies the special directory for assets the middlemac
  # requires by convention. This directory does not have a
  # localized variant.
  # @return [String] The special convention directory.
  # @note This is a Middleman application level config option.

  # @!attribute [rw] options[:partials_dir]=
  # Specifies the default location for partials. Prior to **Middleman** 4.0,
  # all partials were kept in a common directory. **Middlemac** restores this
  # previous behavior by allowing all partials to be grouped in a common
  # directory. When using the `partial` helper, this directory will be checked
  # first for the existence of a partial; if not found, then the default,
  # built-in behavior will take over.
  # @return [String] The directory to search for partials.


  ############################################################
  # Define the options that are to be set within `config.rb`
  # as extension options.
  ############################################################
  option :help_output_location, nil, 'Directory to place the built helpbook.'
  option :help_output_avoid_spaces, true, 'If true, spaces in the help book file name bundle will be replaced with underscores.'
  option :help_output_use_target, true, 'If false, the help book will not include (target) in its bundle name.'
  option :img_auto_extensions, %w(.svg .png .jpg .jpeg .gif .tiff .tif), 'If not empty, then `image_tag` will work without filename extensions.'
  option :retina_srcset, true, 'If true then the image_tag helper will be extended to include automatic @2x images.'
  option :show_debug, false, 'If true, the main layout will show some debug information and site contents.'
  option :show_previous_next, false, 'If true, show navigation controls at the bottom of each content page.'
  option :strip_file_prefixes, true, 'If true leading numbers used for sorting files will be removed for presentation purposes.'


  # @!group Extension Configuration

  # @!attribute [rw] options[:help_output_location]=
  # Specifies the directory where the finished `.help` bundle should go. It
  # must be relative to your `config.rb` file, or set it to `nil` to leave the
  # output in the default location (in the help project directory). The *actual*
  # output directory will be an Apple Help bundle at this location named in the
  # form `#{CFBundleName} (target).help`. By targeting the `Resources` directory
  # of your XCode project with this option, it’s possible to ensure that an
  # Xcode project is automatically up to date every time a help project is
  # built.
  # @return [String] The directory where the final help bundle will be built.
  
  # @!attribute [rw] options[:help_output_avoid_spaces]=
  # Indicates whethr or not the `help_output_location` includes spaces in its
  # filename or not. Some GNU tools, such as make, choke on spaces. The default
  # setting for this option is *yes* in order to maintain backward
  # compatibility.
  # @return [Boolean] `true` or `false` to enable or disable this behavior.
  
  # @!attribute [rw] options[:help_output_use_target]=
  # Indicates whether or not the `help_output_location` includes the `(target)`
  # prefix in the help book bundle name. The default, `true`, will result in
  # `#{CFBundleName} (target).help`, which is the historical behavior. Setting
  # this to `false` will result in a help book named `#{CFBundleName}.help`,
  # instead. This can be useful if you are building help books from scripts via
  # XCode, and you set `help_output_location` to `ENV['BUILT_PRODUCTS_DIR']`.
  # @return [Boolean] `true` or `false` to enable or disable this behavior.

  # @!attribute [rw] options[:img_auto_extensions]=
  # This option determines whether or not to support specifying images without
  # using a file name extension, as well as the priority of the possible file
  # extensions. If not empty or nil, then the `image_tag` helper will work for
  # images even if you don’t specify an extension, but only if a file exists in
  # the sitemap that has one of the extensions in the array.
  # @return [Array<String>] Set to an array of image extensions.

  # @!attribute [rw] options[:show_debug]=
  # This option determines whether or not extra debug information is provided
  # at the bottom of each content page.
  # @return [Boolean] `true` or `false` to enable or disable this feature.

  # @!attribute [rw] options[:show_previous_next]=
  # This option determines whether or not the Apple Help System should display
  # previous and next page navigators at the bottom of each content page. Note
  # that Apple itself does not use this feature.
  # @return [Boolean] `true` or `false` to enable or disable this feature.

  # @!attribute [rw] options[:retina_srcset]=
  # This option determines whether or not the enhanced `image_tag` helper will
  # be used to include an @2x `srcset` attribute automatically. This automatic
  # behavior will only be applied if the image asset exists on disk and this
  # option is set to `true`.
  # @return [Boolean] `true` or `false` to enable or disable this feature.

  # @!attribute [rw] options[:strip_file_prefixes]=
  # If `true` leading numbers used for sorting files will be removed for
  # presentation purposes. This makes it possible to neatly organize your
  # source files in their presentation order on your filesystem but output
  # nice filenames without ugly prefix numbers.
  # @return [Boolean] `true` or `false` to enable or disable this feature.

  # @!endgroup


  ############################################################
  # initialize
  # @visibility private
  ############################################################
  def initialize(app, options_hash={}, &block)

    super

    @md_links_b = {}
    @md_images_b = {}
    @md_sizes_b = nil
    @hb_search_tree_b = nil

  end # initialize


  ############################################################
  # after_configuration
  #  Callback occurs before `before_build`.
  # @visibility private
  #############################################################
  def after_configuration

    # Set the correct :build_dir based on the options.
    dir = options[:help_output_location] || File.expand_path('./')
    cf_bundle_name = app.config[:targets][app.config[:target]][:CFBundleName]
    target = app.config[:target]
    
    if options[:help_output_use_target]
      output_name = "#{cf_bundle_name} (#{target}).help"
    else
      output_name = "#{cf_bundle_name}.help"
    end
    output_name.gsub!(' ', '_') if options[:help_output_avoid_spaces]
    
    app.config[:build_dir] = File.join(dir, output_name, 'Contents')

    return if app.config[:exit_before_ready]

    # Set the other directories accordingly.
    app.config[:layouts_dir]    = File.join(app.config[:assets_dir], app.config[:layouts_dir])
    app.config[:partials_dir]   = File.join(app.config[:assets_dir], app.config[:partials_dir])
    app.config[:convention_dir] = File.join(app.config[:assets_dir], app.config[:convention_dir])
    app.config[:css_dir]        = File.join(app.config[:assets_dir], app.config[:css_dir])
    app.config[:fonts_dir]      = File.join(app.config[:assets_dir], app.config[:fonts_dir])
    app.config[:images_dir]     = File.join(app.config[:assets_dir], app.config[:images_dir])
    app.config[:js_dir]         = File.join(app.config[:assets_dir], app.config[:js_dir])

    # Reset the helpers' buffers when the configuration
    # changes. For speed we don't want to recalculate everything
    # every time a helper is used, but only the first time.
    @md_links_b = {}
    @md_images_b = {}
    @md_sizes_b = nil
    @hb_search_tree_b = nil

    # Build a list of all of the available localizations, so that
    #  - We can run the help indexer multiple times, and
    #  - We can build the data for locale-list.json.
    project_root = File.join(app.config[:source], 'Resources')
    @localizations = Pathname.new(project_root).children.select { |c| c.directory? && c.basename.to_s.end_with?('.lproj') }
                         .map { |p| p.basename.to_s }

    @localizations.each { |k| say "Middlemac will handle localized content for #{k}.", :blue }

  end


  ############################################################
  # after_build
  #  Callback occurs one time after the build.
  # @visibility private
  ############################################################
  def after_build(builder)

    @localizations.each do |locale|
      run_help_indexer(locale)
    end

  end # after_build

end # class Middlemac
