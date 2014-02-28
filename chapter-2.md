## Chapter 2: Building Abstractions With Data

Pending problems: 1, 3, 5

#### Exercise 2.2

    (define (make-segment p1 p2)
      (cons p1 p2))
    
    (define (start-segment seg)
      (car seg))
    
    (define (end-segment seg)
      (cdr seg))
    
    (define (make-point x y)
      (cons x y))
    
    (define (x-point p) (car p))
    (define (y-point p) (cdr p))
    
    (define (avg a b)
      (/ (+ a b)
         2.0))
    
    (define (midpoint-segment s)
      (let ((x1 (x-point (start-segment s)))
            (x2 (x-point (end-segment s)))
            (y1 (y-point (start-segment s)))
            (y2 (y-point (end-segment s))))
        (make-point (avg x1 x2) (avg y1 y2))))
    
    (define s1 (make-segment (make-point 1 1) (make-point 2 2)))
    
    (midpoint-segment s1)

#### Exercise 2.4

    (define (cons x y)
      (lambda (m) (m x y)))
    
    (define (car z)
      (z (lambda (p q) p)))
    
    (define (cdr z)
      (z (lambda (p q) q)))

#### Exercise 2.6

    (define (one)
      (lambda (f)
        (lambda (x) (f x))))
    
    (define (two)
      (lambda (f)
        (lambda (x) (f (f x)))))

#### Exercise 2.7

    (define (make-interval a b) (cons a b))
    
    (define (lower-bound int) (car int))
    (define (upper-bound int) (cdr int))
