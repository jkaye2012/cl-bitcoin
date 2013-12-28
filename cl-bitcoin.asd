;;;; cl-bitcoin.asd

(asdf:defsystem #:cl-bitcoin
  :serial t
  :depends-on (#:drakma
               #:flexi-streams
               #:cl-json)
  :components ((:file "package")
               (:file "bitcoin")
	       (:file "classes")
	       (:file "functions")))

