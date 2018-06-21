# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Coordinate-Systems

import math

import glm
import glad/gl
import glfw
import stb_image/read as stbi

import common/shader


var vertices = [
  # Positions                # Texture Coords
  GLfloat(-0.5),-0.5, -0.5,  0.0, 0.0,
           0.5, -0.5, -0.5,  1.0, 0.0,
           0.5,  0.5, -0.5,  1.0, 1.0,
           0.5,  0.5, -0.5,  1.0, 1.0,
          -0.5,  0.5, -0.5,  0.0, 1.0,
          -0.5, -0.5, -0.5,  0.0, 0.0,

          -0.5, -0.5,  0.5,  0.0, 0.0,
           0.5, -0.5,  0.5,  1.0, 0.0,
           0.5,  0.5,  0.5,  1.0, 1.0,
           0.5,  0.5,  0.5,  1.0, 1.0,
          -0.5,  0.5,  0.5,  0.0, 1.0,
          -0.5, -0.5,  0.5,  0.0, 0.0,

          -0.5,  0.5,  0.5,  1.0, 0.0,
          -0.5,  0.5, -0.5,  1.0, 1.0,
          -0.5, -0.5, -0.5,  0.0, 1.0,
          -0.5, -0.5, -0.5,  0.0, 1.0,
          -0.5, -0.5,  0.5,  0.0, 0.0,
          -0.5,  0.5,  0.5,  1.0, 0.0,

           0.5,  0.5,  0.5,  1.0, 0.0,
           0.5,  0.5, -0.5,  1.0, 1.0,
           0.5, -0.5, -0.5,  0.0, 1.0,
           0.5, -0.5, -0.5,  0.0, 1.0,
           0.5, -0.5,  0.5,  0.0, 0.0,
           0.5,  0.5,  0.5,  1.0, 0.0,

          -0.5, -0.5, -0.5,  0.0, 1.0,
           0.5, -0.5, -0.5,  1.0, 1.0,
           0.5, -0.5,  0.5,  1.0, 0.0,
           0.5, -0.5,  0.5,  1.0, 0.0,
          -0.5, -0.5,  0.5,  0.0, 0.0,
          -0.5, -0.5, -0.5,  0.0, 1.0,

          -0.5,  0.5, -0.5,  0.0, 1.0,
           0.5,  0.5, -0.5,  1.0, 1.0,
           0.5,  0.5,  0.5,  1.0, 0.0,
           0.5,  0.5,  0.5,  1.0, 0.0,
          -0.5,  0.5,  0.5,  0.0, 0.0,
          -0.5,  0.5, -0.5,  0.0, 1.0
]

var
  vao, vbo, texture1, texture2, shaderProgram: GLuint

const
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600


proc setup() =
  shaderProgram = createShaderProgramFromFile("coords2.vs",
                                              "coords2.fs")

  glGenVertexArrays(1, vao.addr)
  glGenBuffers(1, vbo.addr)

  glBindVertexArray(vao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, size = GLsizeiptr(sizeof(vertices)),
               vertices.addr, GL_STATIC_DRAW)

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
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GLint(GL_NEAREST))
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GLint(GL_NEAREST))

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
  data = stbi.load("Data/awesomeface.jpg", width, height, channels,
                   stbi.Default)

  # Create texture
  glTexImage2D(GL_TEXTURE_2D, level = 0,
               internalFormat = GLint(GL_RGB),
               GLsizei(width), GLsizei(height), border = 0,
               format = GL_RGB, type = GL_UNSIGNED_BYTE,
               cast[pointer](data[0].addr))

  glGenerateMipmap(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, 0)

  # Enable depth test
  glEnable(GL_DEPTH_TEST)


proc cleanup() =
  glDeleteVertexArrays(1, vao.addr)
  glDeleteBuffers(1, vbo.addr)


proc draw() =
  # Clear the color buffer
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  shaderProgram.use()

  # Bind textures using texture units
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texture1)
  shaderProgram.setUniform1i("tex1", 0)

  glActiveTexture(GL_TEXTURE1)
  glBindTexture(GL_TEXTURE_2D, texture2)
  shaderProgram.setUniform1i("tex2", 1)

  # Set model matrix
  var model = mat4(GLfloat(1.0))
    .rotate(getTime(), vec3(GLfloat(0.5), 1.0, 0.0))

  shaderProgram.setUniformMatrix4fv("model", model.caddr)

  # Set view matrix
  var view = mat4(GLfloat(1.0))
    .translate(vec3(GLfloat(0.0), 0.0, -3.0))

  shaderProgram.setUniformMatrix4fv("view", view.caddr)

  # Set projection matrix
  var projection = perspective[GLfloat](
    fovy = degToRad(45.0),
    aspect = SCREEN_WIDTH / SCREEN_HEIGHT,
    zNear = 0.1, zFar = 100.0)

  shaderProgram.setUniformMatrix4fv("projection", projection.caddr)

  # Draw container
  glBindVertexArray(vao)
  glDrawArrays(GL_TRIANGLES, first = 0, count = 36)
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
  cfg.size = (w: SCREEN_WIDTH, h: SCREEN_HEIGHT)
  cfg.title = "06-CoordinateSystems/Coords2"
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

