# -*- encoding : utf-8 -*-
require 'babelfish/phrase/node'

class Babelfish
  module Phrase
    # Babelfish AST Literal node.
    class Literal < Node
      attr_accessor :text
    end
  end
end
