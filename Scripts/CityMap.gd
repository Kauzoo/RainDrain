extends TileMap

@export var break_time = 0.6

var dmg_tile_src = 1

var damage = {}
var dmg_layer
var road_layer
var dmg_tiles = [
	Vector2i(4, 7),
	Vector2i(5, 7),
	Vector2i(6, 7),
	Vector2i(7, 5),
	Vector2i(7, 3)
]

func _ready():
	var layers_by_name = {}
	for i in range(0, self.get_layers_count()):
		layers_by_name[self.get_layer_name(i)] = i
	dmg_layer = layers_by_name["damage"]
	road_layer = layers_by_name["roads"]

func _process(delta):
	pass
	
func dmg_to_dmg_level(t):
	return floor(clamp(t, 0, break_time) / break_time * 5)

func _on_deal_damage(pos, delta):
	var tile_pos = self.local_to_map(pos)
	var tile_data = self.get_cell_tile_data(road_layer, tile_pos)
	if not tile_data.get_custom_data("is_road"):
		return

	var old_dmg = damage.get(tile_pos, 0.0)
	var new_dmg = old_dmg + delta
	damage[tile_pos] = new_dmg

	var dmg_level = dmg_to_dmg_level(new_dmg)
	if dmg_level > dmg_to_dmg_level(old_dmg):
		self.set_cell(
			dmg_layer,
			tile_pos,
			dmg_tile_src,
			dmg_tiles[dmg_level - 1], 0
		)
