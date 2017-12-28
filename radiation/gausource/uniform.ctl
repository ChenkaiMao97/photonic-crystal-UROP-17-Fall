(define-param a 1)
(define-param sx 10) 
(define-param sy sx)
(define-param Nx (/ sx 2))
(define-param Ny (/ sy 2))
(define-param r1 0.184)
(define-param r2 0.4)
(define-param eps 11.75)
(define-param v 0.35)
(define-param pmlw 1)
(define-param fcen 0.6)
(define-param df 0.2)
(define-param endt 1)

(set! geometry-lattice (make lattice (size 10 10 no-size)))
(set! pml-layers (list (make pml (thickness pmlw))))
(set! default-material (make dielectric (epsilon 30)))

(set-param! resolution 32)

(define (my-hello) 
(change-sources! (list (make source
                   (src (make continuous-src (frequency fcen) (width 20)))
                   (component Ex)
                   (amplitude 100)
                   (center (+(* -0.4 sx) (* v (meep-time))) 0)
                   (end-time (+ (meep-time) 0.1)))))
)

(define radtest
(add-flux 0.6 1 21
(make flux-region
        (center -3 1) (size 0 2))))
(use-output-directory)
(run-until 30 my-hello
(at-every 0.5 output-efield-x)
)
(display-fluxes radtest)
