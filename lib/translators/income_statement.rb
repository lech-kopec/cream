module Translators
  class BzRadar

    @@translations = YAML.load_file('config/scrapper_locales/biznes_radar.yml')
    @@short_term = YAML.load_file('config/scrapper_locales/short_term.yml')
    puts "Tr loading error" unless @@translations

    @@missing = []

    def self.tr(key)
      x = @@translations[key]
      unless x
        @@missing.push key.to_s
        return nil
      end
      return x
    end

    def self.tr2(key)
      x = @@short_term[key] || @@translations[key]
      unless x
        @@missing.push key.to_s
        return nil
      end
      return x
    end

    def self.missing
      return @@missing
    end
  end
end
