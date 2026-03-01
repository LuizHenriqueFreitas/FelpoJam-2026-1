extends Node3D

const BOSS_SCENE := preload("res://unit/boss/boss.tscn")

@onready var hud = $HUD
@onready var player: Node3D = $Player
@onready var timer_label: Label = $GameTimerLayer/TimerLabel

const PAUSE_MENU = preload("res://menus/pausemenu.tscn")
var pause_menu_aberto := false

@export var cleanup_interval: float = 1.0
@export var cleanup_min_distance_from_player: float = 128.0
@export var cleanup_min_displacement: float = 0.35
@export var cleanup_stuck_time_required: float = 3.0
@export var countdown_start_minutes: int = 10
@export var boss_spawn_min_distance: float = 64.0
@export var boss_spawn_max_distance: float = 128.0

var _cleanup_timer: Timer
var _enemy_motion_tracker: Dictionary = {}
var _remaining_time: float = 0.0
var _boss_spawned: bool = false


func _ready() -> void:
	_setup_enemy_cleanup()
	_remaining_time = float(max(countdown_start_minutes, 0) * 60)
	if timer_label != null:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_update_timer_label()


func _process(delta: float) -> void:
	if _remaining_time > 0.0:
		_remaining_time = max(_remaining_time - delta, 0.0)

	if timer_label != null and _remaining_time <= 0.0:
		timer_label.add_theme_color_override("font_color", Color(1, 0, 0, 1))
		if not _boss_spawned:
			_spawn_boss_from_random_spawner_in_range()

	_update_timer_label()


func _update_timer_label() -> void:
	if timer_label == null:
		return

	var total_seconds: int = int(ceil(_remaining_time))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _spawn_boss_from_random_spawner_in_range() -> void:
	var _player := get_tree().get_first_node_in_group("player") as Node3D
	if _player == null:
		return

	var _spawners := get_tree().get_nodes_in_group("spawner")
	if _spawners.is_empty():
		return

	var valid_spawners: Array[Node3D] = []
	for spawner in _spawners:
		if not (spawner is Node3D):
			continue

		var dist := (spawner as Node3D).global_position.distance_to(_player.global_position)
		if dist >= boss_spawn_min_distance and dist <= boss_spawn_max_distance:
			valid_spawners.append(spawner)

	if valid_spawners.is_empty():
		return

	var chosen_spawner = valid_spawners.pick_random()
	var boss := BOSS_SCENE.instantiate() as Node3D
	if boss == null:
		return

	get_tree().current_scene.add_child(boss)
	boss.global_position = chosen_spawner.global_position
	_boss_spawned = true


func _setup_enemy_cleanup() -> void:
	_cleanup_timer = Timer.new()
	_cleanup_timer.wait_time = max(cleanup_interval, 0.1)
	_cleanup_timer.timeout.connect(_cleanup_far_stuck_enemies)
	_cleanup_timer.autostart = true
	add_child(_cleanup_timer)


func _unhandled_input(event):
	if event.is_action_pressed("pause") and not pause_menu_aberto:
		_abrir_pause()


func _abrir_pause():
	pause_menu_aberto = true
	var menu = PAUSE_MENU.instantiate()
	# Quando o menu for removido, marca como fechado
	menu.tree_exited.connect(func(): pause_menu_aberto = false)
	add_child(menu)


func _cleanup_far_stuck_enemies() -> void:
	if player == null or not is_instance_valid(player):
		player = get_node_or_null("Player")
		if player == null:
			player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	var active_enemy_ids: Dictionary = {}
	var units := get_tree().get_nodes_in_group("base_unit")

	for unit in units:
		if not (unit is BaseUnit):
			continue

		if unit.faction != BaseUnit.Faction.ENEMY:
			continue

		if unit.state == BaseUnit.UnitState.DEAD:
			continue

		var enemy := unit as BaseUnit
		var enemy_id := enemy.get_instance_id()
		active_enemy_ids[enemy_id] = true

		var distance_to_player := enemy.global_position.distance_to(player.global_position)
		if distance_to_player <= cleanup_min_distance_from_player:
			_enemy_motion_tracker.erase(enemy_id)
			continue

		var tracker: Dictionary = _enemy_motion_tracker.get(enemy_id, {
			"last_position": enemy.global_position,
			"stuck_time": 0.0
		})

		var last_position: Vector3 = tracker["last_position"]
		var displacement := enemy.global_position.distance_to(last_position)

		if displacement <= cleanup_min_displacement:
			tracker["stuck_time"] += _cleanup_timer.wait_time
		else:
			tracker["stuck_time"] = 0.0

		tracker["last_position"] = enemy.global_position
		_enemy_motion_tracker[enemy_id] = tracker

		if tracker["stuck_time"] >= cleanup_stuck_time_required:
			_enemy_motion_tracker.erase(enemy_id)
			_despawn_enemy(enemy)

	for tracked_enemy_id in _enemy_motion_tracker.keys():
		if not active_enemy_ids.has(tracked_enemy_id):
			_enemy_motion_tracker.erase(tracked_enemy_id)


func _despawn_enemy(enemy: BaseUnit) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return

	if enemy.health_bar_instance != null and is_instance_valid(enemy.health_bar_instance):
		enemy.health_bar_instance.queue_free()

	enemy.queue_free()
	

	
