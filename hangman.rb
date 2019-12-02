require 'json'
class Game
    def initialize player
        @words = File.open('5desk.txt').filter do |line|
            length = line.strip.size
            line if length >= 5 && length <= 12
        end.map(&:downcase).map(&:strip)
        @player = player
        @randword = ''
        @chances = 8
        @choices = []
        @current_choice = ''
        @table = []
        @misses = []
    end

    def set_randword
        @randword = @words[rand(@words.count)]
    end

    def set_table
        @table = ('_ '*@randword.size).split(" ")
    end

    def display
        cls
        puts "Word: #{@table.join(" ")}"
        puts "Misses: #{@misses.join(",")}"
        puts "Chances left: #{@chances}"
    end

    def cls
        system "clear"
    end

    def start
        puts '---HANGMAN---'
        puts 'Choose a letter to guess the word.'
        return if load_game?
        set_randword
        set_table
        game_steps
    end

    def game_steps
        loop do
            reduce_chances
            display
            choose_letter
            update_misses
            update_table
            break if continue?
            break if finished?
        end
    end

    def load_game?
        option = ''
        loop do
            puts "Press 1: continue, 2: load game"
            option = gets.chomp
            break if validate_option option
        end
        case option
        when "1"
            false
        when "2"
            load_game
            true
        end 
    end

    def load_game
        vars = JSON.load File.read('save.json')
        vars.keys.each do |key|
            instance_variable_set(key, vars[key])
        end
        game_steps
    end 

    def continue?
        option = ''
        loop do
            puts "Press 1: continue, 2: save the game and finish"
            option = gets.chomp
            break if validate_option option
        end
        case option
        when "1"
            false
        when "2"
            save_game
            true
        end 
    end

    def save_game
        File.open('save.json','w').write(serialize)
    end

    def serialize
        obj = {
            '@randword' => @randword,
            '@chances' => @chances,
            '@choices' => @choices,
            '@current_choice' => @current_choice,
            '@table' => @table,
            '@misses' => @misses
        }
        JSON.dump obj
    end

    def validate_option option
        true if option == "1" || option == "2"
    end

    def choose_letter
        @current_choice = @player.choose_letter
        @choices << @current_choice
    end

    def update_table
        @choices.each do |choice|
            @randword.scan(/#{choice}/) { |c| @table[Regexp.last_match.offset(0)[0]] = c }
        end
    end

    def update_misses
        @misses << @current_choice if @randword.count(@current_choice).zero?
    end

    def finished?
        win? || loose?
    end

    def win?
        if @randword == @table.join("")
            puts "You win."
            puts "The word was: #{@randword}"
            true
        end
    end

    def loose?
        if @chances == 0
            puts "You loose."
            puts "The word was: #{@randword}"
            true
        end
    end

    def reduce_chances
        @chances -= 1
    end
end

class Player

    def choose_letter
        letter = ""
        loop do
            puts "Choose a letter:"
            letter = gets.chomp
            break if validate_input letter
        end
        letter.downcase
    end

    def validate_input input
        input.size == 1 && input =~ /[a-z]/i
    end
end

player = Player.new
game = Game.new(player)
game.start