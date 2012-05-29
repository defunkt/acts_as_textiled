begin
  require 'RedCloth' unless defined? RedCloth
rescue LoadError
  nil
end

require 'acts_as_textiled'
require 'instance_tag_monkey_patch'
ActiveRecord::Base.send(:include, Err::Acts::Textiled)
