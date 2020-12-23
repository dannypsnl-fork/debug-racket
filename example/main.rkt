#lang debug-racket

(define (rec n)
  (rec (+ n 1)))

(let ([a 1]
      [b 2])
  (displayln a)
  (let ([b 3])
    (rec b)))
