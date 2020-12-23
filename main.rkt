#lang racket

(provide (except-out (all-from-out racket)
                     define let)
         (rename-out [debug-define define]
                     [debug-let let]))

(require (for-syntax syntax/parse))
(require "env.rkt")

(define (prompt)
  (display "> ")
  (define e (read))
  (match e
    ['env
     (displayln (cur-env))
     (prompt)]
    ['c (void)]
    [`(eval ,e)
     (displayln (eval e (cur-ns)))
     (prompt)]
    [else
     (printf "unknown command: `~a`~n" e)
     (prompt)]))

(define-syntax (debug-define stx)
  (syntax-parse stx
    #:literals (debug-define)
    [(debug-define name:id exp)
     #'(begin
         (define name exp)
         (env/bind (syntax-e #'name) exp))]
    [(debug-define (name:id param*:id ...) e* ... e)
     #'(begin
         (define (name param* ...)
           (parameterize ([cur-env (make-env)])
             (for ([p-name (list #'param* ...)]
                   [p (list param* ...)])
               (env/bind (syntax-e p-name) p))
             (~@ (prompt) e*) ...
             (prompt) e))
         (env/bind (syntax-e #'name) '<function>))]
    ;; since rest form should be invalid, we rebuild define form to get error
    [(debug-define . any) #'(define . any)]))

(define-syntax (debug-let stx)
  (syntax-parse stx
    #:literals (debug-let)
    [(debug-let ([binding-name*:id binding-expr*] ...) e* ... e)
     #'(let ([binding-name* binding-expr*] ...)
         (parameterize ([cur-env (make-env)])
           (for ([b-name (list #'binding-name* ...)]
                 [b-e (list binding-expr* ...)])
             (env/bind (syntax-e b-name) b-e))
           (~@ (prompt) e*) ...
           (prompt) e))]
    [(debug-let . any) #'(let . any)]))

(module reader syntax/module-reader
  debug-racket)
