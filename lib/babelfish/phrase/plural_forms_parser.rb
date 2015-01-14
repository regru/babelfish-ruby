require 'babelfish/phrase/plural_forms'

class Babelfish
    module Phrase
        # Babelfish plurals syntax parser.

        # Returns { script_forms: {}, regular_forms: [] }

        # Every plural form represented as AST.

        class PluralFormsParser
            attr_accessor :phrase, :strict_forms, :regular_forms

            class << self
                attr_accessor :phrase_parser
            end

            def phrase_parser
                PluralFormsParser.phrase_parser ||= Babelfish::Phrase::Parser.new
            end


            # Instantiates parser.
            def initialize( phrase = nil )
                init( phrase )  unless phrase.nil?
            end

            # Initializes parser. Should not be called directly.
            def init( phrase )
                self.phrase = phrase
                self.regular_forms = []
                self.strict_forms = {}
            end

            # Parses specified phrase.
            def parse( phrase )
                init( $phrase )  unless phrase.nil?

                # тут проще регуляркой
                forms = phrase.split( /(?<!\\)\|/s )

                forms.each do |form|
                    value = nil
                    if form =~ /\A=([0-9]+)\s*(.+)\z/s
                        value, form = $1, $2
                    end
                    form = phrase_parser.parse( form )

                    if value.nil?
                        regular_forms.push form
                    else
                        strict_forms[value] = form
                    end
                end

                return {
                    strict:  strict_forms,
                    regular: regular_forms,
                }
            end
        end
    end
end
