# Learn OpenGL in Nim

Example programs and exercises from
[learnopengl.com](https://learnopengl.com/) translated to
[Nim](https://nim-lang.org/). A work in progress.

All programs have been tested on Windows 7 64-bit and OS X El Capitan. If
you're on Linux, see the Linux notes below.

## Requirements

Requires [nim-glfw](https://github.com/ephja/nim-glfw),
[nim-glm](https://github.com/stavenko/nim-glm) and
[stb_Image-Nim](https://gitlab.com/define-private-public/stb_image-Nim).

The easiest way to install the dependencies is with Nimble:

```
nimble nim-glfw glm sbt_image
```

Then you can compile & run any of the examples from their respective
directories, e.g:

```
cd 01-GettingStarted/03-Shaders 
nim c -r Shader1.nim
```

## Linux notes

On Linux the header files required by GLFW aren't usually part of the base
install like on Windows and OS X, so make sure to install them using the
following command:

```
sudo apt-get install xorg-dev libglu1-mesa libglu1-mesa-dev mesa-common-dev
```

With this I was able to compile the code, but unfortunately I could not
actually test them because I'm using Linux in VirtualBox which only supports
OpenGL 2.1.

