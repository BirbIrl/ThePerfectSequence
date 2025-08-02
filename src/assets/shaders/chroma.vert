uniform float elapsed;
uniform bool alphaStuff;

vec2 radialDistortion(vec2 coord, float dist) {
    vec2 cc = coord - 0.5;
    float distFactor = smoothstep(0.0, 0.5, length(cc));
    dist = distFactor * (dot(cc, cc) * dist + cos(elapsed * .3) * .005);
    return (coord + cc * (1.0 + dist) * dist);
}

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
    vec2 tcr = radialDistortion(tc, .24 / 2.) + vec2(.0018, 0);
    vec2 tcg = radialDistortion(tc, .20 / 2.);
    vec2 tcb = radialDistortion(tc, .18 / 2.) - vec2(.0018, 0);

    vec4 res = vec4(Texel(tex, tcr).r, Texel(tex, tcg).g, Texel(tex, tcb).b, 1);

    if (alphaStuff) {
        return Texel(tex, radialDistortion(tc, .24 / 2.));
    } else {
        res.rgb += vec3(-cos(tcg.y * 64. * 3.142 * 2.) * 0.015, -sin(tcg.x * 64. * 3.142 * 2.) * 0.015, 0);
        return res;
    }
}
