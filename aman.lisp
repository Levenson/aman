;; Filename: aman.lisp
;; Description: 
;; Author: User Alex
;; 
;; Maintainer: 
;; Created: Sat May 12 17:06:59 2012 (+0400)
;; Version: 
;; Last-Updated: Sun May 13 23:35:02 2012 (+0400)
;;           By: alex
;;     Update #: 56
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package :aman)

(defvar *event-base*)

(defun make-ami-session (host port username secret &optional &key (events nil))
  (let ((socket (make-socket :connect :active :address-family :internet
			     :type :stream :external-format '(:utf-8 :eol-style :crlf)
			     :ipv6 nil)))
    (let ((ami (%make-ami-session :host host :port port
				  :username username :secret secret
				  :events events :socket socket)))
      (handler-case
	  (progn
	    (connect socket (lookup-hostname host) :port port :wait t)
	    ;; Read hello.
	    (read-line socket)
	    (send-action ami (%make-ami-action :name "login" :id 1 :argv
					       (list (cons "username" username)
						     (cons "secret" secret))))
	    ami)))))

(defun client-disconnector (socket)
  ;; When this function is called, it can be told which callback to remove, if
  ;; no callbacks are specified, all of them are removed! The socket can be
  ;; additionally told to be closed.
  (lambda (&rest events)
    (format t "Disconnecting socket: ~A~%" socket)
    (let ((fd (socket-os-fd socket)))
      (if (not (intersection '(:read :write :error) events))
          (remove-fd-handlers *event-base* fd :read t :write t :error t)
          (progn
            (when (member :read events)
              (remove-fd-handlers *event-base* fd :read t))
            (when (member :write events)
              (remove-fd-handlers *event-base* fd :write t))
            (when (member :error events)
              (remove-fd-handlers *event-base* fd :error t)))))
    ;; and finally if were asked to close the socket, we do so here
    (when (member :close events)
      (close socket))))

(defun run-client (&key (host *host*) (port *port*))
  (let ((*event-base* nil))
    (unwind-protect
         (progn
           ;; When the connection gets closed, either intentionally in the client
           ;; or because the server went away, we want to leave the multiplexer
           ;; event loop. So, when making the event-base, we explicitly state
           ;; that we'd like that behavior.
           (setf *event-base*
                 (make-instance 'iomux:event-base :exit-when-empty t))

           (handler-case
               (make-ami-session host port "skytel" "secret")

             ;; handle a commonly signaled error...
             (socket-connection-refused-error ()
               (format t
                       "Connection refused to ~A:~A. Maybe the server isn't running?~%"
                       (lookup-hostname "localhost") port))))

      ;; ensure we clean up the event base regardless of how we left the client
      ;; algorithm
      (when *event-base*
        (close *event-base*))
      (format t "Client Exited.~%"))))

(defmacro with-ami-session ((var &rest argv) &body body)
  `(let ((,var (make-ami-session ,@argv)))
     (unwind-protect
	  (progn
	    ,@body)
       (ami::close-session ,var))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; aman.lisp ends here
