extends CharacterBody2D

# --- VARIÁVEIS EXPORTÁVEIS (Ajuste no Inspector) ---
@export var vida_maxima: int = 10 
@export var velocidade: float = 100.0 
@export var dano_ataque: int = 5            
@export var tempo_recarga_ataque: float = 1.0 

@onready var som_morte: AudioStreamPlayer2D = $SomMorte

# --- NOMES DAS ANIMAÇÕES (Ajuste no Inspector) ---
@export_group("Animações Padrão")
@export var anim_intro: String = "intro"
@export var anim_morte: String = "morte" 
@export var anim_andar_cima: String = "andar_cima"
@export var anim_andar_baixo: String = "andar_baixo"
@export var anim_andar_esquerda: String = "andar_esquerda" # Usado para andar_direita com flip

@export_group("Animações de Ataque")
@export var anim_ataque_esquerda: String = "ataque_esquerda" # Usado para ataque_direita com flip
@export var anim_ataque_cima_left: String = "ataque_cima_left"
@export var anim_ataque_cima_right: String = "ataque_cima_right"
@export var anim_ataque_baixo_left: String = "ataque_baixo_left"
@export var anim_ataque_baixo_rigth: String = "ataque_baixo_rigth" # Mantive seu "rigth"


# --- REFERÊNCIAS INTERNAS (Nós da Cena) ---
# Lembre-se de renomear os nós na cena para bater com os nomes abaixo!
@onready var sprite_animado: AnimatedSprite2D = $SpriteAnimado
@onready var timer_recarga_ataque: Timer = $TimerRecargaAtaque
@onready var jogador: CharacterBody2D = null

var flash_material: ShaderMaterial

# --- ESTADO DO INIMIGO ---
var vida_atual: int = vida_maxima
var esta_perseguindo: bool = false
var esta_atacando: bool = false 
var esta_morto: bool = false
var jogador_na_area_ataque: bool = false
var proximo_ataque_alternado_sera_left: bool = true

@onready var som_ataque: AudioStreamPlayer2D = $SomAtaque

func _ready():
	# Aguarda um frame para garantir que o AnimatedSprite carregou o material da animação
	await get_tree().process_frame

	if sprite_animado.material is ShaderMaterial:
		sprite_animado.material = sprite_animado.material.duplicate()
	elif sprite_animado.material_override is ShaderMaterial:
		sprite_animado.material_override = sprite_animado.material_override.duplicate()
	else:
		print("⚠ Nenhum ShaderMaterial encontrado no inimigo:", self.name)
		
	flash_material = sprite_animado.material

		
		
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
		
	# 1. Calcula a direção (ainda precisamos dela para perseguir)
	var direcao_normalizada: Vector2 = (jogador.global_position - global_position).normalized()

	# 2. LÓGICA DE ATAQUE ATUALIZADA
	# Verifica se o jogador está na área E se o timer de recarga parou
	if jogador_na_area_ataque and timer_recarga_ataque.is_stopped():
		# Ataca! Passando a direção para a função
		atacar(direcao_normalizada) # <-- MUDANÇA AQUI
	else:
		# Se não, persegue o jogador
		perseguir_jogador(direcao_normalizada)
	
	# 3. Aplica o movimento
	move_and_slide()


func perseguir_jogador(direcao: Vector2):
	if not esta_perseguindo:
		# Garante que só persegue após a intro
		return
		
	# Define a velocidade de perseguição
	velocity = direcao * velocidade
	
	# Verifica qual eixo (X ou Y) tem o movimento mais forte
	if abs(direcao.x) > abs(direcao.y):
		# Movimento horizontal é dominante
		
		# Toca a animação de andar para a direita, não importa a direção
		sprite_animado.play(anim_andar_esquerda) 
		
		# Agora, decidimos se vamos flipar o sprite
		if direcao.x < 0:
			# Movendo para a direita: sem flip
			sprite_animado.flip_h = false 
		else:
			# Movendo para a esquerda: com flip
			sprite_animado.flip_h = true  
			
	else:
		# Movimento vertical é dominante
		# IMPORTANTE: Reseta o flip se estava andando para a esquerda antes
		sprite_animado.flip_h = false 
		
		if direcao.y > 0:
			sprite_animado.play(anim_andar_baixo)
		else:
			sprite_animado.play(anim_andar_cima)


