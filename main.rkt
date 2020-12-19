#lang racket

(require (for-syntax syntax/parse))
(require "env.rkt")

(define (prompt)
  (write "> ")
  (define e (read))
  (match e
    ['env (displayln (cur-env))]
    [else (printf "unknown command: `~a`~n" e)]))

(define-syntax (debug-define stx)
  (syntax-parse stx
    #:literals (debug-define)
    [(debug-define name:id exp)
     #'(begin
         (define name exp)
         (env/bind (syntax-e #'name) exp))]
    [(debug-define (name:id param*:id ...) e* ... e)
     #'(define (name param* ...)
         (parameterize ([cur-env (make-env)])
           (for ([p-name (list #'param* ...)]
                 [p (list param* ...)])
             (env/bind (syntax-e p-name) p))
           (prompt)
           e* ...
           e))]
    ;; since rest form should be invalid, we rebuild define form to get error
    [(debug-define . any) #'(define . any)]))

(debug-define foo 1)
(debug-define (id x) x)

(id 2)
