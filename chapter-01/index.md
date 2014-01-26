
## Chapter 1: Buiding Abstractions With Procedures

#### Exercise 1.3

Define a procedure that takes three numbers as arguments and returns the sum of the squares of the two larger numbers.

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

#### Exercise 1.4

Observe that our model of evaluation allows for combinations whose operators are compound expressions. Use this observation to describe the behavior of the following procedure:

    (define (a-plus-abs-b a b)
      ((if (> b 0) + -) a b))

Here, the if form returns + or - operator which are applied on a and b 

#### Exercise 1.5

    (define (p) (p))

    (define (test x y)
      (if (= x 0) 0 y))

    (test 0 (p))

This always returns 0, because in applicative order evaluation, the predicate of the `if` gets evaluated first, and it returns the consequent because it evaluated to true. If it were to return false, the interpreter would go into an infinite loop.

#### Newton's method to find square roots

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

#### Exercise 1.6

If is redefined as a function:

    (define (new-if predicate then-clause else-clause)
      (cond (predicate then-clause)
            (else else-clause)))

Running this causes the interpreter to run out of memory. Why?

`new-if` is a procedure. In applicative order evaluation, all the arguments of a procedure are evaluated first. So the `then-clause`, which is the recursive call to `square-root-iter` gets called irrespective of whether the `predicate` evaluates to true or not. In case of `if`, the predicate gets evaluated first and based on the result, one of the two clauses gets evaluated.

#### Exercise 1.7

If we were to use 0.001 as the precision in `good-enough?`, square root of a number less than 0.000001 can not be computed accurately. For very large numbers, the difference between the square of guess and the number might never converge, thereby leading to an infinite loop.

We can define `good-enough?` as:

    (define (good-enough? guess x)
        (< (fraction-change guess x) 0.001))

    (define (fraction-change guess x)
        (abs (/ (- x (square guess)) (square guess))))

#### Exercise 1.8

Finding cube roots.

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

#### 1.1.8 Procedures as black box abstractions

Improving the `sqrt` procedure by moving the other procedure definitions inside the `sqrt` definition, and also allowing `x` to be a free variable, we get:

    (define (square a) (* a a))
    (define (average a b) (/ (+ a b) 2))

    (define (sqrt x)
      (define (improve guess)
          (average guess (/ x guess)))

      (define (good-enough? guess)
        (< (abs (- x (square guess))) 0.001))

      (define (square-root-iter guess)
        (if (good-enough? guess)
            guess
            (square-root-iter (improve guess))))
      (square-root-iter 1.0))

* _Block structure_: Allow procedures to have internal definitions that are local to that procedure.
* _Lexical scoping_: Free variables in a procedure are taken to refer to bindings made by enclosing procedure definitions. They are looked up in the environment where they are defined.

### 1.2 Procedures and the processes they generate

#### 1.2.1 Linear recursion and iteration

_Linear recursive process_

    (define (factorial n)
        (if (= n 1)
            1
            (* n (factorial (- n 1)))))

* consists of chain of deferred operations
* amount of information to be kept track of, grows linearly with n.

_Linear iterative process_

    (define (factorial n)
        (define (iter acc counter)
            (if (> counter n)
                acc
                (iter (* acc counter)
                      (+ counter 1))))
        (iter 1 1))

* only need to keep track of two values - acc and counter
* program variables provide the complete description of the state of the process at any point

Even though the process is defined in a recursive manner, Scheme will execute this in constant space, due to its tail recursive implementation.

#### Exercise 1.9 

Using substitution model, illustrate the process generated by each procedure in evaluating (+ 4 5).

    (define (+ a b)
       (if (= a 0)
           b
           (inc (+ (dec a) b))))

The process is recursive.

    (+ 4 5)
    (inc (+ (dec 4) 5))

Simplifying by replacing `(dec n)` by `n-1` wherever possible.

    (inc (+ 3 5))
    (inc (inc (+ 2 5)))
    (inc (inc (inc (+ 1 5))))
    (inc (inc (inc (inc (+ 0 5)))))
    (inc (inc (inc (inc 5))))
    (inc (inc (inc 6)))
    (inc (inc 7))
    (inc 8)
    (9)

Second procedure:

    (define (+ a b)
       (if (= a 0)
           b
           (+ (dec a) (inc b))))

This process is iterative.

    (+ 4 5)
    (+ (dec 4) (inc 5))
    (+ 3 6)
    (+ (dec 3) (inc 6))
    (+ 2 7)
    (+ (dec 2) (inc 7))
    (+ 1 8)
    (+ (dec 1) (inc 8))
    (+ 0 9)
    (9)

#### Exercise 1.10

Give concise mathematical definitions for the following, where A(x, y) is the Ackerman's function.

    (f n) = A(0, n)
    (g n) = A(1, n)
    (h n) = A(2, n)

Solutions:

    (f n) = 2n

    (g 0) = 0
    (g n) = 2^n

    (h n) = 2^(2^(2^(...)))

The term that (h n) reduces to is called a [tetration](http://en.wikipedia.org/wiki/Tetration).

#### Exercise 1.11

Function f is defined as:

    f(n) = n if n < 3
         = f(n-1) + 2 f(n-2) + 3 f(n-3) ; n >= 3

Representing as a recursive process:

    (define (f n)
      (if (< n 3)
          n
          (+ (f (- n 1))
             (* 2 (f (- n 2)))
             (* 3 (f (- n 3))))))

Iterative process:

    (define (f1 n)
      (define (iter x y z c)
        (if (> c n)
            x
            (iter (+ x
                     (* 2 y)
                     (* 3 z))
                  x
                  y
                  (+ c 1))))
      (if (< n 3)
          n
          (iter 2 1 0 3)))

Here, the `iter` procedure keeps track of the 3 co-efficients of f(n). Since `n` is returned directly for n<3, `c` - which keeps track of the count - starts from 3.

#### Exercise 1.12

To find the p-th binomial coefficient of (x + y)^n:

    (define (bc p n)
      (cond ((> p n) 0)
            ((= p 0) 1)
            (else (+ (bc p
                         (- n 1))
                     (bc (- p 1)
                         (- n 1))))))
