shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.01, 0.005); 

void fragment() {
    // Pega as coordenadas móveis (igual a antes)
    vec2 moving_uv = UV + (TIME * scroll_speed);
    
    // Pega a cor da textura (igual a antes)
    vec4 texture_color = texture(TEXTURE, moving_uv);
    
    // --- MUDANÇA AQUI ---
    // Em vez de sobrescrever, nós MULTIPLICAMOS a cor da textura
    // pela cor do 'Modulate' (que já está na variável 'COLOR').
    COLOR = texture_color * COLOR;
}