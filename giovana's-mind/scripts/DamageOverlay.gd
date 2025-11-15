extends ColorRect

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	visible = false

func play_damage_effect():
	if anim_player.is_playing():
		anim_player.stop
	visible = true
	anim_player.play("damage_fade")

func on_animation_player_finished(anim_name:String):
	if anim_name == "damage_fade":
		visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
