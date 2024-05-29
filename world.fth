: btnp? Input.is_action_just_pressed(*) ;
[ 
    UP >>up 
    DOWN >>down
    LEFT >>left
    RIGHT >>right
] <dict> const: DIRS ;

: /tick-mobs ( -- ) 
    mobs>> .values [ +tick ~done ] each
    //player +tick ~done
;


:: /can-move-to? ( pos u:[floor] -- t/f ) 
    mobs>> nav>> { m n } [ it *m .has(*) not it *n .has(*) and ] with! ;

:: /move-player ( dir -- | it/floor -- it/floor ) dup //player .pos + { dir new-pos }
    ( Check to see if there are any interactables )
     *new-pos /can-move-to? [ *dir //player +move
        /tick-mobs 
    ] [
        /gather-interactions //pick-list ~done
        /tick-mobs
    ] if-else
;

:: /player-action 
( -- .. action )
    
    [ 
        it DIRS .has(*) [ it DIRS get drop-it /move-player ] if 
        "Unhandled event " it "!" str(***) err!
        drop-it :exec-floor < it > become
    ] with!
;

: /turn ( input -- | it-floor ) /player-action ;

:: exec-floor ( floor -- ) { f }
    *f [ 
        self ~game_input /turn  
    ] with
;
