#lang racket

(provide (except-out (all-from-out racket)
                     define let)
         (rename-out [debug-define define]
                     [debug-let let]))

(require (for-syntax syntax/parse))
(require "env.rkt")

(define (prompt [line:? #f])
  (displayln line:?)
  (display "> ")
  (define e (read))
  (match e
    ['env
     (displayln (cur-env))
     (prompt line:?)]
    ['c (void)]
    [`(eval ,e)
     (displayln (eval e (cur-ns)))
     (prompt line:?)]
    [else
     (printf "unknown command: `~a`~n" e)
     (prompt line:?)]))

(define-for-syntax (debug-statement expression)
  (with-syntax ([e expression])
    #`(begin
        (prompt (syntax->datum #'e))
        e)))

(define-syntax (debug-define stx)
  (syntax-parse stx
    #:literals (debug-define)
    [(debug-define name:id exp)
     #'(begin
         (define name exp)
         (env/bind (syntax-e #'name) exp))]
    [(debug-define (name:id param*:id ...) . body)
     (with-syntax ([new-body (map debug-statement (syntax-e #'body))])
       #'(begin
           (define (name param* ...)
             (parameterize ([cur-env (make-env)])
               (for ([p-name (list #'param* ...)]
                     [p (list param* ...)])
                 (env/bind (syntax-e p-name) p))
               new-body))
           (env/bind (syntax-e #'name) '<function>)))]
    ;; since rest form should be invalid, we rebuild define form to get error
    [(debug-define . any) #'(define . any)]))

(define-syntax (debug-let stx)
  (syntax-parse stx
    #:literals (debug-let)
    [(debug-let ([binding-name*:id binding-expr*] ...) . body)
     (with-syntax ([new-body (map debug-statement (syntax-e #'body))])
       #'(let ([binding-name* binding-expr*] ...)
           (parameterize ([cur-env (make-env)])
             (for ([b-name (list #'binding-name* ...)]
                   [b-e (list binding-expr* ...)])
               (env/bind (syntax-e b-name) b-e))
             new-body)))]
    ;; name-let was ignored, thus, we throw exception directly
    [(debug-let . any) (error 'debug-let "~a" stx)]))

(module reader syntax/module-reader
  debug-racket)
