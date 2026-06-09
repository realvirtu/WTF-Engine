#pragma header

uniform float time;
uniform float speed;
uniform float frequency;
uniform float waveAmplitude;

void main()
{
    vec2 uv = openfl_TextureCoordv;

    float height = 1.0 / openfl_TextureSize.y;
    float offset = sin(uv.x * frequency + time * speed) * waveAmplitude;

    uv.y += floor(offset / height) * height;
    uv.y = floor(uv.y / height) * height;

    gl_FragColor = texture2D(bitmap, uv);
}