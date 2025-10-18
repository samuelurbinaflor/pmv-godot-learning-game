extends Node2D
@onready var hitbox: Area2D = $hitbox

var player: CharacterBody2D = null

func _process(delta: float) -> void:
	if player:
		if not hitbox.get_overlapping_bodies().has(player): #body exited
			player = null
		else:
			player.hit(1)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		player = body  

#El body exited no funciona
