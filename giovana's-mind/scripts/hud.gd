extends Control

var player_node: Node2D = null

# 1. Referências para os nós de coração na cena
@onready var coracao_1: Sprite2D = $Coracao1
@onready var coracao_2: Sprite2D = $Coracao2
@onready var coracao_3: Sprite2D = $Coracao3

# 2. Pré-carregue suas 5 imagens aqui, NA ORDEM CORRETA
#    (Do 0/4 até o 4/4)
var heart_textures: Array[Texture2D] = [
	preload("res://recursos/sprites/hud/life-option2/heart4.png"), # Vazio (Índice 0)
	preload("res://recursos/sprites/hud/life-option2/heart3.png"), # 1/4 (Índice 1)
	preload("res://recursos/sprites/hud/life-option2/heart2.png"), # 1/2 (Índice 2)
	preload("res://recursos/sprites/hud/life-option2/heart1.png"), # 3/4 (Índice 3)
	preload("res://recursos/sprites/hud/life-option2/heart0.png")  # Cheio (Índice 4)
]

@onready var icone_arma: TextureRect = $WeaponDisplay/IconeArma

# Pré-carregue as imagens dos ursos (ARRUME OS CAMINHOS!)
var icon_azul = preload("res://recursos/assets/iconeUrsinhos/icone ursinho azul.png")
var icon_roxo = preload("res://recursos/assets/iconeUrsinhos/icone ursinho roxo.png")

# Cor para quando estiver em cooldown (Cinza Escuro)
const COR_COOLDOWN = Color(0.4, 0.4, 0.4, 1) # R, G, B, Alpha
const COR_NORMAL = Color(1, 1, 1, 1)         # Branco (Cor original)

func _ready() -> void:
	atualizar_vida_ui(12)
	
	await get_tree().create_timer(0.1).timeout
	player_node = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player_node:
		atualizar_icone_arma()
	
# 3. A mesma função de antes, que o Player pode chamar
func atualizar_vida_ui(current_health: int):
	
	# Coração 1 (HP 0-4)
	var estado_1 = clamp(current_health, 0, 4)
	# Pega a textura correspondente do array
	coracao_1.texture = heart_textures[estado_1]

	# Coração 2 (HP 5-8)
	var estado_2 = clamp(current_health - 4, 0, 4)
	coracao_2.texture = heart_textures[estado_2]
	
	# Coração 3 (HP 9-12)
	var estado_3 = clamp(current_health - 8, 0, 4)
	coracao_3.texture = heart_textures[estado_3]

func atualizar_icone_arma():
	# 1. Troca a imagem baseada no estado da arma
	if player_node.estado_arma == "azul":
		icone_arma.texture = icon_azul
	else:
		icone_arma.texture = icon_roxo
		
	# 2. Aplica o "Filtro Cinza" se estiver em cooldown
	# A variável 'can_swap_arma' é aquela que criamos no Player
	if player_node.can_swap_arma:
		icone_arma.modulate = COR_NORMAL
	else:
		icone_arma.modulate = COR_COOLDOWN
