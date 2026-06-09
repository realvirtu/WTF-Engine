#pragma header

uniform float saturation = 1.0;

void main()
{
    vec4 color = texture2D(bitmap, openfl_TextureCoordv);
    float average = (color.r + color.g + color.b) / 3.0;

    color.rgb = mix(vec3(average), color.rgb, saturation);

    gl_FragColor = color;
}