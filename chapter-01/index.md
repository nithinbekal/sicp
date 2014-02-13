
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

#### Exercise 1.21

    (define (smallest-divisor n)
      (find-divisor n 2))

    (define (square n) (* n n))

    (define (find-divisor n test-divisor)
      (cond ((> (square test-divisor) n) n)
            ((divides? test-divisor n) test-divisor)
            (else (find-divisor n (+ test-divisor 1)))))

    (define (divides? a b)
      (= (remainder b a) 0))

    (smallest-divisor 199)   - 199 
    (smallest-divisor 1999)  - 1999
    (smallest-divisor 19999) - 7

#### Exercise 1.22

It turns out that Racket doesn't have a `runtime` primitive. To fix this, I changed the `#lang` directive to `#lang planet neil/sicp`, which installs an environment that runs all SICP programs.

    (define (smallest-divisor n)
          (find-divisor n 2))

    (define (square n) (* n n))

    (define (find-divisor n test-divisor)
      (cond ((> (square test-divisor) n) n)
            ((divides? test-divisor n) test-divisor)
            (else (find-divisor n (+ test-divisor 1)))))

    (define (divides? a b)
      (= (remainder b a) 0))

    (define (prime? n) (= (smallest-divisor n) n))

    (define (timed-prime-test n)
      (newline)
      (display n)
      (start-prime-test n (runtime)))

    (define (start-prime-test n start-time)
      (if (prime? n)
          (report-prime (- (runtime) start-time))
          #f))

    (define (report-prime elapsed-time)
      (display " *** ")
      (display elapsed-time))

Writing the `search-for-primes` procedure:

    (define (search-for-primes start end)
      (cond ((even? start) (search-for-primes (+ start 1) end))
            ((< start end) (timed-prime-test start)(search-for-primes (+ start 2) end))))

Find the three smallest primes larger than 1000; larger than 10,000; larger than 100,000:

    1000           1009      1013      1019
    1000          10007     10009     10037
    1000         100003    100019    100043

None of these take enough time for the runtime to be significant. The value is displayed as 0 every time. Trying for much larger numbers, I get:

    Prime number         Runtime    Ratio of increase
    10000000019     ***   110000    -
    100000000003    ***   480000    4.363
    1000000000039   ***  1290000    2.687
    10000000000037  ***  4200000    3.255
    100000000000031 *** 13264000    3.158

Runtime increases by a factor approaching sqrt(10) (= 3.162) for every 10x increase in n.

#### Exercise 1.23

Rewriting `(+ test-divisor 1)` as `(next test-divisor)` using this procedure:

    (define (next n)
      (if (even? n) (+ n 1) (+ n 2)))

Runtime:

    Prime number         Old Runtime  New runtime   old/new
    10000000019     ***       110000        60000   1.833
    100000000003    ***       480000       300000   1.600
    1000000000039   ***      1290000       730000   1.767
    10000000000037  ***      4200000      2370000   1.772
    100000000000031 ***     13264000      7272000   1.823

The improvement is about 1.8x the previous version. This is less than the expected 2X improvement. This might be because the `(+ test-divisor 1)` has been replaced by `(next test-divisor)` which evaluates an if condition every time it is called.

#### Exercise 1.24

Using `fast-prime?`:

    (define (expmod base exp m)
      (cond ((= exp 0) 1)
            ((even? exp)
             (remainder (square (expmod base (/ exp 2) m))
                        m))
            (else
             (remainder (* base (expmod base (- exp 1) m))
                        m))))

    (define (fermat-test n)
      (define (try-it a)
        (= (expmod a n n) a))
      (try-it (+ 1 (random 4294967087))))

    (define (fast-prime? n times)
      (cond ((= times 0) true)
            ((fermat-test n) (fast-prime? n (- times 1)))
            (else false)))

    (define (start-prime-test n start-time)
      (if (fast-prime? n 25)
          (report-prime (- (runtime) start-time))
          #f))

I arbitrarily set the `times` argument for `fast-prime?` as 25. Racket's `random` procedure has a limit of 4294967087. I set the random to always pick a number between 1 and 4294967087.

    10000000000037         ***   70000
    100000000000031        ***   60000
    1000000000000037       ***   60000
    10000000000000061      ***   90000
    100000000000000003     ***  100000
    1000000000000000031    ***  100000
    10000000000000000091   ***  130000
    100000000000000000039  ***  100000
    1000000000000000000193 ***  130000

The time increases very gradually, as might be expected from a O(log n) algorithm, but it's rather erratic. Need to test this again after figuring out how to use random numbers greater that 4294967087.

#### Exercise 1.25

Orginal expmod:

    (define (expmod b e m)
      (cond ((= e 0) 1)
            ((even? e)
                (rem (sq (expmod b (/ e 2) m)) m))
            (else (rem (* b (expmod b (- e 1) m)) m))))

Alyssa P Hacker's expmod:

    (define (expmod b e m)
      (remainder (fast-expt b e) m))

    (define (fast-expt b n)
      (cond ((= n 0) 1)
            ((even? n) (square (fast-expt b (/ n 2))))
            (else (* b (fast-expt b (-n 1))))))

Fermat test:

    (define (fermat-test n)
      (define (try-it a) (= (expmod a n n) a))
      (try-it (+ 1 (random (- n 1)))))

After reducing `(expmod 2 13 13)` using substitution model for both cases (not gonna type in the 2 pages of scribbled notes here), it becomes apparent that in the former case, the expmod procedure never has to deal with very large numbers. At each recursive call to expmod also involves reducing that number using `remainder` before `square` is called on that result.

In the latter case, the result of each recursive call to `fast-expt` is followed by either squaring or multiplication operation. The final result - `a^n` - for the values being tested in `fermat-test` is then passed to the remainder procedure. When checking for large prime numbers, the size of `a^n` can be extremely large, and therefore, inefficient.

#### Exercise 1.26

    (define (expmod b e m)
      (cond ((= e 0) 1)
            ((even? e)
                (rem (* (expmod b (/ e 2) m)
                        (expmod b (/ e 2) m)) m))
            (else (rem (* b (expmod b (- e 1) m)) m))))

In the original procedure, each call to the expmod procedure with exponent n calculates expmod of n/2. Due to this, we get an O(log n) process. By making the multiplication explicit, each call to expmod doubles the number of recursive calls to expmod. Thus, it reduces to an O(n) process.

#### Exercise 1.27

Using the `fast-prime?` procedure from exercise 1.24:

    (define (square x) (* x x))

    (define (expmod base exp m)
      (cond ((= exp 0) 1)
            ((even? exp)
             (remainder (square (expmod base (/ exp 2) m))
                        m))
            (else
             (remainder (* base (expmod base (- exp 1) m))
                        m))))

    (define (fermat-test n)
      (define (try-it a)
        (= (expmod a n n) a))
      (try-it (+ 1 (random 4294967087))))

    (define (fast-prime? n times)
      (cond ((= times 0) true)
            ((fermat-test n) (fast-prime? n (- times 1)))
            (else false)))

    (fast-prime? 561 2)
    (fast-prime? 1105 2)
    (fast-prime? 1769 2)
    (fast-prime? 2465 2)

The procedure returns true for these Carmichael numbers.

#### Exercise 1.28

Miller-Rabin test:

    (define (square x) (* x x))

    (define (check a n)
      (if (and (= (remainder (square a) n) 1)
               (not (or (= a 1)
                        (= a (- n 1)))))
          0
          (remainder (square a) n)))

    (define (expmod base exp m)
      (cond ((= exp 0) 1)
            ((even? exp)
             (check (expmod base (/ exp 2) m) m))
            (else
             (remainder (* base (expmod base (- exp 1) m))
                        m))))

    (define (miller-rabin-test n)
      (define (try-it a)
        (= (expmod a n n) a))
      (try-it (+ 2 (random (- n 2)))))

    (define (fast-prime? n times)
      (cond ((= times 0) true)
            ((miller-rabin-test n) (fast-prime? n (- times 1)))
            (else false)))

    (fast-prime? 3 2)
    (fast-prime? 4 2)
    (fast-prime? 23 2)
    (fast-prime? 561 2)
    (fast-prime? 1729 2)

#### Exercise 1.29

Simpson's method for integration:

    (define (sum term a next b)
      (if (> a b)
          0
          (+ (term a)
             (sum term (next a) next b))))

    (define (simpson-integral f a b n)
      (define h (/ (- b a) n))
      (define (next k) (+ k 1))

      (define (term k)
        (* (cond ((odd? k) 4)
                 ((or (= k 0) (= k n)) 1)
                 ((even? k) 2))
           (f (+ a (* k h)))))

      (* (/ h 3)
         (sum term 0.0 next n)))

    (define (cube x) (* x x x))

    (simpson-integral cube 0 1 100)
    (simpson-integral cube 0 1 1000)

#### Exercise 1.30

Iterative sum:

    (define (sum term a next b)
      (define (iter a result)
        (if (= a b)
            (+ (term a) result)
            (iter (next a) (+ (term a) result))))
      (iter a 0))

#### Exercise 1.31

Product procedure:

    (define (product term a next b)
      (define (iter a result)
        (if (= a b)
            (* (term a) result)
            (iter (next a) (* (term a) result))))
      (iter a 1))

Factorial:

    (define (factorial n)
      (define (identity x) x)
      (define (inc x) (+ x 1))
      (product identity 2 inc n))

    (factorial 5)

Formula for pi:

    (define (product term a next b)
      (define (iter a result)
        (if (= a b)
            (* (term a) result)
            (iter (next a) (* (term a) result))))
      (iter a 1.0))

    (define (term k)
      (if (even? k)
          (/ (+ k 2)
             (+ k 3))
          (/ (+ k 3)
             (+ k 2))))

    (define (next k) (+ k 1))

    (product term 0 next 100)

Recursive version:

    (define (product term a next b)
      (if (> a b)
          1
          (* (term a) (product term (next a) next b))))


#### Exercise 1.32

Recursive version:

    (define (accumulate combiner null-value term a next b)
      (if (> a b)
          null-value
          (combiner (term a)
                    (accumulate combiner null-value term (next a) next b))))

    (define (inc x) (+ x 1))
    (define (identity x) x)

    (accumulate + 0 identity 1 inc 5)
    (accumulate * 1 identity 1 inc 5)

Iterative version:

    (define (accumulate combiner null-value term a next b)
      (define (iter a result)
        (if (> a b)
            (combiner null-value result)
            (iter (next a) (combiner (term a) result))))
      (iter a null-value))

#### Exercise 1.33

The `filtered-accumulate` procedure:

    (define (filtered-accumulate combiner null-value term a next b filter?)
      (define (iter a result)
        (if (filter? a)
            (if (> a b)
                (combiner null-value result)
                (iter (next a) (combiner (term a) result)))
            (iter (next a) result)))
      (iter a null-value))

Using the `prime?` procedure from exercise 1.22:

    (define (smallest-divisor n)
          (find-divisor n 2))

    (define (square n) (* n n))

    (define (find-divisor n test-divisor)
      (cond ((> (square test-divisor) n) n)
            ((divides? test-divisor n) test-divisor)
            (else (find-divisor n (+ test-divisor 1)))))

    (define (divides? a b)
      (= (remainder b a) 0))

    (define (prime? n) (= (smallest-divisor n) n))

Sum of squares of primes in range 2 to 10:

    (define (inc x) (+ x 1))
    (filtered-accumulate + 0 square 2 inc 10 prime?)

Filtered accumulate:

    (define (filtered-accumulate combiner null-value term a next b filter?)
      (define (iter a result)
        (if (filter? a)
            (if (> a b)
                (combiner null-value result)
                (iter (next a) (combiner (term a) result)))
            (iter (next a) result)))
      (iter a null-value))

Sum of relative primes:

    (define (gcd a b)
      (if (= b 0)
          a
          (gcd b (remainder a b))))

    (define (inc x) (+ x 1))
    (define (identity x) x)

    (define (product-of-relative-primes-upto n)
      (define (relatively-prime? x)
        (= (gcd x n) 1))
      (filtered-accumulate * 1 identity 2 inc n relatively-prime?))

    (product-of-relative-primes-upto 10)

#### Exercise 1.34

    (define (f g)
      (g 2))

Applying substitution model to `(f f)`:

    (f f)
    (f 2)
    (2 2)

This will cause the error: `procedure application: expected procedure, given: 2; arguments were: 2`.

#### Exercise 1.35

Calculating the value of phi:

    (define tolerance 0.0001)

    (define (fixed-point f first-guess)
      (define (close-enough? v1 v2)
        (< (abs (- v1 v2)) tolerance))
      (define (try guess)
        (let ((next (f guess)))
          (if (close-enough? guess next)
              next
              (try next))))
      (try first-guess))

    (define (f x)
      (+ 1 (/ 1.0 x)))

    (fixed-point f 1.0)

Value: 1.6180555555555556

#### Exercise 1.36

    (define tolerance 0.0001)

    (define (fixed-point f first-guess)
      (define (close-enough? v1 v2)
        (< (abs (- v1 v2)) tolerance))
      (define (try guess)
        (let ((next (f guess)))
          (display guess)
          (newline)
          (if (close-enough? guess next)
              next
              (try next))))
      (try first-guess))

Without damping, it takes 28 steps.

    (define (f x)
      (/ (log 1000) (log x)))

    (fixed-point f 10.0)

With damping, it takes 7 steps.

    (define (f x)
      (+ (/ x 2)
         (/ (log 1000)
            (* 2
               (log x)))))

    (fixed-point f 10.0)

#### Exercise 1.37

Recursive solution:

    (define (cont-frac n d k)
      (define (calc-fraction x)
        (if (< x k)
            (/ (n x)
               (+ (d x)
                  (calc-fraction (+ x 1))))
            (/ (n x) (d x))))
      (calc-fraction 1))

    (cont-frac (lambda (i) 1.0)
               (lambda (i) 1.0)
               12)

The value converged after k=12.

Recursive solution:

    (define (cont-frac n d k)
      (define (calc-fraction x res)
        (if (= x 0)
            res
            (calc-fraction (- x 1) (/ (n x)
                                      (+ (d x)
                                         res)))))
      (calc-fraction k (/ (n k) (d k))))

    (cont-frac (lambda (i) 1.0)
               (lambda (i) 1.0)
               12)

#### Exercise 1.38

Using the same cont-frac procedure as in 1.37, the second argument can be written as:

    (define (dr x)
      (if (= 0 (remainder (+ x 1) 3))
          (/ (* 2 (+ x 1)) 3)
          1))

    (cont-frac (lambda (i) 1.0) dr 10)

This yields the value 0.718 which is equal to (e-2).

#### Exercise 1.39

    (define (tan-cf x k)
      (cont-frac (lambda (i) (if (= i 1)
                                  x
                                  (- (* x x))))
                  (lambda (j) (- (* 2 j)
                                 1))
                  k))

    (tan-cf (/ pi 3) 10)
    => 1.732050807568877

#### Exercise 1.41

    (define (inc x)
      (+ x 1))

    (define (double f)
      (lambda (x) (f (f x))))

    (((double (double double)) inc) 5)

The value returned is 21.

#### Exercise 1.42

    (define (inc x)
      (+ x 1))

    (define (square x) (* x x))

    (define (compose f g)
      (lambda (x) (f (g x))))

    ((compose square inc) 6)

#### Exercise 1.43

    (define (inc x) (+ x 1))
    (define (square x) (* x x))

      (define (compose f g)
        (lambda (x) (f (g x))))

      (define (repeated f n)
        (define (iter g i)
          (if (= i 0)
              g
              (iter (compose f g) (- i 1))))
        (iter f (- n 1)))

    ((repeated square 2) 5)
    625

#### Exercise 1.44

    (define (compose f g)
      (lambda (x) (f (g x))))

    (define (repeated f n)
      (define (iter g i)
        (if (= i 0)
            g
            (iter (compose f g) (- i 1))))
      (iter f (- n 1)))

    (define (smoothed f)
      (lambda (x) (/ (+ (f x)
                        (f (+ x 1))
                        (f (- x 1)))
                     3)))

    (define (n-fold-smoothed f n)
      ((repeated smoothed f n) f))

