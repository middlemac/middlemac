PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
ENV['TEST'] = 'true'

require 'middleman'
require 'middleman-core/step_definitions'
require File.join(PROJECT_ROOT_PATH, 'lib', 'middlemac')


require 'cucumber/formatter/pretty'
class QuietFormatter < Cucumber::Formatter::Pretty
  def initialize(runtime, io, options)
     $stderr = File.new( '/dev/null', 'w' )
    super(runtime, io, options)
  end
  
  def after_features(features)
    $stderr = STDOUT
    super(features)
  end
end
