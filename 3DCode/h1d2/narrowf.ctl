; test simulation of 2D photonic crystal structure with BIC

; output directory name
;(define dirname "h1d50_w0d45")

; material parameters
(define-param n-slab 3.6) ; slab material
(define-param n-air 1)     ; surrounding air

; simulation parameters
(define-param T 1000)      ; run time
(define-param fcen 0.06432)    ; frequency center of source
(define-param df 1)      ; frequency width of source, broadband
(define-param kx 0.1)
(define-param ky 0)
(define-param kz 0)
;(define-param src-cmp Ez)  ; for TM calculation
(define-param src-cmp Hz) ; for TE calculation

; geometry parameters
(define-param modenum 1)
(define-param extraparam 0)
(define-param a 1)         ; period, we shall assume that everything is normalized correctly hereon and not multiply things
(define-param ah 1.2)      ; height of hole
(define-param ar 0.25)     ; radius of hole
(define-param pml-thick 3.0)     ; thickness of PML at the end
(define-param ablen 4.25)  ; length of free radiation region
(define-param nfreq 1)   ; number of frequencies to look at flux spectrum
(define-param nref 10)	 ; number of reference planes to use
(define-param refst (+ (/ ah 2) 0.5))	       ; distance to start reference planes
(define-param refend (+ (/ ah 2) ablen -0.5))    ; distance to end reference planes
(define Lz (+ ah (* 2 (+ ablen pml-thick))))  ; length in z direction

(set! progress-interval 10)			; overwrites default of 4

(define-param fileprefix "")
(set! filename-prefix fileprefix)
(set! force-complex-fields? true)

; create geometry
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

;;(use-output-directory dirname)

;; (define topflux	; transmitted flux                                          
;;         (add-flux fcen df nfreq
;;                   (make flux-region
;;                     (center 0 0 ablen) (size a yt 0))))

;; (define botflux	; transmitted flux, not sure if this is what we want though
;;         (add-flux fcen df nfreq
;;                   (make flux-region
;;                     (center 0 0 (- ablen)) (size a yt 0))))


(set! k-point (vector3 kx ky kz))
(run-sources+ T
	      ;(at-beginning output-epsilon)
	      (after-sources (harminv src-cmp (vector3 src1-x src1-y src1-z) fcen df)))
;(run-until (/ 1 fcen) (at-every (/ 1 fcen 20) output-efield-y))

(define i (sqrt -1))         ; imaginary number
(define (pexp r kx ky kz) (exp (- 0 (* i (vector3-dot r (vector3 kx ky kz)))))) ; phase factor exponential
(define (f r ex) (* ex (pexp r kx ky kz)))         ; function to integrate
;(define (f r ex) (make-polar ex (- 0 (vector3-dot r (vector3 kx ky kz)))))
(define (intsize r var) 1)
(define (intabs r var) (magnitude var))
(define (intnorm r Ex Ey Ez) (vector3-norm (vector3 Ex Ey Ez)))
(define (poyntingflux r Ex Ey Ez Hx Hy Hz) (vector3-dot (vector3 0 0 1) (vector3-cross (vector3 Ex Ey Ez) (vector3 Hx Hy Hz))))

(print "Output format: kx, ky, param, lambda, freq, Q, abs(E)_tot, abs(E)_central, total size, central size, abs(Ex), abs(Ey), abs(Ez), cx_t, cy_t,, cz_t, cx_b, cy_b, cz_b, P_t, P_b, boundary size\n")
(print "Data point:," kx "," ky "," extraparam "," modenum "," fcen "," (/ 1 df) ","
       (integrate-field-function
       	(list Ex Ey Ez) intnorm
      	(volume (size a a Lz) (center 0 0 0))) ","
       (integrate-field-function
       	(list Ex Ey Ez) intnorm
       	(volume (size a a ah) (center 0 0 0))) ","
       (integrate-field-function
	(list Ex) intsize 		; dummy variable Ex, not used in integral
	(volume (size a a Lz) (center 0 0 0))) ","
       (integrate-field-function
	(list Ex) intsize
	(volume (size a a ah) (center 0 0 0))) ","
       (integrate-field-function
	(list Ex) intabs
	(volume (size a a Lz) (center 0 0 0))) ","
       (integrate-field-function
	(list Ey) intabs
	(volume (size a a Lz) (center 0 0 0))) ","
       (integrate-field-function
	(list Ez) intabs
	(volume (size a a Lz) (center 0 0 0))) ","
       nref "," refst "," refend ",")
(define refd refst)
(do ((count 0 (+ count 1))) ((> count nref))
       (set! refd (/ (+ (* count refend) (* (- nref count) refst)) nref))
       (print
       (integrate-field-function 
       	(list Ex) f
       	(volume (size a a 0) (center 0 0 refd))) ","
       (integrate-field-function 
      	(list Ey) f
      	(volume (size a a 0) (center 0 0 refd))) ","
       (integrate-field-function 
      	(list Ez) f
      	(volume (size a a 0) (center 0 0 refd))) ","
       (integrate-field-function 
      	(list Ex) f
      	(volume (size a a 0) (center 0 0 (- refd)))) ","
       (integrate-field-function 
      	(list Ey) f
      	(volume (size a a 0) (center 0 0 (- refd)))) ","
       (integrate-field-function 
      	(list Ez) f
      	(volume (size a a 0) (center 0 0 (- refd)))) ","
       (flux-in-box Z
	(volume (center 0 0 refd) (size a a 0))) ","
       (flux-in-box Z
	(volume (center 0 0 (- refd)) (size a a 0))) ",")
)

       ;; (integrate-field-function
       ;; 	(list Ex Ey Ez Hx Hy Hz) poyntingflux
       ;; 	(volume (size a a 0) (center 0 0 refd))) ","
       ;; (integrate-field-function
       ;; 	(list Ex Ey Ez Hx Hy Hz) poyntingflux
       ;; 	(volume (size a a 0) (center 0 0 (- refd)))) ","
       (print
       (integrate-field-function
	(list Ex) intsize
	(volume (size a a 0) (center 0 0 refd))) ","
       "\n")
;; ;(display-fluxes topflux) ; print out the flux spectrum, seems to be giving some problems at the moment
