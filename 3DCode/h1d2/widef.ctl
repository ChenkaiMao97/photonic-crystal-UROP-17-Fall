; test simulation of 2D photonic crystal structure with BIC

; material parameters
(define-param n-slab 3.6) ; slab material
(define-param n-air 1)     ; surrounding air

; simulation parameters
(define-param T 300)      ; run time
(define-param fcen 0.3)    ; frequency center of source
(define-param df 0.5)      ; frequency width of source, broadband
(define-param kx 0)
(define-param ky 0)
(define-param kz 0)
;(define-param src-cmp Ez)  ; for TE calculation
(define-param src-cmp Hz) ; for TE calculation

; geometry parameters
(define-param a 1)         ; period, we shall assume that everything is normalized correctly hereon and not multiply things
(define-param ah 1.2)      ; height of slab
(define-param ar 0.25)	    ; radius of hole
(define-param pml-thick 3.0)     ; thickness of PML at the end
(define-param ablen 4.25)  ; length of free radiation region
(define-param nfreq 20)   ; number of frequencies to look at flux spectrum
(define Lz (+ ah (* 2 (+ ablen pml-thick))))  ; length in y direction

(define-param fileprefix "")
(set! filename-prefix fileprefix)
(set! force-complex-fields? true)

(set-param! resolution 20)
(set! geometry-lattice (make lattice (size a a Lz)))
(set! geometry
      (list
       (make block
	 (center 0 0 0) (size a a ah)
	 (material (make dielectric (index n-slab))))
       (make cylinder
         (center 0 0 0) (radius ar) (height ah)
	 (material (make dielectric (index n-air))))
      )
)
(set! pml-layers (list (make pml (thickness pml-thick) (direction Z))))

; put sources randomly on the slab mid-plane, away from holes
(define src1-x  0.3058)
(define src1-y  0.1234)
(define src1-z  0)
(define src2-x  0.0821)
(define src2-y -0.2591)
(define src2-z  0)
(set! sources (list
	       (make source
		 (src (make gaussian-src (frequency fcen) (fwidth df)))
		 (component src-cmp)
		 (center src1-x src1-y src1-z))
               (make source
                 (src (make gaussian-src (frequency fcen) (fwidth df)))
                 (component src-cmp)
                 (center src2-x src2-y src2-z))))

;(use-output-directory dirname)

;; (define topflux; transmitted flux                                          
;;         (add-flux fcen df nfreq
;;                   (make flux-region
;;                     (center 0 0 ablen) (size 1 0.1 0))))

(set! k-point (vector3 kx ky kz))
(run-sources+ T
	      (at-beginning output-epsilon)
	      (after-sources (harminv src-cmp (vector3 src1-x src1-y src1-z) fcen df)))
;;(run-until (/ 1 fcen) (at-every (/ 1 fcen 20) output-efield-z))

;; (define i (sqrt -1))         ; imaginary number
;; (define (pexp r kx ky kz) (exp (- 0 (* i (dot r kx ky kz))))) ; phase factor exponential
;; (define (f r ex kx ky kz) (* ex (pexp r kx ky kz)))         ; function to integrate
;; (define (f r ex kx ky kz) (make-polar ex (vector3-dot r (vector3 kx ky kz))))

;; (print "output format: kx, ky, cx_t, cy_t, cx_b, cy_b\n")
;; (print "data point: " kx "," ky ","
;;       (integrate-field-function 
;; 	(list Ex kx ky kz) f
;; 	(volume (size 1 0.1 0) (center 0 0 ablen))) ","
;;       (integrate-field-function 
;; 	(list Ey kx ky kz) f
;; 	(volume (size 1 0.1 0) (center 0 0 ablen))) ","
;;       (integrate-field-function 
;; 	(list Ez kx ky kz) f
;; 	(volume (size 1 0.1 0) (center 0 0 ablen))) ","
;;       (integrate-field-function 
;; 	(list Ex kx ky kz) f
;; 	(volume (size 1 0.1 0) (center 0 0 (- ablen)))) ","
;;       (integrate-field-function 
;; 	(list Ey kx ky kz) f
;; 	(volume (size 1 0.1 0) (center 0 0 (- ablen)))) ","
;;       (integrate-field-function 
;; 	(list Ez kx ky kz) f
;; 	(volume (size 1 0.1 0) (center 0 0 (- ablen))))
;;       "\n")
; (display-fluxes topflux) ; print out the flux spectrum
