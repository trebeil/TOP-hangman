require 'json'

class Game
  attr_accessor :guess_array, :choices, :round, :wrongs
  attr_reader :answer_array
  
  def initialize(answer_array, guess_array, choices, wrongs, round)
    @answer_array = answer_array
    @guess_array = guess_array
    @choices = choices
    @wrongs = wrongs
    @round = round
  end

  def print_round_result
    result_array = self.guess_array.map do |element|
                      if element == nil
                        '_ '
                      else
                        "#{element} "
                      end
                    end
    puts
    puts "\u250c\u2500\u2500\u2500\u2500\u2510"
    puts "\u2502    \033[#{self.wrongs[0]}m\u25EF\033[0m"
    puts "\u2502   \033[#{self.wrongs[1]}m\u002f\033[0m\033[#{self.wrongs[2]}m\u005b\033[0m\033[#{self.wrongs[3]}m\u005d\033[0m\033[#{self.wrongs[4]}m\u005c\033[0m"
    puts "\u2502   \033[#{self.wrongs[5]}m\u005f\033[#{self.wrongs[6]}m\u2571\033[0m\033[#{self.wrongs[7]}m\u2572\033[0m\033[#{self.wrongs[8]}m\u005f\033[0m"
    puts "\u2534" 
    puts
    puts 'Secret word:'
    puts result_array.join('')
    puts
    if round > 0
      puts 'Choices so far:'
      puts choices.join(', ')
      puts
    end
  end

  def play_round
    choice = self.choices.last
    wrong = true
    self.guess_array.each_with_index do |element, index|
      if choice == answer_array[index]
        self.guess_array[index] = choice 
        wrong = false
      end
    end
    if wrong
      index_to_change = self.wrongs.index(0)
      self.wrongs[index_to_change] = 31
    end
  end

  def register_choice(choice)
    self.choices.push(choice)
  end

  def get_filename
    puts
    puts 'What name should your saved game have?'
    filename = gets.chomp
    until /^[\w\- ]+$/.match?(filename)
      puts
      puts 'Invalid characters used. What name should your saved game have?'
      filename = gets.chomp
    end
    if File.exists?("saved_games/#{filename}.json")
      puts
      puts 'There is already a saved game with this name. Do you want to overwrite it? [y/n]'
      overwrite = gets.chomp
      until /^[ny]{1}$/.match?(overwrite)
        puts 'Please choose y or n:'
        overwrite = gets.chomp
      end
    else
      overwrite = 'y'
    end
    return [filename, overwrite]
  end

  def save_game
    hash = {
      :answer_array => answer_array,
      :guess_array => guess_array,
      :choices => choices,
      :wrongs => wrongs,
      :round => round
    }
    Dir.mkdir('saved_games') if !File.exists?('saved_games')
    string = JSON.dump(hash)
    filename = ['', 'n']
    until filename[1] == 'y'
      filename = get_filename
    end
    File.open("saved_games/#{filename[0]}.json", 'w') do |file|
      file.write(string)
    end
    puts
    puts 'Game successfully saved!'
  end

  def self.load_game
    list_available_games
    puts
    puts 'Please choose game to load:'
    filename = gets.chomp
    until File.exists?("saved_games/#{filename}.json")
      puts
      puts
      puts 'There\'s no game with that name.'
      list_available_games
      puts
      puts 'Please choose a valid game to load:'
      filename = gets.chomp
    end
    File.read("saved_games/#{filename}.json")
  end
end