dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true
require 'test/unit'
require 'rubygems'
require 'orchard'
gem 'thoughtbot-shoulda' 
require 'shoulda'
class HandledError < Exception; end