#version 330 core

in vec3 vertexColor;
in vec2 textureCoord;

out vec4 color;

uniform sampler2D tex;

void main()
{
    color = texture(tex, textureCoord);
}
