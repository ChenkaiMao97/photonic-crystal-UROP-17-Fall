; liquid-hole SiN slab in SiO2 medium

; material parameters
(define-param n-slab 2.018)  ; SiN
(define-param n-sio2 1.458)  ; SiO2
(define-param n-liquid  1.458)

; simulation parameters
(define-param T 300)           ; run time
(define-param fcen 0.5)        ; frequency center of source
(define-param df 0.03)          ; frequency width of source
(define-param kx 0)
(define-param ky 0)
(define-param kz 0)
(define-param src-cmp Ez)    ; for TM calculation
;(define-param src-cmp Hz)    ; for TE calculation

; geometry parameters
(define-param a 336.0)               ; period
(define-param slab-thick 179.2)      ; slab thickness
(define-param hole-diameter 160.0)   ; diameter of the holes

(define slab-thick (/ slab-thick a))
(define hole-diameter (/ hole-diameter a))

(define-param medium-thick 7)      ; thickness of medium on both sides
(define pml-thick 3.0)

(define Lz (+ 1 (* medium-thick 2)))
(define z_slab 0)

(define-param tilt_angle 5)
(define tilt_angle (/ (* tilt_angle 3.14159) 180))
(define s_theta (sin tilt_angle))
(define c_theta (cos tilt_angle))

;(set-param! resolution 20)
(set-param! resolution 24)
(set! geometry-lattice (make lattice (size 1 1 Lz)))
(set! geometry
      (list
       (make block
                (center 0 0 (/ Lz 4)) (size infinity infinity (/ Lz 2))
		(material (make dielectric (index n-liquid))))
       (make block
                (center 0 0 (/ Lz -4)) (size infinity infinity (/ Lz 2))
		(material (make dielectric (index n-sio2))))
       (make block
                (center 0 0 z_slab) (size (vector3 infinity infinity slab-thick))
                (material (make dielectric (index n-slab))))
       (make cylinder 
                (center 0 0 z_slab) (radius (/ hole-diameter 2)) (height (* 2 slab-thick))
                (axis s_theta 0 c_theta)
                (material (make dielectric (index n-liquid))))))
(set! pml-layers (list (make pml (thickness pml-thick) (direction Z))))

; put sources randomly on the slab mid-plane, away from holes
(define src1-x  0.3058)
(define src1-y  0.1234)
(define src1-z  z_slab)
(define src2-x  0.0821)
(define src2-y -0.2591)
(define src2-z  z_slab)
(set! sources (list
               (make source
                 (src (make gaussian-src (frequency fcen) (fwidth df)))
                 (component src-cmp)
                 (center src1-x src1-y src1-z))
               (make source
                 (src (make gaussian-src (frequency fcen) (fwidth df)))
                 (component src-cmp)
                 (center src2-x src2-y src2-z))))

(set! k-point (vector3 kx ky kz))
(run-sources+ T
	      ;(at-beginning output-epsilon)
	      (after-sources (harminv src-cmp (vector3 src1-x src1-y src1-z) fcen df)))
