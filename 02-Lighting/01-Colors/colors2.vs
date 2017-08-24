#version 330 core

layout (location = 0) in vec3 aPosition;
layout (location = 1) in vec3 aNormal;

out vec3 normal;
out vec3 fragPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    gl_Position = projection * view * model * vec4(aPosition, 1.0);
    fragPos = vec3(model * vec4(aNormal, 1.0));

    // Calculating the inverse tranpose of the model matrix should be done
    // once on the CPU and sent to the snader via an uniform; this is for
    // learning purposes only.
    normal = mat3(transpose(inverse(model))) * aNormal;
}
