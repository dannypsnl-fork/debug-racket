#lang racket

(require (for-syntax syntax/parse))
(require "env.rkt")

(define-syntax (debug-define stx)
  (syntax-parse stx
    #:literals (debug-define)
    [(debug-define name:id exp)
     #'(begin
         (define name exp)
         (env/bind name exp))]
    [(debug-define (name:id param*:id ...) body)
     #'(define (name param* ...)
         (displayln 'debug)
         body)]
    [(debug-define . any) #'(define . any)]))

(debug-define foo 1)
(debug-define (id x) x)

(id 1)
