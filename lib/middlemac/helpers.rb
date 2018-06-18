################################################################################
# Helpers
#  Methods defined in this helpers block are available in templates.
################################################################################

class Middlemac < ::Middleman::Extension

  helpers do

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
    # Returns the `ProductCopyright` for the current target
    # as configured in your `config.rb`.
    # @return [String] The `ProductCopyright`.
    #--------------------------------------------------------
    def product_copyright
      config[:targets][config[:target]][:ProductCopyright]
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
    # Returns the `ProductURI` for the current target
    # as configured in your `config.rb`.
    # @return [String] The `ProductURI`.
    #--------------------------------------------------------
    def product_uri
      config[:targets][config[:target]][:ProductURI]
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
    # Returns the copyright page, if one is present. The
    # first page in the hb_sitemap which includes "copyright"
    # within its categories.
    # @return [Sitemap::Resource] The root resource.
    #--------------------------------------------------------
    def hb_copyright_page
      hb_sitemap.find{ |r| r&.data&.categories&.include?('copyright') }
    end


    #--------------------------------------------------------
    # Returns the very top of of the current target, i.e.,
    # generally your index.html landing page in the lproj
    # directory.
    # @return [Sitemap::Resource] The root resource.
    #--------------------------------------------------------
    def hb_landing_page
      hb_sitemap.first.breadcrumbs.first
    end


    #--------------------------------------------------------
    # Returns a filtered version of the sitemap for the
    # current target containing only resources that the
    # modern Apple Help can navigate to directly, in the
    # current language.
    # as configured in your `config.rb`.
    # @return [Array<Sitemap::Resource>] The applicable
    #   sitemap.
    #--------------------------------------------------------
    def hb_sitemap
      extensions[:Middlemac].hb_sitemap_impl(current_page)
    end


    #--------------------------------------------------------
    # Returns a list of the locales detected during config.
    # This can be used to build locale-list.json from the
    # data object.
    # @return [Array<String>] The list of locales.
    #--------------------------------------------------------
    def hb_locale_list
      extensions[:Middlemac].hb_locale_list_impl
    end


    #--------------------------------------------------------
    # Returns the search tree for the current locale.
    # @return [String] The search tree in JSON format.
    #--------------------------------------------------------
    def hb_search_tree
      extensions[:Middlemac].hb_search_tree_impl(current_page)
    end


    #--------------------------------------------------------
    # Returns the extension name and version; suitable for
    # the `framework` field of modern Apple Help `framework`
    # field.
    # @return [String] The extension name and version.
    #--------------------------------------------------------
    def hb_framework
      "middlemac-#{Gem.loaded_specs["middlemac"].version.version}"
    end


    #--------------------------------------------------------
    # Returns the name of the configured partials directory
    # to use by default with the `partials` helper, i.e., the
    # value of `options[:partials_dir]`.
    # @return [String] The path of the configured default
    #   partials directory.
    #--------------------------------------------------------
    def partials_dir
      app.config[:partials_dir]
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
    # @param [Block] block An option block as per the
    #   default implementation by **Middleman**.
    # @group Extended Helpers
    #--------------------------------------------------------
    def partial(template, opts={}, &block)
      file_name = extensions[:Middlemac].partial_impl(current_resource, template)
      super(file_name, opts, &block)
    end


    #--------------------------------------------------------
    # This helper provides CSS for every image in your
    # project. Each image will have a declaration that sets
    # `max-width` and `max-height` to the actual size of the
    # image. Proper @2x image support is included. It’s most
    # useful to use this helper in a `some_file.css.erb`
    # file.
    # @return [String] Returns a string with the CSS markup
    #   for every image found in your project.
    #--------------------------------------------------------
    def css_image_sizes
      extensions[:Middlemac].md_sizes_impl
    end


    #--------------------------------------------------------
    # This helper provides access to an index of images in
    # Markdown reference format, enabling you to use
    # reference-style images in documents. Because this
    # helper includes literal Markdown, it’s only useful
    # in Markdown documents.
    # @return [String] Returns a string with the Markdown
    #   index of every image in your project.
    #--------------------------------------------------------
    def md_images
      extensions[:Middlemac].md_images_impl(current_page)
    end


    #--------------------------------------------------------
    # This helper provides access to an index of links in
    # Markdown reference format, enabling you to use
    # reference-style links in documents. Because this
    # helper includes literal Markdown, it’s only useful
    # in Markdown documents. These links are ready to use
    # in modern Helpbooks.
    # @return [String] Returns a string with the Markdown
    #   index of every page in your project.
    #--------------------------------------------------------
    def md_links
      extensions[:Middlemac].md_links_impl(current_page)
    end


    #--------------------------------------------------------
    # Returns a link in a form useful to helpbooks, i.e.,
    # `#/hb_NavId`, so that Apple's Javascript can load the
    # correct file. Simply specify the path to the HTML
    # file, and the helper will return an acceptable link.
    # @param [String] caption The text of the link.
    # @param [String] url The path to the html file in the
    #   output hierarchy.
    # @param [Hash] options Optional parameters to pass to
    #   the helper. Consult Middleman’s documentation for
    #   most of these.
    # @option options [Boolean] :aside Returns the link in
    #   a format suitable for linking to a helpbook “aside”
    #   rather than the link to another page.
    # @return [String] Returns an HTML `<a>` tag.
    # @group Extended Helpers
    #--------------------------------------------------------
    def link_to(caption, url, options = {} )

      unless url.is_a?(String)
        return super caption, url, options
      end

      resource = extensions[:Middlemac]
                     .possible_assets_for_path(url, 'text/', current_page)
                     .find  {|r| r.destination_path.end_with?(url[1..-1])}

      if resource
        if options[:aside]
          options[:aside] = resource.hb_NavId
          options[:class] = 'xRef Aside'
          super caption, "#{resource.hb_NavId}.html##{resource.hb_NavId}", options
        else
          super caption, "#/#{resource.hb_NavId}", options
        end
      else
        super caption, url, options
      end

    end

    #--------------------------------------------------------
    # Returns a link in the help:anchor:bookID format that
    # Apple recommends in their documentation. Although
    # they work, they’re not recommended:
    # - Apple doesn’t use these in their own Help Books. 
    # - When served to a browser, Apple’s JavaScript removes
    #   the link (i.e., they don’t work) because it does not
    #   access the Help Index where the anchors are recorded.
    # @param [String] caption The text of the link.
    # @param [String] anchor The anchor to link to.
    # @return [String] Returns an HTML `<a>` tag.
    #--------------------------------------------------------
    def link_to_anchor( caption, anchor )
      "<a href='help:anchor=#{anchor} bookID=#{config[:targets][config[:target]][:CFBundleID]}'>#{caption}</a>"
    end
    

    #--------------------------------------------------------
    # With the proper options enabled this helper extends
    # the built-in functionality of **Middleman**’s helper
    # in a couple of ways, as documented in the params
    # hash.
    #
    # Note that Apple helpbooks embed nearly all `<img>`
    # tags in a `<figure>`, so this is the default without
    # the appropriate params, below.
    # @param [String] path Specify path to the image file.
    # @param [Hash] params Optional parameters to pass to
    #   the helper. **Middleman** (and other extensions)
    #   provide other parameters in addition to these.
    # @option params [Boolean] :img_auto_extensions Allows
    #   control of the automatic image extensions option
    #   on a per-use basis.
    # @option params [Boolean] :retina_srcset Allows control
    #   of the automatic @2x images feature on a per-use
    #   basis.
    # @option params [Boolean] :figure Allows you to avoid
    #   the automatic framing of the image within a figure
    #   element, when set to `false`.
    # @option params [String] :figure_class Specify the
    #   class, if any, to apply to the enclosing figure.
    # @return [String] Returns an HTML `<img>` tag.
    # @group Extended Helpers
    #--------------------------------------------------------
    def image_tag(path, params={})

      params.symbolize_keys!

      img_auto_extensions = extensions[:Middlemac].options[:img_auto_extensions]
      img_auto_extensions = params.delete(:img_auto_extensions) if params.key?(:img_auto_extensions)
      img_auto_extensions = nil if img_auto_extensions.empty?

      magic_images = app.config[:target_magic_images]
      magic_prefix = "#{app.config[:target_magic_word]}-"
      wanted_prefix = "#{app.config[:target]}-"

      retina_srcset = extensions[:Middlemac].options[:retina_srcset]
      retina_srcset = params.delete(:retina_srcset) if params.key?(:retina_srcset)

      figure = true
      figure = params.delete(:figure) if params.key?(:figure)
      figure_class = params[:figure_class] ? params.delete(:figure_class) : nil


      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Setup our various lookup combinations, i.e., with or without
      # extensions, and the possibility of target-specific images.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      resource = nil
      resource_alt = nil

      srcPath = path;
      srcPath_alt = path.sub(magic_prefix, wanted_prefix)

      domain = extensions[:Middlemac].possible_assets_for_path(srcPath, 'image/', current_page)
      domain_alt = extensions[:Middlemac].possible_assets_for_path(srcPath_alt, 'image/', current_page)

      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Support images without extensions.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if img_auto_extensions && File.extname(srcPath) == ''

        img_auto_extensions.reverse.each do |ext|
          resource ||= domain.find {|r| r.destination_path.end_with?(srcPath[1..-1] + ext)}
        end # each

      else

        resource = domain.find {|r| r.destination_path.end_with?(srcPath[1..-1])}

      end

      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Support possibility of target-specific images.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if magic_images && File.basename(srcPath).start_with?(magic_prefix)

        if img_auto_extensions && File.extname(srcPath_alt) == ''

          img_auto_extensions.reverse.each do |ext|
            resource_alt ||= domain_alt.find {|r| r.destination_path.end_with?(srcPath_alt[1..-1] + ext)}
          end # each

        else

          resource_alt = domain_alt.find {|r| r.destination_path.end_with?(srcPath_alt[1..-1])}

        end

      end


      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # We've got a resource and a resource_alt, maybe.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if resource_alt
        path = resource_alt.destination_path
      elsif resource
        path = resource.destination_path
      else
        bn = File.basename(path, '.*')
        path = path.sub(bn, "#{bn}-NOT_IN_SITEMAP" )
      end


      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Support automatic @2x, @3x, @4x image srcset.
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if retina_srcset

        sets = []
        %w(@2x @3x @4x).each do |res|

          test_path = path.sub(/#{File.extname(path)}/i, "#{res}#{File.extname(path)}")

          if sitemap.resources.find {|r| r.destination_path == test_path}
            sets << "#{test_path} #{res[1..-1]}"
          end

        end

        if !sets.empty?
          sets.unshift("#{path} 1x")
          params[:srcset] ||= sets.join(', ')
        end

      end


      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      # Support :figure
      #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if figure
        if figure_class
          "<figure class='#{figure_class}'>\n  #{super path, params}\n</figure>"
        else
          "<figure>\n  #{super path, params}\n</figure>"
        end
      else
        super path, params
      end

    end #image_tag


    #--------------------------------------------------------
    # This helper makes it easy to create a help book task.
    # It supports markdown for the body of the task.
    #
    # @param [String] id Specify the id attribute for
    #   the containing `<div>`. Ensure that these are
    #   unique throughout your project so that open-closed
    #   states are preserved.
    # @param [String] headline Specify the task’s label.
    #   Note that markdown and HTML are stripped away by
    #   Apple's scripts, and won’t influece the output.
    # @param [Hash] options Optional parameters to pass to
    #   the helper.
    # @option options [Boolean] :markdown By default, the
    #   helper expects that the &block contains markdown;
    #   be sure to set the :markdown option to `false` if
    #   this is not desired.
    # @param [&block] block The content of the task.
    # @return [String] Returns the complete task.
    #--------------------------------------------------------
    def helpbook_task(id, headline, options = nil, &block)
      aria_id = "aria-#{id}"
      captured = block_given? ? capture_html(&block) : nil

      markdown = '1'
      klass = 'Task'
      if options
        markdown = '0' if !options[:markdown]
        klass = "Task #{options[:class]}" if options[:class]
      end

      content = <<-TASK
<div id='#{id}' class='#{klass}'>
<h2 class='Name' role='button' aria-controls='#{aria_id}'>
    #{headline}
</h2>
<div class='TaskBody' role='region' id='#{aria_id}' markdown='#{markdown}'>
#{captured if captured}
</div>      
</div>
      TASK

      concat_content(content)
    end # helpbook_task


  end #helpers

end # class Middlemac
