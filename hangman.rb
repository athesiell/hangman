require 'json'

class WordPicker
  def self.pick_word_length(file_path)
    valid_word = File.readlines(file_path).select do |word|
    word.length.between?(5, 12)
    end
    valid_word.sample.chomp.downcase
  end
end

class HangmanGame
  def initialize
    @word = WordPicker.pick_word_length('english_no_swears.txt')
    @guesses = []
    @lives = 7
    @game_over = false
    @feedback = ''
    @guessed_letters = []
    @fullword = ''
    load_game if File.exist?('saved_game.json')
  end

  def play
    guess_letter until end_game
  end

  private

  def to_json(*_args)
    JSON.dump({
                word: @word,
                guesses: @guesses,
                lives: @lives,
                game_over: @game_over,
                feedback: @feedback,
                guessed_letters: @guessed_letters,
                fullword: @fullword
              })
  end

  def from_json(json)
    data = JSON.load File.new(json)
    @word = data['word']
    @guesses = data['guesses']
    @lives = data['lives']
    @game_over = data['game_over']
    @feedback = data['feedback']
    @guessed_letters = data['guessed_letters']
    @fullword = data['fullword']
  end

  def save_game(file)  
    File.open("saved_game.json", "w") do |game_file| 
      game_file.write(file) 
    end
  end

  def load_game
    puts "Would you like to load your previous game or start a new one? Type 'Y' or 'N'."
    answer = gets.chomp.upcase
    if answer == "Y"
      from_json("saved_game.json")
    elsif answer == "N"
      guess_letter
    else
      'Invalid input, try again'
      load_game
    end
  end

  def hide_word
    @word.split('').map do |letter|
      if @guesses.include?(letter)
        letter
      else
        '_'
      end
    end.join(' ')
  end

  def display_board
    puts "Word: #{hide_word}"
    puts "You have #{@lives} live/s left."
    puts "Feedback: #{@feedback}"
    puts "The letters you guessed so far that are not in a word: #{@guessed_letters.join(", ")}"
  end

  def valid_input(input)
    if input.length > 1 
      input.chars.all? { |char| char.between?('a', 'z') }
    else
      ('a'..'z').include?(input)
    end
  end

  def guess_letter
    puts "Please enter letter/word or type 'save' to save your game."
    display_board
    letter = gets.chomp.downcase
    if letter == 'save'
      puts 'You have successfully saved your game'
      to_json
      save_game(to_json)
      exit
      @game_over = true
    end
    if valid_input(letter)
      if letter == @word
        @fullword << letter
        @feedback = "You guessed '#{letter}'"
      elsif @guesses.include?(letter)
        @feedback = 'You already guessed that letter.'
      elsif @word.include?(letter)
        @guesses << letter
        @feedback = "You correctly guessed '#{letter}'"
      else
        @guesses << letter
        @guessed_letters << letter
        @lives -= 1
        @feedback = "Sorry, '#{letter}' was wrong."
      end
    else
      @feedback = 'Invalid input, use LETTERS!/WORD'
      guess_letter
    end
    @game_over = true if @lives.zero?
  end

  def game_won?
    @word.chars.all? { |letter| @guesses.include?(letter) }
  end

  def end_game
    if game_won? || @fullword == @word
      puts "You win! You correctly guessed the word #{@word.upcase}."
      @game_over = true
    elsif @lives.zero?
      puts "Unfortunately you lose! You ran out of attempts. The word was #{@word.upcase}."
      @game_over = true
    end
  end
end

class GameInterface
def initialize
  puts '----------------------- WELCOME TO THE HANGMAN GAME! ----------------------'
  puts '==========================================================================='
  puts "It's a game where you have to decipher a word within a certain number tries"
  puts ""
  puts 'During the game you can input [a-z] letters or if you wish - full word.'
  puts ""
  puts 'Also you can save your game, then load it and play where you left off, so GL HF!'
  puts ""
end

def start_play
  HangmanGame.new.play
end

end

hangman = GameInterface.new
hangman.start_play