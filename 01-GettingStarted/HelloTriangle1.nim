import math

import glm
import glad/gl
import glfw
import glfw/wrapper

var vertices: array[0..8, GLfloat] = [
  -0.5'f32, -0.5'f32, 0.0'f32,
   0.5'f32, -0.5'f32, 0.0'f32,
   0.0'f32,  0.5'f32, 0.0'f32
]

let vertexShaderSource = """
#version 330 core

layout (location = 0) in vec3 position;

void main()
{
    gl_Position = vec4(position.x, position.y, position.z, 1.0);
}
"""

let fragmentShaderSource = """
#version 330 core

out vec4 color;

void main()
{
    color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
"""

var
  vao, vbo, shaderProgram: GLuint


proc compileVertexShader(): GLuint =
  # Build & compile vertex shader
  var
    vertexShader = glCreateShader(GL_VERTEX_SHADER)
    vertexShaderSourceArr = [cstring(vertexShaderSource)]

  glShaderSource(vertexShader, 1,
                 cast[cstringArray](vertexShaderSourceArr.addr),
                 length = nil)
  glCompileShader(vertexShader)

  # Check for compilation errors
  var
    success: GLint
    infoLog: array[0..511, GLchar]

  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, success.addr)
  if success == 0:
    glGetShaderInfoLog(vertexShader, 512, nil, cast[cstring](infoLog.addr))
    echo "ERROR: vertex shader compilation failed: " & $infoLog

  result = vertexShader


proc compileFragmentShader(): GLuint =
  # Build & compile fragment shader
  var
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
    fragmentShaderSourceArr = [cstring(fragmentShaderSource)]

  glShaderSource(fragmentShader, 1,
                 cast[cstringArray](fragmentShaderSourceArr.addr),
                 length = nil)
  glCompileShader(fragmentShader)

  # Check for compilation errors
  var
    success: GLint
    infoLog: array[0..511, GLchar]

  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, success.addr)
  if success == 0:
    glGetShaderInfoLog(fragmentShader, 512, nil, cast[cstring](infoLog.addr))
    echo "ERROR: fragment shader compilation failed: " & $infoLog

  result = fragmentShader


proc linkShaders(vertexShader, fragmentShader: GLuint): GLuint =
  var shaderProgram = glCreateProgram()
  glAttachShader(shaderProgram, vertexShader)
  glAttachShader(shaderProgram, fragmentShader)
  glLinkProgram(shaderProgram)

  # Check for linking errors
  var
    success: GLint
    infoLog: array[0..511, GLchar]

  glGetProgramiv(shaderProgram, GL_LINK_STATUS, success.addr)
  if success == 0:
    glGetShaderInfoLog(shaderProgram, 512, nil, cast[cstring](infoLog.addr))
    echo "ERROR: shader program linking failed: " & $infoLog

  result = shaderProgram


proc init() =
  # Create shader program
  var
    vertexShader = compileVertexShader()
    fragmentShader = compileFragmentShader()

  shaderProgram = linkShaders(vertexShader, fragmentShader)

  glDeleteShader(vertexShader)
  glDeleteShader(fragmentShader)

  # Create vertex array object
  glGenVertexArrays(1, vao.addr)

  # Create vertex buffer object
  glGenBuffers(1, vbo.addr)

  # Bind the Vertex Array Object first, then bind and set vertex buffer(s) and
  # attribute pointer(s)
  glBindVertexArray(vao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(sizeof(vertices)), vertices.addr,
               GL_STATIC_DRAW)

  glVertexAttribPointer(0, 3, cGL_FLOAT, false, 3 * sizeof(GLfloat),
                        GLvoid(nil))
  glEnableVertexAttribArray(0)

  # Note that this is allowed; the call to glVertexAttribPointer registered
  # vbo as the currently bound vertex buffer object so afterwards we can
  # safely unbind
  glBindBuffer(GL_ARRAY_BUFFER, 0)

  # Unbind VAO (it's always a good thing to unbind any buffer/array to prevent
  # strange bugs)
  glBindVertexArray(0)


proc draw() =
  # Clear the color buffer
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  # Draw triangle
  glUseProgram(shaderProgram)
  glBindVertexArray(vao)
  glDrawArrays(GL_TRIANGLES, 0, 3)
  glBindVertexArray(0)


proc keyCb(w: Win, key: Key, scanCode: int, action: KeyAction,
           modKeys: ModifierKeySet) =

  if action != kaUp:
    if key == keyEscape:
      w.shouldClose = true


proc main() =
  glfw.init()

  # Create window
  var win = newGlWin(
    dim = (w: 800, h: 600),
    title = "Hello Window",
    resizable = false,
    bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 16),
    version = glv33,
    profile = glpCore,
    forwardCompat = true
  )

  # Initialise OpenGL
  glfw.makeContextCurrent(win)

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  # Define viewport dimensions
  var width, height: int
  (width, height) = framebufSize(win)
  glViewport(0, 0, GLint(width), GLint(height))

  # Turn on vsync (0 turns it off)
  glfw.swapInterval(1)

  # Setup callbacks
  win.keyCb = keyCb

  init()

  # Game loop
  while not win.shouldClose:
    glfw.pollEvents()
    draw()
    glfw.swapBufs(win)

  # Properly de-allocate all resources once they've outlived their purpose
  glDeleteVertexArrays(1, vao.addr)
  glDeleteBuffers(1, vbo.addr)

  # Destroy window
  win.destroy()

  # Terminate GLFW, clearing any resources allocated by GLFW
  glfw.terminate()


main()

