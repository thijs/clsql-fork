;;;; -*- Mode: LISP; Syntax: ANSI-Common-Lisp; Base: 10 -*-
;;;; *************************************************************************
;;;;
;;;; $Id$
;;;;
;;;; Definition of SQL operations used with the symbolic SQL syntax. 
;;;;
;;;; This file is part of CLSQL.
;;;;
;;;; CLSQL users are granted the rights to distribute and use this software
;;;; as governed by the terms of the Lisp Lesser GNU Public License
;;;; (http://opensource.franz.com/preamble.html), also known as the LLGPL.
;;;; *************************************************************************

(in-package #:clsql-sys)

;; Keep a hashtable for mapping symbols to sql generator functions,
;; for use by the bracketed reader syntax.

(defvar *sql-op-table* (make-hash-table :test #'equal))


;; Define an SQL operation type. 

(defmacro defsql (function definition-keys &body body)
  `(progn
     (defun ,function ,@body)
     (let ((symbol (cadr (member :symbol ',definition-keys))))
       (setf (gethash (if symbol (string-upcase symbol) ',function)
		      *sql-op-table*)
	     ',function))))


;; SQL operations

(defsql sql-query (:symbol "select") (&rest args)
  (apply #'make-query args))

(defsql sql-any (:symbol "any") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'any :components rest))

(defsql sql-all (:symbol "all") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'all :components rest))

(defsql sql-not (:symbol "not") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'not :components rest))

(defsql sql-union (:symbol "union") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'union :components rest))

(defsql sql-intersect (:symbol "intersect") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'intersect :components rest))

(defsql sql-minus (:symbol "minus") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'minus :components rest))

(defsql sql-group-by (:symbol "group-by") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'group-by :components rest))

(defsql sql-limit (:symbol "limit") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'limit :components rest))

(defsql sql-having (:symbol "having") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'having :components rest))

(defsql sql-null (:symbol "null") (&rest rest)
  (if rest
      (make-instance 'sql-relational-exp :operator '|IS NULL| 
                     :sub-expressions (list (car rest)))
      (make-instance 'sql-value-exp :components 'null)))

(defsql sql-not-null (:symbol "not-null") ()
  (make-instance 'sql-value-exp
		 :components '|NOT NULL|))

(defsql sql-exists (:symbol "exists") (&rest rest)
  (make-instance 'sql-value-exp
		 :modifier 'exists :components rest))

(defsql sql-* (:symbol "*") (&rest rest)
  (if (zerop (length rest))
      (make-instance 'sql-ident :name '*)
      ;(error 'clsql-sql-syntax-error :reason "'*' with arguments")))
      (make-instance 'sql-relational-exp :operator '* :sub-expressions rest)))

(defsql sql-+ (:symbol "+") (&rest rest)
  (if (cdr rest)
      (make-instance 'sql-relational-exp
                     :operator '+ :sub-expressions rest)
      (make-instance 'sql-value-exp :modifier '+ :components rest)))

(defsql sql-/ (:symbol "/") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator '/ :sub-expressions rest))

(defsql sql-- (:symbol "-") (&rest rest)
        (if (cdr rest)
            (make-instance 'sql-relational-exp
                           :operator '- :sub-expressions rest)
            (make-instance 'sql-value-exp :modifier '- :components rest)))

(defsql sql-like (:symbol "like") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator 'like :sub-expressions rest))

(defsql sql-uplike (:symbol "uplike") (&rest rest)
  (make-instance 'sql-upcase-like
		 :sub-expressions rest))

(defsql sql-and (:symbol "and") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator 'and :sub-expressions rest))

(defsql sql-or (:symbol "or") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator 'or :sub-expressions rest))

(defsql sql-in (:symbol "in") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator 'in :sub-expressions rest))

(defsql sql-|| (:symbol "||") (&rest rest)
    (make-instance 'sql-relational-exp
		 :operator '|| :sub-expressions rest))

(defsql sql-is (:symbol "is") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator 'is :sub-expressions rest))

(defsql sql-= (:symbol "=") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator '= :sub-expressions rest))

(defsql sql-== (:symbol "==") (&rest rest)
  (make-instance 'sql-assignment-exp
		 :operator '= :sub-expressions rest))

(defsql sql-< (:symbol "<") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator '< :sub-expressions rest))


(defsql sql-> (:symbol ">") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator '> :sub-expressions rest))

(defsql sql-<> (:symbol "<>") (&rest rest)
        (make-instance 'sql-relational-exp
                       :operator '<> :sub-expressions rest))

(defsql sql->= (:symbol ">=") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator '>= :sub-expressions rest))

(defsql sql-<= (:symbol "<=") (&rest rest)
  (make-instance 'sql-relational-exp
		 :operator '<= :sub-expressions rest))

(defsql sql-count (:symbol "count") (&rest rest)
  (make-instance 'sql-function-exp
		 :name 'count :args rest))

(defsql sql-max (:symbol "max") (&rest rest)
  (make-instance 'sql-function-exp
		 :name 'max :args rest))

(defsql sql-min (:symbol "min") (&rest rest)
  (make-instance 'sql-function-exp
		 :name 'min :args rest))

(defsql sql-avg (:symbol "avg") (&rest rest)
  (make-instance 'sql-function-exp
		 :name 'avg :args rest))

(defsql sql-sum (:symbol "sum") (&rest rest)
  (make-instance 'sql-function-exp
		 :name 'sum :args rest))

(defsql sql-the (:symbol "the") (&rest rest)
  (make-instance 'sql-typecast-exp
		 :modifier (first rest) :components (second rest)))

(defsql sql-function (:symbol "function") (&rest args)
	(make-instance 'sql-function-exp
                       :name (make-symbol (car args)) :args (cdr args)))

;;(defsql sql-distinct (:symbol "distinct") (&rest rest)
;;  nil)

;;(defsql sql-between (:symbol "between") (&rest rest)
;;  nil)
