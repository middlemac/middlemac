################################################################################
# Private Instance Methods
################################################################################

class Middlemac < ::Middleman::Extension

  ############################################################
  # @!group Instance Methods
  ############################################################

  #--------------------------------------------------------
  # Provides the navigable sitemap for the current target.
  # Exclude everything that isn't HTML and doesn't have
  # doesn't have a title (extra index and redirect files).
  #
  # @param [Sitemap::Resource] resource The page for which
  #   the sitemap is being requested.
  # @return [Array<Sitemap::Resource>]
  # @!visibility private
  #--------------------------------------------------------
  def hb_sitemap_impl(resource)
    app.sitemap.resources
      .select { |r| r.content_type && r.content_type.start_with?('text/html', 'application/xhtml')}
      .select { |r| r.data && r.data.title }
      .select { |r| r.hb_NavId }
      .select { |r| r.hb_locale == resource.hb_locale}
  end


  #--------------------------------------------------------
  # Make the global @localizations available to helpers.
  #
  # @return [Array<String>] The list of detected locales.
  # @!visibility private
  #--------------------------------------------------------
  def hb_locale_list_impl
    @localizations
  end


  #--------------------------------------------------------
  # This accessor for @md_images_b lazily populates the
  # backing variable and buffers it for repeated use. In
  # the event of file changes, a server restart is needed.
  #
  # @param [Sitemap::Resource] resource The page for which
  #   the data are being requested.
  # @return [String] Returns the Markdown reference list.
  # @!visibility private
  #--------------------------------------------------------
  def md_images_impl(resource)
    locale = resource.hb_locale.to_sym
    unless @md_images_b[locale]
      @md_images_b[locale] = get_link_data(resource, 'image/')
                                 .collect { |l| "[#{l[:reference]}]: #{l[:link]}" }
                                 .join("\n")
    end
    @md_images_b[locale]
  end


  #--------------------------------------------------------
  # This accessor for @md_links_b lazily populates the
  # backing variable and buffers it for repeated use.
  # In the event of file changes, a server restart is
  # needed.
  #
  # @param [Sitemap::Resource] resource The page for which
  #   the data are being requested.
  # @return [String] Returns the Markdown reference list.
  # @!visibility private
  #--------------------------------------------------------
  def md_links_impl(resource)
    locale = resource.hb_locale.to_sym
    unless @md_links_b[locale]
      @md_links_b[locale] = get_link_data(resource, 'text/html', 'application/xhtml')
                                .collect { |l|
                                  if l[:title]
                                    "[#{l[:reference]}]: #{l[:hb_link]} \"#{l[:title]}\""
                                  else
                                    "[#{l[:reference]}]: #{l[:hb_link]}"
                                  end
                                }
                                .join("\n")
    end

    @md_links_b[locale]
  end


  #--------------------------------------------------------
  # For every image resource in the project, attempt to
  # build the CSS rules. Only bitmap images are supported,
  # as vectors (e.g., SVG) don’t have a specific size.
  #
  # @return [String] Returns the CSS stylesheet with the
  #   maximum width and height for each image.
  # @!visibility private
  #--------------------------------------------------------
  def md_sizes_impl
    unless @md_sizes_b
      @md_sizes_b = []
      app.sitemap.resources
          .select { |r| r.content_type && r.content_type.start_with?('image/') }
          .select { |r| [:locale, :global, :convention].include?(r.asset_path_type) }
          .each do |r|

        file = r.file_descriptor.full_path
        base_name = File.basename(r.destination_path, '.*')
        factor = 1
        factor = 2 if base_name.end_with?('@2x')
        factor = 3 if base_name.end_with?('@3x')
        factor = 3 if base_name.end_with?('@4x')
        if FastImage.size(file)
          width = (FastImage.size(file)[0] / factor).to_i.to_s
          height = (FastImage.size(file)[1] / factor).to_i.to_s

          # CSS matches string literals from the `src` attribute, and not the actual
          # file path for an image, so collisions can occur if the `src` is not
          # specific enough. Luckily all of our paths are absolute from /Resources,
          # and converted to relative from the help book main index.html, so we
          # can be very specific with every image.
          url = Pathname.new(r.url).relative_path_from(Pathname.new('/Resources'))
          @md_sizes_b << "img[src$='#{url}'] { max-width: #{width}px; max-height: #{height}px; }"
        end
      end # each
    end
    @md_sizes_b.join("\n")
  end


  #--------------------------------------------------------
  # Provide a complete path to our version of the `partial`
  # helper that checks for the existence of the requested
  # partial in the following locations, in order:
  #
  # - The localized assets directory.
  # - The partials_dir specified in options.
  # - The inherited behavior.
  #
  # @param [Sitemap::Resource] resource The resource that
  #   is requesting the partial.
  # @param [String] template The name of the partial this
  #   is being requested.
  #
  # @!visibility private
  #--------------------------------------------------------
  def partial_impl(resource, template)
    partials_dir = app.config[:partials_dir]
    file_name = File.join(localized_asset_path(partials_dir, resource), "_#{template}")
    if ::Middleman::TemplateRenderer.resolve_template( @app, file_name)
      file_name = File.join(localized_asset_path(partials_dir, resource), template)
    else
      file_name = File.join(partials_dir, "_#{template}")
      if ::Middleman::TemplateRenderer.resolve_template( @app, file_name)
        file_name = File.join(partials_dir, template)
      else
        file_name = template
      end
    end
    file_name
  end


  #--------------------------------------------------------
  # Given an main asset path, such as :partials_dir,
  # return the localized version of that path for the
  # given resource. This does _not_ convert entire paths;
  # it merely takes, e.g.,
  # /Resources/SharedGlobalAssets/images and turns it into
  # /Resources/en.lproj/assets/images.
  #
  # @param [String] asset_path The base resource path to
  #   convert.
  # @param [Sitemap::Resource] resource A resource in the
  #   locale of interest.
  #
  # @!visibility private
  #--------------------------------------------------------
  def localized_asset_path(asset_path, resource)
    components = Pathname.new(asset_path).each_filename.to_a
    lproj = "#{resource.hb_locale}.lproj"
    File.join(components[0], lproj, 'assets', components[-1])
  end


  #--------------------------------------------------------
  # Get all of the required link data for generating
  # markdown shortcuts for the two property accessors.
  #
  # @param [va_list<String>] types One or more MIME types
  #   specifying the file types for which to build links.
  # @return [Array<Hash>] An array of hashes containing
  #   the file data.
  # @!visibility private
  #--------------------------------------------------------
  def get_link_data( resource, *types )
    all_links = []
    # We'll include a sort by number of path components in this chain so
    # that we can improve the chances of higher-level items not having
    # naming conflicts. For example, the topmost index.html file should
    # not require a prefix!
    app.sitemap.resources
        .select { |r| r.content_type && r.content_type.start_with?( *types ) }
        .select { |r| [:locale, :global, :convention].include?(r.asset_path_type) }
        .select { |r| r.hb_Section? != true}
        .select { |r| r.hb_locale == resource.hb_locale || r.hb_locale == nil }
        .sort { |a, b| Pathname(a.destination_path).each_filename.to_a.count <=> Pathname(b.destination_path).each_filename.to_a.count }
        .each do |r|
      reference_path = Pathname(r.destination_path).each_filename.to_a.reverse
      reference_path.shift
      reference = r.page_name
      link = r.url
      hb_link = defined?(r.hb_NavId) ? "#/#{r.hb_NavId}" : nil
      title = r.data.title ? r.data.title.gsub(%r{</?[^>]+?>}, '') : nil

      i = 0
      while all_links.find { |link| link[:reference] == reference }
        next_piece = reference_path[i].gsub(%r{ }, '_')
        reference = "#{next_piece}-#{reference}"
        i += 1
      end

      all_links << {:reference => reference, :link => link, :title => title, :hb_link => hb_link}
    end # .each

    all_links
  end


  #--------------------------------------------------------
  # Returns a list of assets from the sitemap that match
  #  the given path (including file basename), where
  # `path` might be any of:
  #
  # - An absolute path preceded by /, meaning that we
  #   will search only in the given directory.
  #
  # - A relative path including at least one directory,
  #   indicating that the asset might be in :locale,
  #   :global, or :convention.
  #
  # - A naked basename, where have to search anywhere in
  #   the sitemap, with priority given first to :locale,
  #   then :global, :convention, and anywhere else.
  #
  # @param [String] path Specifies the asset without an
  #   extension, which is to be checked.
  # @param [String] content_type Specifies the MIME
  #   type of the asset. Partial MIME type is supported,
  #   such as `image/`.
  # @param [Sitemap::Resource] resource Specifies the
  #   resource for which the possible assets might apply.
  # @return [Array<Sitemap::Resource>] An array of
  #   resources that might be the sought-after file.
  # @!visibility private
  #--------------------------------------------------------
  def possible_assets_for_path(path, content_type, resource)

    pn = Pathname.new(path)
    dir, base = pn.split
    dir = dir.to_s
    base = File.basename(base.to_s, '.*')

    assets = app.config[:assets_dir]
    locale ="Resources/#{resource.hb_locale}.lproj/"

    # Perform pre-filtering of the entire sitemap, by getting a list of all:
    # - Assets with the given content type
    # - Whose basename without extension matches the provided basename without extension
    # - This isn't an ignored asset.
    # - That exists in :assets_dir or language.lproj.
    domain = app.sitemap.resources.select do |r|
      r&.content_type&.start_with?(content_type) &&
          (base == File.basename(r.destination_path, '.*')) &&
          !r.ignored &&
          (r.destination_path.start_with?(assets) || r.destination_path.start_with?(locale))
    end

    # Perform additional filtering according to what we're looking for.

    if pn.absolute?
      # If absolute, then only select items that were in the orginal
      # path given with the asset.
      domain = domain.select {|r| r.destination_path.start_with?(dir[1..-1])}
    elsif dir == '.'
      # Not absolute, and naked, so it could be anywhere. Filter the list
      # by search priority, so that the first item is likely to be the one
      # that we're after: :locale, :global, :convention
      domain = domain.sort_by do |r|
        [r.asset_path_type == :locale ? 0 : 1,
         r.asset_path_type == :global ? 0 : 1,
         r.asset_path_type == :convention ? 0 : 1
        ]
      end
    else
      # Not absolute, but has a leading directory. We want to ensure that we
      # only return assets for the appropriate asset type in the appropriate
      # directories. The resource.asset_path_type will be :other_dir if it's
      # not already in the correct directory type.
      if content_type.start_with?('/image')
        domain = domain.select {|r| [:locale, :global, :convention].include?(r.asset_path_type) }
      end
    end

    return domain

  end


  #--------------------------------------------------------
  # If the `plutil` executable is available on macOS, then
  # read the given plist. We don’t want to distribute
  # all of the binary plists.
  #
  # @param [String] path The path to the plist file.
  # @return [Array::String] The parsed plist array, or an
  #   empty array if there was an error.
  # @!visibility private
  #--------------------------------------------------------
  def open_binary_stoplist( path )

    # See whether or not the plist utility is available.
    `command -v plutil > /dev/null`
    unless $?.success?
      say "NOTE: The plutil command is not available on your system, so #{path} will not be used.", :red
      return []
    end

    # Make sure the file exists.
    unless File.exist?(path)
      say "NOTE: The file #{path} was not found.", :red
      return []
    end

    # Get the binary file and convert it to text.
    info_plist = File.binread(path)
    IO.popen('plutil -convert xml1 -r -o - -- -', 'r+') do |f|
      f.write(info_plist)
      f.close_write
      info_plist = f.read
    end

    # Reprocess with Nokogiri, and get our string items into
    # and array of strings.
    Nokogiri::XML(info_plist).xpath('//string').collect { |n| n.text }
  end


  #--------------------------------------------------------
  # Analyzes the content of the given resource for words
  # and their frequencies. Omits words in the respective
  # stopwords .plist file. If the resource contains any
  # `exactmatch` entries, they will be added with high
  # weights.
  #
  # @param [Sitemap::Resource] resource The resource for
  #   which to get the word frequency list.
  # @return [Hash] The word frequency list.
  # @!visibility private
  #--------------------------------------------------------
  def word_frequencies_impl(resource)
    # Prevent possible recursion when we render this resource, below.
    return nil if resource == @resource
    @resource = resource

    return nil unless iso_code = resource.hb_locale

    lorem_words = %w(alias consequatur aut perferendis sit voluptatem accusantium doloremque aperiam eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo aspernatur aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt neque dolorem ipsum quia dolor sit amet consectetur adipisci velit sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem ut enim ad minima veniam quis nostrum exercitationem ullam corporis nemo enim ipsam voluptatem quia voluptas sit suscipit laboriosam nisi ut aliquid ex ea commodi consequatur quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae et iusto odio dignissimos ducimus qui blanditiis praesentium laudantium totam rem voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident sed ut perspiciatis unde omnis iste natus error similique sunt in culpa qui officia deserunt mollitia animi id est laborum et dolorum fuga et harum quidem rerum facilis est et expedita distinctio nam libero tempore cum soluta nobis est eligendi optio cumque nihil impedit quo porro quisquam est qui minus id quod maxime placeat facere possimus omnis voluptas assumenda est omnis dolor repellendus temporibus autem quibusdam et aut consequatur vel illum qui dolorem eum fugiat quo voluptas nulla pariatur at vero eos et accusamus officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae itaque earum rerum hic tenetur a sapiente delectus ut aut reiciendis voluptatibus maiores doloribus asperiores repellat)
    my_path = File.dirname(File.expand_path(__FILE__))
    stopwords = File.expand_path(File.join(my_path, '..', '..', 'resources', 'stopwords', "#{iso_code}.plist"))

    stopwords = open_binary_stoplist( stopwords )  + lorem_words

    rendered_resource = "<h1>#{resource.data.title}</h1>" + resource.render(layout: false)
    doc = Nokogiri::HTML.fragment(rendered_resource)
    doc.search('style,script').each(&:remove)
    counter = WordsCounted.count( doc.text, :exclude => [stopwords, ->(t){t.length < 4}] )

    tokens = counter.token_frequency.to_h

    # Give extra weight to tokens that are in the data.keywords.
    resource&.data&.keywords&.each do |k|
      tokens[k] = tokens[k] ? tokens[k] + 10 : 10
    end

    # Give a lot of extra weight to tokens thare in the data.exactmatch.
    resource&.data&.exactmatch&.each do |k|
      tokens[k] = tokens[k] ? tokens[k] + 100 : 100
    end

    tokens
  end


  #--------------------------------------------------------
  # Return the complete searchTree.json contents for the
  # language of the given resource.
  #
  # @param [Sitemap::Resource] resource Any resource in
  #   the desired language.lproj.
  # @return [String] The sitemap in JSON format.
  # @!visibility private
  #--------------------------------------------------------
  def hb_search_tree_impl( resource )

    if @hb_search_tree_b
      return @hb_search_tree_b
    end

    word_list = {}
    sitemap = hb_sitemap_impl(resource).select {|r| r.data.title && !r.hb_Section?}

    # First we need to gather all of the individual resource word frequencies
    # into a master list of "word" => { "hb_NavId" => weight, ... }.
    sitemap.each do |page|
      page.word_frequencies.each do |k,v|
        word_list[k] = {} unless word_list.key?(k)
        word_list[k][page.hb_NavId] = v
        #word_list[k][k] = 0
      end
    end

    # Change the structure to a trie so that navigating the nodes is
    # quite easy.
    word_trie = Trie.new
    word_list.sort.each { |k, v| word_trie.add k, v }

    @hb_search_tree_b = word_trie.to_h.to_json
  end
  

  #--------------------------------------------------------
  # Runs Apple’s help indexer if it is available on
  # the system.
  #
  # @param [Hash] locale The locale for which to run the
  #   help indexer.
  # @return [Void]
  # @!visibility private
  #--------------------------------------------------------
  def run_help_indexer(locale)

    cf_bundle_name = app.config[:targets][app.config[:target]][:CFBundleName]
    target = app.config[:target]

    # see whether a help indexer is available.
    `command -v hiutil > /dev/null`
    if $?.success?

      index_dir = File.expand_path(File.join(app.config[:build_dir], 'Resources', locale))
      index_dst = File.expand_path(File.join(index_dir, "#{cf_bundle_name}.helpindex"))
      iso_code = File.basename(locale, '.*')
      stopwords = File.expand_path(File.join( '..', 'resources', 'stopwords', "#{iso_code}.plist" ))

      say "'…#{index_dir.split(//).last(60).join}' (indexing)", :cyan
      say "'…#{index_dst.split(//).last(60).join}' (final file)", :cyan

      `hiutil -Cf "#{index_dst}" -ag -m 3 -s #{stopwords} -l #{iso_code} "#{index_dir}"`
    else
      say "NOTE: `hiutil` is not found, so no index will exist for target '#{target}'.", :red
    end

  end #run_help_indexer


  #--------------------------------------------------------
  # Output colored messages using ANSI codes.
  #
  # @param [String] message The message to output to the
  #   console.
  # @param [Symbol] color The color in which to display
  #   the message.
  # @return [Void]
  # @!visibility private
  #--------------------------------------------------------
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


end # class Middlemac
