# Experiment with the different texture wrapping methods by specifying texture
# coordinates in the range 0.0f to 2.0f instead of 0.0f to 1.0f. See if you
# can display 4 smiley faces on a single container image clamped at its edge.
#
# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Textures

import math

import glm
import glad/gl
import glfw
import stb_image/read as stbi

import common/shader


var vertices = [
  # Positions               # Texture Coords
  GLfloat(0.5), 0.5, 0.0,   2.0, 2.0,  # Top Right
          0.5, -0.5, 0.0,   2.0, 0.0,  # Bottom Right
         -0.5, -0.5, 0.0,   0.0, 0.0,  # Bottom Left
         -0.5,  0.5, 0.0,   0.0, 2.0   # Top Left
]

var indices = [
  GLuint(0), 1, 3,  # First Triangle
         1,  2, 3   # Second Triangle
]

var
  vao, vbo, ebo, texture1, texture2, shaderProgram: GLuint


proc setup() =
  shaderProgram = createShaderProgramFromFile("exercise2.vs",
                                              "exercise2.fs")

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
  var stride = GLsizei(5 * sizeof(GLfloat))

  glVertexAttribPointer(index = 0, size = 3, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](0))

  glEnableVertexAttribArray(0)

  # TexCoord attribute
  glVertexAttribPointer(index = 1, size = 2, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](3 * sizeof(GLfloat)))

  glEnableVertexAttribArray(1)

  glBindBuffer(GL_ARRAY_BUFFER, GL_NONE)
  glBindVertexArray(GL_NONE)

  # Load and create the textures

  # Texture 1
  # ---------
  # All upcoming GL_TEXTURE_2D operations now have effect on this texture
  # object
  glGenTextures(1, texture1.addr)
  glBindTexture(GL_TEXTURE_2D, texture1)

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

  data = stbi.load("../Data/container.jpg", width, height, channels,
                   stbi.Default)

  # Create texture
  glTexImage2D(GL_TEXTURE_2D, level = 0,
               internalFormat = GLint(GL_RGB),
               GLsizei(width), GLsizei(height), border = 0,
               format = GL_RGB, type = GL_UNSIGNED_BYTE,
               cast[pointer](data[0].addr))

  glGenerateMipmap(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, 0)

  # Texture 2
  # ---------
  # All upcoming GL_TEXTURE_2D operations now have effect on this texture
  # object
  glGenTextures(1, texture2.addr)
  glBindTexture(GL_TEXTURE_2D, texture2)

  # Set the texture wrapping parameters
  # Set texture wrapping to GL_REPEAT (usually basic wrapping method)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GLint(GL_REPEAT))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GLint(GL_REPEAT))

  # Set texture filtering parameters
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GLint(GL_LINEAR))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GLint(GL_LINEAR))

  # Load image
  data = stbi.load("../Data/awesomeface.jpg", width, height, channels,
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

  shaderProgram.use()

  # Bind textures using texture units
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texture1)
  shaderProgram.setUniform1i("tex1", 0)

  glActiveTexture(GL_TEXTURE1)
  glBindTexture(GL_TEXTURE_2D, texture2)
  shaderProgram.setUniform1i("tex2", 1)

  # Draw container
  glBindVertexArray(vao)
  glDrawElements(GL_TRIANGLES, count = GLsizei(6), GL_UNSIGNED_INT,
                 indices = GLvoid(nil))
  glBindVertexArray(GL_NONE)


proc keyCb(win: Window, key: Key, scanCode: int32, action: KeyAction,
           modKeys: set[ModifierKey]) =

  if action != kaUp:
    if key == keyEscape:
      win.shouldClose = true


proc main() =
  # Initialise GLFW
  glfw.initialize()

  # Create window
  var cfg = DefaultOpenglWindowConfig
  cfg.size = (w: 800, h: 600)
  cfg.title = "04-Textures/Exercise2"
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

