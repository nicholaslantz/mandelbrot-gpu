(in-package #:mandelbrot-gpu)

(defparameter *vert-stream* nil)
(defparameter *rect*
  `((,(v! -1 1 0) ,(v! -2 1)) (,(v! 1 1 0) ,(v! 1 1))
    (,(v! 1 -1 0) ,(v! 1 -1)) (,(v! -1 -1 0) ,(v! -2 -1))))
(defparameter *listen* nil)

(defun kb-listener (data input-source index timestamp tpref)
  (declare (ignore input-source timestamp tpref))
  (when data
    (cond ((= index key.h) (left))
	  ((= index key.j) (down))
	  ((= index key.k) (up))
	  ((= index key.l) (right))
	  ((= index key.i) (zoom-in))
	  ((= index key.o) (zoom-out)))))

(defparameter *zoom* 1.0)
(defparameter *position* (v! 0 0))

(defun zoom-in (&optional (amt 1.1))
  (setf *zoom* (/ *zoom* amt)))
(defun zoom-out (&optional (amt 1.1))
  (setf *zoom* (* *zoom* amt)))

(flet ((width () (* *zoom* 3))
       (height () (* *zoom* 2)))
  (defun left (&optional (amt 0.25))
    (setf *position* (rtg-math.vector2:- *position* (v! (* amt (width)) 0))))
  (defun right (&optional (amt 0.25))
    (setf *position* (rtg-math.vector2:+ *position* (v! (* amt (width)) 0))))
  (defun up (&optional (amt 0.25))
    (setf *position* (rtg-math.vector2:+ *position* (v! 0 (* amt (height))))))
  (defun down (&optional (amt 0.25))
    (setf *position* (rtg-math.vector2:- *position* (v! 0 (* amt (height)))))))
(defun-g vert-pt ((vert g-pt) &uniform (zoom :float) (position :vec2))
  (values (v! (pos vert) 1)
	  (:smooth (+ position (* (v! zoom zoom) (tex vert))))))

(defun-g mandelbrot-iter ((z :vec2) (c :vec2))
  (let ((a (s~ z :x)) (b (s~ z :y)))
    (+ (v! (- (* a a) (* b b)) (* 2 a b)) c)))

(defun-g get-color ((i :int) (m :int))
  (let ((c (expt (/ (float m) +pi+) -1))
	(fi (float i)))
    (v! (* 0.5 (+ 1 (cos (* fi 1 c))))
	(* 0.5 (+ 1 (cos (* fi 3 c))))
	(* 0.5 (+ 1 (cos (* fi 5 c))))
	1.0)))

(defun-g mandelbrot-check ((uv :vec2))
  (let ((tmp (v! 0 0))
	(val 0))
    (dotimes (i 256)
      (cond ((> (length tmp) 2.0) (setf val i) (break))
	    ((= i (1- 256)) (setf val i) (break))
	    (t (setf tmp (mandelbrot-iter tmp uv)))))
    (get-color val 256)))

(defun-g frag-mb ((uv :vec2))
  (mandelbrot-check uv))

(defpipeline-g prog-1 ()
  :vertex (vert-pt g-pt)
  :fragment (frag-mb :vec2))

(defun step-demo ()
  (step-host)
  (update-repl-link)
  (clear)
  (map-g #'prog-1 *vert-stream*
	 :zoom *zoom*
	 :position *position*)
  (swap))

(let ((running nil))
  (defun run-loop ()
    (setf running t)
    (setf *listen* (listen-to #'kb-listener (keyboard) :button))
    (setf *vert-stream* (make-buffer-stream
		      (make-gpu-array
		       (mapcar (lambda (i) (nth i *rect*)) '(0 3 1 1 3 2))
		       :dimensions 6 :element-type 'g-pt)))
    (loop :while (and running (not (shutting-down-p))) :do
	 (continuable (step-demo))))
  (defun stop-loop ()
    (stop-listening *listen*)
    (setf *listen* nil)
    (setf running nil)))


