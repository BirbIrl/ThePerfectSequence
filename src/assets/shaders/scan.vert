//yoinked from moonshine
extern float phase;
vec4 effect(vec4 c, Image tex, vec2 tc, vec2 _) {
    float width = float(16);
    float thickness = float(1);
    float opacity = 0.15;
    vec3 color;
    number v = .5 * (sin(tc.y * 3.14159 / width * love_ScreenSize.y + phase * float(2)) + float(1.));
    c = Texel(tex, tc);
    //c.rgb = mix(color, c.rgb, mix(1, pow(v, thickness), opacity));
    c.rgb -= (color - c.rgb) * (pow(v, thickness) - 1.0) * opacity;
    return c;
}
