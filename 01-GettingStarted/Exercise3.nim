import math

import glm
import glad/gl
import glfw
import glfw/wrapper


proc keyCb(w: Win, key: Key, scanCode: int, action: KeyAction,
           modKeys: ModifierKeySet) =

  if action != kaUp:
    if key == keyEscape:
      w.shouldClose = true


proc compileShader(shaderType: GLenum, source: string): GLuint =
  var
    shader = glCreateShader(shaderType)
    sourceArr = [cstring(source)]

  glShaderSource(shader, 1, cast[cstringArray](sourceArr.addr), nil)
  glCompileShader(shader)
  result = shader


proc getShaderCompilationResult(shader: GLuint): tuple[success: bool,
                                                       error: string] =
  var
    success: GLint
    infoLog: array[1024, GLchar]

  glGetShaderiv(shader, GL_COMPILE_STATUS, success.addr)

  if success == 0:
    glGetShaderInfoLog(shader, GLsizei(infoLog.len), nil, infoLog)
    result = (success: false, error: $infoLog)
  else:
    result = (success: true, error: "")


proc getProgramLinkingResult(program: GLuint): tuple[success: bool,
                                                     error: string] =
  var
    success: GLint
    infoLog: array[1024, GLchar]

  glGetProgramiv(program, GL_LINK_STATUS, success.addr)

  if success == 0:
    glGetShaderInfoLog(program, GLsizei(infoLog.len), nil, infoLog)
    result = (success: false, error: $infoLog)
  else:
    result = (success: true, error: "")


proc createShaderProgram(vertexShaderSource,
                         fragmentShaderSource: string): GLuint =
  # Compile shaders
  let
    vertexShader = compileShader(GL_VERTEX_SHADER, vertexShaderSource)
    fragmentShader = compileShader(GL_FRAGMENT_SHADER, fragmentShaderSource)

  var res = getShaderCompilationResult(vertexShader)
  if not res.success:
    echo "ERROR: vertex shader compilation failed: " & res.error

  res = getShaderCompilationResult(fragmentShader)
  if not res.success:
    echo "ERROR: fragment shader compilation failed: " & res.error

  # Create shader program
  let shaderProgram = glCreateProgram()
  glAttachShader(shaderProgram, vertexShader)
  glAttachShader(shaderProgram, fragmentShader)
  glLinkProgram(shaderProgram)

  res = getProgramLinkingResult(shaderProgram)
  if not res.success:
    echo "ERROR: shader program linking failed: " & res.error

  # We don't need the compiled shaders anymore, just the program
  glDeleteShader(vertexShader)
  glDeleteShader(fragmentShader)

  result = shaderProgram


var vertices1 = [
  GLfloat(-0.7),-0.3, 0.0,
          -0.1, -0.3, 0.0,
          -0.4,  0.3, 0.0
]

var vertices2 = [
  GLfloat( 0.1),-0.3, 0.0,
           0.7, -0.3, 0.0,
           0.4,  0.3, 0.0
]

let vertexShaderSource = """
#version 330 core

layout (location = 0) in vec3 position;

void main()
{
    gl_Position = vec4(position.x, position.y, position.z, 1.0);
}
"""

let fragmentShaderSource1 = """
#version 330 core

out vec4 color;

void main()
{
    color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
"""

let fragmentShaderSource2 = """
#version 330 core

out vec4 color;

void main()
{
    color = vec4(1.0f, 1.0f, 0.2f, 1.0f);
}
"""

var
  vao1, vao2, vbo1, vbo2, shaderProgram1, shaderProgram2: GLuint


proc setupVertexData(vao, vbo: ptr GLuint,
                     vertices: ptr GLfloat, numVertices: GLsizeiptr) =

  # Create Vertex Array Object
  glGenVertexArrays(1, vao)

  # Create Vertex Buffer Object
  glGenBuffers(1, vbo)

  # Bind the Vertex Array Object first, then bind and set vertex buffer(s)
  # and attribute pointer(s)
  glBindVertexArray(vao[])
  glBindBuffer(GL_ARRAY_BUFFER, vbo[])

  # Copy vertex data from CPU memory into GPU memory
  glBufferData(GL_ARRAY_BUFFER, numVertices, vertices, GL_STATIC_DRAW)

  # Tell OpenGL how it should interpret the vertex data
  glVertexAttribPointer(index = 0, size = 3, `type` = cGL_FLOAT,
                        normalized = false,
                        stride = 3 * sizeof(GLfloat),
                        `pointer` = GLvoid(nil))

  # Enable vertex attribute at location 0 (all vertex attributes are disabled
  # by default)
  glEnableVertexAttribArray(index = 0)

  # Note that this is allowed; the call to glVertexAttribPointer registered
  # VBO as the currently bound vertex buffer object so afterwards we can
  # safely unbind
  glBindBuffer(GL_ARRAY_BUFFER, GL_NONE)

  # Unbind VAO (it's always a good thing to unbind any buffer/array to prevent
  # strange bugs)
  glBindVertexArray(GL_NONE)


proc setup() =
  shaderProgram1 = createShaderProgram(vertexShaderSource,
                                       fragmentShaderSource1)

  shaderProgram2 = createShaderProgram(vertexShaderSource,
                                       fragmentShaderSource2)

  setupVertexData(vao1.addr, vbo1.addr,
                  vertices1[0].addr, GLsizeiptr(sizeof(vertices1)))

  setupVertexData(vao2.addr, vbo2.addr,
                  vertices2[0].addr, GLsizeiptr(sizeof(vertices2)))


proc cleanup() =
  glDeleteVertexArrays(1, vao1.addr)
  glDeleteVertexArrays(1, vao2.addr)

  glDeleteBuffers(1, vbo1.addr)
  glDeleteBuffers(1, vbo2.addr)


proc draw() =
  # Clear the color buffer
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  # Draw orange triangle
  glUseProgram(shaderProgram1)
  glBindVertexArray(vao1)
  glDrawArrays(GL_TRIANGLES, first = 0, count = 6)

  # Draw yellow triangle
  glUseProgram(shaderProgram2)
  glBindVertexArray(vao2)
  glDrawArrays(GL_TRIANGLES, first = 0, count = 6)

  glBindVertexArray(GL_NONE)


proc main() =
  # Initialise GLFW
  glfw.init()

  # Create window
  let win = newGlWin(
    dim = (w: 800, h: 600),
    title = "Hello Triangle1",
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

  # Setup shaders and various OpenGL objects
  setup()

  # Game loop
  while not win.shouldClose:
    glfw.pollEvents()
    draw()
    glfw.swapBufs(win)

  # Properly de-allocate all resources once they've outlived their purpose
  cleanup()

  # Destroy window
  win.destroy()

  # Terminate GLFW, clearing any allocated resources
  glfw.terminate()


main()

