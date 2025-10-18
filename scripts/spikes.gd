extends Node2D

var player: CharacterBody2D = null

func _process(delta: float) -> void:
	if player:
		player.hit(1)  # Solo pega si el player sigue dentro
		player = null


func _on_hitbox_body_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		player = body  # Guardamos al player que está dentro


func _on_hitbox_body_exited(body: Node2D) -> void:
	if player == body:
		player = null  # Lo borramos al salir
