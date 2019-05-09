require 'yaml'

class HangmanGame

  def initialize
    @save_file = 'hangman_save.yaml'
    @chances = 8
    @file_path = '5desk.txt'
    @letters_guessed = []
    load_save
    if @word.nil?
      @word = get_a_word
    end
  end

  def save_to_yaml
    save_data = YAML.dump ({
      :chances => @chances,
      :letters_guessed => @letters_guessed,
      :word => @word
    })
    file = File.open(@save_file, "w")
    file.puts save_data
    file.close
  end

  def remove_save
    if File.exist?(@save_file)
      File.delete(@save_file)
    end
  end

  def load_save
    if File.exist?(@save_file)
      file = File.open(@save_file, "r")
      file_data = file.read
      save_data = YAML.load file_data
      save_data.each do |x, value| # how was this handled?
        instance_variable_set("@#{x}", value)
      end
    end
  end

  def get_a_word(min_length=5, max_length=12)
    dictionary_file = File.open(@file_path, 'r')
    dictionary_words = dictionary_file.readlines
    word = ''
    while word.length < min_length or word.length > max_length
      word = dictionary_words.sample.chomp
    end
    dictionary_file.close
    return word.upcase
  end

  def display_status
    puts "\n\n"
    puts "Letters guessed: #{@letters_guessed.join(' ').to_s}"
    display_word = ''
    @word.split('').each do |x|
      if @letters_guessed.any?(x)
        display_word = display_word + ' ' + x
      else
        display_word = display_word + ' _'
      end
    end
    puts display_word
    puts "Remaining Chances: #{@chances}"
  end

  def play
    display_status

    while @chances > 0
      puts "Guess or quit & save by inputting 'CTRL+C'"
      guess = gets.chomp.upcase
      if guess.length > 1
        puts "You're guessing the word! #{guess}"
        if guess == @word
          puts "You got it!"
          remove_save
          exit
        else
          puts "You didn't get it!"
        end
      else
        puts "Your guess was #{guess}"
        if @letters_guessed.any?(guess)
          puts "You already guessed #{guess}"
        else
          if (@word.split('').any?(guess))
            puts "You got one!"
          else
            puts "Miss"
          end
          @letters_guessed << guess
        end
      end
      @chances -= 1
      save_to_yaml
      display_status
    end

    puts "The word was #{@word}."
    remove_save
  end
end

a = HangmanGame.new
a.play