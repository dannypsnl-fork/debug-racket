#lang racket

(require (for-syntax syntax/parse))

(struct env (cur-map parent) #:transparent)
(define (make-env [parent (cur-env)])
  (env (make-hash) parent))
(define cur-env (make-parameter (make-env #f)))

(define-syntax (debug-define stx)
  (syntax-parse stx
    	#:literals (debug-define)
    [(debug-define name:id exp)
     #'(define name exp)]
    [(debug-define (name:id param*:id ...) body)
     #'(define (name param* ...)
         (displayln 'debug)
         body)]
    [(debug-define . any) #'(define . any)]))

(debug-define foo 1)
(debug-define (id x) x)

(id 1)
