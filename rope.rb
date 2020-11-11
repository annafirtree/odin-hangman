# frozen_string_literal: true

# Rope class handles drawing the hanging figure for hangman
class Rope
  MAX = 6

  def initialize(body_parts = 0)
    @body_parts = body_parts
  end

  def tighten
    @body_parts += 1 unless @body_parts == MAX
  end

  def draw
    draw_scaffold_top
    draw_head_layer
    draw_torso_layer
    draw_leg_layer
    draw_bottom_scaffold
    write_how_many_wrong_guesses_left
  end

  def dead?
    @body_parts == MAX
  end

  def draw_winner
    draw_scaffold_top
    draw_empty_scaffold(3)
    draw_winning_head
    draw_torso_with_two_arms
    draw_two_legs
    draw_bottom_scaffold
  end

  def to_yaml
    YAML.dump({
                body_parts: @body_parts
              })
  end

  def self.from_yaml(string)
    data = YAML.load string
    new(data[:body_parts])
  end

  private

  def draw_scaffold_top
    puts ' '
    2.times { puts '------------8------' }
    puts '            8    ||'
  end

  def draw_empty_scaffold(vertical_layers)
    vertical_layers.times { puts '                 ||' }
  end

  def draw_head_layer
    @body_parts.positive? ? draw_head : draw_empty_scaffold(6)
  end

  def draw_head
    puts '    ---     8    ||'
    puts '  /     \\   8    ||'
    puts ' |  * *  | 8     ||' if @body_parts < MAX
    puts ' |  X X  | 8     ||' if @body_parts == MAX
    puts '  \\  O  / 8      ||'
    puts '    ---  8       ||'
    puts '   888888        ||'
  end

  def draw_torso_layer
    draw_empty_scaffold(5) if @body_parts < 2
    draw_armless_torso if @body_parts == 2
    draw_torso_with_one_arm if @body_parts == 3
    draw_torso_with_two_arms if @body_parts > 3
  end

  def draw_armless_torso
    5. times { puts '     |           ||' }
  end

  def draw_torso_with_one_arm
    puts '    /|           ||'
    puts '   / |           ||'
    puts '  /  |           ||'
    puts ' /   |           ||'
    puts '     |           ||'
  end

  def draw_torso_with_two_arms
    puts '    /|\\          ||'
    puts '   / | \\         ||'
    puts '  /  |  \\        ||'
    puts ' /   |   \\       ||'
    puts '     |           ||'
  end

  def draw_leg_layer
    draw_empty_scaffold(4) if @body_parts < 5
    draw_one_leg if @body_parts == 5
    draw_two_legs if @body_parts > 5
    draw_empty_scaffold(2)
  end

  def draw_one_leg
    puts '    /            ||'
    puts '   /             ||'
    puts '  /              ||'
    puts ' /               ||'
  end

  def draw_two_legs
    puts '    / \\          ||'
    puts '   /   \\         ||'
    puts '  /     \\        ||'
    puts ' /       \\       ||'
  end

  def draw_bottom_scaffold
    2.times { puts ' ------------------' }
  end

  def write_how_many_wrong_guesses_left
    puts "\n You have #{MAX - @body_parts} body part(s) left to lose.\n"
  end

  def draw_winning_head
    puts '    ---          ||'
    puts '  /     \\        ||'
    puts ' |  * *  |       ||'
    puts '  \\ \\_/ /        ||'
    puts '    ---          ||'
  end
end
