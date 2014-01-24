
# Chapter 1: Buiding Abstractions With Procedures


## Exercise 1.5

    (define (p) (p))

    (define (test x y)
      (if (= x 0) 0 y))

    (test 0 (p))

This always returns 0, because in applicative order evaluation, the predicate of the `if` gets evaluated first, and it returns the consequent because it evaluated to true. If it were to return false, the interpreter would go into an infinite loop.

## Newton's method to find square roots

    (define (square x) (* x x))
    (define (average x y) (/ (+ x y) 2))
    (define (improve guess x) (average guess (/ x guess)))

    (define (good-enough? guess x)
      (< (abs
          (- x (square guess))) 0.001))

    (define (square-root-iter guess x)
      (if (good-enough? guess x)
          guess
          (square-root-iter (improve guess x) x)))

    (define (sqrt x)
      (square-root-iter 1.0 x))

## Exercise 1.6

If is redefined as a function:

    (define (new-if predicate then-clause else-clause)
      (cond (predicate then-clause)
            (else else-clause)))

Running this causes the interpreter to run out of memory. Why?

`new-if` is a procedure. In applicative order evaluation, all the arguments of a procedure are evaluated first. So the `then-clause`, which is the recursive call to `square-root-iter` gets called irrespective of whether the `predicate` evaluates to true or not. In case of `if`, the predicate gets evaluated first and based on the result, one of the two clauses gets evaluated.

## Exercise 1.7

If we were to use 0.001 as the precision in `good-enough?`, square root of a number less than 0.000001 can not be computed accurately. For very large numbers, the difference between the square of guess and the number might never converge, thereby leading to an infinite loop.

We can define `good-enough?` as:

    (define (good-enough? guess x)
        (< (fraction-change guess x) 0.001))

    (define (fraction-change guess x)
        (abs (/ (- x (square guess)) (square guess))))

## Exercise 1.8 - Finding cube roots

    (define (square x) (* x x))
    (define (cube x) (* x x x))
    (define (average x y) (/ (+ x y) 2))
    (define (next-approximation x g) (/ (+
                                         (/ x (square g))
                                         (* 2 g))
                                        3) )
    (define (improve guess x) (average guess (next-approximation x guess)))

    (define (good-enough? guess x)
      (< (abs
          (- x (cube guess))) 0.001))

    (define (cube-root-iter guess x)
      (if (good-enough? guess x)
          guess
          (cube-root-iter (improve guess x) x)))

    (define (cube-root x)
      (cube-root-iter 1.0 x))

    (cube-root 1000000)


