uniform float opacity;

vec4 effect(vec4 c, Image tex, vec2 tc, vec2 _)
{
    vec4 color = vec4(0, 0, 0, 1);
    float radius = 0.9;
    float softness = 0.5;
    number aspect = love_ScreenSize.x / love_ScreenSize.y;
    aspect = max(aspect, 1.0 / aspect); // use different aspect when in portrait mode
    number v = 1.0 - smoothstep(radius, radius - softness,
                length((tc - vec2(0.5)) * aspect));
    return mix(Texel(tex, tc), color, v * opacity);
}
