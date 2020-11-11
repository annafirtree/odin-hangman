# frozen_string_literal: true

require './rope'

# Hangman class plays a game of Hangman in a command-line interface.
class Hangman
  UNKNOWN = '_'

  def initialize(
    secret_word = File.open('5desk.txt', 'r').readlines.sample.chomp.downcase,
    eliminated = [],
    known = [],
    rope = Rope.new
  )
    @secret_word = secret_word
    @eliminated = eliminated
    @known = known.length.zero? ? Array.new(@secret_word.length, UNKNOWN) : known
    @rope = rope
  end

  def welcome_message
    puts "\n\nWelcome to Hangman.\n"
  end

  def start_of_turn_message
    @rope.draw
    puts 'Word:'
    @known.each { |letter| print " #{letter} " }
    puts "\nLetters eliminated:\n "
    @eliminated.each { |letter| print letter.to_s }
    puts ' '
  end

  def message_to_ask_for_input
    print 'Pick a letter.'
  end

  def valid_input?(input)
    letter = input.downcase
    letter.length == 1 && ('a'..'z').include?(letter) && !@eliminated.include?(letter) && !@known.include?(letter)
  end

  def invalid_input_message(input)
    puts 'You already tried that letter.' if @eliminated.include?(input) || @known.include?(input)
    puts 'Just one letter please.' if input.length > 1
  end

  def play_a_turn(letter)
    letter = letter.downcase
    @secret_word.include?(letter) ? success(letter) : wrong(letter)
  end

  def done?
    @rope.dead? || !@known.include?(UNKNOWN)
  end

  def final_message
    if won?
      @rope.draw_winner
      puts "\nCongrats, you won!"
    else
      @rope.draw
      puts "\nYou\'re dead!"
    end
    puts "The word was #{@secret_word}.\n\n"
  end

  def to_yaml
    YAML.dump({
                secret_word: @secret_word,
                eliminated: @eliminated,
                known: @known,
                rope: @rope
              })
  end

  def self.from_yaml(string)
    data = YAML.load string
    new(data[:secret_word], data[:eliminated], data[:known], data[:rope])
  end

  private

  def success(new_letter)
    @secret_word.split('').each_with_index do |secret_letter, position|
      @known[position] = new_letter if new_letter == secret_letter
    end
    puts 'Good guess.'
  end

  def wrong(letter)
    @eliminated << letter
    @rope.tighten
    puts 'That letter is not present. The noose tightens.'
  end

  def won?
    !@known.include?(UNKNOWN)
  end
end
