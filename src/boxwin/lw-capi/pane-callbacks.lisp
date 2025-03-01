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

(in-package :boxer-window)

(defparameter *boxer-pane-initialized* nil)

(defun boxer-pane-display-callback (canvas x y wid hei)
  ;; canvas ignore

  (unless *boxer-pane-initialized*
    (opengl:rendering-on (*boxer-pane*)
                (initialize-ogl-color-pool)
                (boxer::initialize-colors)
                (%set-pen-color box::*foreground-color*)
                ;; do other OpenGL inits...
                (setq *ogl-current-color-vector* (make-ogl-color 0.0 0.0 0.0)
                      *blinker-color* (make-ogl-color .3 .3 .9 .5))
                (opengl:gl-enable opengl:*gl-scissor-test*)
                (opengl::gl-enable opengl::*gl-line-smooth*)
                (opengl::gl-enable opengl::*gl-polygon-smooth*)
                (opengl::gl-enable opengl::*gl-blend*)
                (opengl::gl-blend-func opengl::*gl-src-alpha* opengl::*gl-one-minus-src-alpha*)
                (opengl::gl-hint opengl::*gl-line-smooth-hint* opengl::*gl-nicest*))

    (let ((arial-12 (boxer::make-boxer-font '("Arial" 12)))
          (arial-16 (boxer::make-boxer-font '("Arial" 16)))
          (arial-16-bold (boxer::make-boxer-font '("Arial" 16 :bold))))
      (setq  boxer::*normal-font-no*           arial-16
              boxer::*default-font*             arial-16
              boxer::*box-border-label-font-no* arial-12
              boxer::*border-label-font*        arial-12
              boxer::*box-border-name-font-no*  arial-16-bold
              boxer::*border-name-font*         arial-16-bold
              boxer::*sprite-type-font-no*      arial-16-bold
              boxer::*initial-graphics-state-current-font-no* arial-16-bold
              boxer::*graphics-state-current-font-no* arial-16-bold
              boxer::*boxtop-text-font*         arial-16-bold
      ))
    ;; #+freetype-fonts
    (boxer::load-freetype-faces)
    (let ((boxer::%private-graphics-list nil))
      ;; needed by shape-box updater in the redisplay inits but not set until
      ;; (boxer-eval::setup-evaluator) farther down
      (run-redisplay-inits))
      (resize-handler-utility)
      (setf *boxer-pane-initialized* t))

  (unless boxer::*evaluation-in-progress?*
    (resize-handler canvas x y wid hei))
)
