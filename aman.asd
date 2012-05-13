;; -*- mode: Lisp; -*-
;; Filename: aman.asd
;; Description: 
;; Author: User Alex
;; 
;; Maintainer: 
;; Created: Sat May 12 12:55:07 2012 (+0400)
;; Version: 
;; Last-Updated: Sat May 12 18:46:45 2012 (+0400)
;;           By: User Alex
;;     Update #: 23
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :cl-user)

(defpackage aman-asd
  (:use :cl :asdf))

(in-package :aman-asd)

(defsystem "aman"
  :description "Asterisk Management system"
  :author "Levensn@gmail.com"
  :license "MIT"
  :depends-on (:cffi :iolib)
  :components ((:file "ami")
	       (:file "package" :depends-on ("ami"))
	       (:file "aman" :depends-on ("package"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; aman.asd ends here
