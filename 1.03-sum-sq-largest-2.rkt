#lang racket

#| Exercise 1.3.  Define a procedure that takes three numbers as arguments and
   returns the sum of the squares of the two larger numbers.                  |#

(define (sq x) (* x x))

(define (zero-if-smallest a b c)
  (if (and (< a b) (< a c))
      0
      a))

(define (sum-of-sq-of-largest-2 x y z)
  (+ (sq (zero-if-smallest x y z))
     (sq (zero-if-smallest y x z))
     (sq (zero-if-smallest z x y))))

(sum-of-sq-of-largest-2 2 1 3)
#| 13 |#