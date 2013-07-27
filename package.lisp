;;;; package.lisp

(defpackage #:spellcheck
  (:use #:cl #:alexandria)
  (:export
   #:*freq*
   #:reset
   #:initialize
   #:words
   #:train
   #:train-with-file
   #:correct))


