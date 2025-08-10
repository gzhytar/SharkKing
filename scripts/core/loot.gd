extends Object

const LOOT_SCENE := preload("res://scenes/loot/LootPickup.tscn")

static func spawn_pickup(amount: int, position: Vector2, parent: Node) -> void:
    if amount <= 0:
        return
    if parent == null or not is_instance_valid(parent):
        return
    var pickup := LOOT_SCENE.instantiate()
    if pickup == null:
        return
    if pickup.has_variable("amount"):
        pickup.amount = amount
    else:
        pickup.set("amount", amount)
    if pickup is Node2D:
        (pickup as Node2D).global_position = position
    parent.add_child(pickup)


