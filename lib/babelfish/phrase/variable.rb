# -*- encoding : utf-8 -*-
require 'babelfish/phrase/node'

class Babelfish
    module Phrase
        # Babelfish AST Variable substitution node.
        class Variable < Node

            attr_accessor :name
        end
    end
end
