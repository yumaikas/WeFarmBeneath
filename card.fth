16 16 v2 const: cell_size

: 2/ 2 div ;
: /tween-prop ( obj prop val t -- tweener ) it .tween_property(****) ;
: /par ( tweener -- par-tweener ) it .parallel() ;
: #trans-circ @Tween.TRANS_CIRC .set_trans(*) ;
:: animate/hop! { to card -- }
    *card .position *to .pos 2/ 0 -4 v2 + { midpoint }
    self .create_tween() [ 
        *card "position:x" *midpoint .x 0.125 /tween-prop drop
        *card "position:y" *midpoint .y 0.125 2/ /par /tween-prop #trans-circ

        *card "position:x" *to .x 0.125 /tween-prop drop
        *card "position:y" *to .y 0.125 2/ /par /tween-prop #trans-circ
    ] with
;

: card/move ( to card -- ) 
    [ >>pos pos>> cell_size * node>> animate/hop ~finished ] with! ;

: <card> ( init -- card ) <dict> [
   self .card() >>node
   image>> node>> >texture
   :card/move >>move
] with ;
