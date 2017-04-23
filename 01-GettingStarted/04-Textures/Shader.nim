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
    infoLog: array[1024, GLchar]

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
    infoLog: array[1024, GLchar]

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

