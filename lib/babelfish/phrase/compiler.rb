# -*- encoding : utf-8 -*-
require 'babelfish/phrase/literal'
require 'babelfish/phrase/variable'
require 'babelfish/phrase/plural_forms'

class Babelfish
  module Phrase
    # Babelfish AST Compiler.
    # Compiles AST to string or to Proc.
    class Compiler
      attr_accessor :ast

      def initialize(ast = nil)
        init(ast)  unless ast.nil?
      end

      # Initializes compiler. Should not be called directly.
      def init(ast)
        self.ast = ast
      end

      # Throws given message in compiler context.
      def throw(message)
        fail "Cannot compile: #{message}"
      end

      # Compiles AST.

      # Result is string when possible; Proc otherwise.
      def compile(ast)
        init(ast)  unless ast.nil?

        throw('No AST given')  if ast.nil?
        throw('Empty AST given')  if ast.length == 0

        if ast.length == 1 && ast.first.is_a?(Babelfish::Phrase::Literal)
          #  просто строка
          return ast.first.text
        end

        ready = ast.map do |node|
          case node
          when Babelfish::Phrase::Literal
            node.text
          when Babelfish::Phrase::Variable
            node
          when Babelfish::Phrase::PluralForms
            sub = node.to_ruby_method
          else
            throw("Unknown AST node: #{node}")
          end
        end

        lambda do |params|
          data = ready.map do |what|
            case what
            when Babelfish::Phrase::Variable
              params[what.name.to_s].to_s
            when Proc
              what = what.call(params)
            else
              what
            end
          end.join('')
          data
        end
      end
    end
  end
end
