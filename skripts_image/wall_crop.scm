;poměr 128 : 96
;model 	(left 230)
;	(top 42)
;	(height_frame 450)
;	(width_frame 580)
;tunika  (left 338)
;	(top 106)
;	(height_frame 284)
;	(width_frame 264)

	

(define my_first_wall (lambda()

		(let* ((w_scale 64) ;výška vysledného obrázku
			(start_position 1) ; od kteryho obrazku 0001
			(my-list (list 1 2)) ; obrázky ze souboru				
				(jump 1) ; skok po kolika obrázkách
				(count 1) ; Počet obrázku vpodstatě len ze seznamu ale kdyby asi nebyl seznam ????
				(count-iter 1) ;asi počet iterací přes obrázky ???
				(left 350) ;Pozice začatku vystřihu zleva v originálu
				(top 1); Pozice začátku výstřihu shora v originálu
				(height_frame 538) ; výška obrázku v originále
				(width_frame (- 609 350))	;šířka obrázku v originále
					(sides 4) ; počet stran natočení

					 ;; POstava cut 
					(h_scale (+ 1 (round (* w_scale (/ height_frame width_frame)))))
					(sizex (* count w_scale)) ;; POstava cut (gimp-image-crop img width_frame (* 1.75 width_frame) 180 10 )
					(sizey (* sides h_scale))

					(main_im (car (gimp-image-new sizex sizey 0)))
					(e (car (gimp-layer-new main_im sizex sizey RGB-IMAGE "main" 100 NORMAL-MODE)))
					(z (gimp-image-add-layer main_im e -1))
					(main_d (car (gimp-image-get-active-layer main_im)))
			(my_func
		(lambda (path_r h_scale count)

			(let* ((inc start_position)
						(x 0)
						(y 0)
						(num 1)			
						(sizex (* count width_frame))
						(sizey (* (/ height_frame width_frame) width_frame))
						(main_im (car (gimp-image-new sizex sizey 0)))
						(e (car (gimp-layer-new main_im sizex sizey  RGB-IMAGE "foobar" 100 NORMAL-MODE)))
						(z (gimp-image-add-layer main_im e -1))
						(main_d (car (gimp-image-get-active-layer main_im))))
						
						(gimp-display-new main_im)
			;(gimp-display-new main_im)
				(while (<= inc count-iter)
						(if (and my-list (>= inc 0)) (set! num (list-ref my-list inc)))
						(let* ((path (string-append path_r (if (> num 9) "00" "000")  (number->string num) ".png"))
		
								(img (car (gimp-file-load RUN-NONINTERACTIVE path path)))
							 (drw (car (gimp-image-get-active-layer img)))
			; 					(new-layer)
			
							(original-width (car (gimp-image-width img)))
							(original-height (car (gimp-image-height img)))
							
					)
			;	(gimp-display-new img)	
					(gimp-image-crop img width_frame height_frame left top)
					(gimp-layer-set-name drw (number->string inc))

					(gimp-edit-copy drw)
					(gimp-edit-paste main_d FALSE)
					(set! drw (car (gimp-image-get-active-layer main_im)))	
					(gimp-layer-translate drw (+ (/ width_frame 2) (- x (/ sizex 2))) 0)
					(gimp-floating-sel-anchor drw)

				
				(set! x (+ x width_frame))
				(set! inc (+ inc 1)))
					
			)main_im)))

	
				(inc 1))
		(gimp-display-new main_im)	
		(while (<= inc sides)
			(let* ((picture (my_func (string-append "/home/ondrej/programe/engine-RPG-only-sdl/bin/images/" (number->string (* inc 2)) "/") h_scale count))
							(drw (car (gimp-image-get-active-layer picture))))
				(gimp-image-scale-full picture (* count w_scale) h_scale 0)
				(gimp-edit-copy drw)
					(gimp-edit-paste main_d FALSE)
				(set! drw (car (gimp-image-get-active-layer main_im)))
				(gimp-layer-translate drw 0 (- (* (- inc 1) h_scale) (* (- sides 1) (/ h_scale 2))))
				(gimp-floating-sel-anchor drw)


				;	(set! (car (gimp-image-get-active-layer picture)) (car (gimp-image-get-active-layer main_im)))
			(set! inc (+ inc 1))
		)
))))


(define my_func )

 (script-fu-register
          "my_first_wall"                        ;func name
          "skript for wall"                                  ;menu label
          "Creates a simple text box, sized to fit\
            around the user's choice of text,\
            font, font size, and color."              ;description
          "Michael Terry"                             ;author
          "copyright 1997, Michael Terry"             ;copyright notice
          "October 27, 1997"                          ;date created
          ""                     ;image type that the script works on
     
        )
        (script-fu-menu-register "my_first_wall" "<Toolbox>/Xtns/Script-Fu/Text")
