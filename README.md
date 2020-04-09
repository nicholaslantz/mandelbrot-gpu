# Mandelbrot-GPU

A project to try out [CEPL](https://github.com/cbaggers/cepl).  Once
CEPL and the main loop are started, it will draw the Mandelbrot Set to
the window CEPL creates.  Once there, the viewing frame is controlled
with Vim keybinding, plus ~i~ and ~o~ to zoom in and out respectively.

## Getting Started

First install drivers for your video card.  Then Clone the project
into your Quicklisp projects folder.

Then start up your Lisp environment, run the following:

```
CL-USER> (ql:quickload :mandelbrot-gpu)
CL-USER> (in-package :mandelbrot-gpu)
MANDELBROT-GPU> (cepl:repl 720 480)
MANDELBROT-GPU> (run-loop)
```

And the window should appear and you'll be good to go.

## Compatability
In theory this should work on any platform with a correctly installed
CEPL environment.  In practice I've only tested on Void Linux with SBCL,
so if you get it running on another environment let me know!
