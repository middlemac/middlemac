require 'middleman-core'

Middleman::Extensions.register :Middlemac, :before_configuration do
  require_relative 'middlemac/extension'
  require_relative 'middlemac/sitemap'
  require_relative 'middlemac/helpers'
  require_relative 'middlemac/private'
  require_relative 'middlemac/trie'
  Middlemac
end
