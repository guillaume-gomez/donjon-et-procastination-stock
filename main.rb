require 'byebug'
require 'csv'

CARD_NUMBER_COLUMN_NUMBER = 0
CARD_TILE_COLUMN_NUMBER = 1
QUANTITY_COLUMN_NUMBER = 2
CARD_TYPE_COLUMN_NUMBER = 3

def load_file(filepath)
  arr_of_rows = CSV.read(filepath, headers: true)
end

def gold_cards(stock_data)
  stock_gold_cards = stock_data.filter{|row| row[CARD_TYPE_COLUMN_NUMBER] == "gold" }
  stock_gold_cards.reduce([]) do |acc, row|
    cards = Array.new(row[QUANTITY_COLUMN_NUMBER].to_i, row[CARD_TILE_COLUMN_NUMBER])
    acc.concat(cards)
  end
end

def classic_cards(stock_data)
  stock_classic_cards = stock_data.filter{|row| row[CARD_TYPE_COLUMN_NUMBER] != "gold" }
  stock_classic_cards.reduce([]) do |acc, row|
    cards = Array.new(row[QUANTITY_COLUMN_NUMBER].to_i, row[CARD_TILE_COLUMN_NUMBER])
    acc.concat(cards)
  end
end

def pick_gold_card(gold_cards)
  gold_card = gold_cards.sample
end

def pick_classic_card(classic_cards)
  classic_cards.sample
end

def compute_booster(gold_cards, classic_cards)
  gold_card = pick_gold_card(gold_cards)
  new_gold_cards = gold_cards.dup
  new_gold_cards.delete_at(new_gold_cards.index(gold_card))

  new_classic_cards = classic_cards.dup
  classic_card1 = pick_classic_card(new_classic_cards)
  new_classic_cards.delete_at(new_classic_cards.index(classic_card1))

  classic_card2 = pick_classic_card(new_classic_cards)
  new_classic_cards.delete_at(new_classic_cards.index(classic_card2))

  classic_card3 = pick_classic_card(new_classic_cards)
  new_classic_cards.delete_at(new_classic_cards.index(classic_card3))

  classic_card4 = pick_classic_card(new_classic_cards)
  new_classic_cards.delete_at(new_classic_cards.index(classic_card4))

  return {
    booster: [gold_card, classic_card1, classic_card2, classic_card3, classic_card4],
    gold_cards: new_gold_cards,
    classic_cards: new_classic_cards
  }
end

def compute_stock(stock_data)
  boosters = []
  gold_cards = gold_cards(stock_data)
  classic_cards = classic_cards(stock_data)

  while(gold_cards.count >= 1 && classic_cards.count >= 5) do
    booster_data = compute_booster(gold_cards, classic_cards)

    boosters.append(booster_data[:booster])
    gold_cards = booster_data[:gold_cards]
    classic_cards = booster_data[:classic_cards]

  end
  return {
    boosters: boosters,
    remaining_gold_cards: gold_cards,
    remaining_classic_cards: classic_cards
  }
end

def stock_sum(stock_data)
  stock_data.reduce(0) { |acc, row| acc + row[QUANTITY_COLUMN_NUMBER].to_i }
end

def main
  stock_data = load_file("./data.csv")
  sum = stock_sum(stock_data)
  stock = compute_stock(stock_data)
  
  boosters = stock[:boosters]
  remaining_gold_cards = stock[:remaining_gold_cards]
  remaining_classic_cards = stock[:remaining_classic_cards]
  
  puts "They are #{sum} cards in the stock"
  puts "The stock has #{boosters.count} packs"
  print boosters
  puts ""
  puts "Number of remaining gold cards #{remaining_gold_cards.count}"
  puts "Number of remaining classic cards #{remaining_classic_cards.count}"
end

def display_packs(booster)
end

def display_pack(booster)
end


main()
