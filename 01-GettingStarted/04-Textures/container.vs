#version 330 core

// The position variable has attribute position 0
layout (location = 0) in vec3 position;

// Specify a color output to the fragment shader
out vec4 vertexColor;

void main()
{
    // See how we directly give a vec3 to vec4's constructor
    gl_Position = vec4(position, 1.0f);

    // Set the output variable to a dark-red color
    vertexColor = vec4(0.5f, 0.0f, 0.0f, 1.0f);
}
