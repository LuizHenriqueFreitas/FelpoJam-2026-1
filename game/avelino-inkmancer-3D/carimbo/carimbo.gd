extends Area3D
class_name Carimbo

enum Rarity { COMMON, UNCOMMON, RARE }
enum Type { MELEE, RANGED, SIEGE }

var extra_attributes_selection: Dictionary = { "damage": "0", "health": "0", "move_speed": "0"}
var rarity: Rarity
var type: Type
var svelted: bool = false
var number_of_extra_attributes: int

func _ready() -> void:
	var random: int = randi_range(0, 18)
	if random <= 10:
			rarity = Rarity.COMMON
			number_of_extra_attributes = 3
	elif random > 10 && random < 15:
			rarity = Rarity.UNCOMMON
			number_of_extra_attributes = 6
	else:
			rarity = Rarity.RARE
			number_of_extra_attributes = 9

func svelt(_type: Type, damage: int, health: int, move_speed: int):
	type = _type
	extra_attributes_selection.damage = damage
	extra_attributes_selection.health = health
	extra_attributes_selection.damage = move_speed
	svelted = true
	
func _on_body_entered(body: BaseUnit):
	if body.is_in_group("player"):
		print("peguei")
	
