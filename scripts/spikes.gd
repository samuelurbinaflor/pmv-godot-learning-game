extends Node2D
@onready var hitbox: Area2D = $hitbox

var player: CharacterBody2D = null
var can_hit := true
var cooldown_time := 0.5  # medio segundo de cooldown
var cooldown_timer := 0.0

func _process(delta: float) -> void:
	if not player:
		return

	if not hitbox.get_overlapping_bodies().has(player):
		player = null
		return

	if can_hit:
		player.hit(1)
		can_hit = false
		cooldown_timer = cooldown_time
	else:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_hit = true
			
func _on_hitbox_body_entered(body: Node2D) -> void:
	if "player" in body.get_groups():
		player = body
