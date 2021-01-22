require "rainbow"
require "yaml"

#Hangman game
class Game
  attr_accessor :playerAnswer, :playerChoices, :chances, :guessWord
  #START MENU
  def startMenu()
    puts ""
    puts "Welcome to Hangman!!"
    puts "(1) Start game"
    puts "(2) Load game"
    puts "(3) Exit game"
    puts "(4) CLEAR SAVE FILES"
    print "=> "
    menuOption = gets.chomp
    if menuOption == "1"
      gameReset()
      gameRun()
    elsif menuOption == "2"
      loadGame()
    elsif menuOption == "3"
      exit!
    elsif menuOption == "4"
      puts Rainbow("ALL SAVE FILES WILL BE REMOVED. ARE YOU SURE YOU WANT TO CONTINUE?(Y/N)").red
      wipeAllFiles()
    else
      puts "Invalid option!!"
      startMenu()
    end
  end

  def wipeAllFiles()
    playerInput = ""
    playerInput = gets.chomp.upcase
    if playerInput == "Y"
      Dir.glob("save/*").each { |file| File.delete(file) }
      puts Rainbow("Save files deleted").red
      startMenu()
    elsif playerInput == "N"
      startMenu()
    else
      puts "Enter a valid option (Y-yes, N-no)"
      wipeAllFiles()
    end
  end

  def loadGame()
    loadSlot = 0
    #Dir.glob("save/*") #show files in the folder

    puts "Choose a saved slot number or type \"menu\" to go back to menu:"
    for i in 1..5
      if File.exist?("save/save#{i}.yml")
        puts "Slot #{i}: save#{i}"
      else
        puts "Slot #{i}: <empty>"
      end
    end
    print "=> "
    loadSlot = gets.chomp.to_i
    while !File.exists?("save/save#{loadSlot.to_i}.yml") || loadSlot == "menu"
      puts "Choose a valid slot or type \"menu\" to go back to menu:"
      print "=> "
      loadSlot = gets.chomp
      if loadSlot == "menu"
        systemClear()
        startMenu()
        return
      end
    end
    content = YAML.load(File.read("save/save#{loadSlot}.yml"))
    @playerAnswer = content[:playerAnswer].chomp.split("")
    @playerChoices = content[:playerChoices].chomp.split("")
    @chances = content[:chances].to_i
    @guessWord = content[:guessWord].chomp.split("")
    systemClear()
    gameRun()
  end

  def saveGame()
    numberSlots = 5
    saveSlot = -1
    playerEntry = ""
    puts "Choose a slot number:"
    for i in 1..numberSlots
      if File.exist?("save/save#{i}.yml")
        puts "Slot #{i}: save#{i}"
      else
        puts "Slot #{i}: <empty>"
      end
    end
    while saveSlot < 1 || saveSlot > 5
      print "=> "
      tempSlot = gets.chomp.to_i
      if File.exist?("save/save#{tempSlot}.yml")
        puts "This file already exists. Do you want to overwrite(Y/N)?"
        print "=> "
        playerEntry = gets.chomp.upcase.to_s
        if playerEntry == "Y"
          saveSlot = tempSlot
        elsif playerEntry == "N"
          puts "Choose another slot."
        end
      else
        saveSlot = tempSlot
      end
    end

    saveFileName = "save/save#{saveSlot}.yml"
    saveContent = YAML.dump({
      playerAnswer: @playerAnswer.join.to_s,
      playerChoices: @playerChoices.join,
      chances: @chances,
      guessWord: @guessWord.join,
    })

    saveFile = File.open(saveFileName, "w") { |file| file.write saveContent }

    system "clear"
    system "clear"
    puts "Game Saved"
    puts "Choose an Option"
    puts "(1) Go back to game."
    puts "(2) Exit game "
    print "=> "
    menuOption = gets.chomp.to_i
    systemClear()
    if menuOption == 1
      gameRun()
    elsif menuOption == 2
      exit!
    end
  end

  def gameReset
    systemClear()
    @guessWord = ""            #THE WORD to be decypher (have his own function to sort)
    @playerAnswer = Array.new  #array that show the word, is filled with the right letters
    @playerChoices = Array.new #array with all player choices(wrong and right)
    @chances = 6               #number chances(♪ left arm, right arm, left leg, right leg, body and head ♪)
    @playerInput = ""          #player input(it is obvious)

    @guessWord = getWord()
    @guessWord.each do |letter|
      @playerAnswer.push("_")
    end
  end

  # RUN GAME
  def gameRun()
    while @chances > 0
      #puts @guessWord.join #remove comment for test
      printResult()
      puts "Number of chances #{@chances}"
      puts "Guess the letter or choose an option:"
      puts "(1) Main Menu."
      puts "(2) Save Game."
      puts "(3) Exit Game."
      print "=> "
      @playerInput = gets.chomp.upcase
      systemClear()

      if @playerInput == "1"
        startMenu()
      elsif @playerInput == "2"
        saveGame()
      elsif @playerInput == "3"
        exit!
      elsif @playerInput.length != 1 || !@playerInput.match(/^[a-zA-Z]*$/)
        puts Rainbow("Enter only one letter, from a to z (uppercase or lowercase)").red
      elsif @playerAnswer.include?(@playerInput) || @playerChoices.include?(@playerInput)
        puts Rainbow("Você ja escolheu essa letra. Tente outra!").red
      elsif @guessWord.include?(@playerInput)
        puts "You choose #{@playerInput}"
        puts Rainbow("Right choice!").green
        @playerChoices.push(@playerInput)

        @guessWord.each_with_index do |letter, idx|
          if letter == @playerInput
            @playerAnswer[idx] = @playerInput
          end
        end
      else
        puts "You choose #{@playerInput}"
        puts Rainbow("Wrong choice!").red
        @playerChoices.push(@playerInput)
        @chances -= 1
      end

      #test if all "_" in @playerAnswer were changed by letters (victory condition)
      if !@playerAnswer.include?("_")
        puts "Game ended. You won!!"
        startMenu()
      else
      end
    end

    puts "Right answer: #{@guessWord.join}"
    puts "Lost all rounds. You lose!!"
    startMenu()
  end

  def getWord()
    wordDictionary = Array.new
    #File.open("teste.txt").readlines.each do |line| #simple word dictionary, use for test
    File.open("5desk.txt").readlines.each do |line| #project word dictionary
      wordDictionary.push(line)
    end
    i = false
    while i == false
      @guessWord = wordDictionary.sample.upcase.chomp.split("")
      if @guessWord.length >= 5 && @guessWord.length <= 12
        i = true
      else
        #puts "searching another word"
      end
    end
    return @guessWord
    @guessWord = wordDictionary[rand(wordDictionary.length)].upcase.chomp.split("")
  end

  def printResult()
    print ("Word: ")
    for i in 0..@playerAnswer.length
      print @playerAnswer[i]
    end
    puts("")
    print("Your choices: ")
    for i in 0..@playerChoices.length
      if @playerAnswer.include?(@playerChoices[i])
        print Rainbow("#{@playerChoices[i]}").green
      else
        print Rainbow("#{@playerChoices[i]}").red
      end
    end
    puts("")
  end

  def systemClear()
    system "clear"
    system "clear"
  end
end

#start
Dir.mkdir("save") unless Dir.exists?("save")
gamePlay = Game.new
gamePlay.startMenu()
