;;;; package information

(in-package #:cl-bitcoin)

;;; externally visible functions - this class contains the public api for
;;; cl-bitcoin as well as the function building framework that we need to
;;; easily handle the multiple return types that are possible from the
;;; bitcoind server methods 

;; function building framework - resolving function return types into 
;; specific btc objects (as defined in classes.lisp)

(defun create-btc-obj (fn result err id)
  "A basic factory function - takes a bitcoind method name and its results, then
   parses that information into cl-bitcoin objects for the end user"
  (case fn
    ((:addmultisigaddress :addnode :backupwallet :importprivkey :keypoolrefill
			  :walletlock :walletpassphrasechange) 
     (make-instance 'btc-base :err  err :id id))
    ((:dumpprivkey :encryptwallet :getaccount :getaccountaddress :getaddressesbyaccount
		   :getbalance :getbestblockhash :getblockcount :getblockhash 
		   :getconnectioncount :getdifficulty :getgenerate :gethashespersec
		   :getnewaddress :getrawchangeaddress :getreceivedbyaccount 
		   :getreceivedbyaddress :help 
		   :walletpassphrase)
     (make-btc-single result err id))
    (:getblock         (make-btc-block result err id))
    (:getblocktemplate (make-btc-blocktemplate result err id))
    (:getinfo          (make-btc-info result err id))
    (:getmininginfo    (make-btc-mininginfo result err id))
    (:gettxoutsetinfo  (make-btc-txoutset result err id))
    (:getwork          (make-btc-workinfo result err id))
    (:listsinceblock   (make-btc-sinceblock result err id))
    (otherwise (error "Unable to parse function ~S to a btc object" fn))))

(defmacro defbtcfun (name &rest args)
  "Defines a function that will be exported as part of the cl-bitcoin public API."
  ; function definitions may specify &optional - don't pass that to bitcoind!
  (let ((passargs (remove "&" args :test #'(lambda (x y) 
					    (string= x (subseq (string y) 0 1))))))
  `(progn
     (eval-when (:compile-toplevel :load-toplevel :execute)
       (export ',name 'cl-bitcoin))
     (defun ,name ,args
       (let ((g (intern (string ',name) :keyword)))
	 (multiple-value-bind (result err id) (get-bitcoind-result g ,@passargs)
	   (create-btc-obj g result err id)))))))

;; function definitions (each of these functions should have a corresponding case in 
;; create-btc-obj above, otherwise a condition will be signaled)
;; optional parameters with no values supplied are not sent to the bitcoind server at all
;; the server default values will therefore be used in every case

; methods that resolve into btc-base
(defbtcfun addmultisigaddress nrequired keys &optional account)
(defbtcfun addnode node specifier)
(defbtcfun backupwallet destination)
(defbtcfun importprivkey bitcoinprivkey &optional label rescan)
(defbtcfun keypoolrefill)
(defbtcfun walletlock)
(defbtcfun walletpassphrasechange)

; methods that resolve into btc-single
(defbtcfun dumpprivkey bitcoinaddress)
(defbtcfun encryptwallet passphrase)
(defbtcfun getaccount bitcoinaddress)
(defbtcfun getaccountaddress account)
(defbtcfun getaddressesbyaccount account)
(defbtcfun getbalance &optional account minconf)
(defbtcfun getbestblockhash)
(defbtcfun getblockcount)
(defbtcfun getblockhash)
(defbtcfun getconnectioncount)
(defbtcfun getdifficulty)
(defbtcfun getgenerate)
(defbtcfun gethashespersec)
(defbtcfun getnewaddress &optional account)
(defbtcfun getrawchangeaddress &optional account)
(defbtcfun getreceivedbyaccount account &optional minconf)
(defbtcfun getreceivedbyaddress bitcoinaddress &optional minconf)
(defbtcfun help method)
(defbtcfun walletpassphrase passphrase timeout)

; methods that resolve into their own types
(defbtcfun getblock hash)
(defbtcfun getblocktemplate) ;TODO: this can take an optional JSON object parameter
(defbtcfun getinfo)
(defbtcfun getmininginfo)
(defbtcfun gettxoutsetinfo)
(defbtcfun getwork)
(defbtcfun listsinceblock &optional blockhash target-confirmations)

;TODO: handle getpeerinfo
;TODO: handle getrawmempool
;TODO: handle gettransaction
;TODO: handle gettxout
;TODO: handle getwork with supplied data
;TODO: handle listaccounts
;TODO: handle listaddressgroupings (nothing returned for some reason..?)
;TODO: handle listreceivedbyaccount
;TODO: handle listreceivedbyaddress
;TODO: handle listtransactions
;TODO: handle listunspent