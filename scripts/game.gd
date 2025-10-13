extends Node2D

@onready var game_over_scene: Control = $CanvasLayer/GameOver


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
