class Babelfish
    module Phrase
        # Babelfish pluralizer.
        module Pluralizer

            @rules = {}

            def self.add( locales, rule )
                locales = [ locales ]  unless locales.kind_of?(Array)

                locales.each { |locale|  @rules[locale] = rule }
            end

            def self.find_rule( locale )
                return @rules[locale]  if @rules.has_key?(locale)

                locale = @rules.keys.find do |loc|
                    locale =~ /\A\Q#{loc}\E[\-_]/s
                end || 'en'

                return @rules[locale]
            end

            def self.is_int( input )
                return (0 == input % 1)
            end

            ## PLURALIZATION RULES
            ## https://github.com/nodeca/babelfish/blob/master/lib/babelfish/pluralizer.js#L51

            # Azerbaijani, Bambara, Burmese, Chinese, Dzongkha, Georgian, Hungarian, Igbo,
            # Indonesian, Japanese, Javanese, Kabuverdianu, Kannada, Khmer, Korean,
            # Koyraboro Senni, Lao, Makonde, Malay, Persian, Root, Sakha, Sango,
            # Sichuan Yi, Thai, Tibetan, Tonga, Turkish, Vietnamese, Wolof, Yoruba

            add(['az', 'bm', 'my', 'zh', 'dz', 'ka', 'hu', 'ig',
                'id', 'ja', 'jv', 'kea', 'kn', 'km', 'ko',
                'ses', 'lo', 'kde', 'ms', 'fa', 'root', 'sah', 'sg',
                'ii',  'th', 'bo', 'to', 'tr', 'vi', 'wo', 'yo'
            ], lambda { |n|
                return 0;
            });

            # Manx

            add(['gv'], lambda { |n|
                m10, m20 = n % 10, n % 20

                if (m10 == 1 || m10 == 2 || m20 == 0) && is_int(n)
                    return 0;
               end

                return 1;
            });


            # Central Morocco Tamazight

            add(['tzm'],  lambda { |n|
                if n == 0 || n == 1 || (11 <= n && n <= 99 && is_int(n))
                    return 0;
               end

                return 1;
            });


            # Macedonian

            add(['mk'], lambda { |n|
                if (n % 10 == 1) && (n != 11) && is_int(n)
                    return 0;
               end

                return 1;
            });


            # Akan, Amharic, Bihari, Filipino, Gun, Hindi,
            # Lingala, Malagasy, Northern Sotho, Tagalog, Tigrinya, Walloon

            add(['ak', 'am', 'bh', 'fil', 'guw', 'hi',
              'ln', 'mg', 'nso', 'tl', 'ti', 'wa'
            ], lambda { |n|
                return (n == 0 || n == 1) ? 0 : 1;
            });


            # Afrikaans, Albanian, Basque, Bemba, Bengali, Bodo, Bulgarian, Catalan,
            # Cherokee, Chiga, Danish, Divehi, Dutch, English, Esperanto, Estonian, Ewe,
            # Faroese, Finnish, Friulian, Galician, Ganda, German, Greek, Gujarati, Hausa,
            # Hawaiian, Hebrew, Icelandic, Italian, Kalaallisut, Kazakh, Kurdish,
            # Luxembourgish, Malayalam, Marathi, Masai, Mongolian, Nahuatl, Nepali,
            # Norwegian, Norwegian Bokmål, Norwegian Nynorsk, Nyankole, Oriya, Oromo,
            # Papiamento, Pashto, Portuguese, Punjabi, Romansh, Saho, Samburu, Soga,
            # Somali, Spanish, Swahili, Swedish, Swiss German, Syriac, Tamil, Telugu,
            # Turkmen, Urdu, Walser, Western Frisian, Zulu

            add(['af', 'sq', 'eu', 'bem', 'bn', 'brx', 'bg', 'ca',
              'chr', 'cgg', 'da', 'dv', 'nl', 'en', 'eo', 'et', 'ee',
              'fo', 'fi', 'fur', 'gl', 'lg', 'de', 'el', 'gu', 'ha',
              'haw', 'he', 'is', 'it', 'kl', 'kk', 'ku',
              'lb', 'ml', 'mr', 'mas', 'mn', 'nah', 'ne',
              'no', 'nb', 'nn', 'nyn', 'or', 'om',
              'pap', 'ps', 'pt', 'pa', 'rm', 'ssy', 'saq', 'xog',
              'so', 'es', 'sw', 'sv', 'gsw', 'syr', 'ta', 'te',
              'tk', 'ur', 'wae', 'fy', 'zu'
            ], lambda { |n|
                return (1 == n) ? 0 : 1;
            });


            # Latvian

            add(['lv'], lambda { |n|
                if n == 0
                    return 0;
               end

                if (n % 10 == 1) && (n % 100 != 11) && is_int(n)
                    return 1;
               end

                return 2;
            });


            # Colognian

            add(['ksh'], lambda { |n|
                return (n == 0) ? 0 : ((n == 1) ? 1 : 2);
            });


            # Cornish, Inari Sami, Inuktitut, Irish, Lule Sami, Northern Sami,
            # Sami Language, Skolt Sami, Southern Sami

            add(['kw', 'smn', 'iu', 'ga', 'smj', 'se',
              'smi', 'sms', 'sma'
            ], lambda { |n|
                return (n == 1) ? 0 : ((n == 2) ? 1 : 2);
            });


            # Belarusian, Bosnian, Croatian, Russian, Serbian, Serbo-Croatian, Ukrainian

            add(['be', 'bs', 'hr', 'ru', 'sr', 'sh', 'uk'], lambda { |n|
                m10, m100 = n % 10, n % 100

                if !is_int(n)
                    return 3;
               end

                # one → n mod 10 is 1 and n mod 100 is not 11;
                if 1 == m10 && 11 != m100
                    return 0;
               end

                # few → n mod 10 in 2..4 and n mod 100 not in 12..14;
                if 2 <= m10 && m10 <= 4 && !(12 <= m100 && m100 <= 14)
                    return 1;
               end

                ## many → n mod 10 is 0 or n mod 10 in 5..9 or n mod 100 in 11..14;
                ##  if 0 === m10 || (5 <= m10 && m10 <= 9) || (11 <= m100 && m100 <= 14)
                ##   return 2;
                ##end

                ## other
                ## return 3;
                return 2;
            });


            # Polish

            add(['pl'], lambda { |n|
                m10, m100 = n % 10, n % 100

                if !is_int(n)
                    return 3;
               end

                # one → n is 1;
                if n == 1
                    return 0;
               end

                # few → n mod 10 in 2..4 and n mod 100 not in 12..14;
                if 2 <= m10 && m10 <= 4 && !(12 <= m100 && m100 <= 14)
                    return 1;
               end

                # many → n is not 1 and n mod 10 in 0..1 or
                # n mod 10 in 5..9 or n mod 100 in 12..14
                # (all other except partials)
                return 2;
            });


            # Lithuanian

            add(['lt'], lambda { |n|
                m10, m100 = n % 10, n % 100

                if !is_int(n)
                    return 2;
               end

                # one → n mod 10 is 1 and n mod 100 not in 11..19
                if m10 == 1 && !(11 <= m100 && m100 <= 19)
                    return 0;
               end

                # few → n mod 10 in 2..9 and n mod 100 not in 11..19
                if 2 <= m10 && m10 <= 9 && !(11 <= m100 && m100 <= 19)
                    return 1;
               end

                # other
                return 2;
            });


            # Tachelhit

            add(['shi'], lambda { |n|
                return (0 <= n && n <= 1) ? 0 : ((is_int(n) && 2 <= n && n <= 10) ? 1 : 2);
            });


            # Moldavian, Romanian

            add(['mo', 'ro'], lambda { |n|
                m100 = n % 100;

                if !is_int(n)
                    return 2;
               end

                # one → n is 1
                if n == 1
                    return 0;
               end

                # few → n is 0 OR n is not 1 AND n mod 100 in 1..19
                if n == 0 || (1 <= m100 && m100 <= 19)
                    return 1;
               end

                # other
                return 2;
            });


            ## Czech, Slovak

            add(['cs', 'sk'], lambda { |n|
                # one → n is 1
                if n == 1
                    return 0;
               end

                # few → n in 2..4
                if n == 2 || n == 3 || n == 4
                    return 1;
               end

                # other
                return 2;
            });



            # Slovenian

            add(['sl'], lambda { |n|
                m100 = n % 100;

                if !is_int(n)
                    return 3;
               end

                # one → n mod 100 is 1
                if m100 == 1
                    return 0;
               end

                # one → n mod 100 is 2
                if m100 == 2
                    return 1;
               end

                # one → n mod 100 in 3..4
                if m100 == 3 || m100 == 4
                    return 2;
               end

                # other
                return 3;
            });


            # Maltese

            add(['mt'], lambda { |n|
                m100 = n % 100;

                if !is_int(n)
                    return 3;
               end

                # one → n is 1
                if n == 1
                    return 0;
               end

                # few → n is 0 or n mod 100 in 2..10
                if n == 0 || (2 <= m100 && m100 <= 10)
                    return 1;
               end

                # many → n mod 100 in 11..19
                if 11 <= m100 && m100 <= 19
                    return 2;
               end

                # other
                return 3;
            });


            # Arabic

            add(['ar'], lambda { |n|
                m100 = n % 100;

                if !is_int(n)
                    return 5;
               end

                if n == 0
                    return 0;
               end
                if n == 1
                    return 1;
               end
                if n == 2
                    return 2;
               end

                # few → n mod 100 in 3..10
                if 3 <= m100 && m100 <= 10
                    return 3;
               end

                # many → n mod 100 in 11..99
                if 11 <= m100 && m100 <= 99
                    return 4;
               end

                # other
                return 5;
            });


            # Breton, Welsh

            add(['br', 'cy'], lambda { |n|
                if n == 0
                    return 0;
               end
                if n == 1
                    return 1;
               end
                if n == 2
                    return 2;
               end
                if n == 3
                    return 3;
               end
                if n == 6
                    return 4;
               end

                return 5;
            });


            ## FRACTIONAL PARTS - SPECIAL CASES

            # French, Fulah, Kabyle

            add(['fr', 'ff', 'kab'], lambda { |n|
                return (0 <= n && n < 2) ? 0 : 1;
            });


            # Langi

            add(['lag'], lambda { |n|
                return (n == 0) ? 0 : ((0 < n && n < 2) ? 1 : 2);
            });

        end
    end
end
