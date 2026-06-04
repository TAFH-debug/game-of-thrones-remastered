extends Control


func set_data(player_data: PlayerData):
	$Container/Label.text = player_data.nickname
	$Container/ReadyLabel.visible = player_data.ready
