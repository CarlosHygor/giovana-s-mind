extends CharacterBody2D

# --- VARIÁVEIS EXPORTÁVEIS (Ajuste no Inspector) ---
@export var vida_maxima: int = 10 
@export var velocidade: float = 100.0 
@export var dano_ataque: int = 5            
@export var alcance_ataque: float = 30.0        
@export var tempo_recarga_ataque: float = 1.0 

# --- NOMES DAS ANIMAÇÕES (Ajuste no Inspector) ---
@export_group("Animações")
@export var anim_intro: String = "intro" 
@export var anim_ataque: String = "ataque" 
@export var anim_morte: String = "morte" 
@export var anim_andar_cima: String = "andar_cima"
@export var anim_andar_baixo: String = "andar_baixo"
@export var anim_andar_esquerda: String = "andar_esquerda"
@export var anim_andar_direita: String = "andar_direita"

# --- REFERÊNCIAS INTERNAS (Nós da Cena) ---
# Lembre-se de renomear os nós na cena para bater com os nomes abaixo!
@onready var sprite_animado: AnimatedSprite2D = $SpriteAnimado
@onready var timer_recarga_ataque: Timer = $TimerRecargaAtaque
@onready var jogador: CharacterBody2D = null

# --- ESTADO DO INIMIGO ---
var vida_atual: int = vida_maxima
var esta_perseguindo: bool = false
var esta_atacando: bool = false 
var esta_morto: bool = false


func _ready():
	# 1. Encontra o Jogador (deve estar no grupo "player")
	jogador = get_tree().get_first_node_in_group("player") 
	
	# 2. Configura o Timer de Recarga
	timer_recarga_ataque.wait_time = tempo_recarga_ataque
	timer_recarga_ataque.timeout.connect(ao_terminar_recarga_ataque)

	# 3. Inicializa HP
	vida_atual = vida_maxima

	# 4. Inicia a animação de introdução
	sprite_animado.play(anim_intro)
	sprite_animado.animation_finished.connect(ao_terminar_intro)

	# 5. Inicia no estado Parado
	esta_perseguindo = false


func _physics_process(delta):
	# Se morto, atacando ou sem Jogador, para o movimento
	if esta_morto or esta_atacando or not is_instance_valid(jogador):
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	# 1. Calcula a distância e direção até o jogador
	var direcao_vetor: Vector2 = jogador.global_position - global_position
	var distancia_do_jogador: float = direcao_vetor.length()
	var direcao_normalizada: Vector2 = direcao_vetor.normalized()

	# 2. Lógica de Ataque ou Perseguição
	if distancia_do_jogador <= alcance_ataque and timer_recarga_ataque.is_stopped():
		# Está no alcance E o cooldown acabou -> Ataca
		atacar()
	else:
		# Fora do alcance ou em cooldown -> Persegue
		perseguir_jogador(direcao_normalizada)
	
	# 3. Aplica o movimento
	move_and_slide()


func perseguir_jogador(direcao: Vector2):
	if not esta_perseguindo:
		# Garante que só persegue após a intro
		return
		
	# Define a velocidade de perseguição
	velocity = direcao * velocidade
	
	# --- NOVA LÓGICA: ESCOLHE A ANIMAÇÃO DE 4 DIREÇÕES ---
	# Verifica qual eixo (X ou Y) tem o movimento mais forte
	if abs(direcao.x) > abs(direcao.y):
		# Movimento horizontal é dominante
		if direcao.x > 0:
			sprite_animado.play(anim_andar_direita)
		else:
			sprite_animado.play(anim_andar_esquerda)
	else:
		# Movimento vertical é dominante
		if direcao.y > 0:
			sprite_animado.play(anim_andar_baixo)
		else:
			sprite_animado.play(anim_andar_cima)


func atacar():
	# 1. Entra no estado de ataque
	esta_atacando = true
	
	# 2. Para o movimento imediatamente
	velocity = Vector2.ZERO
	
	# 3. Toca a animação de ataque
	sprite_animado.play(anim_ataque)
	
	# 4. Chama a função de dano
	aplicar_dano_no_jogador() 
	
	# 5. Inicia o cooldown
	timer_recarga_ataque.start()


func aplicar_dano_no_jogador():
	# Esta função simula o dano instantâneo.
	if is_instance_valid(jogador):
		# NOTA: O jogador precisa ter uma função "receber_dano(dano)"
		# jogador.receber_dano(dano_ataque)
		print("ATACOU O JOGADOR!") # Placeholder para teste
		pass 


# Função pública para o jogador ou projéteis chamarem
func receber_dano(quantidade_dano: int):
	if esta_morto:
		return

	vida_atual -= quantidade_dano
	
	if vida_atual <= 0:
		morrer()


func morrer():
	if esta_morto:
		return
		
	esta_morto = true
	esta_perseguindo = false 
	esta_atacando = false
	
	# Para de calcular a física e colisão
	set_physics_process(false)
	
	sprite_animado.play(anim_morte)
	# Conecta o sinal para remover o inimigo quando a animação de morte terminar


# --- SINAIS (Callbacks) ---

func ao_terminar_intro():
	# Chamado quando a animação de intro termina
	sprite_animado.animation_finished.disconnect(ao_terminar_intro)
	esta_perseguindo = true


# Conecte o sinal "animation_finished" do nó SpriteAnimado a esta função
func _on_sprite_animado_animation_finished():
	# Chamado após QUALQUER animação terminar
	if sprite_animado.animation == anim_ataque:
		# Se a animação de ataque terminou, voltamos ao estado "normal"
		esta_atacando = false
		
	#Verificamos se a animação de morte terminou
	elif sprite_animado.animation == anim_morte:
		# Remove o inimigo da cena
		queue_free()

func ao_terminar_recarga_ataque():
	# Chamado quando o Timer de Cooldown termina
	# Apenas permite que a lógica de ataque em _physics_process funcione de novo
	pass
