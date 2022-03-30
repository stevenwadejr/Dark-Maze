extends Area2D

class_name SecretPassageway

var corresponding_passageway : SecretPassageway
var incoming = false

signal player_entered(corresponding_passageway, origin_passageway)

func _on_SecretPassageway_area_entered(area):
	if area.get_name() == "PlayerCore" && incoming == false:
		emit_signal("player_entered", get_corresponding_passageway(), self)

func set_corresponding_passageway(passageway : SecretPassageway):
	corresponding_passageway = passageway

func get_corresponding_passageway() -> SecretPassageway :
	return corresponding_passageway


func _on_SecretPassageway_area_exited(area):
	if area.get_name() == "PlayerCore":
		incoming = false

func accept_incoming():
	incoming = true
