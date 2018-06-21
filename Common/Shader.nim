import glm
import glad/gl


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


proc createShaderProgram*(vertexShaderSource,
                          fragmentShaderSource: string): GLuint =
  # Compile shaders
  let
    vertexShader = compileShader(GL_VERTEX_SHADER, vertexShaderSource)
    fragmentShader = compileShader(GL_FRAGMENT_SHADER, fragmentShaderSource)

  var res = getShaderCompilationResult(vertexShader)
  if not res.success:
    quit "ERROR: vertex shader compilation failed: " & res.error

  res = getShaderCompilationResult(fragmentShader)
  if not res.success:
    quit "ERROR: fragment shader compilation failed: " & res.error

  # Create shader program
  let shaderProgram = glCreateProgram()
  glAttachShader(shaderProgram, vertexShader)
  glAttachShader(shaderProgram, fragmentShader)
  glLinkProgram(shaderProgram)

  res = getProgramLinkingResult(shaderProgram)
  if not res.success:
    quit "ERROR: shader program linking failed: " & res.error

  # We don't need the compiled shaders anymore, just the program
  glDeleteShader(vertexShader)
  glDeleteShader(fragmentShader)

  result = shaderProgram


proc createShaderProgramFromFile*(vertexShaderFn,
                                  fragmentShaderFn: string): GLuint =
  var f: File

  if not open(f, vertexShaderFn):
    quit "ERROR: cannot open vertex shader file '" & vertexShaderFn & "'"

  var vertexShaderSource = f.readAll()
  close(f)

  if not open(f, fragmentShaderFn):
    quit "ERROR: cannot open fragment shader file '" & vertexShaderFn & "'"

  var fragmentShaderSource = f.readAll()
  close(f)

  result = createShaderProgram(vertexShaderSource, fragmentShaderSource)


proc use*(shaderProgram: GLuint) =
  glUseProgram(shaderProgram)


proc setUniform1i*(shaderProgram: GLuint, name: string, v0: GLint) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform1i(location, v0)

proc setUniform2i*(shaderProgram: GLuint, name: string, v0, v1: GLint) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform2i(location, v0, v1)

proc setUniform3i*(shaderProgram: GLuint, name: string, v0, v1, v2: GLint) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform3i(location, v0, v1, v2)

proc setUniform4i*(shaderProgram: GLuint, name: string,
                   v0, v1, v2, v3: GLint) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform4i(location, v0, v1, v2, v3)


proc setUniform1f*(shaderProgram: GLuint, name: string, v0: GLfloat) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform1f(location, v0)

proc setUniform2f*(shaderProgram: GLuint, name: string, v0, v1: GLfloat) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform2f(location, v0, v1)

proc setUniform3f*(shaderProgram: GLuint, name: string, v0, v1, v2: GLfloat) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform3f(location, v0, v1, v2)

proc setUniform4f*(shaderProgram: GLuint, name: string,
                   v0, v1, v2, v3: GLfloat) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform4f(location, v0, v1, v2, v3)


# TODO do the rest
proc setUniform3fv*(shaderProgram: GLuint, name: string,
                    v: var Vec3[GLfloat]) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniform3fv(location, count = 1, v.caddr)


# TODO use glm types
proc setUniformMatrix2fv*(shaderProgram: GLuint, name: string,
                          data: ptr GLfloat) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniformMatrix3fv(location, count = 1, transpose = false, data)

proc setUniformMatrix3fv*(shaderProgram: GLuint, name: string,
                          data: ptr GLfloat) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniformMatrix3fv(location, count = 1, transpose = false, data)

proc setUniformMatrix4fv*(shaderProgram: GLuint, name: string,
                          data: ptr GLfloat) =
  let location = glGetUniformLocation(shaderProgram, name)
  glUniformMatrix4fv(location, count = 1, transpose = false, data)

