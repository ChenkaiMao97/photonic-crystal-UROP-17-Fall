; Some parameters to describe the geometry:
(define-param eps 13)
(define-param w 1.2) ; width of waveguide
(define-param r 0.36)
(define-param sy 12); size of cell in y direction (perpendicular to wvg.)
(define-param dpml 1) ; PML thickness (y direction only!)
(set! geometry-lattice (make lattice (size 1 sy no-size)))
(set! geometry 
		(list (make block (center 0 0) (size infinity w infinity)
					(material (make dielectric (epsilon eps))))
					(make cylinder (center 0 0) (radius r) (height infinity) (material air))))
(set-param! resolution 20)

(set! pml-layers (list (make pml (direction Y) (thickness dpml))))

(define-param fcen 0.25) ; pulse center frequency                            
(define-param df 1.5) ; pulse freq. width: large df = short impulse
(set! sources(list
				(make source
				(src (make gaussian-src (frequency fcen) (fwidth df)))
				(component Hz) (center 0.1234 0))))
(set! symmetries (list (make mirror-sym (direction Y) (phase -1))))

(set-param! k-point (vector3 0.4 0))
(run-sources+ 300 (after-sources (harminv Hz (vector3 0.1234) fcen df)))

(define-param k-interp 19)
(run-k-points 300 (interpolate k-interp (list (vector3 0) (vector3 0.5))))
