extends Control

const MAX_HEALTH := 3
@onready var hearts := $HeartsContainer.get_children()

func update_hearts(current_health: int):
	for i in range(MAX_HEALTH):
		var heart = hearts[i]

		if i < current_health:
			if heart.animation == "hit":  # estaba vacío
				heart.play("up")          # animación de aparecer
				await heart.animation_finished
				heart.play("idle")        # se queda lleno
			else:
				heart.play("idle")        # ya estaba lleno

		else:
			if heart.animation != "hit":   # no estaba vacío
				heart.play("hit")          # animación de perder vida

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
