extends Area2D

# Vamos usar um Enum para definir o tipo de buff
enum BuffType { HEAL, SPEED, DAMAGE, COOLDOWN }

# Você poderá escolher isso no inspetor do Godot
@export var tipo_de_buff: BuffType = BuffType.HEAL

# Conecte o sinal "body_entered" da Area2D a esta função
func _on_body_entered(body):
	# 1. Verifica se foi o player que entrou
	if body.is_in_group("player"):
		
		# 2. Aplica o buff correto
		match tipo_de_buff:
			BuffType.HEAL:
				body.heal(4) # Cura 1 coração inteiro (4/4)
			BuffType.SPEED:
				body.aplicar_buff_velocidade(1.2) # 20% mais rápido
			BuffType.DAMAGE:
				body.aplicar_buff_dano(1) # +1 de dano
			BuffType.COOLDOWN:
				body.aplicar_buff_cooldown(0.8) # 20% mais rápido

		# 3. Some com a pelúcia
		queue_free()
