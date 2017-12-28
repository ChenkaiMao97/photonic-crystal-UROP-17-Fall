(define-param sx 16) ; size of cell in X direction                              
(define-param sy 32) ; size of cell in Y direction                              
(set! geometry-lattice (make lattice (size sx sy no-size)))

(define-param pad 4) ; padding distance between waveguide and cell edge         
(define-param w 1) ; width of waveguide    

(define wvg-ycen (* -0.5 (- sy w (* 2 pad)))) ; y center of horiz. wvg          
(define wvg-xcen (* 0.5 (- sx w (* 2 pad)))) ; x center of vert. wvg 

(define-param no-