module Translators
  class BzRadar

    @@translations = YAML.load_file('config/scrapper_locales/biznes_radar.yml')
    puts "Tr loading error" unless @@translations

    @@missing = []

    def self.tr(key)
      x = @@translations[key]
      unless x
        puts key
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
