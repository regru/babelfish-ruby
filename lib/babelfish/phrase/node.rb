# -*- encoding : utf-8 -*-
class Babelfish
    module Phrase
        # Babelfish AST abstract node.
        class Node

            def initialize( args = {} )
                args.keys.each do |key|
                    send("#{key}=", args[key])  if respond_to?("#{key}=")
                end
            end
        end
    end
end
