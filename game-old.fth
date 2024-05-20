 ( Goal is to work on a "farm beath game" )
 ( Which involves moving up/down floors in a cave system )
 ( Trying to farm mushrooms and fend off cave dwellers )

"ERP" print
: switch-scene ( scn-path -- ) self .switchScene(*)! ;
: dLH ( l h -- rand ) ForthUtil.randi_range(**) ;
: dX ( x -- r ) 0 swap ForthUtil.randi_range(**) ;

: UP 0 -1 Vector2(**) ; : DOWN 0 1 Vector2(**) ;
: RIGHT 1 0 Vector2(**) ; : LEFT -1 0 Vector2(**) ;


:: gen-array ( count block -- arr ) =block =count *count range *block each *count narray ;

: <card> ( image -- card ) "TODO" ( Cards hold an image, and can be animated ) ;

:: <floor> ( -- floor ) dict =floor ( A floor is a set of layers that each contain things )
    dict *floor :items put ( Items do not block movment )
    dict *floor :mobs put ( Mobs block movement )
    0 narray *floor :entities put ( Both are ticked )
    *floor
;

:: populate ( depth floor -- floor ) =floor =depth
     ( TODO: Finish logic )
;

: get-player ( -- player ) 
  "res://PlayerPicker.tscn" show-dialog ~done dup :cancel eq? [  ] if ;

:: <game> ( -- game ) 
    dict =game 

    5 [ <floor> populate ] gen-array =floors
     ( TODO: Finish logic )

    *floors *game :floors put ( An array of floors )
    get-player [ "main-menu" { } become  ] [ *game :player put ( ) ] if
    *game
;
    

:: player-move ( game dir -- ) =dir =game
     *game current-floor .mobs =mobs
     ( TODO: Finish logic )
;

: pressed? ( action -- pressed? ) Input.is_action_just_pressed(*) ;


:: check-inputs ( game -- player-moved? ) =game
    false =moved?
    :up pressed? [ *game UP player-move true =moved? ] if
    :down pressed? [ *game DOWN player-move true =moved?  ] if
    :left pressed? [ *game LEFT player-move true =moved? ] if
    :right pressed? [ *game RIGHT player-move true =moved? ] if
    *moved?
;

:: main-menu ( -- ) "res://MainMenu.tscn" switch-scene
    self .scene ~picked
    dup "new-game" eq?  [ :new-game { } become ] if
    dup "load-game" eq?  [ :load-game { } become ] if
    dup "quit" eq?  [ drop bye ] if
    :main-menu { } become
;

"XEH" print
main-menu
