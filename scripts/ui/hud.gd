extends CanvasLayer

var _player: Node = null

func _process(_delta: float) -> void:
    if _player == null:
        _player = _find_player()
    _update_hp()
    _update_counts()

func _update_hp() -> void:
    if _player != null and "hp" in _player and "max_hp" in _player:
        var label := get_node_or_null("HP") as Label
        if label:
            label.text = "HP: %d/%d" % [_player.hp, _player.max_hp]

func _update_counts() -> void:
    var prey_count := get_tree().get_nodes_in_group("prey").size()
    var pred_count := get_tree().get_nodes_in_group("predator").size()
    var biomass := 0
    if _player != null and "biomass" in _player:
        biomass = _player.biomass
    var label := get_node_or_null("Counts") as Label
    if label:
        label.text = "Biomass: %d  Prey: %d  Pred: %d" % [biomass, prey_count, pred_count]

func _find_player() -> Node:
    var root := get_tree().current_scene
    if root == null:
        return null
    return root.find_child("Player", true, false)
