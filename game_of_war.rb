#!/usr/bin/env ruby

# Store all our game data (players deck values) in GameState
module GameState
	DATA = {
		players: [],
		card_deck: [2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13,14,14,14,14],
		cards_in_play: [],
	}
end

$card_value_hash = {
	2 => "2",
	3 => "3",
	4 => "4",
	5 => "5",
	6 => "6",
	7 => "7",
	8 => "8",
	9 => "9",
	10 => "10",
	11 => "J",
	12 => "Q",
	13 => "K",
	14 => "A",
}

$round_number = 1

# Setup player decks
def game_setup(players)
	cards_per_player = GameState::DATA[:card_deck].length / players;
	(1..players).each do |plyr|
		GameState::DATA[:players] << {
			player_id: plyr,
			player_cards: [],
			current_card_in_play: 0,
    	}

    	for crd in 1..cards_per_player
			random_index = rand(0...GameState::DATA[:card_deck].length)
			card = GameState::DATA[:card_deck].delete_at(random_index)
			GameState::DATA[:players][plyr-1][:player_cards].push(card)
    	end
  	end
end

# WAR +-+
def war(round_results, players, is_war)
	winner=nil
	current_high_card_players = []
	current_high_card = 0
	players.each do |plyr|
		if is_war
			for x in 1..3
				if plyr[:player_cards].length > 0
					card_value = plyr[:player_cards].shift
					GameState::DATA[:cards_in_play].push(card_value)
				end
			end
		end

		if plyr[:player_cards].length > 0
			card_value = plyr[:player_cards].shift
			plyr[:current_card_in_play] = $card_value_hash[card_value]
			GameState::DATA[:cards_in_play].push(card_value)
			if card_value > current_high_card
				winner = plyr
				current_high_card_players = [plyr]
				current_high_card = card_value
			elsif card_value == current_high_card
				current_high_card_players.push(plyr)
			end
		else 
			plyr[:current_card_in_play] = "-"
		end
	end

	tag_cards = ""
	if is_war
		tag_cards = "[X,X,X]"
	end

	# Print result
	output_string = "Round Number #{$round_number} - "
	players.each do |plyr|
		if plyr[:current_card_in_play] == $card_value_hash[current_high_card]
			if current_high_card_players.length > 1
				output_string += "\e[31mWinner P#{plyr[:player_id]}:[#{plyr[:current_card_in_play]}]\e[0m #{tag_cards} "
			else
				output_string += "\e[32mWinner P#{plyr[:player_id]}:[#{plyr[:current_card_in_play]}]\e[0m #{tag_cards} "
			end
		else
			output_string += "P#{plyr[:player_id]}:[#{plyr[:current_card_in_play]}] #{tag_cards} "
		end
	end
	round_results.push(output_string)

	# Check if WAR
	if current_high_card_players.length > 1
		return war(round_results,current_high_card_players,true)
	else
		return winner
	end
end

# Play a round
def play_round(players)
	# Play and check for a winner
	round_results = []
	winner = war(round_results, players, false)

	# Winner gets cards
	while GameState::DATA[:cards_in_play].length > 0
		random_index = rand(0...GameState::DATA[:cards_in_play].length)
		card = GameState::DATA[:cards_in_play].delete_at(random_index)
		winner[:player_cards].push(card)
	end

	# Print Results
	round_results.each do |rnd_rst|
		puts rnd_rst
	end
	
	# Current Deck Size
	deck_count = "Deck Count - "
	players.each do |plyr|
		deck_count += "P#{plyr[:player_id]}:#{plyr[:player_cards].length} "
	end
	puts deck_count
	return winner
end

# Game is now running
def run_game
	puts "~~~~~WAR CARD GAME~~~~~"
	puts "How many players (2-4):"
	player_count = gets.chomp.to_i
	while player_count != 2 && player_count != 4
		puts "How many players (NOTE Only 2 or 4 players are accepted):"
		player_count = gets.chomp.to_i
	end
	game_setup(player_count)
	puts "Start game:"
	$round_number = 1;
	game_over = false;

	while !game_over
		puts "(Press enter to play a round)"
		gets
		play_round(GameState::DATA[:players])
		$round_number += 1

		empty_decks = 0
		GameState::DATA[:players].each do |plyr|
			if plyr[:player_cards].length < 1
				empty_decks += 1
			end
		end

		if empty_decks == player_count-1
			game_over = true
		end
	end
end

run_game()