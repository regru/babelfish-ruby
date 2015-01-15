# -*- encoding : utf-8 -*-
require 'find'
require 'yaml'

require 'babelfish/phrase/string_to_compile'
require 'babelfish/phrase/parser'
require 'babelfish/phrase/compiler'

class Babelfish
  attr_accessor :dictionaries, :dirs, :suffix, :default_locale
  attr_accessor :fallbacks, :fallback_cache
  attr_accessor :file_filter, :watch, :watchers
  attr_accessor :compiler, :parser
  attr_accessor :_cfg

  def _built_config(cfg)
    {
      dictionaries:   {},
      dirs:           ['./locales'],
      fallbacks:      {},
      fallback_cache: {},
      suffix:         cfg[:suffix] || 'yml',
      default_locale: cfg[:default_locale] || 'en_US',
      watch:          cfg[:watch] || 0,
      watchers:       {}
    }.merge(cfg || {})
  end

  def initialize(cfg = {})
    cfg = {
      _cfg: cfg
    }.merge(_built_config(cfg))

    cfg.keys.each do |key|
      send("#{key}=", cfg[key])  if respond_to?("#{key}=")
    end

    self.parser = Babelfish::Phrase::Parser.new
    self.compiler = Babelfish::Phrase::Compiler.new

    load_dictionaries(file_filter)
    self.locale = default_locale
  end

  attr_reader :locale

  def locale=(new_locale)
    @locale = detect_locale(new_locale)
  end

  def watch?
    !!watch
  end

  def prepare_to_compile
    dictionaries.each_pair do |_locale, dic|
      dic.each_pair do |key, value|
        if phrase_need_compilation(value, key)
          dic[key] = Babelfish::Phrase::StringToCompile.new(value) # lazy compile
          # dic[key] = compiler.compile( parser.parse(value, locale) );
        end
      end
    end
    true
  end

  def detect_locale(locale)
    return locale  if dictionaries.key?(locale)
    alt_locale = dictionaries.keys.find { |loc| loc =~ /^#{Regexp.escape(locale)}[\-_]/i }
    if alt_locale && dictionaries.key?(alt_locale)
      # Lets locale dictionary will refer to alt locale dictinary.
      # This speeds up all subsequent calls of t/detect/exists on this locale.
      dictionaries[locale] = dictionaries[alt_locale]

      fallback_cache[locale] = fallback_cache[alt_locale]  if fallback_cache.key?(alt_locale)

      fallbacks[locale] = fallbacks[alt_locale]  if fallbacks.key?(alt_locale)

      return locale
    end
    return default_locale  if dictionaries.key?(default_locale)
    fail "bad locale: #{locale} and bad default_locale: #{default_locale}."
  end

  def load_dictionaries(filter)
    dirs.each do |dir|
      fdir = File.absolute_path(dir)
      Find.find(dir) do |file|
        file_path = File.absolute_path(file)
        next  unless FileTest.file? file_path
        return  if filter && !filter(file_path)
        directories, base = File.split(file_path)
        tmp = base.split('.')
        cur_suffix = tmp.pop
        return  if cur_suffix != suffix
        locale = tmp.pop
        dictname = tmp.join('.')
        subdir = directories
        if subdir =~ /^#{Regexp.escape(fdir)}[\\\/](.+)$/
          dictname = "#{Regexp.last_match[1]}#{dictname}"
        end
        _load_dictionary(dictname, locale, file)
      end
    end
    prepare_to_compile
  end

  def _load_dictionary(dictname, lang, file)
    dictionaries[lang] ||= {}

    yaml = YAML.load_file(file)
    _flat_hash_keys(yaml, "#{dictname}.", dictionaries[lang])

    return  unless watch?
    watchers[file] = File.mtime(file)
  end

  def phrase_need_compilation(phrase, key)
    fail "L10N: #{key} is undef"  if phrase.nil?
    phrase.is_a?(String) && phrase =~ /(?:\(\(|\#\{|\\\\)/
  end

  def on_watcher_change
    _cfg.keys.each do |key|
      send("#{key}=", nil)  if respond_to?("#{key}=")
    end

    new_cfg = _built_config(_cfg)
    new_cfg.keys.each do |key|
      send("#{key}=", new_cfg[key])  if respond_to?("#{key}=")
    end
    load_dictionaries
    self.locale = default_locale
  end

  def look_for_watchers
    ok = true
    watchers.each_pair do | file, mtime |
      new_mtime = File.mtime(file)
      if mtime.nil? || new_mtime.nil? || new_mtime != mtime
        ok = false
        break
      end
    end
    return  if ok
    on_watcher_change
  end

  def t_or_undef(dictname_key, params = nil, custom_locale = nil)
    # disallow non-ASCII keys
    fail("wrong dictname_key: #{dictname_key}")  if dictname_key =~ /\P{ASCII}/

    look_for_watchers  if watch?

    _locale = custom_locale ? detect_locale(custom_locale) : locale

    r = dictionaries[_locale][dictname_key]

    unless r.nil?
      if r.is_a?(Babelfish::Phrase::StringToCompile)
        dictionaries[_locale][dictname_key] = r = compiler.compile(
            parser.parse(r, _locale)
        )
      end
    # fallbacks
    else
      fallback_cache[_locale] ||= {}
      #  Cache can contain undef, as unexistent value.
      if fallback_cache[_locale].key?(dictname_key)
        r = fallback_cache[_locale][dictname_key]
      else
        fallback_locales = fallbacks[_locale] || []
        fallback_locales.each do |fallback|
          r = dictionaries[fallback][dictname_key]
          unless r.nil?
            if r.is_a?(Babelfish::Phrase::StringToCompile)
              dictionaries[fallback][dictname_key] = r = compiler.compile(
                  parser.parse(r, fallback)
              )
            end
            break
          end
        end
        fallback_cache[_locale][dictname_key] = r
      end
    end

    if r.is_a?(Proc)
      flat_params = {}
      # Convert parameters hash to flat form like "key.subkey"
      unless params.nil?
        # Scalar interpreted as { count => scalar, value => scalar }.
        unless params.is_a?(Hash)
          flat_params = {
            'count' => params,
            'value' => params
          }
        else
          _flat_hash_keys(params, '', flat_params)
        end
      end

      return r.call(flat_params)
    end
    r
  end

  def t(dictname_key, params = nil, custom_locale = nil)
    t_or_undef(dictname_key, params, custom_locale) || "[#{dictname_key}]"
  end

  def has_any_value(dictname_key, custom_locale = nil)
    # disallow non-ASCII keys
    fail("wrong dictname_key: #{dictname_key}")  if dictname_key =~ /\P{ASCII}/

    look_for_watchers  if watch?

    _locale = custom_locale ? detect_locale(custom_locale) : locale

    return true  if dictionaries[_locale].key?(dictname_key)

    fallback_cache[_locale] ||= {}
    return !fallback_cache[_locale][dictname_key].nil?  if fallback_cache[_locale].key?(dictname_key)

    fallback_locales = fallbacks[_locale] || []
    return true  if fallback_locales.find do |fallback|
      !dictionaries[fallback][dictname_key].nil?
    end

    false
  end

  def set_fallback(locale, fallback_locales)
    return  unless fallback_locales && fallback_locales.size

    _locale = detect_locale(locale)

    fallbacks[_locale] = fallback_locales
    fallback_cache.delete(_locale)

    true
  end

  def _flat_hash_keys(hash, prefix, store)
    hash.each_pair do | key, value |
      if value.is_a?(Hash)
        _flat_hash_keys(value, "#{prefix}#{key}.", store)
      else
        store["#{prefix}#{key}"] = value.is_a?(Symbol) ? value.to_s : value
      end
    end
    true
  end

  def addPhrase(locale, phrase, translation, flatten_level = Float::INFINITY)
    fl = Float::INFINITY
    case flatten_level
    when FalseClass
      fl = 0
    when TrueClass
      fl = Float::INFINITY
    when FixNum, Float
      fl = flatten_level.to_i
      fl = 0  if fl < 0
    else
      fl = Float::INFINITY
    end

    if translation.is_a?(Hash) && fl > 0
      translation.each_pair do | key, val |
        addPhrase(locale, "#{phrase}.#{key}", val, fl - 1)
      end
      return
    end

    if  phrase_need_compilation(translation)
      dictionaries[locale][phrase] = Babelfish::Phrase::StringToCompile.new(translation)
    else
      dictionaries[locale][phrase] = translation
    end

    self.fallback_cache = {}
  end

  # Executes block with given I18n.locale set.
  def with_locale(tmp_locale = nil)
    if tmp_locale
      current_locale = locale
      self.locale    = tmp_locale
    end
    yield
  ensure
    self.locale = current_locale if tmp_locale
  end
end
