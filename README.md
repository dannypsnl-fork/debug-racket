# debug-racket

### Install

```sh
git clone https://github.com/dannypsnl/debug-racket.git
cd debug-racket && raco pkg install --auto
```

### Usage

Change `#lang` to `debug-racket`:

```racket
#lang debug-racket

(define (rec n)
  (rec (+ n 1)))

(rec 1)
```

While run this file, it would stop and waiting your debugging command:

1. `c`: continue to next line
2. `env`: show current environment
3. `(eval $e)`: evaluate `$e` with current environment

### Warning

This is a prototype project to check idea, it only works with `let` and `define` syntax and the final step will have a weird invoke to `#<void>`, but they are not going to be fixed.
