# -*- encoding : utf-8 -*-
class Babelfish
  module Phrase
    # Babelfish pluralizer.
    module Pluralizer
      @rules = {}

      def self.add(locales, rule)
        locales = [locales]  unless locales.is_a?(Array)

        locales.each { |locale|  @rules[locale] = rule }
      end

      def self.find_rule(locale)
        return @rules[locale]  if @rules.key?(locale)

        locale = @rules.keys.find do |loc|
          /^#{Regexp.escape(loc)}[\-_]/.match(locale) ? loc : nil
        end
        locale = 'en'  if locale.nil?

        @rules[locale]
      end

      def self.is_int(input)
        (0 == input % 1)
      end

      ## PLURALIZATION RULES
      ## https://github.com/nodeca/babelfish/blob/master/lib/babelfish/pluralizer.js#L51

      # Azerbaijani, Bambara, Burmese, Chinese, Dzongkha, Georgian, Hungarian, Igbo,
      # Indonesian, Japanese, Javanese, Kabuverdianu, Kannada, Khmer, Korean,
      # Koyraboro Senni, Lao, Makonde, Malay, Persian, Root, Sakha, Sango,
      # Sichuan Yi, Thai, Tibetan, Tonga, Turkish, Vietnamese, Wolof, Yoruba

      add(%w(az bm my zh dz ka hu ig id ja jv kea kn km ko ses lo kde ms fa root sah sg ii th bo to tr vi wo yo), lambda do |_n|
                                                                                                                    return 0
                                                                                                                  end)

      # Manx

      add(['gv'], lambda do |n|
        m10, m20 = n % 10, n % 20

        if (m10 == 1 || m10 == 2 || m20 == 0) && is_int(n)
          return 0
       end

        return 1
      end)

      # Central Morocco Tamazight

      add(['tzm'],  lambda do |n|
        if n == 0 || n == 1 || (11 <= n && n <= 99 && is_int(n))
          return 0
       end

        return 1
      end)

      # Macedonian

      add(['mk'], lambda do |n|
        if (n % 10 == 1) && (n != 11) && is_int(n)
          return 0
       end

        return 1
      end)

      # Akan, Amharic, Bihari, Filipino, Gun, Hindi,
      # Lingala, Malagasy, Northern Sotho, Tagalog, Tigrinya, Walloon

      add(%w(ak am bh fil guw hi ln mg nso tl ti wa), lambda do |n|
                                                        return (n == 0 || n == 1) ? 0 : 1
                                                      end)

      # Afrikaans, Albanian, Basque, Bemba, Bengali, Bodo, Bulgarian, Catalan,
      # Cherokee, Chiga, Danish, Divehi, Dutch, English, Esperanto, Estonian, Ewe,
      # Faroese, Finnish, Friulian, Galician, Ganda, German, Greek, Gujarati, Hausa,
      # Hawaiian, Hebrew, Icelandic, Italian, Kalaallisut, Kazakh, Kurdish,
      # Luxembourgish, Malayalam, Marathi, Masai, Mongolian, Nahuatl, Nepali,
      # Norwegian, Norwegian Bokmål, Norwegian Nynorsk, Nyankole, Oriya, Oromo,
      # Papiamento, Pashto, Portuguese, Punjabi, Romansh, Saho, Samburu, Soga,
      # Somali, Spanish, Swahili, Swedish, Swiss German, Syriac, Tamil, Telugu,
      # Turkmen, Urdu, Walser, Western Frisian, Zulu

      add(%w(af sq eu bem bn brx bg ca chr cgg da dv nl en eo et ee fo fi fur gl lg de el gu ha haw he is it kl kk ku lb ml mr mas mn nah ne no nb nn nyn or om pap ps pt pa rm ssy saq xog so es sw sv gsw syr ta te tk ur wae fy zu), lambda do |n|
                                                                                                                                                                                                                                          return (1 == n) ? 0 : 1
                                                                                                                                                                                                                                        end)

      # Latvian

      add(['lv'], lambda do |n|
        if n == 0
          return 0
       end

        if (n % 10 == 1) && (n % 100 != 11) && is_int(n)
          return 1
       end

        return 2
      end)

      # Colognian

      add(['ksh'], lambda do |n|
        return (n == 0) ? 0 : ((n == 1) ? 1 : 2)
      end)

      # Cornish, Inari Sami, Inuktitut, Irish, Lule Sami, Northern Sami,
      # Sami Language, Skolt Sami, Southern Sami

      add(%w(kw smn iu ga smj se smi sms sma), lambda do |n|
                                                 return (n == 1) ? 0 : ((n == 2) ? 1 : 2)
                                               end)

      # Belarusian, Bosnian, Croatian, Russian, Serbian, Serbo-Croatian, Ukrainian

      add(%w(be bs hr ru sr sh uk), lambda do |n|
        m10, m100 = n % 10, n % 100

        unless is_int(n)
          return 3
       end

        # one → n mod 10 is 1 and n mod 100 is not 11;
        if 1 == m10 && 11 != m100
          return 0
       end

        # few → n mod 10 in 2..4 and n mod 100 not in 12..14;
        if 2 <= m10 && m10 <= 4 && !(12 <= m100 && m100 <= 14)
          return 1
       end

        ## many → n mod 10 is 0 or n mod 10 in 5..9 or n mod 100 in 11..14;
        ##  if 0 === m10 || (5 <= m10 && m10 <= 9) || (11 <= m100 && m100 <= 14)
        ##   return 2
        # #end

        ## other
        ## return 3
        return 2
      end)

      # Polish

      add(['pl'], lambda do |n|
        m10, m100 = n % 10, n % 100

        unless is_int(n)
          return 3
       end

        # one → n is 1;
        if n == 1
          return 0
       end

        # few → n mod 10 in 2..4 and n mod 100 not in 12..14;
        if 2 <= m10 && m10 <= 4 && !(12 <= m100 && m100 <= 14)
          return 1
       end

        # many → n is not 1 and n mod 10 in 0..1 or
        # n mod 10 in 5..9 or n mod 100 in 12..14
        # (all other except partials)
        return 2
      end)

      # Lithuanian

      add(['lt'], lambda do |n|
        m10, m100 = n % 10, n % 100

        unless is_int(n)
          return 2
       end

        # one → n mod 10 is 1 and n mod 100 not in 11..19
        if m10 == 1 && !(11 <= m100 && m100 <= 19)
          return 0
       end

        # few → n mod 10 in 2..9 and n mod 100 not in 11..19
        if 2 <= m10 && m10 <= 9 && !(11 <= m100 && m100 <= 19)
          return 1
       end

        # other
        return 2
      end)

      # Tachelhit

      add(['shi'], lambda do |n|
        return (0 <= n && n <= 1) ? 0 : ((is_int(n) && 2 <= n && n <= 10) ? 1 : 2)
      end)

      # Moldavian, Romanian

      add(%w(mo ro), lambda do |n|
        m100 = n % 100

        unless is_int(n)
          return 2
       end

        # one → n is 1
        if n == 1
          return 0
       end

        # few → n is 0 OR n is not 1 AND n mod 100 in 1..19
        if n == 0 || (1 <= m100 && m100 <= 19)
          return 1
       end

        # other
        return 2
      end)

      ## Czech, Slovak

      add(%w(cs sk), lambda do |n|
        # one → n is 1
        if n == 1
          return 0
       end

        # few → n in 2..4
        if n == 2 || n == 3 || n == 4
          return 1
       end

        # other
        return 2
      end)

      # Slovenian

      add(['sl'], lambda do |n|
        m100 = n % 100

        unless is_int(n)
          return 3
       end

        # one → n mod 100 is 1
        if m100 == 1
          return 0
       end

        # one → n mod 100 is 2
        if m100 == 2
          return 1
       end

        # one → n mod 100 in 3..4
        if m100 == 3 || m100 == 4
          return 2
       end

        # other
        return 3
      end)

      # Maltese

      add(['mt'], lambda do |n|
        m100 = n % 100

        unless is_int(n)
          return 3
       end

        # one → n is 1
        if n == 1
          return 0
       end

        # few → n is 0 or n mod 100 in 2..10
        if n == 0 || (2 <= m100 && m100 <= 10)
          return 1
       end

        # many → n mod 100 in 11..19
        if 11 <= m100 && m100 <= 19
          return 2
       end

        # other
        return 3
      end)

      # Arabic

      add(['ar'], lambda do |n|
        m100 = n % 100

        unless is_int(n)
          return 5
       end

        if n == 0
          return 0
       end
        if n == 1
          return 1
       end
        if n == 2
          return 2
       end

        # few → n mod 100 in 3..10
        if 3 <= m100 && m100 <= 10
          return 3
       end

        # many → n mod 100 in 11..99
        if 11 <= m100 && m100 <= 99
          return 4
       end

        # other
        return 5
      end)

      # Breton, Welsh

      add(%w(br cy), lambda do |n|
        if n == 0
          return 0
       end
        if n == 1
          return 1
       end
        if n == 2
          return 2
       end
        if n == 3
          return 3
       end
        if n == 6
          return 4
       end

        return 5
      end)

      ## FRACTIONAL PARTS - SPECIAL CASES

      # French, Fulah, Kabyle

      add(%w(fr ff kab), lambda do |n|
        return (0 <= n && n < 2) ? 0 : 1
      end)

      # Langi

      add(['lag'], lambda do |n|
        return (n == 0) ? 0 : ((0 < n && n < 2) ? 1 : 2)
      end)
    end
  end
end
