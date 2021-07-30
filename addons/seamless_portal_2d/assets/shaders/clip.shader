shader_type canvas_item;

uniform vec2 clip_center = vec2(0.0, 0.0);
uniform vec2 clip_normal = vec2(1.0, 0.0);
uniform float clip_offset = 0.0;
uniform mat4 global_transform;

varying vec2 world_position;

void vertex()
{
	world_position = (global_transform * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment()
{
    vec2 adjusted_center = clip_center + clip_normal * clip_offset;
    vec2 offset_from_clip_center = adjusted_center - world_position;
	
    if (dot(offset_from_clip_center, clip_normal) < 0.0)
        discard;
}