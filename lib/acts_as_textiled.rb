module Err 
  module Acts #:nodoc: all
    module Textiled
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def acts_as_textiled(*attributes)

          @textiled_unicode = String.new.respond_to? :chars

          ruled = attributes.last.is_a?(Hash) ? attributes.pop : {}
          attributes += ruled.keys

          type_options = %w( plain source )

          textiled_attributes = read_inheritable_attribute(:textiled_attributes) || []

          attributes.each do |attribute|
            next if textiled_attributes.include? attribute

            unless method_defined?(attribute)
              define_method(attribute) do |*args|
                self[attribute]
              end
            end

            define_method(attribute.to_s + "_with_textiled") do |*args|
              type = args.first

              value = __send__(attribute.to_s + "_without_textiled", *args)

              if type.nil? && value
                textiled[attribute.to_s] ||= RedCloth.new(value, Array(ruled[attribute])).to_html 
              elsif type.nil? && value.nil?
                nil
              elsif type_options.include?(type.to_s)
                send("#{attribute}_#{type}")
              else
                raise "I don't understand the `#{type}' option.  Try #{type_options.join(' or ')}."
              end
            end

            alias_method_chain attribute, :textiled

            define_method("#{attribute}_plain",  proc { strip_redcloth_html(__send__(attribute)) if __send__(attribute) } )
            define_method("#{attribute}_source", proc { __send__("#{attribute}_before_type_cast") } )

            textiled_attributes << attribute
          end

          write_inheritable_attribute(:textiled_attributes, textiled_attributes)

          include Err::Acts::Textiled::InstanceMethods
        end

        def textiled_attributes
          Array(read_inheritable_attribute(:textiled_attributes)) 
        end
      end

      module InstanceMethods
        def textiled
          textiled? ? (@textiled ||= {}) : @attributes.dup
        end

        def textiled?
          @is_textiled != false
        end

        def textiled=(bool)
          @is_textiled = !!bool
        end

        def textilize
          self.class.textiled_attributes.each { |attr| __send__(attr) }
        end

        def reload
          textiled.clear
          super
        end

        def write_attribute(attr_name, value)
          textiled[attr_name.to_s] = nil
          super
        end

      private
        def strip_redcloth_html(html)
          html.dup.gsub(html_regexp, '').tap do |h|
            redcloth_glyphs.each do |(entity, char)|
              sub = [ :gsub!, entity, char ]
              @textiled_unicode ? h.chars.send(*sub) : h.send(*sub)
            end
          end
        end

        def redcloth_glyphs
           [[ '&#8217;', "'" ], 
            [ '&#8216;', "'" ],
            [ '&lt;', '<' ], 
            [ '&gt;', '>' ], 
            [ '&#8221;', '"' ],
            [ '&#8220;', '"' ],            
            [ '&#8230;', '...' ],
            [ '\1&#8212;', '--' ], 
            [ ' &rarr; ', '->' ], 
            [ ' &#8211; ', '-' ], 
            [ '&#215;', 'x' ], 
            [ '&#8482;', '(TM)' ], 
            [ '&#174;', '(R)' ],
            [ '&#169;', '(C)' ]]
        end

        def html_regexp
          %r{<(?:[^>"']+|"(?:\\.|[^\\"]+)*"|'(?:\\.|[^\\']+)*')*>}xm
        end
      end
    end
  end
end
