require "json"
require "strscan"

class Board
  attr_reader :file, :board_id, :hands, :bids, :vulnerability, :dealer

  VULNERABILITIES = %w(
    none
    ns
    ew
    both
    ns
    ew
    both
    none
    ew
    both
    none
    ns
    both
    none
    ns
    ew
  )
  DEALER = %w(n e s w)

  def self.from_json(contents)
    data = JSON.parse(contents)
    new(data.fetch('file'), data.fetch('board_id'), data.fetch('hands'), data.fetch('bids'))
  end

  def initialize(file, board_id, hands, bids)
    @file = file
    @board_id = board_id
    @hands = hands
    @bids = bids
    calculate_dealer_vulnerability
  end

  def to_json
    JSON.dump({file: @file, board_id: @board_id, hands: @hands, bids: @bids})
  end

  private
  def calculate_dealer_vulnerability
    @vulnerability = VULNERABILITIES[(board_id - 1) % 16]
    @dealer = DEALER[(board_id - 1) % 4]
  end
end

class Parser
  def parse(file, contents)
    ss = StringScanner.new(contents)

    ss.define_singleton_method(:find_pair) do |name|
      ss.scan_until(/(?:\||[\n\r]+)#{name}\|([^|]+)/m)
      ss[1]
    end

    boards = []

    while board_id = ss.find_pair("qx")
      hands = ss.find_pair("md").split(',')
      bids = []
      while true
        bids.push ss.find_pair("mb").downcase
        if bids.count >= 3 && bids[-3, 3].map {|b| b[0].chr} === %w(p p p)
          break
        end
      end
      hands = hands.map do |hand|
        parse_hand(hand)
      end
      boards.push Board.new(file, board_id[/\d+/].to_i, hands, bids)
    end

    boards
  end

  private
  def parse_hand(hand)
    matches = hand.scan(/([SHCD][^SHCD]+)/i)
    raise "invalid hand #{hand}" unless matches[0]
    suits = {}
    count = 0
    puts "hand: #{hand} matches #{matches}"
    matches.flatten.each do |suit|
      puts "suit: #{suit} #{suit[1, suit.size]}"
      cards = suit[1, suit.size].upcase.split('')
      suits[suit[0].chr.downcase] = cards
      count += cards.size
    end
    raise unless count === 13
    suits
  end
end
