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


proc draw() =
  glClearColor(0.2, 0.3, 0.3, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)


proc main() =
  # Initialise GLFW
  glfw.init()

  # Create window
  var win = newGlWin(
    dim = (w: 800, h: 600),
    title = "Hello Window",
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

  # Game loop
  while not win.shouldClose:
    glfw.pollEvents()
    draw()
    glfw.swapBufs(win)

  # Destroy window
  win.destroy()

  # Terminate GLFW, clearing any allocated resources
  glfw.terminate()


main()

