#version 330 core

in vec2 textureCoord;

out vec4 color;

uniform sampler2D tex1;
uniform sampler2D tex2;

void main()
{
    color = mix(texture(tex1, textureCoord),
                texture(tex2, vec2(1.0f - textureCoord.x, textureCoord.y)),
                0.2);
}
