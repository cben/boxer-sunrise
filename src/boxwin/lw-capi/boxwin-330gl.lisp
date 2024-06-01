;;;;
;;;;      Boxer
;;;;      Copyright 1985-2022 Andrea A. diSessa and the Estate of Edward H. Lay
;;;;
;;;;      Portions of this code may be copyright 1982-1985 Massachusetts Institute of Technology. Those portions may be
;;;;      used for any purpose, including commercial ones, providing that notice of MIT copyright is retained.
;;;;
;;;;      Licensed under the 3-Clause BSD license. You may not use this file except in compliance with this license.
;;;;
;;;;      https://opensource.org/licenses/BSD-3-Clause
;;;;
;;;;
;;;;                                           +-Data--+
;;;;                  This file is part of the | BOXER | system
;;;;                                           +-------+
;;;;
;;;;
;;;;  CAPI interface and demo harness for OpenGL 330 Shaders use
(in-package :boxer)

(defclass boxwin-330gl-device ()
  ((draw-device)
   (frame)
   (pane)))

(defun resolution (&optional (pane *boxer-pane*))
  "Returns the boxer canvas resolution as vector of size 2. #(x y)"
  (make-array '(2) :initial-contents #+lispworks (list (gp:port-width pane) (gp:port-height pane))
                                     #+glfw-engine (list 800 600)))

(defun make-boxwin-330gl-device (gl-frame gl-pane &key (wid 600) (hei 600))
  (let* ((gl-device nil)
         (device (make-instance 'boxwin-330gl-device)))
    (setf gl-device (make-boxgl-device wid hei))
    (setf (slot-value device 'frame) gl-frame)
    (setf (slot-value device 'pane) gl-pane)
    (setf (slot-value device 'draw-device) gl-device)
  device))
