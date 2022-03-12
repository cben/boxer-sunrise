;;; -*- Package: EVAL; Mode: LISP; Base: 10; Syntax: Common-lisp -*-
;;;
;;; $Header: recursive-prims.lisp,v 1.0 90/01/24 22:16:18 boxer Exp $
;;;
;;; $Log:	recursive-prims.lisp,v $
;;;Revision 1.0  90/01/24  22:16:18  boxer
;;;Initial revision
;;;

#|

    Boxer
    Copyright 1985-2022 Andrea A. diSessa and the Estate of Edward H. Lay

    Portions of this code may be copyright 1982-1985 Massachusetts Institute of Technology. Those portions may be
    used for any purpose, including commercial ones, providing that notice of MIT copyright is retained.

    Licensed under the 3-Clause BSD license. You may not use this file except in compliance with this license.

    https://opensource.org/licenses/BSD-3-Clause


                                      +-------+
             This file is part of the | Boxer | System
                                      +-Data--+


 9/06/09 Errant #-opengl caused change shape bug
 1/13/02 UPDATE-SHAPE: do nothing if there are graphics and no text
 1/13/02 Start logging changes: source = boxer version 2.5

|#

;;;

(in-package :boxer-eval)

;;;
;;; This file contains defrecursive-*-primitives that should
;;; go in other files when Lucid fixes the defstruct package lossage.

;;; From GRPRIM:

;this isn't quite right either.  it will produce a value if the shape
;produces a value. we don't want to produce a value.  also the
;two with-sprite-primitive-environment calls assume that the
;sprite hasn't changed in the execution of the shape box.
;we could check explicitly.  It also won't work with multiple sprites.

(defrecursive-funcall-primitive bu::update-shape ()
  :STACK-FRAME-ALLOCATION (1 1 1 1) ;; nested update-shapes?
  :STATE-VARIABLES (boxer::%learning-shape? boxer::%turtle-state
                    boxer::%learning-shape-graphics-list
                    boxer::*graphics-command-recording-mode*
                    boxer::*current-sprite*)
  ;; look at with-graphics-vars-bound to see how the value of
  ;; %learning-shape-graphics-list gets into %graphics-list
  :BEFORE
  (let* ((sprites (boxer::get-sprites))
         (turtle (slot-value sprites 'boxer::graphics-info)) ;'boxer::associated-turtle))
         (shape-slot (slot-value turtle 'boxer::shape))
         (shape-box (boxer::box-interface-box shape-slot)))
    (cond ((null sprites)
          ;; We can use signal-error instead of primitive-signal-error
          ;; because this is the last form to be executed in this
          ;; primitive, and will return.  I.e., we aren't going to
          ;; do SET-AND-SAVE-STATE-VARIABLES or RECURSIVE-FUNCALL-INVOKE.
          (signal-error :sprite-error "Don't have a Sprite to Talk to"))
          ((not (boxer::inside-sprite? sprites))
           ;; do nothing if the trigger has been invoked
           ;; outside of the sprite box
           )
          ((and (not (null (boxer::graphics-sheet shape-box)))
                (boxer::empty-box? shape-box))
           ;; do nothing if there are graphics and no text
           )
          (t
          (let* ((new-graphics-list (boxer::make-graphics-command-list))
                  (assoc-graphics-box (slot-value turtle
                          'boxer::assoc-graphics-box)))
             (cond
;              ((not (null (boxer::graphics-sheet
;                           (boxer::box-interface-box
;                            (slot-value turtle 'boxer::shape)))))
;               ;; if there is a graphical representation, prefer that
;               (boxer::set-shape turtle (boxer::box-interface-box
;                                         (slot-value turtle 'boxer::shape))))
               (t
                (set-and-save-state-variables
                 t (boxer::reset-turtle-and-return-state turtle)
                 new-graphics-list ':boxer sprites)
                (boxer::new-shape-preamble turtle new-graphics-list)
                (setf (boxer::box-interface-value shape-slot) new-graphics-list)
                (unless (null shape-box)
                  (recursive-funcall-invoke
                   (convert-data-to-function shape-box)))))))))
  :AFTER
  ;; we will make it in error to do TELL JOE... inside shapes.
  (let* ((sprites (boxer::get-sprites))
        (turtle (slot-value sprites 'boxer::graphics-info)) ;'boxer::associated-turtle))
        (assoc-graphics-box (slot-value turtle 'boxer::assoc-graphics-box)))
    ;; no need to check for a null sprite since we did it in the :BEFORE clause
    (setq boxer::%learning-shape-graphics-list nil)
    (unwind-protect
        ;; this protects against aborting out of errors
        ;; inside of Update-Save-Under
        (progn (setq boxer::%learning-shape? nil)
           #-opengl (boxer::update-save-under turtle))
      (boxer::update-window-shape-allocation turtle)
      (boxer::restore-turtle-state turtle boxer::%turtle-state))
      (restore-state-variables))
  :UNWIND-PROTECT-FORM
  (let* ((sprites (boxer::get-sprites))
        (turtle (slot-value sprites 'boxer::graphics-info)) ;'boxer::associated-turtle))
        (assoc-graphics-box (slot-value turtle 'boxer::assoc-graphics-box)))
    ;; no need to check for a null sprite since we did it in the :BEFORE clause
    (setq boxer::%learning-shape-graphics-list nil)
    ;; why is this let necessary?
    (let ((old-state boxer::%turtle-state))
      ;;must clear boxer::%learning-shape? before moving
      (setq boxer::%learning-shape? nil)
      ;; the shape can be in an inconsistent state here so make
      ;; sure all the things that depend on the shape synchronize
      ;; themselves to the shape's current state
      ; sgithens remove #-opengl (boxer::update-save-under turtle)
      (boxer::update-window-shape-allocation turtle)
      (boxer::restore-turtle-state turtle old-state))
    (restore-state-variables)))

(boxer::add-sprite-update-function boxer::shape bu::update-shape)

;;; private drawing
(defrecursive-funcall-primitive bu::draw-private ((list-rest what))
  :STACK-FRAME-ALLOCATION (1 1 1 1)
  :STATE-VARIABLES (boxer::%private-graphics-list)
  :BEFORE (let* ((sprites (boxer::get-sprites))
                 (turtle (slot-value sprites 'boxer::graphics-info))
                 (private-list
                  (when (boxer::turtle? turtle)
                    (or (slot-value turtle 'boxer::private-gl)
                        (let ((newpgl (boxer::make-graphics-command-list)))
                          (setf (slot-value turtle 'boxer::private-gl) newpgl)
                          newpgl)))))
            (cond ((null private-list))
                  (t
                   (set-and-save-state-variables private-list)
                   (recursive-funcall-invoke
                    (make-interpreted-procedure-from-list (list what))))))
  :AFTER (progn (restore-state-variables) nil))

;;;; WITHOUT-RECORDING

(defrecursive-funcall-primitive bu::without-recording ((list-rest what))
  :STACK-FRAME-ALLOCATION (10 5 10 10)
  :STATE-VARIABLES (boxer::*supress-graphics-recording?*)
  :BEFORE (progn (set-and-save-state-variables T)
                 (recursive-funcall-invoke
                  (make-interpreted-procedure-from-list (list what))))
  :AFTER  (progn (restore-state-variables) nil))
