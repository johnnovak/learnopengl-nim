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

let cubePositions = [
  vec3[GLfloat]( 0.0,  0.0,   0.0),
  vec3[GLfloat]( 2.0,  5.0, -15.0),
  vec3[GLfloat](-1.5, -2.2,  -2.5),
  vec3[GLfloat](-3.8, -2.0, -12.3),
  vec3[GLfloat]( 2.4, -0.4,  -3.5),
  vec3[GLfloat](-1.7,  3.0,  -7.5),
  vec3[GLfloat]( 1.3, -2.0,  -2.5),
  vec3[GLfloat]( 1.5,  2.0,  -2.5),
  vec3[GLfloat]( 1.5,  0.2,  -1.5),
  vec3[GLfloat](-1.3,  1.0,  -1.5)
]

var
  vao, vbo, texture1, texture2, shaderProgram: GLuint

const
  SCREEN_WIDTH = 200
  SCREEN_HEIGHT = 100

let
  cameraFrontStart = vec3[GLfloat](0.0, 0.0, -1.0)

  cursorSensitivity = 0.1
  cameraSpeedFactor = 2.5

var
  cameraPos   = vec3[GLfloat](0.0, 0.0,  3.0)
  cameraFront = vec3[GLfloat](0.0, 0.0, -1.0)
  cameraUp    = vec3[GLfloat](0.0, 1.0,  0.0)
  cameraSpeed = 0.05

  lastXPos = 0.0
  lastYPos = 0.0
  lastFrameTime = 0.0

  yaw = 0.0
  pitch = 0.0


proc setup() =
  shaderProgram = createShaderProgramFromFile("camera2.vs",
                                              "camera2.fs")

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
  let
    t = getTime()
    dt = getTime() - lastFrameTime

  lastFrameTime = t

  cameraSpeed = cameraSpeedFactor * dt

  # Clear the color buffer
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  glUseProgram(shaderProgram)

  # Bind textures using texture units
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texture1)
  shaderProgram.setUniform1i("tex1", 0)

  glActiveTexture(GL_TEXTURE1)
  glBindTexture(GL_TEXTURE_2D, texture2)
  shaderProgram.setUniform1i("tex2", 1)

  # Set view matrix
  var view = lookAt(cameraPos, cameraPos + cameraFront, cameraUp)

  shaderProgram.setUniformMatrix4fv("view", view.caddr)

  # Set projection matrix
  var projection = perspective[GLfloat](
    fovy = degToRad(45.0),
    aspect = SCREEN_WIDTH / SCREEN_HEIGHT,
    zNear = 0.1, zFar = 100.0)

  shaderProgram.setUniformMatrix4fv("projection", projection.caddr)

  # Draw container
  glBindVertexArray(vao)

  for i, pos in cubePositions.pairs:
    # Set model matrix
    let angle = 20.0 * float(i)
    var model = mat4(GLfloat(1.0))
      .translate(pos)
      .rotate(vec3(GLfloat(0.5), 1.0, 0.0), degToRad(angle))

    shaderProgram.setUniformMatrix4fv("model", model.caddr)
    glDrawArrays(GL_TRIANGLES, first = 0, count = 36)

  glBindVertexArray(GL_NONE)


proc cursorPosCb(win: Win, pos: tuple[x, y: float64]) =
  let
    dx = (pos.x - lastXPos) * cursorSensitivity
    dy = (pos.y - lastYPos) * cursorSensitivity

  yaw += dx
  if yaw > 360.0:
    yaw -= 360.0
  if yaw < -360:
    yaw += 360.0

  pitch = max(min(pitch + dy, 89.0), -89.0)

  var tx = mat4(GLfloat(1.0))
             .rotate(vec3(GLfloat(0.0), 1.0, 0.0), degToRad(yaw))
             .rotate(vec3(GLfloat(1.0), 0.0, 0.0), degToRad(pitch))

  cameraFront = (vec4(cameraFrontStart, 0.0) * tx).xyz

  lastXPos = pos.x
  lastYPos = pos.y


proc keyCb(w: Win, key: Key, scanCode: int, action: KeyAction,
           modKeys: ModifierKeySet) =

  if action != kaUp:
    case key:
    of keyEscape:
      w.shouldClose = true
    of keyW:
      cameraPos += cameraFront * cameraSpeed
    of keyS:
      cameraPos -= cameraFront * cameraSpeed
    of keyA:
      cameraPos += normalize(cross(cameraUp, cameraFront)) * cameraSpeed
    of keyD:
      cameraPos -= normalize(cross(cameraUp, cameraFront)) * cameraSpeed
    else:
      discard


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

  # Hide and capture mouse cursor
  win.cursorMode = cmDisabled

  # Define viewport dimensions
  var width, height: int
  (width, height) = framebufSize(win)
  glViewport(0, 0, GLint(width), GLint(height))

  # Turn on vsync (0 turns it off)
  glfw.swapInterval(1)

  # Setup callbacks
  win.keyCb = keyCb
  win.cursorPosCb = cursorPosCb

  # Setup shaders and various OpenGL objects
  setup()

  # Game loop
  while not win.shouldClose:
    glfw.swapBufs(win)
    draw()
    glfw.pollEvents()

  # Properly de-allocate all resources once they've outlived their purpose
  cleanup()

  # Destroy window
  win.destroy()

  # Terminate GLFW, clearing any allocated resources
  glfw.terminate()


main()

