import math

import glm
import glad/gl


const
  YAW = -90.0
  PITCH = 0.0
  CURSOR_SENSITIVITY = 0.1
  MOVEMENT_SPEED = 2.5
  MIN_FOV = 1.0
  MAX_FOV = 45.0
  FOV = 45.0

type
  FpsCamera* = ref object
    pos*, front*, up*: Vec3[GLfloat]
    movementSpeed*: float
    yaw*, pitch*: float
    fov*: float

  CameraMovement* = enum
    cmForward, cmBackward, cmLeft, cmRight


proc updateCameraVectors(c: FpsCamera) =
  const
    yAxis = vec3[GLfloat](1.0, 0.0, 0.0)
    xAxis = vec3[GLfloat](0.0, 1.0, 0.0)

  let tx = mat4(GLfloat(1.0)).rotate(yAxis, degToRad(c.pitch))
                             .rotate(xAxis, degToRad(c.yaw))

  const frontStart = vec3[GLfloat](0.0, 0.0, -1.0)

  c.front = (vec4(frontStart, 0.0) * tx).xyz


proc newFpsCamera*(pos:   Vec3[GLfloat] = vec3[GLfloat](0.0, 0.0, 0.0),
                   up:    Vec3[GLfloat] = vec3[GLfloat](0.0, 1.0, 0.0),
                   yaw:   float = YAW,
                   pitch: float = PITCH): FpsCamera =
  new(result)

  result.fov = FOV
  result.movementSpeed = MOVEMENT_SPEED

  result.pos   = pos
  result.up    = up
  result.yaw   = yaw
  result.pitch = pitch
  result.front = vec3[GLfloat](0.0, 0.0, -1.0)

  result.updateCameraVectors()


proc newFpsCamera*(posX, posY, posZ: float,
                   upX,  upY,  upZ:  float,
                   yaw:      float = YAW,
                   pitch:    float = PITCH): FpsCamera =

  newFpsCamera(vec3[GLfloat](posX, posY, posZ),
               vec3[GLfloat](upX,  upY,  upZ),
               yaw, pitch)


proc move*(c: FpsCamera, m: CameraMovement, deltaTime: float) =
  let velocity = c.movementSpeed * deltaTime

  case m:
  of cmForward:  c.pos += c.front * velocity
  of cmBackward: c.pos -= c.front * velocity
  of cmLeft:     c.pos += normalize(cross(c.up, c.front)) * velocity
  of cmRight:    c.pos -= normalize(cross(c.up, c.front)) * velocity

  c.updateCameraVectors()


proc headLook*(c: FpsCamera, xoffs, yoffs: float) =
  let
    dx = xoffs * CURSOR_SENSITIVITY
    dy = yoffs * CURSOR_SENSITIVITY

  c.yaw += dx
  if c.yaw > 360.0:
    c.yaw -= 360.0
  if c.yaw < -360:
    c.yaw += 360.0

  c.pitch = max(min(c.pitch + dy, 89.0), -89.0)
  c.updateCameraVectors()


proc zoom*(c: FpsCamera, offs: float) =
  c.fov = max(min(c.fov - offs, MAX_FOV), MIN_FOV)


proc getViewMatrix*(c: FpsCamera): Mat4[GLfloat] =
  lookAt(c.pos, c.pos + c.front, c.up)

