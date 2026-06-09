#pragma header

uniform sampler2D texture;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 color = texture2D(bitmap, uv);
    vec4 texColor = texture2D(texture, uv);

    if (color.a > 0.0)
    {
        color.rgb = texColor.rgb;
    }

    gl_FragColor = color;
}