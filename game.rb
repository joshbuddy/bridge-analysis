require 'json'
require './lib/parser'
require 'sinatra/base'
require 'securerandom'

module Game
  class Boards
    attr_reader :count

    def initialize
      path = File.join(File.dirname(__FILE__), 'boards/**/*.json')
      @boards = Dir.glob(path)
      @parser = Parser.new
      @count = @boards.count
    end

    def load(number)
      path = @boards[number]
      Board.from_json(File.read(path))
    end

    def self.instance
      @instance ||= Boards.new
    end
  end

  class Web < Sinatra::Application
    helpers do
      def card_image(suit, rank)
        long_suit = {'s' => 'spades', 'h' => 'hearts', 'd' => 'diamonds', 'c' => 'clubs'}[suit]
        image = case rank
        when 'A'
          "ace_of_#{long_suit}.png"
        when 'K'
          "king_of_#{long_suit}2.png"
        when 'Q'
          "queen_of_#{long_suit}2.png"
        when 'J'
          "jack_of_#{long_suit}2.png"
        when 'T'
          "10_of_#{long_suit}.png"
        else
          "#{rank}_of_#{long_suit}.png"
        end

        "/#{image}"
      end
    end

    get "/" do
      @play_id = SecureRandom.hex
      erb :index
    end

    get "/play/:id/:step" do
      play_id = params[:id].to_i(16)
      step = params[:step].to_i

      boards = Boards.instance

      random = Random.new(play_id)
      random_numbers = 5.times.map do |i|
        (random.rand * boards.count).floor
      end

      @board = boards.load(random_numbers[step])
      erb :play
    end

  end
end