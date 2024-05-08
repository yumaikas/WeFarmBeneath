 ( Goal is to work on a "farm beath game" )
 ( Which involves moving up/down floors in a cave system )
 ( Trying to farm mushrooms and fend off cave dwellers )

: dLH ( l h -- rand ) Util.randi_range(**) ;
: dX ( x -- r ) Util.dX(*) ;

: UP 0 -1 Vector2(**) ; : DOWN 0 1 Vector2(**) ;
: RIGHT 1 0 Vector2(**) ; : LEFT -1 0 Vector2(**) ;

:: gen-array ( count block -- arr ) u< dup u> times narray ;

: <card> ( image -- card ) "TODO" ( Cards hold an image, and can be animated ) ;

:: <floor> ( -- floor ) dict =floor ( A floor is a set of layers that each contain things )
    dict *floor :items put ( Items do not block movment )
    dict *floor :mobs put ( Mobs block movement )
    0 narray *floor :entities put ( Both are ticked )
    *floor
;

: populate ( floor -- floor )
     ( TODO: Finish logic )
;

:: <game> ( -- game ) 
    dict =game

    5 [ <floor> populate ] times 5 narray =floors
     ( TODO: Finish logic )

    *floors *game :floors put ( An array of floors )
    *game
;
    

:: player-move ( game dir -- ) =dir =game
     *game current-floor .mobs =mobs
     ( TODO: Finish logic )
;

: pressed? ( action -- pressed? ) Input.is_action_just_pressed(*) ;

:: check-inputs ( game -- player-moved? ) =game
    false =moved?
    "up" pressed? [ *game UP player-move true =moved? ] if
    "down" pressed? [ *game DOWN player-move true =moved?  ] if
    "left" pressed? [ *game LEFT player-move true =moved? ] if
    "right" pressed? [ *game RIGHT player-move true =moved? ] if
    *moved?
;

:: _update ( dt game -- ) nip =game
    *game check-inputs ~done [
        *game tick ~done
    ] if
    *game should-close? [ *game close ] if
;
