
## Chapter 1: Buiding Abstractions With Procedures

### Notes from lecture 1B

**Substitution model**

* Evaluate the operator to get procedure
* Evaluate operand to get arguments
* Apply procedure to args
  - Copy body of procedure, substituting the args supplied for the formal params of the procedure.
  - Evaluate the resulting new body

To evaluate `if`:

* Evaluate predicate first
* if predicate yields true, evaluate conseuent
* else evaluate alternative

Iteration - all the state is in explicit variables so if the process were to be paused, we could continue evaluation using the state variables.

Recursion - current state variables not enough to continue evaluation.

**Fibonacci program**

- time complexity: O(fib n)
- space complexity: O(n)

Space complexity is O(n) because the space used is the length of the longest path of the recursion tree.

**Towers of Hanoi**

Move n high tower from spike `from` to spike `to` with an extra spike `spare`.

    (define (move n from to spare)
      (cond (= n 0) 'done')
            (else
              (move (- n 1) from spare to)
              (print-move from to)
              (move (- n 1) spare to from)))

    (move 3 1 3 2)

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

#### Exercise 1.15

a) The value passed to `p` is reduced to 1/3rd of the value in the previous call to the procedure. To calculate the number of calls to `p`, divide the original angle by 3 until the final value is < 0.1.

    12.15
     4.05
     1.35
     0.45
     0.15
     0.05 -> p is not called in this case.

So the total number of calls to `p` is 5.

b) An additional step is required to compute the sine every time the angle increases by a factor of 3. The order of growth can be given as O(log n).


#### Exercise 1.16 - Fast exponentiation

    (define (exp b n)
      (define (iter b n a)
        (cond ((= n 0) a)
              ((even? n) (iter (* b b)
                               (/ n 2)
                               a))
              ((odd? n) (iter (* b b)
                              (/ (- n 1) 2)
                              (* a b)))))
      (iter b n 1))

#### Exercise 1.17 - Fast multiplication

    (define (mul a b)
      (define (double x) (* x 2))
      (define (halve  x) (/ x 2))

        (cond ((= a 0) 0)
              ((= a 1) b)
              ((even? a) (mul (halve a)
                              (double b)))
              ((odd? a) (* a
                           (mul (halve (- a 1))
                                (double b))))))

#### Exercise 1.18 - Fast multiplication (iterative)

    (define (mul a b)
      (define (double x) (* x 2))
      (define (halve  x) (/ x 2))

      (define (iter a b c)
        (cond ((= a 0) 0)
              ((= a 1) b)
              ((even? a) (iter (halve a)
                               (double b)
                               c))
              ((odd? a) (iter (halve (- a 1))
                              (double b)
                              (* a c)))))
      (iter a b 1))

#### Exercise 1.19 - Fibonacci

Applying Tpq once, we get a1, b1:

    a1 = bq + aq + ap
    b1 = bp + aq

Applying Tpq on a1 and b1, we get a2 and b2:

    a2 = b1 q  +  a1 q  +  a1 p
    a2 = (bp + aq)q + (bq + aq + ap)q + (bq + aq + ap)p
    a2 = bpq + aqq + bqq + aqq + apq + bpq + apq + app
    a2 = 2bpq + 2aqq + bqq + aqq + 2apq + app
    a2 = a(pp + 2pq + qq) + b(qq + 2pq)

    b2 = b1 p  +  a1 q
    b2 = (bp + aq)p + (bq + aq + ap)q
    b2 = bpp + apq + bqq + aqq + apq
    b2 = b(pp + qq) + a(qq + 2pq)

We also know:

    b2 = bp` + aq`

Comparing the coefficients of a and b in the previous equation, we get p' and q'.

    p` = pp + qq
    q` = qq + 2pq

