# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Textures

import math

import glm
import glad/gl
import glfw
import glfw/wrapper
import stb_image/read as stbi

import common/shader


var vertices = [
  # Positions               # Colors         # Texture Coords
  GLfloat(0.5), 0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0,  # Top Right
          0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0,  # Bottom Right
         -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0,  # Bottom Left
         -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0   # Top Left
]

var indices = [
  GLuint(0), 1, 3,  # First Triangle
         1,  2, 3   # Second Triangle
]

var
  vao, vbo, ebo, texture, shaderProgram: GLuint


proc setup() =
  shaderProgram = createShaderProgramFromFile("container1.vs",
                                              "container1.fs")

  glGenVertexArrays(1, vao.addr)
  glGenBuffers(1, vbo.addr)
  glGenBuffers(1, ebo.addr)

  glBindVertexArray(vao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, size = GLsizeiptr(sizeof(vertices)),
               vertices.addr, GL_STATIC_DRAW)

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, size = GLsizeiptr(sizeof(indices)),
               indices.addr, GL_STATIC_DRAW);

  # Position attribute
  var stride = GLsizei(8 * sizeof(GLfloat))

  glVertexAttribPointer(index = 0, size = 3, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](0))

  glEnableVertexAttribArray(0)

  # Color attribute
  glVertexAttribPointer(index = 1, size = 3, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](3 * sizeof(GLfloat)))

  glEnableVertexAttribArray(1)

  # TexCoord attribute
  glVertexAttribPointer(index = 2, size = 2, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](6 * sizeof(GLfloat)))

  glEnableVertexAttribArray(2)

  glBindBuffer(GL_ARRAY_BUFFER, GL_NONE)
  glBindVertexArray(GL_NONE)

  # Load and create a texture

  # All upcoming GL_TEXTURE_2D operations now have effect on this texture
  # object
  glGenTextures(1, texture.addr)
  glBindTexture(GL_TEXTURE_2D, texture)

  # Set the texture wrapping parameters
  # Set texture wrapping to GL_REPEAT (usually basic wrapping method)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GLint(GL_REPEAT))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GLint(GL_REPEAT))

  # Set texture filtering parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GLint(GL_LINEAR))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GLint(GL_LINEAR))

  # Load image
  var
    width, height, channels: int
    data: seq[uint8]

  data = stbi.load("Data/container.jpg", width, height, channels,
                   stbi.Default)

  # Create texture
  glTexImage2D(GL_TEXTURE_2D, level = 0,
               internalFormat = GLint(GL_RGB),
               GLsizei(width), GLsizei(height), border = 0,
               format = GL_RGB, type = GL_UNSIGNED_BYTE,
               cast[pointer](data[0].addr))

  glGenerateMipmap(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, 0)


proc cleanup() =
  glDeleteVertexArrays(1, vao.addr)
  glDeleteBuffers(1, vbo.addr)
  glDeleteBuffers(1, ebo.addr)


proc draw() =
  # Clear the color buffer
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  glBindTexture(GL_TEXTURE_2D, texture)

  shaderProgram.use()

  glBindVertexArray(vao)
  glDrawElements(GL_TRIANGLES, count = GLsizei(6), GL_UNSIGNED_INT,
                 indices = GLvoid(nil))
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
    title = "Container1",
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

