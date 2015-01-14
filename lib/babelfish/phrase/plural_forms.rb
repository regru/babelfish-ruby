# -*- encoding : utf-8 -*-
require 'babelfish/phrase/node'
require 'babelfish/phrase/pluralizer'
require 'babelfish/phrase/compiler'

class Babelfish
    module Phrase
        # Babelfish AST pluralization node.
        class PluralForms < Node

            class << self
                attr_accessor :sub_data, :compiler

            end

            PluralForms.sub_data = []

            attr_accessor :forms, :name, :compiled, :locale

            def to_ruby_method
                unless compiled
                    PluralForms.compiler ||= Babelfish::Phrase::Compiler.new
                    forms[:regular].map! do |form|
                        PluralForms.compiler.compile( form )
                    end
                    new_strict = {}
                    forms[:strict].each_pair do |key, form|
                        new_strict[key] = PluralForms.compiler.compile( form )
                    end
                    forms[:strict].replace(new_strict)
                    self.compiled = true
                end

                rule = Babelfish::Phrase::Pluralizer::find_rule( locale )

                PluralForms.sub_data << [
                    rule,
                    forms[:strict],
                    forms[:regular],
                ]

                return _to_ruby_method( name, PluralForms.sub_data.length - 1 );
            end

            def _to_ruby_method( name, index )
                lambda do |params|
                    value = params[name].to_f
                    rule, strict_forms, regular_forms = PluralForms.sub_data[index]
                    r = nil
                    if value.nan?
                        warn "#{name} parameter is not numeric"
                        r = regular_forms[-1]
                    else
                        r = strict_forms[value] || regular_forms[rule.call(value)] || regular_forms[-1];
                    end
                    return r  if r.kind_of?(String)
                    return ''  if r.nil?
                    r.call(params)
                end

            end

        end
    end
end
