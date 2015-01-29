BabelFish - human friendly i18n for Ruby
========================================

Internationalisation with easy syntax for Ruby, Perl, node.js and browser. Classic solutions
use multiple phrases for plurals. But we define plurals inline - that's more
compact, and easy for programmers. Also, phrases are grouped into nested scopes,
like in Ruby.

We support all pluralisation rules from [unicode CLDR](http://unicode.org/repos/cldr-tmp/trunk/diff/supplemental/language_plural_rules.html),
version [2.0.1](http://cldr.unicode.org/index/downloads).

### Installation

```bash
gem ins babelfish

# or simply bundle it into your Gemfile
```

### Phrases Syntax

- `#{varname}` Echoes value of variable
- `((Singular|Plural1|Plural2)):count` Plural form

example:

- `А у меня в кармане #{nails_count} ((гвоздь|гвоздя|гвоздей)):nails_count`

You can also omit anchor variable for plurals, by default it will be `count`.
Thus following variants are equal:

- `I have #{count} ((nail|nails))`
- `I have #{count} ((nail|nails)):count`

Also you can use variables in plural parts:

- `I have ((#{count} nail|#{count} nails))`

Need special zero form or overwrite any specific value? No problems:

- `I have ((=0 no nails|#{count} nail|#{count} nails))`


##### Escape chars

If you need `#{`, `((`, `|` or `))` somewhere in text, where it can be considered
as markup part - just escape them with `\`.


##### Example with YAML

As BabelFish flatten scopes, it's really fun and nice to store translations in
YAML files:

```yaml
---
ru-RU:
  profile: Профиль
  forums: Форумы
  apps:
    forums:
      new_topic: Новая тема
      last_post:
        title : Последнее сообщение
        by : от
  demo:
    apples: На столе лежит #{count} ((яблоко|яблока|яблок))
```

### Usage

```ruby
# Create new instance of Babelfish with default language/locale: 'en-GB'
require 'babelfish'
i18n = Babelfish.new('en-GB');


# Fill in some phrases
i18n.addPhrase('en-GB', 'demo.hello',         'Hello, #{user.name}.');
i18n.addPhrase('en-GB', 'demo.conv.wazup',    'Whats up?');
i18n.addPhrase('en-GB', 'demo.conv.alright',  'Alright, man!');
i18n.addPhrase('en-GB', 'demo.coerce',        'Total: #{count}.');

i18n.addPhrase('ru-RU', 'demo.hello',         'Привет, #{user.name}.');
i18n.addPhrase('ru-RU', 'demo.conv.wazup',    'Как дела?');

i18n.addPhrase('uk-UA', 'demo.hello',         'Здоровенькі були, #{user.name}.');


# Set locale fallback to use the most appropriate translation when possible
i18n.setFallback('by-BY', 'ru-RU');


# Translate
var params = {user: {name: 'ixti'}};

i18n.t('demo.hello', params, 'ru-RU');  // -> 'Привет, ixti.'
i18n.t('demo.conv.wazup', 'ru-RU');     // -> 'Как дела?'
i18n.t('demo.conv.alright', 'ru-RU');   // -> 'Alright, man!'

i18n.t('demo.hello', params, 'uk-UA');  // -> 'Здоровенькі були, ixti.'
i18n.t('demo.conv.wazup', 'uk-UA');     // -> 'Как дела?'
i18n.t('demo.conv.alright', 'uk-UA');   // -> 'Alright, man!'

# When params is number or strings, it will be coerced to
# `{ count: XXX, value: XXX }` - use any of those in phrase.
i18n.t('demo.coerce', 5, 'en-GB');      // -> 'Total: 5.'


# You may wish to "dump" translations to load in browser later
# Dump will include all fallback translations and fallback rules
var locale_dump = i18n.stringify('ru-RU');

# Use objects instead of strings (object/array/number/boolean) - can be
# useful to prepare bulk data for external libraries.
# Note, only JSON-supported types are ok (no date & regex)
i18n.addPhrase('en-GB', 'demo.boolean',  true);
i18n.addPhrase('en-GB', 'demo.number',   123);
i18n.addPhrase('en-GB', 'demo.array',    [1, 2, 3]);
# fourth param required for hashes (objects) to disable flattening,
# other types are autodetected
i18n.addPhrase('en-GB', 'demo.array',    { foo:1, bar:"2" }, false);
```

### Implementations in other languages

- JavaScript - [nodeca/babelfish](https://github.com/nodeca/babelfish)
- Perl - [Locale::Babelfish](https://metacpan.org/pod/Locale::Babelfish)


### License

View the [LICENSE](https://github.com/regru/babelfish-ruby/blob/master/LICENSE) file (MIT).
