;;;;; -*- Mode:LISP; Syntax: Common-Lisp; Package:BOXER; Base:8.-*-
;;;;
;;;;    Boxer
;;;;    Copyright 1985-2022 Andrea A. diSessa and the Estate of Edward H. Lay
;;;;
;;;;    Portions of this code may be copyright 1982-1985 Massachusetts Institute of Technology. Those portions may be
;;;;    used for any purpose, including commercial ones, providing that notice of MIT copyright is retained.
;;;;
;;;;    Licensed under the 3-Clause BSD license. You may not use this file except in compliance with this license.
;;;;
;;;;    https://opensource.org/licenses/BSD-3-Clause
;;;;
;;;;
;;;;                                         +-Data--+
;;;;                This file is part of the | BOXER | system
;;;;                                         +-------+
;;;;
;;;;   This file contains the low level drawing primitives which are
;;;;   machine independent.  This file is meant to coexist with various
;;;;   "xxx-draw-low" files which are the machine specific primitives.
;;;;
(in-package :boxer)

;;;
;;; DRAWING-ON-WINDOW macros
;;;

(defmacro drawing-on-window ((window) &body body)
  "DRAWING-ON-WINDOW is an &body macro which all the drawing macros in this
must be called inside of. It basically prepares the window to be drawn on
and binds all the magic variables that the drawing macros need including
the bootstrapping of the clipping and coordinate scaling variables."
  (once-only (window)
    `(prepare-sheet (,window)
       (drawing-on-window-without-prepare-sheet (,window) . ,body))))

(defmacro drawing-on-window-bootstrap-clipping-and-scaling ((x y wid hei) &body body)
  `(let* ((%origin-x-offset ,x) (%origin-y-offset ,y)
          ;; absolute clipping parameters
          (%clip-lef ,x) (%clip-top ,y)
    (%clip-rig (+& %clip-lef ,wid)) (%clip-bot (+& %clip-top ,hei))
          ;; relative clipping parameters
          (%local-clip-lef 0)    (%local-clip-top 0)
          (%local-clip-rig ,wid) (%local-clip-bot ,hei))
     %clip-rig %clip-bot %origin-x-offset %origin-y-offset ;bound but never...
     %local-clip-lef %local-clip-top %local-clip-rig %local-clip-bot
                ,@body))

(defmacro drawing-on-window-without-prepare-sheet ((window) &body body)
  "DRAWING-ON-WINDOW-WITHOUT-PREPARE-SHEET is a variant of Drawing-On-Window
which does everything Drawing-On-Window does except that it does not do a
PREPARE-SHEET of the window. Unless you really know what you are doing
you should only use this inside the :BLINK method for a blinker."
  (once-only (window)
    `(let ((%drawing-window ,window)
           (%drawing-array  ,window))
       %drawing-window %drawing-array    ;bound but never...
       (drawing-on-window-bootstrap-clipping-and-scaling
         (0 0
          (sheet-inside-width ,window) (sheet-inside-height ,window))
          . ,body))))

(defmacro drawing-on-bitmap ((bitmap) &body body)
  "Used instead of DRAWING-ON-WINDOW for bitmaps."
  (let ((bwidth-var (gensym)) (bheight-var (gensym)))
    `(let ((%drawing-window ,bitmap) (%drawing-array ,bitmap)
             (,bwidth-var (offscreen-bitmap-width ,bitmap))
             (,bheight-var (offscreen-bitmap-height ,bitmap)))
         %drawing-window %drawing-array ; bound but never used errors....
         (drawing-on-window-bootstrap-clipping-and-scaling
           (0 0 ,bwidth-var ,bheight-var)
           (with-system-dependent-bitmap-drawing (,bitmap ,bwidth-var ,bheight-var)
       . ,body)))))

;;;
;;; Scaling and Clipping Macros
;;;

;; origin gets reset in hardware by scaling macros so these are no ops
;; They need to be defined because other functions (usually sprite graphics)
;; will use them explicitly to convert coords.
(defmacro scale-x (x) x)
(defmacro scale-y (y) y)

(defmacro with-drawing-inside-region ((x y wid hei) &body body)
  "**** this is the reverse of the software version because the
WITH-CLIPPING-INSIDE macro should use the new coordinate system
set by WITH-ORIGIN-AT"
  `(with-origin-at (,x ,y)
     (with-clipping-inside (0 0 ,wid ,hei)
       . ,body)))

(defmacro with-origin-at ((x y) &body body)
  "Opengl set-origin is RELATIVE !"
  (let ((fx (gensym)) (fy (gensym)) (ux (gensym)) (uy (gensym)))
    `(let* ((,fx (float ,x)) (,fy (float ,y))
            (,ux (float-minus ,fx)) (,uy (float-minus ,fy))
            ;; keep track of scaling because bitblt doesn't respect OpenGL translation
            (%origin-x-offset (+ %origin-x-offset ,x))
            (%origin-y-offset (+ %origin-y-offset ,y)))
       (unwind-protect
           (progn
             (window-system-dependent-set-origin ,fx ,fy)
             . ,body)
         (window-system-dependent-set-origin ,ux ,uy)))))

