#version 330 core

// The position variable has attribute position 0
layout (location = 0) in vec3 position;

out vec4 vertexPos;

void main()
{
    // See how we directly give a vec3 to vec4's constructor
    gl_Position = vec4(position, 1.0f);

    vertexPos = gl_Position;
}
