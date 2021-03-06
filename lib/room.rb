
require "thread"

$state = {}

def reload! room_name = nil, filename = nil
  $commands = {}
  
  $room_name ||= room_name
  $last_filename ||= filename
  
  load $last_filename
  load!
  
  $state[:here] ||= $starting_room
end

def prefs_paths
  dir_path = File.expand_path("~/.room")
  file_path = File.join(dir_path, $room_name)
  [dir_path, file_path]
end

def no_save!
  $no_save = true
end

def save! obj = $state
  return if $no_save
  
  dir_path, file_path = prefs_paths
  begin
    Dir::mkdir dir_path unless File.exist? dir_path
    File.open(file_path, "wb") { |f| f.write Marshal.dump(obj || {}) }
    @previous_save_error = false
  rescue Exception => e
    unless @previous_save_error
      Printer.puts "[warning: couldn't save state: #{e}]"
      @previous_save_error = true
    end
  end
end

def load!
  _, file_path = prefs_paths
  return unless File.exist? file_path
  begin
    $state = Marshal.load(File.read(file_path))
    @previous_load_error = false
  rescue Exception => e
    unless @previous_load_error
      Printer.puts "[warning: couldn't load state: #{e}]"
      @previous_load_error = true
    end
  end
end

class String
  def |(o)
    if o.nil?
      self
    else
      self + "\n" + o
    end
  end
  
  def commandify
    Regexp.compile("^" + Regexp.escape(self.gsub("_", " ")).gsub("XXX", "(.+)") + "$")
  end
  
  # I actively support the inclusion of this method
  def underscore
    word = dup
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

class Printer
  class << self
    def puts(str = "")
      lines = str.split("\n", -1)
      lines << "" if lines.length == 0
      lines.each { |line| sleep 0.05; $stdout.puts line }
    end
  end
end

class Room
  DEFAULT_COMMANDS = [["look".commandify, :look], ["l".commandify, :look], ["look_around".commandify, :look]]
  
  def go key
    Room.go key
  end
  
  def quietly_go key
    Room.go key, false
  end
  
  def no_echo
    $secretive = true
  end
  
  def inventory
    $state[:inventory] ||= []
  end
  
  def have? item
    inventory.include? item
  end
  
  def take item
    inventory << item
  end
  
  def lose item
    inventory.delete item
  end
  
  def do action
    Printer.puts
    if action.strip == ""
    elsif (r = self.class.commands.detect { |c, m| c =~ action })
      command, method = r
      args = command.match(action).to_a.drop(1)
      Printer.puts self.send(method, *args).to_s.rstrip
    else
      Printer.puts huh?(action)
    end
  end
  
  def immediate *text
    Printer.puts *text
  end
  
  def look
    "A nondescript room."
  end
  
  def huh? action = nil
    "I don't understand."
  end
  
  def unknown_room key
    "" |
    "The fourth wall falls over and you realize you didn't really" |
    "want to go to '#{key}' anyway. You decide to let the author" |
    "know about this terrible oversight as soon as possible."
  end
  
  class << self
    def key
      self.to_s.underscore
    end
    
    def commands
      $commands ||= {}
      $commands[key] ||= DEFAULT_COMMANDS.dup
    end
    
    def room key
      $state[:rooms] ||= {}
      $state[:rooms][key] = room_keys[key].new if $state[:rooms][key].nil? && room_keys[key]
      $state[:rooms][key]
    end
    
    def room_keys
      $room_keys ||= {}
    end
    
    def here
      room $state[:here]
    end
    
    def go key, look = true
      if room key
        $state[:here] = key
        "\n" + here.look if look
      else
        here.unknown_room key
      end
    end
    
    def do action
      if action == "debug!"
        Printer.puts
        Printer.puts $state.inspect
      elsif action == "restart!"
        $state = { :here => $starting_room }
        Printer.puts
        Printer.puts "    ....."
        Printer.puts "Your mind, a wild monkey."
        Printer.puts "        ....,.,"
        Room.do "look"
      elsif action == "reload!"
        reload!
        Printer.puts
        Printer.puts "A great wave of relief washes over you."
      elsif here
        here.do action
      else
        Printer.puts
        Printer.puts "Where am I?"
      end
    end
    
    def dup *cmds
      cmds.each do |cmd|
        alias_method cmd, $last_command
      end
    end
    
    def add_command regexp, method
      commands << [regexp, method]
    end
    
    def inherited subclass
      room_keys[subclass.key] = subclass
      $starting_room ||= subclass.key
      $state[:here] ||= $starting_room
    end
    
    def method_added name
      if public_instance_methods.include? name.to_s
        $last_command = name
        
        if /^look(.+)/ =~ name.to_s
          %w{ look l look_at look_at_the examine ex }.each do |prefix|
            add_command "#{prefix}#{$1}".commandify, name
          end
        elsif /^enter(.+)/ =~ name.to_s
          %w{ enter enter_the go_into go_into_the }.each do |prefix|
            add_command "#{prefix}#{$1}".commandify, name
          end
        else
          add_command name.to_s.commandify, name
        end
      end
    end
  end
end
