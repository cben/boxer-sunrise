(in-package :opengl)

(defconstant *GL-AUX-BUFFERS*                      #x0C00)
(defconstant *GL-AUX1*                             #x040A)
(defconstant *GL-BACK*                             #x0405)
(defconstant *GL-BLEND*                            #x0BE2)
(defconstant *GL-COLOR-BUFFER-BIT*                 #x00004000)
(defconstant *GL-CURRENT-COLOR*                    #x0B00)
(defconstant *GL-LINES*                            #x0001)
(defconstant *GL-LINE-LOOP*                        #x0002)
(defconstant *GL-LINE-SMOOTH-HINT*                 #x0C52)
(defconstant *GL-LINE-SMOOTH*                      #x0B20)
(defconstant *GL-LINE-STIPPLE*                     #x0B24)
(defconstant *GL-LINE-STRIP*                       #x0003)
(defconstant *GL-LINE-WIDTH*                       #x0B21)
(defconstant *GL-NICEST*                           #x1102)
(defconstant *GL-ONE-MINUS-SRC-ALPHA*              #x0303)
(defconstant *GL-POLYGON*                          #x0009)
(defconstant *GL-POLYGON-SMOOTH*                   #x0B41)
(defconstant *GL-PROJECTION*                       #x1701)
(defconstant *GL-SCISSOR-TEST*                     #x0C11)
(defconstant *GL-SRC-ALPHA*                        #x0302)

(defconstant *GL-RGBA*                             #x1908)
(defconstant *GL-UNSIGNED-BYTE*                    #x1401)


(defun free-gl-vector (object))
(defun gl-begin (mode))
(defun gl-blend-func (sfactor dfactor))
(defun gl-clear (mask))
(defun gl-clear-color (red green blue alpha))
(defun gl-color4-fv (v))
(defun gl-disable (cap))
(defun gl-draw-buffer (mode))
(defun gl-enable (cap))
(defun gl-end ())
(defun gl-flush ())
(defun gl-get-booleanv (pname params))
(defun gl-get-floatv (pname params))
(defun gl-get-integerv (pname params) )
(defun gl-hint (target mode) )
(defun gl-is-enabled (cap) )
(defun gl-line-width (width) )
(defun gl-load-identity () )
(defun gl-matrix-mode (mode) )
(defun gl-ortho (left right bottom top z-near z-far) )
(defun gl-point-size (size) )
(defun gl-rectf (x1 y1 x2 y2) )
(defun gl-scissor (x y width height) )
(defun gl-translatef (x y z) )
(defun gl-vector-aref (object subscript) )
(defun gl-vertex2-f (x y) )
(defun gl-viewport (x y width height) )
(defun make-gl-vector (type length &key (contents nil contentsp)) )

; opengl-pane is a capi pane...
; swap-buffers is also a capi method
; describe-configuration is a capi method too

(defmacro rendering-on ((opengl-pane) &body body) )


