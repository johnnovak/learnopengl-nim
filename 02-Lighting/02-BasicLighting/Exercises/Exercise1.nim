# Right now the light source is a boring static light source that doesn't
# move. Try to move the light source around the scene over time using either
# sin or cos. Watching the lighting change over time gives you a good
# understanding of Phong's lighting model
#
# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Camera

import math

import glm
import glad/gl
import glfw
import stb_image/read as stbi

import common/shader
import common/fpscamera


var vertices = [
  # Positions                # Normals
  GLfloat(-0.5),-0.5, -0.5,  0.0,  0.0, -1.0,
           0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
           0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
           0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
          -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,
          -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,

          -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,
           0.5, -0.5,  0.5,  0.0,  0.0,  1.0,
           0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
           0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
          -0.5,  0.5,  0.5,  0.0,  0.0,  1.0,
          -0.5, -0.5,  0.5,  0.0,  0.0,  1.0,

          -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
          -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
          -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
          -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
          -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
          -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

           0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
           0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
           0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
           0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
           0.5, -0.5,  0.5,  1.0,  0.0,  0.0,
           0.5,  0.5,  0.5,  1.0,  0.0,  0.0,

          -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
           0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
           0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
           0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
          -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
          -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

          -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
           0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
           0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
           0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
          -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
          -0.5,  0.5, -0.5,  0.0,  1.0,  0.0
]

var
  containerVao, lightVao, vbo, lightingShader, lampShader: GLuint

const
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600

var
  lastXPos = 0.0
  lastYPos = 0.0
  lastFrameTime = 0.0

  camera = newFpsCamera(pos = vec3[GLfloat](-4.0, 0.0, 3.0),
                        yaw = 60.0, pitch = 0.0)

proc setup() =
  lightingShader = createShaderProgramFromFile("exercise1.vs",
                                               "exercise1.fs")
  lampShader = createShaderProgramFromFile("lamp.vs", "lamp.fs")

  glGenBuffers(1, vbo.addr)

  # Configure the container object's VAO
  glGenVertexArrays(1, containerVao.addr)
  glBindVertexArray(containerVao)

  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, size = GLsizeiptr(sizeof(vertices)),
               vertices.addr, GL_STATIC_DRAW)

  # Position attribute
  var stride = GLsizei(6 * sizeof(GLfloat))

  glVertexAttribPointer(index = 0, size = 3, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](0))

  glEnableVertexAttribArray(0)

  # Normal attribute
  stride = GLsizei(6 * sizeof(GLfloat))

  glVertexAttribPointer(index = 1, size = 3, type = cGL_FLOAT,
                        normalized = false, stride,
                        pointer = cast[pointer](3 * sizeof(GLfloat)))

  glEnableVertexAttribArray(1)

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

  # Draw container
  let t = getTime()
  var lightPos = vec3[GLfloat](cos(t) * 2.0,
                               cos(t / 4) * 1.0,
                               sin(t) * 2.0)

  lightingShader.use()
  lightingShader.setUniform3f("objectColor", 1.0, 0.5, 0.3)
  lightingShader.setUniform3f("lightColor",  1.0, 1.0, 1.0)
  lightingShader.setUniform3fv("lightPos", lightPos)
  lightingShader.setUniform3fv("viewPos", camera.pos)

  # Set model matrix
  var model = mat4(GLfloat(1.0))
  lightingShader.setUniformMatrix4fv("model", model.caddr)

  # Set view matrix
  var view = camera.getViewMatrix()
  lightingShader.setUniformMatrix4fv("view", view.caddr)

  # Set projection matrix
  var projection = perspective[GLfloat](
    fovy = degToRad(camera.fov),
    aspect = SCREEN_WIDTH / SCREEN_HEIGHT,
    zNear = 0.1, zFar = 100.0)

  lightingShader.setUniformMatrix4fv("projection", projection.caddr)

  glBindVertexArray(containerVao)
  glDrawArrays(GL_TRIANGLES, first = 0, count = 36)

  # Draw lamp
  lampShader.use()
  lampShader.setUniformMatrix4fv("projection", projection.caddr)
  lampShader.setUniformMatrix4fv("view", view.caddr)

  model = mat4(GLfloat(1.0))
    .translate(lightPos)
    .scale(vec3[GLfloat](0.2))

  lampShader.setUniformMatrix4fv("model", model.caddr)

  glBindVertexArray(lightVao)
  glDrawArrays(GL_TRIANGLES, first = 0, count = 36)

  # Unvind VAO
  glBindVertexArray(GL_NONE)


proc cursorPosCb(win: Window, pos: tuple[x, y: float64]) =
  let
    xoffs = pos.x - lastXPos
    yoffs = pos.y - lastYPos

  lastXPos = pos.x
  lastYPos = pos.y

  camera.headLook(xoffs, yoffs)


proc scrollCb(win: Window, offset: tuple[x, y: float64]) =
  camera.zoom(offset.y)


proc processInput(win: Window) =
  let
    currFrameTime = getTime()
    dt = currFrameTime - lastFrameTime

  lastFrameTime = currFrameTime

  if win.isKeyDown(keyEscape):
      win.shouldClose = true

  if win.isKeyDown(keyW):
    camera.move(cmForward, dt)
  if win.isKeyDown(keyS):
    camera.move(cmBackward, dt)
  if win.isKeyDown(keyA):
    camera.move(cmLeft, dt)
  if win.isKeyDown(keyD):
    camera.move(cmRight, dt)


proc main() =
  # Initialise GLFW
  glfw.initialize()

  # Create window
  var cfg = DefaultOpenglWindowConfig
  cfg.size = (w: SCREEN_WIDTH, h: SCREEN_HEIGHT)
  cfg.title = "02-BasicLighting/Exercise1"
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

  # Hide and capture mouse cursor
  win.cursorMode = cmDisabled

  # Turn on vsync (0 turns it off)
  glfw.swapInterval(1)

  # Setup callbacks
  win.cursorPositionCb = cursorPosCb
  win.scrollCb = scrollCb

  # Setup shaders and various OpenGL objects
  setup()

  # Game loop
  while not win.shouldClose:
    glfw.pollEvents()
    processInput(win)
    draw()
    glfw.swapBuffers(win)

  # Properly de-allocate all resources once they've outlived their purpose
  cleanup()

  # Destroy window
  win.destroy()

  # Terminate GLFW, clearing any allocated resources
  glfw.terminate()


main()

