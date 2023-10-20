extends Node2D

@onready var tilemap : TileMap = $TileMap

var path = []
var block_padding_x : int = 2
var starting_position : Vector2 = Vector2(0, 0)

func _ready():
	generate_map()
#	tilemap.tile_set.terrain_sets
	
	
func generate_map():
	path = []
	for k in range(100):
		generate_block()
	tilemap.set_cells_terrain_connect(0, path, 0, 0)
	
func generate_block():
	var weight = randi() % 10

	if (weight <= 5):
		rectangle()
	else:
		shape()
	
func rectangle():
	var width = randi() % 10 + 1
	var height = randi() % 3 + 1
	for w in range(width):
		for h in range(height):
			var coords = Vector2i(starting_position.x + w, starting_position.y + h)
			path.append(coords)
			
	starting_position.x = starting_position.x + width + block_padding_x
	
func shape():
	var width = 1
	var height = 3
	for w in range(width):
		for h in range(height):
			var coords = Vector2i(starting_position.x + w, starting_position.y + h)
			path.append(coords)
	
	starting_position.x = starting_position.x + width + block_padding_x
