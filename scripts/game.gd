extends Node2D

@onready var game_over_scene: Control = $CanvasLayer/GameOver
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var hidden_tiles: Array[Vector2i] = []  # guarda las celdas borradas
@onready var pig_throwing_bomb_3: Node2D = $Enemies/pig_throwing_bomb3


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("Player")
	var door_out = get_node("door_out")
	
	player.visible = true
	door_out.open_door()
	await player.door_out()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over():
	print("gamover")
	game_over_scene.visibility_layer = true


func _on_hidden_zone_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	hidden_tiles.clear()

	for cell in tile_map_layer.get_used_cells():
		var source_id = tile_map_layer.get_cell_source_id(cell)
		if source_id == 2:  # Terrain2.png
			hidden_tiles.append(cell)
			tile_map_layer.set_cell(cell, -1)

#No funciona
func _on_hidden_zone_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return

	for cell in hidden_tiles:
		tile_map_layer.set_cell(cell, 2, Vector2i(0, 0))
