#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;

out vec3 normal;
out vec3 fragPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    mat4 modelView = view * model
    fragPos = vec3(modelView * vec4(aPos, 1.0));

    // Calculating the inverse transpose of the model-view matrix should be
    // done once on the CPU and sent to the shader via an uniform; this is for
    // learning purposes only.
    normal = mat3(transpose(inverse(modelView))) * aNormal;

    gl_Position = projection * vec4(fragPos, 1.0);
}
