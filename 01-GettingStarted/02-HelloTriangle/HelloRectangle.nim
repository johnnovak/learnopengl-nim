# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Hello-Triangle

import math

import glm
import glad/gl
import glfw


var vertices = [
   GLfloat(0.5), 0.5, 0.0,  # top right
           0.5, -0.5, 0.0,  # bottom right
          -0.5, -0.5, 0.0,  # bottom left
          -0.5,  0.5, 0.0   # top left
]

var indices = [
  GLuint(0), 1, 3,  # first triangle
         1,  2, 3   # second triangle
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
  ebo, vao, vbo, shaderProgram: GLuint


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
    infoLog = newString(1024)

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
    infoLog = newString(1024)

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


proc keyCb(win: Window, key: Key, scanCode: int32, action: KeyAction,
           modKeys: set[ModifierKey]) =

  if action != kaUp:
    if key == keyEscape:
      win.shouldClose = true


proc setup() =
  shaderProgram = createShaderProgram(vertexShaderSource,
                                      fragmentShaderSource)

  # Create Vertex Array Object
  glGenVertexArrays(1, vao.addr)

  # Create Element Buffer Object
  glGenBuffers(1, ebo.addr)

  # Create Vertex Buffer Object
  glGenBuffers(1, vbo.addr)

  # Bind the Vertex Array Object first, then bind and set vertex & element
  # buffer(s) and attribute pointer(s)
  glBindVertexArray(vao)

  # Copy vertex data from CPU memory into GPU memory
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, size = GLsizeiptr(sizeof(vertices)),
               vertices.addr, GL_STATIC_DRAW)

  # Tell OpenGL how it should interpret the vertex data
  glVertexAttribPointer(index = 0, size = 3, type = cGL_FLOAT,
                        normalized = false,
                        stride = 3 * sizeof(GLfloat),
                        pointer = cast[pointer](0))

  # Enable vertex attribute at location 0 (all vertex attributes are disabled
  # by default)
  glEnableVertexAttribArray(index = 0)

  # Copy element data from CPU memory into GPU memory
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, size = GLsizeiptr(sizeof(indices)),
               indices.addr, GL_STATIC_DRAW)

  # Note that this is allowed; the call to glVertexAttribPointer registered
  # VBO as the currently bound vertex buffer object so afterwards we can
  # safely unbind
  glBindBuffer(GL_ARRAY_BUFFER, GL_NONE)

  # Unbind VAO (it's always a good thing to unbind any buffer/array to prevent
  # strange bugs)
  glBindVertexArray(GL_NONE)


proc cleanup() =
  glDeleteVertexArrays(1, vao.addr)
  glDeleteBuffers(1, vbo.addr)
  glDeleteBuffers(1, ebo.addr)


proc draw() =
  # Clear the color buffer
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  # Draw triangle
  glUseProgram(shaderProgram)
  glBindVertexArray(vao)
  glDrawElements(GL_TRIANGLES, count = GLsizei(6), GL_UNSIGNED_INT,
                 indices = GLvoid(nil))
  glBindVertexArray(GL_NONE)


proc main() =
  # Initialise GLFW
  glfw.initialize()

  # Create window
  var cfg = DefaultOpenglWindowConfig
  cfg.size = (w: 800, h: 600)
  cfg.title = "02-HelloTriangle/HelloRectangle"
  cfg.resizable = false
  cfg.bits = (r: 8, g: 8, b: 8, a: 8, stencil: 8, depth: 16)
  cfg.version = glv33
  cfg.profile = opCoreProfile
  cfg.forwardCompat = true

  var win = newWindow(cfg)

  # Initialise OpenGL
  glfw.makeContextCurrent(win)

  if not gladLoadGL(getProcAddress):
    quit "Error initialising OpenGL"

  # Define viewport dimensions
  var width, height: int
  (width, height) = framebufferSize(win)
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
    glfw.swapBuffers(win)

  # Properly de-allocate all resources once they've outlived their purpose
  cleanup()

  # Destroy window
  win.destroy()

  # Terminate GLFW, clearing any allocated resources
  glfw.terminate()


main()

