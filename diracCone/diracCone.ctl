(define-param eps 12.5)
(define-param a 1)
(define-param r 0.2)
(define-param sx 10) 
(define-param sy sx)
(define-param N (/ sx 2))
(define-param fcen 0.54)
(define-param df 0.1)
         
(set! geometry-lattice (make lattice (size 10 10 no-size)))

(set! geometry
	(geometric-object-duplicates (vector3 0 a) 0 (- (* 2 N) 1)
	(geometric-object-duplicates (vector3 a 0) 0 (- (* 2 N) 1)
		(make cylinder (center (+ (* (- N) a) (/ a 2)) (+ (* (- N) a) (/ a 2))) (radius r) (height infinity) (material (make dielectric (epsilon eps)))))))

(set-param! resolution 20)
(set! sources (list
        (make source
        (src (make gaussian-src (frequency fcen) (fwidth df)))
        (component Hz) (center 0.1234 -0.4321))))

(define-param k-interp 19)
(run-k-points 200 (interpolate k-interp (list (vector3 -0.1) (vector3 0.1))))

