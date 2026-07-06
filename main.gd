extends Control

var player = {
	"gold": 50,
	"castle_hp": 100,
	"soldiers": 0,
	"archers": 0,
	"catapults": 0,
	"mines": 0
}

var enemy = {
	"gold": 50,
	"castle_hp": 100,
	"soldiers": 0,
	"archers": 0,
	"catapults": 0,
	"mines": 0
}

var attacked_this_turn = false

func _ready():
	$MarginContainer/VBoxContainer/TargetOption.clear()
	$MarginContainer/VBoxContainer/TargetOption.add_item("Soldiers")
	$MarginContainer/VBoxContainer/TargetOption.add_item("Archers")
	$MarginContainer/VBoxContainer/TargetOption.add_item("Catapults")
	$MarginContainer/VBoxContainer/TargetOption.add_item("Castle")
	log_message(
	"[b]GAME START[/b]\n" +
	"Recruit your army.\n" +
	"Destroy the enemy castle."
)

	update_ui()

func log_message(message):

	$MarginContainer/VBoxContainer/LogLabel.clear()
	$MarginContainer/VBoxContainer/LogLabel.append_text(message + "\n")
	$MarginContainer/VBoxContainer/LogLabel.scroll_to_line(999)

func update_ui():
	$MarginContainer/VBoxContainer/GoldLabel.text = "Gold: " + str(player["gold"])
	$MarginContainer/VBoxContainer/CastleLabel.text = "Castle HP: " + str(player["castle_hp"])
	$MarginContainer/VBoxContainer/SoldierLabel.text = "Soldiers: " + str(player["soldiers"])
	$MarginContainer/VBoxContainer/ArcherLabel.text = "Archers: " + str(player["archers"])
	$MarginContainer/VBoxContainer/CatapultLabel.text = "Catapults: " + str(player["catapults"])
	$MarginContainer/VBoxContainer/MineLabel.text = "Mines: " + str(player["mines"])

	$MarginContainer/VBoxContainer/EnemyGoldLabel.text = "Gold: " + str(enemy["gold"])
	$MarginContainer/VBoxContainer/EnemyCastleLabel.text = "Castle HP: " + str(enemy["castle_hp"])
	$MarginContainer/VBoxContainer/EnemySoldierLabel.text = "Soldiers: " + str(enemy["soldiers"])
	$MarginContainer/VBoxContainer/EnemyArcherLabel.text = "Archers: " + str(enemy["archers"])
	$MarginContainer/VBoxContainer/EnemyCatapultLabel.text = "Catapults: " + str(enemy["catapults"])
	$MarginContainer/VBoxContainer/EnemyMineLabel.text = "Mines: " + str(enemy["mines"])



func recruit_soldier(target):
	if target["gold"] >= 10:
		target["gold"] -= 10
		target["soldiers"] += 1

func recruit_archer(target):
	if target["gold"] >= 15:
		target["gold"] -= 15
		target["archers"] += 1

func recruit_catapult(target):
	if target["gold"] >= 30:
		target["gold"] -= 30
		target["catapults"] += 1

func build_mine(target):
	if target["gold"] >= 50:
		target["gold"] -= 50
		target["mines"] += 1


func _on_recruit_soldier_button_pressed() -> void:
	recruit_soldier(player)
	update_ui()


func _on_recruit_archer_button_pressed() -> void:
	recruit_archer(player)
	update_ui()


func _on_recruit_catapult_button_pressed() -> void:
	recruit_catapult(player)
	update_ui()

func _on_build_mine_button_pressed() -> void:
	build_mine(player)
	update_ui()

func enemy_turn():

	end_turn(enemy)

	if enemy["gold"] >= 50 and enemy["mines"] < 2:
		build_mine(enemy)

	elif enemy["soldiers"] < 5 and enemy["gold"] >= 10:
		recruit_soldier(enemy)

	elif enemy["archers"] < 3 and enemy["gold"] >= 15:
		recruit_archer(enemy)

	elif enemy["catapults"] < 3 and enemy["gold"] >= 30:
		recruit_catapult(enemy)

	elif enemy["gold"] >= 10:
		recruit_soldier(enemy)

