# Adjust the vertex shader so that the triangle is upside down.
#
# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Shaders

import math

import glm
import glad/gl
import glfw
import glfw/wrapper

import common/shader


var vertices = [
  # Positions                # Colors
  GLfloat(-0.5),-0.5, 0.0,   1.0, 0.0, 0.0,   # Bottom Right
           0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   # Bottom Left
           0.0,  0.5, 0.0,   0.0, 0.0, 1.0    # Top
]

var
  vao, vbo, shaderProgram: GLuint


proc setup() =
  shaderProgram = createShaderProgramFromFile("exercise1.vs", "exercise1.fs")

  # Create Vertex Array Object
  glGenVertexArrays(1, vao.addr)

  # Create Vertex Buffer Object
  glGenBuffers(1, vbo.addr)

  # Bind the Vertex Array Object first, then bind and set vertex & element
  # buffer(s) and attribute pointer(s)
  glBindVertexArray(vao)

  # Copy vertex data from CPU memory into GPU memory
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, size = GLsizeiptr(sizeof(vertices)),
               vertices.addr, GL_STATIC_DRAW)

  # Position attribute
  glVertexAttribPointer(index = 0, size = 3, type = cGL_FLOAT,
                        normalized = false,
                        stride = 6 * sizeof(GLfloat),
                        pointer = cast[pointer](0))

  glEnableVertexAttribArray(index = 0)

  # Color attribute
  glVertexAttribPointer(index = 1, size = 3, type = cGL_FLOAT,
                        normalized = false,
                        stride = 6 * sizeof(GLfloat),
                        pointer = cast[pointer](3 * sizeof(GLfloat)))

  glEnableVertexAttribArray(index = 1)

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


proc draw() =
  # Clear the color buffer
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  # Draw the triangle
  glUseProgram(shaderProgram)
  glBindVertexArray(vao)
  glDrawArrays(GL_TRIANGLES, first = 0, count = 3)
  glBindVertexArray(GL_NONE)


proc keyCb(w: Win, key: Key, scanCode: int, action: KeyAction,
           modKeys: ModifierKeySet) =

  if action != kaUp:
    if key == keyEscape:
      w.shouldClose = true


proc main() =
  # Initialise GLFW
  glfw.init()

  # Create window
  let win = newGlWin(
    dim = (w: 800, h: 600),
    title = "Exercise1",
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

