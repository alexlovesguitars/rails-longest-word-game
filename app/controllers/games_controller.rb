require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    session[:grid] = @letters.join(", ")
    return session[:grid]
  end

  def score
    @letters = session[:grid]
    @guess = params[:guess]
    @time = params[:time]
    @score_message = if included?(params[:guess].upcase, @letters)
      if english_word?(params[:guess])
        score = compute_score(params[:guess], params[:time])
        [score, "well done"]
      else
        [0, "not an English word"]
      end
    else
      [0, "not in the grid"]
    end
    @score = @score_message.first
    @message = @score_message.last
  end

  private

  def included?(guess, letters)
    guess.chars.all? { |letter| letters.count(letter) >= guess.count(letter) }
  end

  def english_word?(guess)
    response = URI.parse("https://dictionary.lewagon.com/#{guess}")
    json = JSON.parse(response.read)
    return json['found']
  end

  def compute_score(time, guess)
    time.to_f > 60.0 ? 0 : (guess.size * (1.0 - (time.to_f / 60.0)))
  end

end
