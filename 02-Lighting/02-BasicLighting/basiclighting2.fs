#version 330 core

in vec3 normal;
in vec3 fragPos;

out vec4 color;

uniform vec3 lightPos;
uniform vec3 viewPos;
uniform vec3 lightColor;
uniform vec3 objectColor;

void main()
{
    float ambientStrength = 0.1;
    float specularStrength = 0.5;

    vec3 lightDir = normalize(lightPos - fragPos);
    vec3 viewDir = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-lightDir, normal);

    vec3 ambient = ambientStrength * lightColor;

    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = specularStrength * spec * lightColor;

    vec3 col = (ambient + diffuse + specular) * objectColor;
    color = vec4(col, 1.0);
}
