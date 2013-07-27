;;;; spellcheck.lisp
;;;;
;;;; Peter Norvig's spell corrector
;;;; (http://norvig.com/spell-correct.html) by Mikael Jansson
;;;; <mikael@lisp.se>
;;;;
;;;; Packaging and minor modifications by Rob Blackwell
;;;; <rob.blackwell@robblackwell.org.uk>

(in-package #:spellcheck)

(defvar *alphabet* "abcdefghijklmnopqrstuvwxyz")

(defparameter *freq* (make-hash-table :test #'equal))

(defun reset ()
  "Resets the default frequency distribution to empty."
  (setf *freq* (make-hash-table :test #'equal)))

(defun words (string)
  "Tokenizes string into a list of words."
  (cl-ppcre:all-matches-as-strings "[a-z]+" string))

(defun train (words &key (frequency *freq*))
  "Adds the given list of words to the frequency distribution."
  (dolist (word words)
    ;; default 1 to make unknown words OK
    (setf (gethash word frequency) (1+ (gethash word frequency 1))))
  frequency)

(defun train-with-file (&optional (filename 
				   (merge-pathnames (asdf:system-source-directory :spellcheck) "big.txt"))
			&key (frequency *freq*))
  "Adds the list of words from the given file to the frequency distribution."
  (train (words (nstring-downcase (read-file-into-string filename))) :frequency frequency))

(defun initialize ()
  "Initialize with default settings."
  (reset)
  (train-with-file))

(defun edits-1 (word)
  "Returns a list of one character edits of word."
  (let* ((splits (loop for i from 0 upto (length word)
		    collecting (cons (subseq word 0 i) (subseq word i))))
         (deletes (loop for (a . b) in splits
		     when (not (zerop (length b)))
		     collect (concatenate 'string a (subseq b 1))))
         (transposes (loop for (a . b) in splits
			when (> (length b) 1)
			collect (concatenate 'string a (subseq b 1 2) (subseq b 0 1) (subseq b 2))))
         (replaces (loop for (a . b) in splits
		      nconcing (loop for c across *alphabet*
				  when (not (zerop (length b)))
				  collect (concatenate 'string a (string c) (subseq b 1)))))
         (inserts (loop for (a . b) in splits
		     nconcing (loop for c across *alphabet*
				 collect (concatenate 'string a (string c) b)))))
    (nconc deletes transposes replaces inserts))) 

(defun known-edits-2 (word &key (frequency *freq*))
  "Returns the list of two character edits of word."
  (loop for e1 in (edits-1 word) nconcing
       (loop for e2 in (edits-1 e1)
	  when (gethash word frequency)
	  collect e2)))

(defun known (words &key (frequency *freq*))
  "Looks up the list of words to see if they are known."
  (loop for word in words
     when (gethash word frequency)
     collect word))

(defun known-word-p (word &key (frequency *freq*))
  "Returns true if word is known."
  (gethash word frequency))

(defun correct (word &key (frequency *freq*))
  "Returns the most likely spelling correction of word, or word itself."
  (loop for word in (or (known (list word) :frequency frequency) 
			(known (edits-1 word)) 
			(known-edits-2 word :frequency frequency) 
			(list word))
     maximizing (gethash word frequency 1)
     finally (return word)))



