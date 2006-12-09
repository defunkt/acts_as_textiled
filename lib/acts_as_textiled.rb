module Err 
  module Acts #:nodoc: all
    module Textiled
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def acts_as_textiled(*attrs)
          @textiled_attributes = []
          def textiled_attributes; Array(@textiled_attributes) end

          ruled = Hash === attrs.last ? attrs.pop : {}
          attrs += ruled.keys

          attrs.each do |attr|
            define_method(attr) do
              textiled[attr.to_s] ||= RedCloth.new(read_attribute(attr), Array(ruled[attr])).to_html if read_attribute(attr)
            end
            define_method("#{attr}_plain",  proc { strip_redcloth_html(__send__(attr)) if __send__(attr) } )
            define_method("#{attr}_source", proc { __send__("#{attr}_before_type_cast") } )
            @textiled_attributes << attr
          end

          include Err::Acts::Textiled::InstanceMethods
        end
      end

      module InstanceMethods
        def textiled
          textiled? ? (@textiled ||= {}) : @attributes.dup
        end

        def textiled?
          @is_textiled || true
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
          super(attr_name, value)
        end

      private
        def strip_redcloth_html(html)
          returning html.dup.gsub(html_regexp, '') do |h|
            redcloth_glyphs.each do |(entity, char)|
              h.gsub!(entity, char)
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
