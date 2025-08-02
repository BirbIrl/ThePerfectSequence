// yoinked and modified version of https://gist.github.com/mebens/4218802

vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
    float samples = float(30);
    vec4 source = Texel(tex, tc);
    vec4 sum = vec4(0);
    float diff = (samples - float(1)) / float(2);
    vec2 sizeFactor = vec2(1) / love_ScreenSize.xy * float(10); //10 = quality

    for (float x = -diff; x <= diff; x++)
    {
        for (float y = -diff; y <= diff; y++)
        {
            vec2 offset = vec2(x, y) * sizeFactor;
            sum += Texel(tex, tc + offset);
        }
    }
    vec4 result = (sum / (samples * samples)); //30 = samples

    return mix(source, result + source, float(1)) * colour;
}
