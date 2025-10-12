extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var _player_near := false  # para saber si el jugador está cerca
@export var wait_time: float = 3.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.play("Idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _player_near and Input.is_action_just_pressed("jump"):
		abrir_puerta()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = true
		body.door_near = true
	
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = false
		body.door_near = false
		
		
func abrir_puerta():
	if animated_sprite.animation == "Opening":
		return  
		
	animated_sprite.play("Opening")
	await animated_sprite.animation_finished
	await get_tree().create_timer(wait_time).timeout		
	
	animated_sprite.play("Closing")
	print("Fin")
