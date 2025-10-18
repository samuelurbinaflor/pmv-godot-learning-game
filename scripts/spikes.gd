extends Node2D

var is_inside := false
var player: CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_inside:
		player.hit(1)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		is_inside = true
		player = body
		body.hit(1)


func _on_hitbox_body_exited(body: Node2D) -> void:
	if "player" in body.get_groups():
		is_inside = false
		player = null
		
