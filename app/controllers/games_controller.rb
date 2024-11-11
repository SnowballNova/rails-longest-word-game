class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    @word = params[:new]  # Get the word from the form
    grid = params[:letters].split(",")  # Get the letters from the hidden field
    start_time = Time.parse(params[:start_time])  # Get the start time
    end_time = Time.now  # Record the end time
    @time_taken = end_time - start_time  # Calculate time taken

    valid_attempt = valid_word_in_grid?(@word, grid)
    valid_word = valid_word_in_dictionary?(@word)

    # Calculate the score based on word validity and length
    @score = calculate_score(@word, valid_attempt, valid_word)
    @message = generate_message(valid_attempt, valid_word)

    # Update cumulative score in session
    session[:total_score] ||= 0
    session[:total_score] += @score
    @total_score = session[:total_score]
  end

  def valid_word_in_grid?(attempt, grid)
    grid_clone = grid.dup
    attempt.upcase.chars.all? do |letter|
      if grid_clone.include?(letter)
        grid_clone.delete_at(grid_clone.index(letter))
      else
        return false
      end
    end
    true
  end

  def valid_word_in_dictionary?(attempt)
    url = "https://dictionary.lewagon.com/#{attempt}"
    response = URI.open(url).read
    word_info = JSON.parse(response)
    word_info["found"]
  end

  def generate_message(valid_attempt, valid_word)
    if valid_attempt
      if valid_word
        "The word '#{@word}' is valid according to the grid and is an English word ✅"
      else
        "The word '#{@word}' is valid according to the grid, but is not a valid English word ❌"
      end
    else
      "The word '#{@word}' can't be built out of the original grid ❌"
    end
  end

  def calculate_score(attempt, valid_attempt, valid_word)
    return 0 unless valid_attempt && valid_word

    # Score is the square of the number of letters in the valid word
    attempt.length ** 2
  end
end
