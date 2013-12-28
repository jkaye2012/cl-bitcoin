;;;; package.lisp

(defpackage #:cl-bitcoin
  (:use #:cl)
  (:export #:btc-base-err
	   #:btc-base-id
	   #:with-connection-parameters
	   #:set-connection-parameters
	   #:reset-rpc-id))

