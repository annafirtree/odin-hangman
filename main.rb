# frozen_string_literal: true

require 'yaml'
require './hangman'

# Game class is designed to handle saving and loading files for a turn-based command-line game.
#   By adding a 'require [game_file]' and setting THIS_GAME to ParticularGameClass, it can
#   work with any game that meets its requirements.
# To interface with this class, the particular game class must implement the following public methods:
#   .welcome_message
#   .start_of_turn_message
#   .message_to_ask_for_input
#   .valid_input?
#     - This should return false for an empty string
#   .invalid_input_message(input)
#   .play_a_turn(input)
#   .done?
#   .final_message
#   .to_yaml
#   self.from_yaml
# If the word "save" is valid input for the game, this class will save the game
#   instead of passing that on as input.
class Game
  NEW = 'new'
  THIS_GAME = Hangman
  NO_SAVED_GAME = 'no_saved_game'
  STOP_GAME_TO_SAVE = 'stop_game_to_save'

  def initialize
    @game = THIS_GAME.new
    @loaded_from_saved_file = NO_SAVED_GAME
  end

  def play
    @game.welcome_message
    new_or_load = saved_games_exist? ? ask_for_new_or_load : NEW
    load_from_save(new_or_load) unless new_or_load == NEW
    done = keep_playing
    @game.final_message if done
  end

  private

  def ask_for_new_or_load
    input = ''
    keep_going = true
    while keep_going
      puts 'Type N to play a new game or L to see a list of saved games. Type the name of a saved game to load it.'
      input = gets.chomp.downcase
      list_saved_games if input == 'l'
      keep_going = false if input == 'n' || File.exist?(formatted_file_name(input))
    end
    input == 'n' ? NEW : input
  end

  def list_saved_games
    puts 'Saved games:'
    Dir.glob(in_saved_folder('*')).each { |file_with_path| puts strip_file_path(file_with_path) }
  end

  def keep_playing
    until @game.done?
      @game.start_of_turn_message
      input = ask_for_valid_input
      if input == STOP_GAME_TO_SAVE
        save_game
        return false
      end
      @game.play_a_turn(input)
    end
    true
  end

  def ask_for_valid_input
    input = ''
    until @game.valid_input?(input)
      puts "#{@game.message_to_ask_for_input} Or type 'save' to save game."
      input = gets.chomp
      return STOP_GAME_TO_SAVE if input.downcase == 'save'

      @game.invalid_input_message(input) unless @game.valid_input?(input)
    end
    input
  end

  def save_game
    Dir.mkdir(in_saved_folder('')) unless Dir.exist? in_saved_folder('')
    @loaded_from_saved_file = ask_for_saved_file_name if @loaded_from_saved_file == NO_SAVED_GAME
    File.open(formatted_file_name(@loaded_from_saved_file), 'w').puts @game.to_yaml
    puts 'Your game was saved.'
  end

  def ask_for_saved_file_name
    input = ''
    until valid_file_name?(input)
      puts 'What would you like to name your saved game? Names must be alphanumeric and at least 2 characters.'
      input = gets.chomp.downcase
      return input if save_over_file?(input)
    end
    input
  end

  def save_over_file?(input)
    return false unless File.exist?(formatted_file_name(input))

    puts 'Would you like to replace the saved game by that name? Type Y for yes, or N for no.'
    answer = gets.chomp.downcase
    answer == 'y'
  end

  def valid_file_name?(input)
    input.length > 1 && input != 'save' && input.match(/^[a-z0-9]+$/)
  end

  def load_from_save(file)
    @game = Hangman.from_yaml(File.read(formatted_file_name(file)))
    @loaded_from_saved_file = file
  end

  def formatted_file_name(file)
    in_saved_folder(with_extension(file))
  end

  def with_extension(file)
    return file if file.include?('.')

    "#{file}.yml"
  end

  def in_saved_folder(file)
    "saved_games/#{file}"
  end

  def saved_games_exist?
    Dir.glob(in_saved_folder('*')).length.positive?
  end

  def strip_file_path(file_path)
    first_index = in_saved_folder('').length
    second_index = file_path.split('').index('.') - 1
    file_path[first_index..second_index]
  end
end

game = Game.new
game.play
