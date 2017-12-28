(define-param a 1)
(define-param N 10)
(define-param r1 0.184)
(define-param r2 0.4)
(define-param eps 11.75)
(define-param v 0.199)
(define-param pmlw 1)


(set! geometry-lattice (make lattice (size 10 10 no-size)))

(set! geometry
	(geometric-object-duplicates (vector3 0 a) 0 (- (* 2 N) 1)
		(geometric-object-duplicates (vector3 a 0) 0 (- (* 2 N) 1)
			(list
				(make cylinder (center (+ (* (- N) a) (/ a 2)) (+ (* (- N) a) (/ a 2))) (radius r2) (height infinity) (material (make dielectric (epsilon eps))))
				(make cylinder (center (+ (* (- N) a) (/ a 2)) (+ (* (- N) a) (/ a 2))) (radius r1) (height infinity) (material air))
			)
		)
	)
)

(define-param k-interp 10)
(run-k-points 200 (interpolate k-interp (list (vector3 0 -0.3) (vector3 0 0.3))))