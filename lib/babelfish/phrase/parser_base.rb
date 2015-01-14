# -*- encoding : utf-8 -*-
class Babelfish
    module Phrase
        # Babelfish abstract parser.
        class ParserBase
            attr_accessor :phrase, :index, :length, :prev, :piece, :escape


            def initialize(phrase = nil)
                init(phrase)  if phrase
            end

            def init(phrase)
                self.phrase = phrase
                self.index = -1
                self.prev = nil
                self.length = phrase.length
                self.piece = ''
                self.escape = false
            end

            # Gets character on current cursor position.
            # Will return empty string if no character.
            def char
                r = phrase[ index ]
                r.nil? ? '' : r
            end

            # Gets character on next cursor position.
            # Will return empty string if no character.
            def next_char
                return ''  if index >= length - 1
                r = phrase[ index + 1 ]
                r.nil? ? '' : r
            end

            # Moves cursor to next position.
            # Return new current character.
            def to_next_char
                self.prev = char  if self.index >= 0
                self.index =  self.index + 1
                return ''  if self.index == length
                char()
            end

            # Throws given message in phrase context.
            def throw( message )
                raise "Cannot parse phrase \""+ ( phrase || 'nil' )+ "\" at ". ( index || '-1' )+ " index: #{message}"
            end

            # Adds given chars to current piece.
            def add_to_piece(chars)
                self.piece += chars
            end

            # Moves cursor backward.
            def backward
                self.index = index - 1
                if index > 0
                    r = phrase[ index - 1 ]
                    self.prev = r.nil? ? '' : r
                end
            end

            # Parses specified phrase.
            def parse( phrase = nil )
                init(phrase)  unless phrase.nil?
                throw( "No phrase given" )  if phrase.nil?
                phrase
            end
        end
    end
end
