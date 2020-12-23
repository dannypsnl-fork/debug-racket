#lang racket/base

(provide make-env cur-env cur-ns
         env/bind env/lookup)

(struct env (cur-ns bind* parent)
  #:methods gen:custom-write
  [(define (write-proc env port mode)
     (fprintf port "~a (~a)" (env-bind* env) (env-parent env)))]
  #:transparent)
(define (make-env [parent (cur-env)])
  (env (make-base-namespace) (make-hash) parent))
(define cur-env (make-parameter (make-env #f)))

(define (cur-ns) (env-cur-ns (cur-env)))

(define (env/bind id val)
  (let* ([ns (cur-ns)]
         [binding* (env-bind* (cur-env))])
    (hash-set! binding* id val)
    (namespace-set-variable-value! id val
                                   #f
                                   ns)))
(define (env/lookup id)
  (let* ([ns (cur-ns)]
         [parent (env-parent (cur-env))])
    (namespace-variable-value id
                              #f
                              (λ () (if parent
                                        (parameterize ([cur-env parent])
                                          (env/lookup id))
                                        #f))
                              ns)))

(module+ test
  (require rackunit)

  (parameterize ([cur-env (make-env #f)])
    (env/bind 'a 1)
    (check-equal? (env/lookup 'a) 1)))
