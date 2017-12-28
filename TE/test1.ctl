(define-param a 1)
(define-param r1 0.181)
(define-param eps 11.75)
(define-param r2 0.4)
(define-param fcen 0.6)
(define-param df 0.3)

(set! geometry-lattice (make lattice (size 1 1 no-size)))

(set! geometry
        (list
        (make cylinder (center 0 0) (radius r2) (height infinity) (material (make dielectric (epsilon eps))))
        (make cylinder (center 0 0) (radius r1) (height infinity) (material air))))
(set-param! resolution 32)
(set! sources (list
        (make source
        (src (make gaussian-src (frequency fcen) (fwidth df)))
        (component Ez) (center 0.321 -0.1234))))

(define-param k-interp 100)
(run-k-points 200 (interpolate k-interp (list (vector3 0 -0.3) (vector3 0 0.3))))