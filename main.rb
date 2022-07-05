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
  gold_cards.sample
end

def pick_classic_card(classic_cards, picked_cards)
  (classic_cards - picked_cards).sample
end

def update_cards_stock(card_stock, picked_card)
  new_cards = card_stock.dup
  new_cards.delete_at(new_cards.index(picked_card))
  new_cards
end

def compute_booster(gold_cards, classic_cards)
  gold_card = pick_gold_card(gold_cards)
  new_gold_cards = update_cards_stock(gold_cards, gold_card)

  classic_card1 = pick_classic_card(classic_cards, [])
  new_classic_cards = update_cards_stock(classic_cards, classic_card1)
  
  classic_card2 = pick_classic_card(new_classic_cards, [classic_card1])
  new_classic_cards = update_cards_stock(new_classic_cards, classic_card2)

  classic_card3 = pick_classic_card(new_classic_cards, [classic_card1, classic_card2])
  new_classic_cards = update_cards_stock(new_classic_cards, classic_card3)

  classic_card4 = pick_classic_card(new_classic_cards, [classic_card1, classic_card2, classic_card3])
  new_classic_cards = update_cards_stock(new_classic_cards, classic_card4)

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
  display_packs(boosters)
  puts "The stock has #{boosters.count} packs"
  puts "Number of remaining gold cards #{remaining_gold_cards.count}"
  puts "Number of remaining classic cards #{remaining_classic_cards.count}"
end

def display_packs(boosters)
  boosters.each do |booster|
    display_pack(booster)
  end
end

def display_pack(booster)
  puts booster.to_s
end


main()
