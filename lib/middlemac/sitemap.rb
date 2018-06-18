################################################################################
# Sitemap manipulators.
#  Add new methods to each resource.
################################################################################

class Middlemac < ::Middleman::Extension

  #--------------------------------------------------------
  # We want to handle shallower paths first, and ensure
  # that for any directory the index_file is first. This
  # gives us the ability to rename our directories if the
  # parent directory is to be renamed.
  # @!visibility private
  #--------------------------------------------------------
  def resource_sort_comparator( x, y )
    x_length = Pathname(x.path).each_filename.to_a.count
    x_basename = File.basename(x.path)
    x_dirname = File.dirname(x.path)
    y_length = Pathname(y.path).each_filename.to_a.count
    y_basename = File.basename(y.path)
    y_dirname = File.dirname(y.path)

    if x_length != y_length
      return x_length <=> y_length
    else
      if [x_basename, y_basename].include?(app.config[:index_file])
        # If either is an index file, favor the index file.
        # If both are index files, favor the path.
        if x_basename == y_basename
          return x_basename <=> y_basename
        else
          return x_basename == app.config[:index_file] ? -1 : 1
        end
      else
        # If the dir names are the same, favor the basename,
        # otherwise favor the entire path name.
        if x_dirname == y_dirname
          return x_basename <=> y_basename
        else
          return x_dirname <=> y_dirname
        end
      end
    end
  end


  #--------------------------------------------------------
  # Add our own resource methods to each resource in the
  # site map.
  # @!visibility private
  #--------------------------------------------------------
  def manipulate_resource_list(resources)

    resources.sort { |a,b| resource_sort_comparator(a,b) }
        .each do |resource|


      #--------------------------------------------------------
      # Returns the navigation ID suitable for use in the
      # modern Help's `navigation.json` file. It is either a
      # `topicId` or `sectionId`, depending on whether the 
      # resource is a topic, or a section metadata resource.
      # @return [String] The navigation ID of the current
      #  resource.
      #--------------------------------------------------------
      def resource.hb_NavId
        prefix = self.hb_Section? ? 'section' : 'topic'
        "#{prefix}-#{self.page_group}-#{self.page_name}"
      end


      #--------------------------------------------------------
      # Returns the locale for the current resource, based on
      # which language.lproj directory it's in, or nil if it's
      # not in one.
      # @return [String] The locale.
      #--------------------------------------------------------
      def resource.hb_locale
        if matches = self.path.match(/([^\/]+)\.lproj/i)
          matches.captures[0]
        else
          nil
        end
      end


      #--------------------------------------------------------
      # Returns the path as it should be used in the help book
      # `navigation.json` file, i.e., relative to the
      # `language.lproj` directory. Note that this is
      # incomplete for use in `href` attributes, which require
      # this path to be accessed via a javascript value, e.g.,
      # `#/hb_path`.
      # @return [String] The navigation ID of the current
      #  resource.
      #--------------------------------------------------------
      def resource.hb_Path
        orig_path = Pathname.new(self.destination_path)
        project_root = Pathname.new("Resources/#{self.hb_locale}.lproj/")
        orig_path.relative_path_from(project_root).to_s
      end


      #--------------------------------------------------------
      # Returns a path to this resource via the main file
      # index.html file that runs the entire helpbook. Useful
      # for redirecting naked pages in the site to index file
      # for proper display in a meta refresh tag. For example,
      # ../../index.html?localePath=en.lproj#/topic-sample_group_number_one-page_one
      # Note that in this case, the link *must* be relative,
      # because the Apple Help Viewer doesn't seem to work
      # with book-absolute paths.
      # @return [String] Absolute path of this resource via
      #  index.html.
      #--------------------------------------------------------
      def resource.hb_redirect_path
        index = Pathname.new(@app.extensions[:Middlemac].hb_sitemap_impl(self).first.breadcrumbs.first.parent.url)
        from_dir = Pathname.new(File.dirname(self.url))
        relative = index.relative_path_from(from_dir)
        navId = self.hb_NavId
        locale = self.hb_locale
        "#{relative.to_s}?localePath=#{locale}.lproj#/#{navId}"
      end


      #--------------------------------------------------------
      # Make `page_name` available for each resource. This is
      # the file’s base name after any renaming has occurred,
      # unless the file is a content index.html, in which
      # case the name is the name of the containing folder.
      # This ensures we keep the same name for cases such as
      # carrot.html or carrot/index.html.
      # Useful for assigning classes, etc.
      # @return [String] The `page_name` of the current page.
      #--------------------------------------------------------
      def resource.page_name
        path = Pathname(self.destination_path)
        page_name = File.basename( self.destination_path, '.*' )
        if page_name == File.basename( @app.config[:index_file], '.*' )
          File.basename( path.parent.to_s )
        else
          page_name
        end
      end


      #--------------------------------------------------------
      # Make `page_group` available for each resource.
      # Useful for for assigning classes, and/or group
      # conditionals. The page group is the enclosing folder;
      # if it's a content index.html alone in a folder, then
      # it's the grandfather folder, in order to preserve
      # topics when carrot.html becomes carrot/index.html.
      # @return [String] The `page_group` of the current page.
      #--------------------------------------------------------
      def resource.page_group
        path = Pathname(self.destination_path)
        page_name = File.basename( self.destination_path, '.*' )
        if page_name == File.basename( @app.config[:index_file], '.*' )
          result = File.basename( path.parent.parent.to_s )
        else
          result = File.basename( path.parent.to_s )
        end
        result
      end


      #--------------------------------------------------------
      # Indicates whether or not a page is "legitimate" in
      # terms of automatic navigation, based in:
      #
      #  * The resource has a sort order and isn't zero.
      #  * The resource isn't ignored.
      #
      # @return (Boolean) Returns `true` if this pages 
      #   participates in automatic navigation features.
      #--------------------------------------------------------
      def resource.legitimate?
        self.sort_order && self.sort_order != 0 && !self.ignored
      end


      #--------------------------------------------------------
      # Indicates whether or not a resource is a section entry
      # for a modern Apple HelpBook.
      # @return [Boolean] True if the resource represents a
      #  section heading.
      #--------------------------------------------------------
      def resource.hb_Section?
        (self.legitimate?) && (self.legitimate_children.count > 0)
      end


      #--------------------------------------------------------
      # Return the parent of the resource. This implementation
      # corrects a bug in **Middleman** as of 4.1.7 wherein
      # **Middleman** doesn’t return the parent if the the
      # directory has been renamed for output.
      # @return [Sitemap::Resource] The resource instance of
      #   the resource’s parent.
      #--------------------------------------------------------
      def resource.parent
        root = path.sub(/^#{::Regexp.escape(traversal_root)}/, '')
        parts = root.split('/')

        tail = parts.pop
        is_index = (tail == @app.config[:index_file])

        if parts.empty?
          return is_index ? nil : @store.find_resource_by_path(@app.config[:index_file])
        end

        test_expr = parts.join('\\/')
        # eponymous reverse-lookup
        found = @store.resources.find do |candidate|
          candidate.path =~ %r{^#{test_expr}(?:\.[a-zA-Z0-9]+|\/)$}
        end

        if found
          found
        else
          parts.pop if is_index
          @store.find_resource_by_path("#{parts.join('/')}/#{@app.config[:index_file]}")
        end
      end


      #--------------------------------------------------------
      # Returns an array of all of the siblings of this page,
      # taking into account their eligibility for display.
      #
      #  * is not already the current page.
      #  * has a `sort_order`.
      #  * is not ignored.
      #
      # The returned array will be sorted by each item’s
      # `sort_order`.
      # @return [Array<Sitemap::Resource>] An array of
      #   resources.
      #--------------------------------------------------------
      def resource.brethren
        self.siblings
          .find_all { |p| p.legitimate? && p != self }
          .sort_by { |p| p.sort_order }
      end


      #--------------------------------------------------------
      # Returns the next sibling based on order, or `nil` if
      # there is no next sibling.
      # @return [Sitemap::Resource] The resource instance of
      #   the next sibling.
      #--------------------------------------------------------
      def resource.brethren_next
        if self.sort_order == 0
          return nil
        else
          return self.brethren.find { |p| p.sort_order > self.sort_order }
        end
      end


      #--------------------------------------------------------
      # Returns the previous sibling based on order, or `nil`
      # if there is no previous sibling.
      # @return [Sitemap::Resource] The resource instance of
      #   the previous sibling.
      #--------------------------------------------------------
      def resource.brethren_previous
        if self.sort_order == 0
          return nil
        else
          return self.brethren.reverse.find { |p| p.sort_order < self.sort_order }
        end
      end


      #--------------------------------------------------------
      # Returns an array of all of the children of this
      # resource, taking into account their eligibility for
      # display. Each child is legitimate if it:
      #
      #  * has a sort_order.
      #  * is not ignored.
      #
      # The returned array will be sorted by each item’s
      # `sort_order`.
      #
      # @return [Array<Sitemap::Resource>] An array of
      #   resources.
      #--------------------------------------------------------
      def resource.legitimate_children
        self.children
          .find_all { |p| p.legitimate? }
          .sort_by { |p| p.sort_order }
      end


      #--------------------------------------------------------
      # Returns an array of resources leading to this resource.
      # @return [Array<Sitemap::Resource>] An array of
      #   resources.
      #--------------------------------------------------------
      def resource.breadcrumbs
        hierarchy = [] << self
        hierarchy.unshift hierarchy.first.parent while hierarchy&.first&.parent&.data&.title
        hierarchy
      end


      #--------------------------------------------------------
      # Returns the quantity of pages in the current page’s
      # group, including this current page, i.e., the number
      # of `brethren + 1`.
      # @return [Integer] The total number of pages in the
      #   this page’s current group.
      #--------------------------------------------------------
      def resource.group_count
        self.brethren.count + 1
      end


      #--------------------------------------------------------
      # Returns the page sort order or 0 if no page sort order
      # was applied.
      #
      # Pages without a sort order can still be linked to;
      # they simply aren't brethren or legitimate children,
      # and so don’t participate in any of the automatic
      # navigation features.
      # @return [Integer] The current resource’s sort order
      #   within its group, or 0 if no sort order was applied.
      #--------------------------------------------------------
      def resource.sort_order
        options[:sort_order]
      end


      #--------------------------------------------------------
      # Returns the page sequence amongst all of the brethren,
      # and can be used as a page number surrogate. The first
      # page is 1. Pages without a sort order will have a `nil`
      # `page_sequence`.
      # @return [Integer, Nil] The current page sequence of
      #   this resource among its brethren.
      #--------------------------------------------------------
      def resource.page_sequence
        if self.sort_order == 0
          return nil
        else
          self.siblings
            .find_all { |p| p.legitimate? }
            .push(self)
            .sort_by { |p| p.sort_order }
            .find_index(self) + 1
        end
      end


      #--------------------------------------------------------
      # Returns the word frequency hash for the content of 
      # the resource.
      #
      # @return [Hash] The :word => frequency content of the
      #   resource.
      #--------------------------------------------------------
      def resource.word_frequencies
        @app.extensions[:Middlemac].word_frequencies_impl(self)
      end
      

      #--------------------------------------------------------
      # Indicates whether the asset is located in the :locale,
      # the :global, the :convention, or an :other_dir folder.
      # This can be useful to sort assets in a comparitor by
      # priority if there are assets of the same name.
      #
      # @return [Symbol] :locale, :global, :convention, or
      #   :other_dir (in the event that it's not expected).
      #--------------------------------------------------------
      def resource.asset_path_type
        path = self.destination_path
        content_type = self.content_type
        result = :other_dir
        check_global = nil

        if content_type.start_with?('text/html', 'application/xhtml')
          return self.hb_locale ? :locale : :other_dir
        elsif content_type.start_with?('image/')
          check_global = @app.config[:images_dir]
        elsif content_type == 'text/css'
          check_global = @app.config[:css_dir]
        elsif content_type == 'application/javascript'
          check_global = @app.config[:js_dir]
        elsif content_type.start_with?('font/')
          check_global = @app.config[:fonts_dir]
        else
          return result
        end

        check_locale = @app.extensions[:Middlemac].localized_asset_path(check_global, self)

        if path.start_with?(@app.config[:convention_dir])
          result = :convention
        elsif path.start_with?(check_locale)
          result = :locale
        elsif path.start_with?(check_global)
          result = :global
        end

        return result
      end



      #========================================================
      #  sort_order and destination_path
      #    Take this opportunity to gather page sort orders
      #    and rename pages so that they don't include sort
      #    order as part of their names.
      #
      #    Only X/HTML files with an `order` data key, or
      #    with an integer prefix + underscore will be
      #    considered for sort orders.
      #
      #    If :strip_file_prefixes, then additionally we will
      #    prettify the output page name.
      #========================================================
      strip = @app.extensions[:Middlemac].options[:strip_file_prefixes]
      page_name = File.basename(resource.path, '.*')
      path_part = File.dirname(resource.destination_path)
      file_renamed = false

      if resource.content_type && resource.content_type.start_with?('text/html', 'application/xhtml')

        # Set the resource's sort order if provided via various means.
        if resource.data.key?('order')
          # Priority for ordering goes to the :order front matter key.
          sort_order = resource.data['order']
        elsif ( match = /^(\d*?)_/.match(page_name) )
          # Otherwise if the file has an integer prefix we will use that.
          sort_order = match[1]
        elsif ( match = /^(\d*?)_/.match(path_part.split('/').last) ) && File.basename( resource.path ) == app.config[:index_file]
          # Otherwise if we're an index file then set the sort order based on
          # its containing group. Because we sorted the resources, we are sure
          # that this is the first resource to be processed in this directory.
          sort_order = match[1]
        else
          sort_order = nil
        end

        # Remove the sort order indicator from the file or directory name.
        # This will only change the output path for files that have a sort
        # order. Other files in a renamed directory that need to have their
        # paths changed will be changed below.
        if strip && sort_order

          path_parts = path_part.split('/')

          # Handle preceding path parts, first, if there's a grandparent (all
          # top level items have a parent and aren't part of this case). These
          # will have already been set because we've done shallower paths first.
          if resource.parent && resource.parent.parent
            parent_path_parts = File.dirname(resource.parent.destination_path).split('/')
            path_parts = parent_path_parts + path_parts[parent_path_parts.count..-1]
          end

          # Handle our immediate directory.
          path_parts.last.sub!(/^(\d*?)_/, '')

          # Join up everything and write the correct path.
          path_part = path_parts.join('/')
          name_part = page_name.sub( "#{sort_order}_", '') + File.extname( resource.path )
          if path_part == '.'
            resource.destination_path = name_part
          else
            resource.destination_path = File.join(path_part, name_part)
          end
          file_renamed = true
        end

        resource.options[:sort_order] = sort_order.to_i

      end
      
      unless file_renamed
      
        # For other files, check to see if there's an index file in this source
        # directory. If so then our rules state it will have a sort order, which
        # means we can ensure that our output path is without a sorting prefix.
        # If there is, then make sure OUR immediate destination directory is
        # the same as the index file’s, in case we've renamed it.
        index_file = [path_part, app.config[:index_file] ].join('/')
        index_found = resources.select { |r| r.path == index_file }[0]

        if strip && index_found && index_found.options[:sort_order]
          path_part = File.dirname(index_found.destination_path)
          name_part = File.basename(resource.destination_path)
          if path_part == '.'
            resource.destination_path = name_part
          else
            resource.destination_path = File.join(path_part, name_part)
          end

        end

      end


    end # resources.each

    resources

  end # manipulate_resource_list

end # class Middlemac
