# frozen_string_literal: true

require_relative './game'
require 'json'

def select_random_word
  dictionary = File.open('google-10000-english-no-swears.txt', 'r').readlines
  word = ''
  loop do
    random_index = Random.rand(0..(dictionary.length - 1))
    word = dictionary[random_index].chomp
    break if word.length >= 5 && word.length <= 12
  end
  word
end

def list_available_games
  puts
  puts 'Available saved games:'
  Dir.entries('saved_games').each do |entry|
    puts entry.sub('.json','') if entry.match?('.json')
  end
end

def play_again?
  puts 'Do you want to play again? [y/n]'
  play_again = gets.chomp
  until /^[ny]{1}$/.match?(play_again)
    puts 'Please choose y or n:'
    play_again = gets.chomp
  end
  play_again == 'y'
end

puts 'Welcome to Hangman!'
puts
puts %{In this game, you must discover the secret word by guessing its characters.

Each chosen character that is not a part of the secret word is counted as a 
mistake, and makes a body part from the Hangman to turn red, as in the example
below.

\u250c\u2500\u2500\u2500\u2500\u2510        \u250c\u2500\u2500\u2500\u2500\u2510
\u2502    \033[0m\u25EF\033[0m        \u2502    \033[31m\u25EF\033[0m
\u2502   \033[0m\u002f\033[0m\033[0m\u005b\033[0m\033[0m\u005d\033[0m\033[0m\u005c\033[0m      \u2502   \033[0m\u002f\033[0m\033[0m\u005b\033[0m\033[0m\u005d\033[0m\033[0m\u005c\033[0m
\u2502   \033[0m\u005f\033[0m\u2571\033[0m\033[0m\u2572\033[0m\033[0m\u005f\033[0m      \u2502   \033[0m\u005f\033[0m\u2571\033[0m\033[0m\u2572\033[0m\033[0m\u005f\033[0m
\u2534             \u2534

The man's body is divided in 9 parts. So, if you make 9 mistakes, the poor man 
is hanged, and you lose the game.

If you are able to choose the right characters and guess the secret
before 9 mistakes, the man is saved! \o/

Ready? Then let's start!
}

puts

play_again = true

while play_again
  puts 'What do you want to do?'
  puts '[1] Start new game'
  puts '[2] Load saved game'
  choice = gets.chomp

  if choice == '1' ||
     (choice == '2' && (!File.exist?('saved_games') || Dir.empty?('saved_games')))
    if choice == '2'
      puts
      puts 'There are no saved games yet.'
    end
    puts
    puts 'Starting new game!'
    puts
    answer = select_random_word
    answer_array = answer.split('')
    guess_array = Array.new(answer_array.length)
    choices = []
    wrongs = Array.new(9, 0)
    round = 0
  else
    string = Game.load_game
    game_variables = JSON.parse(string)
    answer_array = game_variables['answer_array']
    guess_array = game_variables['guess_array']
    choices = game_variables['choices']
    wrongs = game_variables['wrongs']
    round = game_variables['round']
    puts
    puts 'Game loaded! The current status was:'
  end

  game = Game.new(answer_array, guess_array, choices, wrongs, round)
  game.print_round_result

  until game.wrongs.none?(0) || game.guess_array.none?(nil)
    game.round += 1

    puts
    puts "___________Round #{game.round}___________"

    puts
    puts 'Please choose a letter to continue, or type 1 to save and exit:'
    choice = gets.chomp
    until /^[a-zA-Z1]{1}$/.match?(choice)
      puts
      puts 'Please choose a letter [a - z or A - Z] to continue or type 1 to save and exit:'
      choice = gets.chomp
    end

    if choice == '1'
      game.round -= 1
      game.save_game
      play_again = false
      break
    else
      game.register_choice(choice.downcase)
      game.play_round
      game.print_round_result
    end
  end

  if game.wrongs.none?(0)
    puts
    puts 'You lose! The secret word was:'
    puts game.answer_array.join('')
    puts
    play_again = play_again?
  elsif game.guess_array.none?(nil)
    puts
    puts 'You win! Congratulations'
    puts
    play_again = play_again?
  end
end