Filling in the value of p' and q' in the `fib-iter` procedure:

    (define (fib n)
      (fib-iter 1 0 0 1 n))

    (define (fib-iter a b p q count)
      (cond ((= count 0) b)
            ((even? count)
             (fib-iter a
                       b
                       (+ (* p p) (* q q))    ; compute p'
                       (+ (* q q) (* 2 p q))  ; compute q'
                       (/ count 2)))
            (else (fib-iter (+ (* b q) (* a q) (* a p))
                            (+ (* b p) (* a q))
                            p
                            q
                            (- count 1)))))


#### Exercise 1.20

GCD procedure:

    (define (gcd aa bb)
      (if (= bb 0)
          aa
          (gcd bb (remainder aa bb))))

**Normal order**:

    (gcd 206 40)

    (if (= 40 0)
          206
          (gcd 40 (remainder 206 40)))

    (gcd 40 (remainder 206 40))

    (if (= (remainder 206 40) 0)
          40
          (gcd (remainder 206 40) (remainder 40 (remainder 206 40))))

The predicate of the if gets evaluated here. So we now have remainder evaluated once.

    (if (= 6 0)
          40
          (gcd (remainder 206 40) (remainder 40 (remainder 206 40))))

    (gcd (remainder 206 40) (remainder 40 (remainder 206 40)))

    (if (= (remainder 40 (remainder 206 40)) 0)
          (remainder 206 40)
          (gcd (remainder 40 (remainder 206 40)) (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))))

Now the two remainders in the predicate of the if form get evaluated. 3.

    (if (= (remainder 40 6) 0)
          (remainder 206 40)
          (gcd (remainder 40 (remainder 206 40)) (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))))    

    (if (= 4 0)
          (remainder 206 40)
          (gcd (remainder 40 (remainder 206 40)) (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))))

    (gcd (remainder 40 (remainder 206 40)) (remainder (remainder 206 40) (remainder 40 (remainder 206 40))))

    (if (= (remainder (remainder 206 40) (remainder 40 (remainder 206 40))) 0)
        (remainder 40 (remainder 206 40))
        (gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
             (remainder (remainder 40 (remainder 206 40))
                        (remainder (remainder 206 40)
                                   (remainder 40 (remainder 206 40))))))

Now the 4 remainders inside the if get evaluated. 7.

    (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
    (remainder (remainder 206 40) (remainder 40 6))
    (remainder 6 4)
    2

Replacing 2 in the if:

    (if (= 2 0)
        (remainder 40 (remainder 206 40))
        (gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
             (remainder (remainder 40 (remainder 206 40))
                        (remainder (remainder 206 40)
                                   (remainder 40 (remainder 206 40))))))

    (gcd (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
         (remainder (remainder 40 (remainder 206 40))
                    (remainder (remainder 206 40)
                               (remainder 40 (remainder 206 40)))))

    (if (= b 0)
        (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))
        (gcd b (remainder (remainder (remainder 206 40) (remainder 40 (remainder 206 40))) b)))

The expression `b` gets evaluated in the above expression. It is the same as:

    (remainder  (remainder 40 (remainder 206 40))
                (remainder  (remainder 206 40)
                            (remainder 40 (remainder 206 40))))

    (remainder  4 2)
    0

That was 7 more. Total 14. So this gets evaluated:

    (remainder (remainder 206 40) (remainder 40 (remainder 206 40)))

4 more there, taking the total to 18.

**In applicative order,**

    (gcd 206 40)
    (if (= 40 0) 206 (gcd 40 (remainder 206 40)))
    (gcd 40 (remainder 206 40))
    (gcd 40 6)
    (if (= 6 0) 40 (gcd 6 (remainder 40 6)))
    (gcd 6 (remainder 40 6))
    (gcd 6 4)
    (if (= 4 0) 6 (gcd 4 (remainder 6 4)))
    (gcd 4 (remainder 6 4))
    (gcd 4 2)
    (if (= 2 0) 4 (gcd 2 (remainder 4 2)))
    (gcd 2 (remainder 4 2))
    (gcd 2 0)
    (if (= 0 0) 2 (gcd 0 (remainder 2 0)))

Here, the `remainder` operations are performed 4 times.

