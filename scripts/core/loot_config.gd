extends Resource
class_name LootConfig

@export var default_bonus: int = 0
@export var group_bonus: Dictionary = {}

func get_bonus_for(node: Node) -> int:
    if node == null:
        return 0
    for group_name in group_bonus.keys():
        var value = group_bonus[group_name]
        if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
            continue
        if node.is_in_group(str(group_name)):
            return int(value)
    return default_bonus


