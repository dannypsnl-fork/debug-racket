#lang racket

(require (for-syntax syntax/parse))
(require "env.rkt")

(define-syntax (debug-define stx)
  (syntax-parse stx
    #:literals (debug-define)
    [(debug-define name:id exp)
     #'(begin
         (define name exp)
         (env/bind (syntax-e #'name) exp))]
    [(debug-define (name:id param*:id ...) body)
     #'(define (name param* ...)
         (parameterize ([cur-env (make-env)])
           (for ([p-name (list #'param* ...)]
                 [p (list param* ...)])
             (env/bind (syntax-e p-name) p))
           (displayln (cur-env))
           body))]
    [(debug-define . any) #'(define . any)]))

(debug-define foo 1)
(debug-define (id x) x)

(id 2)