func _on_end_turn_button_pressed() -> void:
	end_turn(player)
	enemy_turn()

	attacked_this_turn = false

	update_ui()

func end_turn(target):
	target["gold"] += 20
	target["gold"] += target["mines"] * 10

func attack_soldiers():

	if attacked_this_turn:
		return

	attacked_this_turn = true

	var player_damage = player["soldiers"] * UNIT_STATS["soldiers"]["dmg"]
	var enemy_damage = enemy["soldiers"] * UNIT_STATS["soldiers"]["dmg"] * 0.8

	var enemy_killed = min(enemy["soldiers"], units_killed(player_damage, "soldiers"))
	var player_killed = min(player["soldiers"], units_killed(enemy_damage, "soldiers"))

	enemy["soldiers"] -= enemy_killed
	player["soldiers"] -= player_killed

	log_message(
		"[b]⚔ SOLDIER BATTLE[/b]\n\n" +
		"Enemy lost " + str(enemy_killed) + " Soldiers.\n" +
		"You lost " + str(player_killed) + " Soldiers."
	)

	update_ui()

const UNIT_STATS = {
	"soldiers": {
		"hp": 10,
		"dmg": 5
	},
	"archers": {
		"hp": 10,
		"dmg": 3
	},
	"catapults": {
		"hp": 10,
		"dmg": 10
	}
}

func units_killed(damage, unit_type):
	return int(damage / UNIT_STATS[unit_type]["hp"])

func attack_archers():

	if attacked_this_turn:
		return

	attacked_this_turn = true

	var player_damage = (
		player["soldiers"] * UNIT_STATS["soldiers"]["dmg"] +
		player["archers"] * UNIT_STATS["archers"]["dmg"]
	)

	var enemy_damage = (
		enemy["soldiers"] * UNIT_STATS["soldiers"]["dmg"] +
		enemy["archers"] * UNIT_STATS["archers"]["dmg"]
	) * 0.8

	var enemy_killed = min(enemy["archers"], units_killed(player_damage, "archers"))
	var player_killed = min(player["archers"], units_killed(enemy_damage, "archers"))

	enemy["archers"] -= enemy_killed
	player["archers"] -= player_killed

	log_message(
		"[b]🏹 ARCHER BATTLE[/b]\n\n" +
		"Enemy lost " + str(enemy_killed) + " Archers.\n" +
		"You lost " + str(player_killed) + " Archers."
	)

	update_ui()

func attack_catapults():

	if attacked_this_turn:
		return

	attacked_this_turn = true

	var player_damage = player["soldiers"] * 5

	var enemy_killed = min(enemy["catapults"], int(player_damage / 10))

	enemy["catapults"] = max(0, enemy["catapults"] - enemy_killed)

	log_message(
		"[b]🪨 CATAPULT RAID[/b]\n\n" +
		"Enemy lost " + str(enemy_killed) + " Catapults."
	)

	update_ui()


func attack_castle():

	if attacked_this_turn:
		return

	attacked_this_turn = true

	var damage = player["catapults"] * 10

	enemy["castle_hp"] = max(0, enemy["castle_hp"] - damage)

	log_message(
		"[b]🏰 CASTLE ATTACK[/b]\n\n" +
		"Enemy Castle took " + str(damage) + " damage.\n" +
		"Castle HP: " + str(enemy["castle_hp"])
	)

	update_ui()

func attack(target_name):

	match target_name:

		"Soldiers":
			attack_soldiers()

		"Archers":
			attack_archers()

		"Catapults":
			attack_catapults()

		"Castle":
			attack_castle()

func _on_attack_button_pressed() -> void:

	var target = $MarginContainer/VBoxContainer/TargetOption.get_item_text(
		$MarginContainer/VBoxContainer/TargetOption.selected
	)

	attack(target)
	