(defmacro with-clipping-inside ((x y wid hei) &body body)
  `(with-window-system-dependent-clipping (,x ,y ,wid ,hei) . ,body))

(defmacro with-scrolling-origin ((scroll-x scroll-y) &body body)
  ;; do we need to readjust the clip region here ????
  `(with-origin-at (,scroll-x ,scroll-y)
     . ,body))

(defmacro with-turtle-clipping ((wid hei . args) &body body)
  "This MUST use the hardware clipping regardless of speed.
It is used only around bodies which do sprite graphics
so the frequency of use is MUCH less than it is in the redisplay

this adjusts the clipping to be width and height AT the current
scaled origin"
  `(with-window-system-dependent-clipping (0 0 ,wid ,hei . ,args) . ,body))

;;;
;;; Drawing functions
;;;

(defun draw-arc (alu x y wid hei start-angle sweep-angle)
  (%draw-arc %drawing-window alu (scale-x x) (scale-y y)
             wid hei start-angle sweep-angle))

(defun draw-cha (char x y)
  "Draw-cha needs to draw at the char's baseline rather than the top left corner.  In a
multifont row, the common reference point will be the baseline instead of the top edge"
  (%draw-cha x y char))

(defun draw-circle (x y radius &optional filled?)
  (%draw-circle x y radius filled?))

(defun draw-filled-arc (alu x y wid hei start-angle sweep-angle)
  (%draw-filled-arc %drawing-window alu (scale-x x) (scale-y y)
                    wid hei start-angle sweep-angle))

(defun draw-line (x0 y0 x1 y1)
  (%draw-line x0 y0 x1 y1))

(defun draw-point (x y)
  (%draw-point x y))

(defun draw-poly (points)
  ;; should'nt transform the points because translation is done @ hardware level in OpenGL
  (unless (null points)
    (%draw-poly (boxer-points->window-system-points points (x x) (y y)))))

(defun draw-rectangle (w h x y)
  (%draw-rectangle w h x y))

(defun erase-rectangle (w h x y)
  (%erase-rectangle w h x y %drawing-window))

(defun draw-string (font-no string region-x region-y)
  (%draw-string font-no string region-x region-y))


(defun bitblt-to-screen (wid hei from-array from-x from-y to-x to-y)
  (%bitblt-to-screen wid hei from-array from-x from-y to-x to-y))

(defun bitblt-from-screen (wid hei to-array from-x from-y to-x to-y)
  (%bitblt-from-screen wid hei to-array from-x from-y to-x to-y))


(defun swap-graphics-buffers (&optional (pane *boxer-pane*))
  (%flush-port-buffer pane))

;;;
;;; Drawing operations to wrap Graphics List Playback to allow for varying performance
;;; optimizations
;;;
;;; For instance, in OpenGL we can put a bunch of lines on a C buffer and then draw them
;;; at once, and this requires keeping track of some state variables. The methods below
;;; allow you to perform these initializations, drawing, finalizations before and after
;;; iterating through a list of graphics commands, and before each graphic command is processed.
;;;

(defun draw-before-graphics-list-playback (gl)
  (%draw-before-graphics-list-playback gl))

(defun draw-after-graphics-list-playback (gl)
  (%draw-after-graphics-list-playback gl))

(defun draw-before-graphics-command-marker (command gl)
  (%draw-before-graphics-command-marker command gl))
