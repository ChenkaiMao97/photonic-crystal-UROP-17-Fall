(define-param eps 11.75)
(define-param v 0.199)
(define-param pmlw 1)
(define-param endt 1)
(define-param fcen 0.5)
(define-param df 0.2)
(define-param sx 100)
(define-param sy 10)

(set! pml-layers (list (make pml (thickness pmlw))))
(set-param! resolution 25)

(set! geometry-lattice (make lattice (size sx sy no-size)))
(set! default-material (make dielectric (epsilon 50)))
;(set! sources (list (make source
;                   (src (make continuous-src (frequency fcen) (fwidth df)))
;                   (component Ex)
;                   (amplitude 100)
;                   (center (+(* -0.1 sx) (* v (meep-time))) 0)
;                   (end-time endt))))

(define radtest
(add-flux 0.5 0.2 3
(make flux-region
          (center 0 0) (size 0 (/ sy 2)))))
(run-sources+ 20
           (at-end output-efield-x))

(define (my-hello) 
(print "Hello World!\n")
(change-sources! (list (make source
                   (src (make continuous-src (frequency fcen) (fwidth df)))
                   (component Ex)
                   (amplitude 100)
                   (center (+(* -0.1 sx) (* v (meep-time))) 0)
                   (end-time endt))))
(at-every 0.1 (output-png Hz "-vZc dkbluered -M 1"))

;(define radtest
;(add-flux 0.5 0.2 3
;(make flux-region
;          (center 0 0) (size 0 (/ sy 2)))))
;(run-sources+ 20
;           (at-end output-efield-x))
;(display-fluxes radtest)
)

(run-until 30 output-efield-x my-hello)
(meep-time)
