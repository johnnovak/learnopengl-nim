# Read the accompanying article at
# https://learnopengl.com/#!Getting-started/Hello-Window

import math

import glm
import glad/gl
import glfw


proc draw() =
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)


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
  cfg.title = "HelloWindow"
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

  # Game loop
  while not win.shouldClose:
    glfw.pollEvents()
    draw()
    glfw.swapBuffers(win)

  # Destroy window
  win.destroy()

  # Terminate GLFW, clearing any allocated resources
  glfw.terminate()


main()

