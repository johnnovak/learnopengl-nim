#version 330 core

// The position variable has attribute position 0
layout (location = 0) in vec3 position;

// The color variable has attribute position 1
layout (location = 1) in vec3 color;

// Output a color to the fragment shader
out vec3 ourColor;

void main()
{
    gl_Position = vec4(position, 1.0f);

    // Set ourColor to the input color we got from the vertex data
    ourColor = color;
}
