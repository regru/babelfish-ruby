require 'babelfish/phrase/parser_base'
require 'babelfish/phrase/literal'
require 'babelfish/phrase/variable'
require 'babelfish/phrase/plural_forms'
require 'babelfish/phrase/plural_forms_parser'

class Babelfish
    module Phrase
        # Babelfish syntax parser.
        class Parser < ParserBase

            attr_accessor :locale, :mode, :pieces, :escape, :pf0

            LITERAL_MODE  = 'Literal'.freeze
            VARIABLE_MODE = 'Variable'.freeze
            PLURALS_MODE  = 'Plurals'.freeze
            VARIABLE_RE   = /^[a-zA-Z0-9_\.]+$/

            AST_MAP = {
                LITERAL_MODE  => Babelfish::Phrase::Literal,
                VARIABLE_MODE => Babelfish::Phrase::Variable,
                PLURALS_MODE  => Babelfish::Phrase::PluralForms,
            }

            # Instantiates parser.
            def initialize( phrase = nil, locale = nil )
                super( phrase )
                init( phrase )  unless phrase.nil?
                self.locale = locale  if locale
            end

            # Initializes parser. Should not be called directly.
            def init( phrase )
                super( phrase )
                self.mode = LITERAL_MODE
                self.pieces = []
                self.pf0 = nil # plural forms without name yet
            end

            # Finalizes all operations after phrase end.
            def finalize_mode
                case mode
                when LITERAL_MODE
                    pieces.push( AST_MAP[LITERAL_MODE].new( text: piece ) ) if !piece.empty? || pieces.size == 0;
                when VARIABLE_MODE
                    throw( "Variable definition not ended with \"}\": " + piece )
                when PLURALS_MODE
                    throw( "Plural forms definition not ended with \"))\": " + piece )  if pf0.nil?
                    pieces.push( AST_MAP[PLURALS_MODE].new( forms: pf0, name: piece, locale: locale ) )
                else
                    throw( "Logic broken, unknown parser mode: " + mode );
                end
            end

            class << self
                attr_accessor :plurals_parser
            end

            def plurals_parser
                Parser.plurals_parser ||= Babelfish::Phrase::PluralFormsParser.new
            end

            def escape?
                !! self.escape
            end

            # Parses specified phrase.
            def parse( phrase = nil, locale = nil )
                super( phrase )
                self.locale = locale  unless locale.nil?

                while true
                    _char = to_next_char

                    if _char.empty?
                        finalize_mode
                        return pieces
                    end

                    case mode
                    when LITERAL_MODE
                        if escape?
                            add_to_piece( _char )
                            self.escape = false
                            next
                        end

                        if _char == "\\"
                            self.escape = true
                            next
                        end

                        if _char == '#' && next_char == '{'
                            unless piece.empty?
                                pieces.push( AST_MAP[LITERAL_MODE].new( text: piece ) )
                                self.piece = ''
                            end
                            self.to_next_char # skip "{"
                            self.mode = VARIABLE_MODE
                            next
                        end

                        if _char == '(' && next_char == '('
                            unless piece.empty?
                                pieces.push( AST_MAP[LITERAL_MODE].new( text: piece ) )
                                self.piece = ''
                            end
                            to_next_char # skip second "("
                            self.mode = PLURALS_MODE
                            next
                        end

                    when VARIABLE_MODE
                        if escape?
                            add_to_piece( _char )
                            self.escape = false
                            next
                        end

                        if _char == "\\"
                            self.escape = true
                            next
                        end

                        if _char == '}'
                            name = piece.strip
                            if name.empty?
                                throw( "No variable name given." );
                            end
                            if name !~ VARIABLE_RE
                                throw( "Variable name doesn't meet conditions: #{name}." );
                            end
                            pieces.push( AST_MAP[VARIABLE_MODE].new( name: name ) )
                            self.piece = ''
                            self.mode = LITERAL_MODE
                            next
                        end

                    when PLURALS_MODE
                        unless pf0.nil?
                            if _char =~ VARIABLE_RE && (_char != '.' || next_char =~ VARIABLE_RE)
                                add_to_piece( _char )
                                next
                            else
                                pieces.push( AST_MAP[PLURALS_MODE].new( forms: pf0, name: piece, locale:locale ) )
                                self.pf0 = nil
                                self.mode = LITERAL_MODE
                                self.piece = ''
                                backward
                                next
                            end
                        end
                        if _char == ')' && next_char == ')'
                            self.pf0 = plurals_parser.parse( piece )
                            self.piece = ''
                            to_next_char # skip second ")"
                            if next_char == ':'
                                to_next_char # skip ":"
                                next
                            end
                            pieces.push( AST_MAP[PLURALS_MODE].new( forms: pf0, name: 'count', locale: locale ) )
                            self.pf0 = nil
                            self.mode = LITERAL_MODE
                            next
                        end
                    end
                    add_to_piece( _char )
                end # while ( 1 )
            end
        end
    end
end
