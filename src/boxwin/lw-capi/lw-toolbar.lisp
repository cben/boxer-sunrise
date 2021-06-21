(in-package :boxer-window)

(defun text-toolbar-toggle-callback (self)
  (with-slots (text-toolbar) self
    (let ((toggle-button (elt (capi:collection-items
                               (elt (capi:collection-items text-toolbar) 0))
                              0)))
    ;; (set-toolbar-test-message
    ;;  self (string-append "Text Toggle "
    ;;                      (if (capi:item-selected toggle-button)
    ;;                          "On"
    ;;                        "Off")))
                           )))

(defun text-toolbar-switch-callback (self)
  (with-slots (text-toolbar) self
    (let ((number-button (elt (capi:collection-items text-toolbar) 2)))
      (setf (capi:item-data number-button)
            ;; A random number that often changes in length.
            (+ 1 (random 9) (* (1+ (random 9)) (expt 10 (random 5))))))
    (set-toolbar-test-message self "Randomize Number")))

(defun text-toolbar-number-callback (self)
  (with-slots (text-toolbar) self
    (let ((number-button (elt (capi:collection-items text-toolbar) 2)))
      (set-toolbar-test-message self
                                (format nil "Number ~D"
                                        (capi:item-data number-button))))))

(defun make-change-font-toolbar-button-menu (self)
  (make-instance
   'capi:menu
   :items boxer::*font-families* ;;'("Arial" "Courier New" "Times New Roman" "Verdana")
   :callback-type :data
   :callback (lambda (num)
               (with-slots (change-font-toolbar-button) self
                 (setf (capi:item-text change-font-toolbar-button)
                       num)
               (format t "~%toolbar font num: ~A" num)
               (font-menu-action num 0)))))

(defun make-change-fontsize-toolbar-button-menu (self)
  (make-instance
   'capi:menu
   :items '("8" "9" "10" "11" "12" "14" "16" "18" "20" "22" "24" "26" "28" "36" "48" "72")
   :callback-type :data
   :callback (lambda (num)
               (with-slots (change-fontsize-toolbar-button) self
                 (setf (capi:item-text change-fontsize-toolbar-button)
                       num)
                 (font-size-menu-action (parse-integer num) 0)
                       ))))

(defun make-change-fontcolor-toolbar-button-menu (self)
  (make-instance
   'capi:menu
   :items '("Black")
;;    (list (make-instance 'capi::menu-item
;;                                                          :title "Black" :data boxer::*black*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "White" :data boxer::*white*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Red" :data boxer::*red*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Green" :data boxer::*green*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Blue" :data boxer::*blue*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Cyan" :data boxer::*cyan*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Magenta" :data boxer::*magenta*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Yellow" :data boxer::*yellow*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Orange" :data boxer::*orange*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Purple" :data boxer::*purple*)
;;                                           (make-instance 'capi::menu-item
;;                                                          :title "Gray" :data boxer::*gray*))
   :callback-type :data
   :callback (lambda (num)
               (with-slots (change-fontcolor-toolbar-button) self
                 (setf (capi:item-text change-fontcolor-toolbar-button)
                       num)
                 (font-color-menu-action num 0)))))

(defun set-toolbar-test-message (self message)
;;   (with-slots (message-pane) self
;;     (setf (capi:title-pane-text message-pane)
;;           (format nil "~A was selected." message)))
  (format t "~A was selected." message)
          )
