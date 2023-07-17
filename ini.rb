class IniParser
    def initialize(file_path)
        @data = {}
        @file_path = file_path
        parse(file_path)
    end
  
    def getValue(section, key)
        @data[section][key] if @data[section]
    end
  
    def setValue(section, key, value)
        if @data[section]
            @data[section][key] = value
        else
            @data[section] = { key => value }
        end
    end
  
    def sync_ini
        File.open(@file_path, 'w') do |file|
            @data.each do |section, keys|
                file.puts "[#{section}]"
                keys.each { |key, value| file.puts "#{key} = #{value}" }
                file.puts
            end
        end
    end

    private
  
    def parse(file_path)
        current_section = nil
  
        File.foreach(file_path) do |line|
            line.strip!
  
            next if line.empty? || line.start_with?('#')
  
            if line.start_with?('[') && line.end_with?(']')
                current_section = line[1..-2]
                @data[current_section] ||= {}
            else
                key, value = line.split('=', 2).map(&:strip)
                @data[current_section][key] = value if current_section
            end
        end
    end
end



def to_b(string)
    return true if string.downcase == "true"
    return false if string.downcase == "false"
    nil
end  