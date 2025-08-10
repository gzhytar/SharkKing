extends Object

const LOOT_SCENE := preload("res://scenes/loot/LootPickup.tscn")
const LOOT_CONFIG := preload("res://data/loot_config.tres")

static func spawn_pickup(amount: int, position: Vector2, parent: Node) -> void:
	if amount <= 0:
		return
	if parent == null or not is_instance_valid(parent):
		return
	var pickup := LOOT_SCENE.instantiate()
	if pickup == null:
		return
	pickup.set("amount", amount)
	if pickup is Node2D:
		(pickup as Node2D).global_position = position
	parent.add_child(pickup)

static func spawn_pickup_with_bonus(base_amount: int, killed_node: Node, position: Vector2, parent: Node) -> void:
	var bonus := 0
	if LOOT_CONFIG != null:
		bonus = LOOT_CONFIG.get_bonus_for(killed_node)
	spawn_pickup(base_amount + bonus, position, parent)
