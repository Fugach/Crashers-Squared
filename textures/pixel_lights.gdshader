shader_type canvas_item;

uniform float pixel_size = 4.0;

void fragment() {
    // Snap lighting and shadows to pixel grid.
    LIGHT_VERTEX.xy = floor(LIGHT_VERTEX.xy / pixel_size) * pixel_size;
    SHADOW_VERTEX = floor(SHADOW_VERTEX / pixel_size) * pixel_size;

    // Normal rendering.
    COLOR = texture(TEXTURE, UV);
}