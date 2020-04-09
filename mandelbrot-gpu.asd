(asdf:defsystem :mandelbrot-gpu
  :description "A simple Mandelbrot Visualization tool that uses OpenGL."
  :author "Nicholas Lantz"
  :license "Public Domain"
  :version "0.1.0"
  :depends-on (#:cepl #:rtg-math.vari #:cepl.sdl2 #:swank #:livesupport #:cepl.skitter.sdl2 #:dirt)
  :components ((:file "package")
	       (:file "mandelbrot-gpu" :depends-on ("package"))))
