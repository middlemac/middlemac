##########################################################################
# Our template groups the methods by @group instead of lumping all of 
# them together as instance methods. This is because most of them simply
# *aren't* instance methods but rather helpers or resource methods.
# This template will be used by default because .yardopts loads this
# file; however `rake partials` will override this template via the
# command line in order to use the `template-partials` instead.
##########################################################################
YARD::Templates::Engine.register_template_path File.join(File.dirname(__FILE__), 'template-grouped')

##########################################################################
# Force Yard to parse the helpers block in a Middleman extension.
#
#  * Assign a generic "Helpers" group to each item if they don't have
#    their own @group assignment. Note that @!group doesn't work in this
#    section.
#  * Add a @note to each item to distinguish them in a mixed up instance
#    method detail section.
##########################################################################
class HelpersHandler < YARD::Handlers::Ruby::Base
  handles method_call(:helpers)
  namespace_only

  def process

    statement.last.last.each do |node|

      extra = ''

      # Find out if there's a @group assigned.
      extra << '@group Helpers' unless node.docstring.match(/^@group (.*?)$/i)

      # Clean up the doc string because we like - and = borders.
      # Force the note and group on each of these "fake" methods.
      if node.docstring
        docstring = node.docstring
        docstring = docstring.gsub(/^[\-=]+\n/, '')
        docstring = docstring.gsub(/[\-=]+$/, '')
        docstring << extra
        node.docstring = docstring
      else
        node.docstring = extra
      end

      parse_block(node, :owner => self.owner)
    end # do

  end # def

end # class


##########################################################################
# Force Yard to parse the resources.each block in a Middleman extension.
#
#  * Assign a generic "Resource Extensions" group to each item if they
#    don't have their own @group assignment. Note that @!group
#    doesn't work in this section.
#  * Force each item to have a `@visibility public` because we will
#    probably have `@visibility private` in the wrapping method.
#  * Add a @note to each item to distinguish them in a mixed up instance
#    method detail section.
##########################################################################
class ResourcesHandler < YARD::Handlers::Ruby::Base
  handles :def
  namespace_only

  def process
    extra = <<HEREDOC
@visibility public
HEREDOC

    return unless statement.method_name(true).to_sym == :manipulate_resource_list

    # Block consists of everything in the actual `do` block
    block = statement.last.first.last.last
    block.each do | node |
      if node.type == :defs
        # Clean up the doc string because we like - and = borders.
        # Force the note and public on each of these "fake" methods.
        if node.docstring
          docstring = node.docstring
          docstring = docstring.gsub(/^[\-=]+\n/, '')
          docstring = docstring.gsub(/[\-=]+$/, '')
          docstring << extra
        else
          docstring = extra
        end

        # Find out if there's a @group assigned.
        if ( group = docstring.match(/^@group (.*?)$/i) )
          group = group[1]
        else
          group = 'Resource Extensions'
        end

        def_name = node[2][0]
        object = YARD::CodeObjects::MethodObject.new(namespace, "resource.#{def_name}")
        register(object)
        object.dynamic = true
        object.source = node.source.clone
        object[:docstring] = docstring
        object[:group] = group
      end
    end # do

  end # def

end # class
