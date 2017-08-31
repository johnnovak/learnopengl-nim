#version 330 core

out vec4 color;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main()
{
    color = vec4(objectColor * lightColor, 1.0);
}
