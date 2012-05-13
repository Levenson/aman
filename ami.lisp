;; -*- mode: lisp; -*-
;; Filename: ami.lisp
;; Description: 
;; Author: User Alex
;; 
;; Maintainer: 
;; Created: Sat May 12 13:20:48 2012 (+0400)
;; Version: 
;; Last-Updated: Sun May 13 12:49:44 2012 (+0400)
;;           By: User Alex
;;     Update #: 66
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :cl-user)

(defpackage ami
  (:use :cl :asdf :iolib)
  (:export :ami-session))

(in-package :ami)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Action

(defstruct (ami-action (:constructor %make-ami-action)
		       (:conc-name ami-action-))
  (name nil :type simple-array)
  (id nil :type fixnum)
  (argv nil :type list))

(defmethod print-object ((object ami-action) (stream stream))
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~s ID:~a" (ami-action-name object) (ami-action-id object))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Session

(defstruct (ami-session (:constructor %make-ami-session)
		(:conc-name ami-session-))
  ;; Hostname with AMI interface. 
  (host nil :type (or ipv4-address ipv6-address))
  ;; AMI port
  (port nil :type fixnum)
  (username nil :type simple-array)
  (secret nil :type simple-array)
  ;; not-NULL If you need to subscribe to events being generated by
  ;; Asterisk.
  (events nil :type boolean)
  (socket nil))

(defmethod print-object ((object ami-session) (stream stream))
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~a:~a" (ami-session-host object) (ami-session-port object))))

(defmethod send-action ((object ami-session) (action ami-action))
  (let  ((socket (ami-session-socket object)))
    (format socket "Action: ~a~%" (ami-action-name action))
    (format socket "ActionID: ~a~%" (ami-action-id action))
    (dolist (key/value (ami-action-argv action))
      (format socket "~a: ~a~%" (car key/value) (cdr key/value)))
    (finish-output socket)))

(defmethod get-respond ((object ami-session))
  (let ((socket (ami-session-socket object)))
    (format t "~a~%" (read-line socket))
    ;; (do ((line (read-line socket nil)
    ;; 	   (read-line socket nil)))
    ;;     ((equal line ""))
    ;;   (format t "~a~%" line))
    ))

(defmethod close-session ((object ami-session))
  (close (ami-session-socket object)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ami.lisp ends here