;;;; spellcheck.asd

(asdf:defsystem #:spellcheck
  :version "0.0.1"
  :author "Mikael Jansson <mikael@lisp.se>"
  :description "Peter Norvig's spell corrector."
  :serial t
  :depends-on (#:alexandria
	       #:cl-ppcre)
  :components ((:file "package")
	       (:file "spellcheck")))


