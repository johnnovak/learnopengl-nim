#version 330 core

// The input variable from the vertex shader (same name and same type)
in vec4 vertexColor;

out vec4 color;

void main()
{
    color = vertexColor;
}
