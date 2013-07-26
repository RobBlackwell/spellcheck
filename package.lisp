;;;; package.lisp

(defpackage #:spellcheck
  (:use #:cl #:alexandria)
  (:export
   #:*freq*
   #:reset
   #:words
   #:train
   #:train-with-file
   #:correct
   #:conservative-correct))


