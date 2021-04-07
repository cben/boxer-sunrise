;;;;
;;;;      Boxer
;;;;      Copyright 1985-2020 Andrea A. diSessa and the Estate of Edward H. Lay
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
;;;;   This file contains the `start-boxer` function for use in the MacOS .app bundle.
;;;;

(in-package :boxer)

(defun base-install-folder ()
  "Returns the base installed folder of boxer, which can be used to create deeper paths
   to the folders for fonts, libraries, and such from wherever boxer is installed or
   being run from the file system.

   This differs slightly between MacOS and Windows because of the folder the executable is
   placed in."
   #+mac (butlast (pathname-directory (lw:lisp-image-name)))
   #+win32 (pathname-directory (lw:lisp-image-name)))

(defun start-boxer ()
    ;; Here we are adding the Resources/libs directory of the application bundle
    ;; which will libfreetype.6.dylib, as well as any other *.dylib and *.dll files.
    (pushnew
        (make-pathname :host (pathname-host (lw:lisp-image-name))
                       :directory(append (base-install-folder) '("Resources" "libs")))
        cffi:*foreign-library-directories* :test #'equal)

    ;; This adds the directory where we are keeping the compiled version of freetype2,
    ;; such that it can be included eventually using asdf:load-system.

    ;; sgithens, I don't think this is necessary at the moment since we're manually loading things...
    (setf asdf:*central-registry*
               (list* '*default-pathname-defaults*
                      (make-pathname :directory
                        (append (butlast (pathname-directory (lw:lisp-image-name)))
                        '("Resources" "cl-deps" "cl-freetype2")))
                asdf:*central-registry*))


    ;; sgithens 2020-12-09 This requires some explanation. We are currently manually loading
    ;; the entire cl-freetype2 system, rather than using asdf because:
    ;;  - cffi grovel is invoked on loading :cl-freetype2
    ;;  - this uses compile-file
    ;;  - compile-file is not available on delivered lispworks applications
    ;;  - currently on MacOS unloading of C modules is not supported, so we can't add it as
    ;;    part of the image during delivery
    ;;
    ;;  We are working on isolating the location where cl-freetype2 calls compile-file, or
    ;;  other possible fixes. Hopefully this will be removed in the near future and the
    ;;  asdf:load-system call used instead.
    ;; (asdf:load-system :cl-freetype2)
    (let ((freetype-deps-dir (make-pathname
                               :host (pathname-host (lw:lisp-image-name))
                               :directory (append (base-install-folder) '("Resources" "cl-deps" "cl-freetype2" "src"))))
          (freetype-source-parts '("package"
                                   "ffi/grovel/grovel-freetype2"
                                   "ffi/cffi-cwrap"
                                   "ffi/cffi-defs"
                                   "ffi/ft2-lib"
                                   "ffi/ft2-init"
                                   "ffi/ft2-basic-types"
                                   "ffi/ft2-face"
                                   "ffi/ft2-glyph"
                                   "ffi/ft2-size"
                                   "ffi/ft2-outline"
                                   "ffi/ft2-bitmap"
                                   "init"
                                   "face"
                                   "bitmap"
                                   "glyph"
                                   "render"
                                   "outline"
                                   "toy")))
      (dolist (source-part freetype-source-parts)
        ;; Currently the file extensions for 64-bit x86 compiled lisp files on MacOS and Windows
        ;; are .64xfasl and 64ofasl respectively
        #+mac (load (merge-pathnames (concatenate 'string source-part ".64xfasl") freetype-deps-dir))
        #+win32 (load (merge-pathnames (concatenate 'string source-part ".64ofasl") freetype-deps-dir))))


    ;; Adding the fonts directory based on whereever this MacOS application happens to
    ;; be running from.
    (setf *capogi-font-directory* (make-pathname
                                                  :host (pathname-host (lw:lisp-image-name))
                                                  :directory (append (base-install-folder) '("Resources" "Fonts"))))

    ;; See the above comments on freetype, but we are manually loading our code for it
    ;; here, because the freetype package is not yet declared when we build our system.
    (load (make-pathname
            :host (pathname-host (lw:lisp-image-name))
            :directory (append (base-install-folder) '("Resources" "cl-deps"))
            :name "freetype-fonts" :type "lisp"))

    (boxer-window::window-system-specific-make-boxer)
    (boxer-window::window-system-specific-start-boxer)
    ;; Set the appropriate default font we'd like to have when the system starts.
    (boxer-window::font-size-menu-action 3 nil))
