#lang debug-racket

(let ([a 1]
      [b 2])
  (displayln a)
  (let ([b 3])
    (displayln b)))
