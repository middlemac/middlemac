require 'middleman-core'

Middleman::Extensions.register :Middlemac, :before_configuration do
  require_relative 'middlemac/extension'
  Middlemac
end
