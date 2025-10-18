extends Node2D

@onready var game_over_scene: Control = $CanvasLayer/GameOver
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


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
	print(tile_map_layer.tile_set)

func _on_hidden_zone_body_exited(body: Node2D) -> void:
	if tile_map_layer.z_index == 7:
		tile_map_layer.visible = true
