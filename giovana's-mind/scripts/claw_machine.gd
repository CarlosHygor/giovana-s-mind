extends Area2D

# --- Arraste as cenas das pelúcias aqui ---
@export var heal_plushie_scene: PackedScene
@export var damage_plushie_scene: PackedScene
@export var speed_plushie_scene: PackedScene
@export var cooldown_plushie_scene: PackedScene

# --- Variáveis de Controle ---
@export var cooldown_time: float = 10.0
var can_use: bool = true
var player_in_area: Node2D = null

# --- Referências dos Nós ---
@onready var anim_sprite: AnimatedSprite2D = $Sprite2D
@onready var drop_heal_pos: Marker2D = $DropLocationHeal
@onready var drop_buff_pos: Marker2D = $DropLocationBuff


func _ready():
	# Garante que a máquina comece na animação "default"
	anim_sprite.play("inicio")

# Conecte os sinais "body_entered" e "body_exited" a estas funções
func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body
		# (Opcional: mostrar um balão "Aperte E")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = null
		# (Opcional: esconder o balão "Aperte E")


# Checa a tecla de interação
func _physics_process(delta):
	# Checa a cada frame se o player está na área e apertou o botão
	if player_in_area and can_use and Input.is_action_just_pressed("interact"):
		usar_maquina()


func usar_maquina():
	# 1. Trava a máquina (antes da animação)
	can_use = false
	
	# 2. Toca a animação de interação
	anim_sprite.play("interact")
	
	# 3. ESPERA a animação terminar
	await anim_sprite.animation_finished
	
	# --- SÓ EXECUTA DAQUI PARA BAIXO QUANDO A ANIMAÇÃO ACABAR ---

	# 4. Dropa a Cura (no local 1)
	var heal_plushie = heal_plushie_scene.instantiate()
	heal_plushie.global_position = drop_heal_pos.global_position
	get_parent().add_child(heal_plushie)

	# 5. Dropa o Buff Aleatório (no local 2)
	var buff_list = [damage_plushie_scene, speed_plushie_scene, cooldown_plushie_scene]
	var random_buff_scene = buff_list.pick_random() # Sorteia um
	
	var buff_plushie = random_buff_scene.instantiate()
	buff_plushie.global_position = drop_buff_pos.global_position
	get_parent().add_child(buff_plushie)
	
	# 6. Volta para a animação "default"
	anim_sprite.play("default")
	
	# 7. Inicia o cooldown
	await get_tree().create_timer(cooldown_time).timeout
	can_use = true
