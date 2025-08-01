// yoinked and modified version of https://gist.github.com/mebens/4218802
extern int samples = 30; // pixels per axis; higher = bigger glow, worse performance
extern float quality = 10; // lower = smaller glow, better quality
extern float alpha = 1; // % of shader applied

vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
    vec4 source = Texel(tex, tc);
    vec4 sum = vec4(0);
    int diff = (samples - 1) / 2;
    vec2 sizeFactor = vec2(1) / love_ScreenSize.xy * quality;

    for (int x = -diff; x <= diff; x++)
    {
        for (int y = -diff; y <= diff; y++)
        {
            vec2 offset = vec2(x, y) * sizeFactor;
            sum += Texel(tex, tc + offset);
        }
    }
    vec4 result = (sum / (samples * samples));

    return mix(source, result + source, alpha) * colour;
}
