class_name WesterosThroneOfBladesCard
extends WesterosCard

func resolve(server: GameServer) -> void:
	var it_holder := server._get_token_holder_iron_throne()
	if it_holder == null:
		server._advance_westeros_phase()
		return
	server._choice_queue.clear()
	server._after_choices = func(): server._advance_westeros_phase()
	var choice := ThroneOfBladesChoice.new()
	choice.player_id = it_holder.id
	server._choice_queue.append(choice)
	server._process_next_choice()
