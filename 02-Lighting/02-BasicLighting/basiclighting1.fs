#version 330 core

in vec3 normal;
in vec3 fragPos;

out vec4 color;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 lightPos;

void main()
{
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;

    vec3 lightDir = normalize(lightPos - fragPos);

    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    vec3 col = (ambient + diffuse) * objectColor;
    color = vec4(col, 1.0);
}
