module Err 
  module Acts #:nodoc: all
    module Textiled
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def acts_as_textiled(*attrs)
          ruled = attrs.last.is_a?(Hash) ? attrs.pop : {}
          attrs += ruled.keys

          attrs.each do |attr|
            define_method(attr) do
              textiled[attr.to_s] ||= RedCloth.new(read_attribute(attr), Array(ruled[attr])).to_html
            end
            define_method("#{attr}_plain",  proc { strip_redcloth_html(__send__(attr)) } )
            define_method("#{attr}_source", proc { __send__("#{attr}_before_type_cast") } )
          end

          include Err::Acts::Textiled::InstanceMethods
        end
      end

      module InstanceMethods
        def textiled
          textiled? ? (@textiled ||= {}) : @attributes.dup
        end

        def textiled?
          @is_textiled.nil? ? true : @is_textiled
        end

        def textiled=(bool)
          @is_textiled = !!bool
        end

        def textilize
          logger.debug "I GOT HIT!"
          attribute_names.each { |attr| __send__(attr) }
        end

        def reload
          textiled.clear
          super
        end

        def write_attribute(attr_name, value)
          textiled[attr_name.to_s] = nil
          super(attr_name, value)
        end

      private
        def strip_redcloth_html(html)
          html.gsub!(html_regexp, '') 
          redcloth_glyphs.each do |(entity, char)|
            html.gsub!(entity, char)
          end
          html
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
