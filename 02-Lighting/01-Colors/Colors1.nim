# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Camera

import math

import glm
import glad/gl
import glfw
import glfw/wrapper
import stb_image/read as stbi

import common/shader


var vertices = [
  # Positions
  GLfloat(-0.5),-0.5, -0.5,
           0.5, -0.5, -0.5,
           0.5,  0.5, -0.5,
           0.5,  0.5, -0.5,
          -0.5,  0.5, -0.5,
          -0.5, -0.5, -0.5,

          -0.5, -0.5,  0.5,
           0.5, -0.5,  0.5,
           0.5,  0.5,  0.5,
           0.5,  0.5,  0.5,
          -0.5,  0.5,  0.5,
          -0.5, -0.5,  0.5,

          -0.5,  0.5,  0.5,
          -0.5,  0.5, -0.5,
          -0.5, -0.5, -0.5,
          -0.5, -0.5, -0.5,
          -0.5, -0.5,  0.5,
          -0.5,  0.5,  0.5,

           0.5,  0.5,  0.5,
           0.5,  0.5, -0.5,
           0.5, -0.5, -0.5,
           0.5, -0.5, -0.5,
           0.5, -0.5,  0.5,
           0.5,  0.5,  0.5,

          -0.5, -0.5, -0.5,
           0.5, -0.5, -0.5,
           0.5, -0.5,  0.5,
           0.5, -0.5,  0.5,
          -0.5, -0.5,  0.5,
          -0.5, -0.5, -0.5,

          -0.5,  0.5, -0.5,
           0.5,  0.5, -0.5,
           0.5,  0.5,  0.5,
           0.5,  0.5,  0.5,
          -0.5,  0.5,  0.5,
          -0.5,  0.5, -0.5
]

var
  containerVao, lightVao, vbo, lightingShader, lampShader: GLuint

const
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600


proc setup() =
  lightingShader = createShaderProgramFromFile("colors1.vs", "colors1.fs")

  lampShader = createShaderProgramFromFile("colors1-lamp.vs",
                                           "colors1-lamp.fs")

  glGenBuffers(1, vbo.addr)

  # Configure the container object's VAO
  glGenVertexArrays(1, containerVao.addr)
  glBindVertexArray(containerVao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, size = GLsizeiptr(sizeof(vertices)),
               vertices.addr, GL_STATIC_DRAW)

  # Position attribute
  var stride = GLsizei(3 * sizeof(GLfloat))

  glVertexAttribPointer(index = 0, size = 3, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](0))

  glEnableVertexAttribArray(0)

  # Configure the light object's VAO (VBO stays the same; the vertices are the
  # same for the light object which is also a 3D cube)
  glGenVertexArrays(1, lightVao.addr)
  glBindVertexArray(lightVao)

  # We only need to bind to the VBO (to link it with glVertexAttribPointer),
  # no need to fill it; the VBO's data already contains all we need (it's
  # already bound, but we do it again for educational purposes)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)

  # Position attribute
  glVertexAttribPointer(index = 0, size = 3, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](0))

  glEnableVertexAttribArray(0)

  # Unbind VBO and VAO
  glBindBuffer(GL_ARRAY_BUFFER, GL_NONE)
  glBindVertexArray(GL_NONE)

  # Enable depth test
  glEnable(GL_DEPTH_TEST)


proc cleanup() =
  glDeleteVertexArrays(1, containerVao.addr)
  glDeleteBuffers(1, vbo.addr)


proc draw() =
  # Clear the color buffer
  glClearColor(0.1, 0.1, 0.1, 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  lightingShader.use()
  lightingShader.setUniform3f("objectColor", 1.0, 0.5, 0.3)
  lightingShader.setUniform3f("lightColor",  1.0, 1.0, 1.0)

  # Set model matrix
  var model = mat4(GLfloat(1.0))
    .rotate(vec3(GLfloat(1.0), 0.0, 0.0), degToRad(-55.0))

  lightingShader.setUniformMatrix4fv("model", model.caddr)

  # Set view matrix
  var view = lookAt(
    eye    = vec3[GLfloat](0.0, 0.0, 3.0),
    center = vec3[GLfloat](0.0, 0.0, 0.0),
    up     = vec3[GLfloat](0.0, 1.0, 0.0))

  lightingShader.setUniformMatrix4fv("view", view.caddr)

  # Set projection matrix
  var projection = perspective[GLfloat](
    fovy = degToRad(45.0),
    aspect = SCREEN_WIDTH / SCREEN_HEIGHT,
    zNear = 0.1, zFar = 100.0)

  lightingShader.setUniformMatrix4fv("projection", projection.caddr)

  # Draw container
  glBindVertexArray(containerVao)
  glDrawArrays(GL_TRIANGLES, first = 0, count = 36)

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
    dim = (w: SCREEN_WIDTH, h: SCREEN_HEIGHT),
    title = "Coords3",
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