func atacar(direcao: Vector2):
	som_ataque.play()
	# 1. Entra no estado de ataque
	esta_atacando = true
	
	# 2. Para o movimento imediatamente
	velocity = Vector2.ZERO
	
	# 3. LÓGICA DE ATAQUE DIRECIONAL
	var anim_name = ""
	
	# Converte o vetor de direção em um ângulo (em graus)
	# 0 = direita, 90 = baixo, 180/-180 = esquerda, -90 = cima
	var angulo = rad_to_deg(direcao.angle())
	
	if angulo > 45 and angulo < 135:
		# ----- ZONA: BAIXO -----
		
		# --- NOVA LÓGICA DE ALTERNÂNCIA ---
		if proximo_ataque_alternado_sera_left:
			anim_name = anim_ataque_baixo_left
			proximo_ataque_alternado_sera_left = false # O próximo será right
		else:
			anim_name = anim_ataque_baixo_rigth
			proximo_ataque_alternado_sera_left = true # O próximo será left
			
		sprite_animado.flip_h = false # Ataques de cima/baixo nunca usam flip
			
	elif angulo < -45 and angulo > -135:
		# ----- ZONA: CIMA -----
		
		# --- NOVA LÓGICA DE ALTERNÂNCIA ---
		if proximo_ataque_alternado_sera_left:
			anim_name = anim_ataque_cima_left
			proximo_ataque_alternado_sera_left = false # O próximo será right
		else:
			anim_name = anim_ataque_cima_right
			proximo_ataque_alternado_sera_left = true # O próximo será left
			
		sprite_animado.flip_h = false # Ataques de cima/baixo nunca usam flip
			
	else:
		# ----- ZONA: HORIZONTAL (LÓGICA ANTIGA MANTIDA) -----
		# Esta zona não alterna, apenas usa a direção
		anim_name = anim_ataque_esquerda # Animação base
		if direcao.x < 0:
			sprite_animado.flip_h = false # Atacando para a esquerda
		else:
			sprite_animado.flip_h = true # Atacando para a direita (flip)

	# 4. Toca a animação de ataque decidida
	sprite_animado.play(anim_name)
	
	# 5. Chama a função de dano
	aplicar_dano_no_jogador() 
	
	# 6. Inicia o cooldown
	timer_recarga_ataque.start()

func aplicar_dano_no_jogador():
	# Esta função aplica o dano no jogador.
	
	# Verifica se o jogador ainda existe na cena
	if is_instance_valid(jogador):
		
		# Chama a função "take_damage" DO JOGADOR,
		# passando o dano do inimigo (dano_ataque)
		jogador.take_damage(dano_ataque)
		print("dano")


# Função pública para o jogador ou projéteis chamarem
func receber_dano(quantidade_dano: int):
	if esta_morto:
		return
	
	vida_atual -= quantidade_dano
	
	piscar_vermelho()
	
	if vida_atual <= 0:
		$AreaHitbox/CollisionShape2D.disabled = true
		$CollisionShape2D.disabled = true
		$AreaHitbox/CollisionShape2D.disabled=true
		morrer()


func morrer():
	som_morte.play()
	if esta_morto:
		return
		
	esta_morto = true
	esta_perseguindo = false 
	esta_atacando = false
	
	# Para de calcular a física e colisão
	set_physics_process(false)
	
	sprite_animado.play(anim_morte)
	# Conecta o sinal para remover o inimigo quando a animação de morte terminar

func piscar_vermelho():
	var tween = create_tween()
	flash_material.set("shader_parameter/flash_strength", 1.0)
	tween.tween_property(flash_material, "shader_parameter/flash_strength", 0.0, 0.15)
	
# --- SINAIS (Callbacks) ---
func ao_terminar_intro():
	# Chamado quando a animação de intro termina
	sprite_animado.animation_finished.disconnect(ao_terminar_intro)
	esta_perseguindo = true


func _on_sprite_animado_animation_finished():
	# Chamado após QUALQUER animação terminar
	var anim_atual = sprite_animado.animation
	
	# MUDANÇA: Verifica se a animação que terminou é QUALQUER animação de ataque
	if anim_atual.begins_with("ataque_"):
		# Se a animação de ataque terminou, voltamos ao estado "normal"
		esta_atacando = false
		
	#Verificamos se a animação de morte terminou
	elif anim_atual == anim_morte:
		# Remove o inimigo da cena
		queue_free()

func ao_terminar_recarga_ataque():
	# Chamado quando o Timer de Cooldown termina
	# Apenas permite que a lógica de ataque em _physics_process funcione de novo
	pass


func _on_area_ataque_body_entered(body):
	# Chamado quando um corpo FÍSICO (como o Player) entra na área
	
	# Verifica se o corpo que entrou é o jogador (pelo grupo "player")
	if body.is_in_group("player"):
		jogador_na_area_ataque = true


func _on_area_ataque_body_exited(body):
	# Chamado quando um corpo FÍSICO (como o Player) sai da área
	
	if body.is_in_group("player"):
		jogador_na_area_ataque = false
