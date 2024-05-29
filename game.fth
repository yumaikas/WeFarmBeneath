( Goal is to be a "farm beneath" game, I think? )

: $ ( str -- node ) .get_node(*) ; 


: //player //game .player ;
: /mainhand.equip ( item -- ) //player .equips >mainhand ; 
: /magic.set-school ( school -- ) //player >magic ;

: apply-loadout ( loadout -- ) [ 
    weapon>> "dagger" eq? [ <dagger> /mainhand.equip ] if
    weapon>> "spear" eq?  [ <spear>  /mainhand.equip ] if
    weapon>> "axe" eq?    [ <axe>    /mainhand.equip ] if

    tool>> "pot" eq?     [ <pot> //bag +add ] if
    tool>> "pickaxe" eq? [ <pickaxe> //bag +add ] if
    tool>> "lamp" eq?    [ <lamp> //bag +add ] if

    magic>> "mosswitch" eq?  [ <mosswitch>  /magic.set-school ] if
    magic>> "aurumage" eq?   [ <aurumage>   /magic.set-school ] if
    magic>> "telemancer" eq? [ <telemancer> /magic.set-school ] if
] with! ;

: start-game ( loadout -- ) //player.init apply-loadout //game print ;

: load-game bye ;

:: main-menu ( -- ) 
    "res://MainMenu.tscn" switch-scene
    self .scene ~picked dup print
    dup "new-game" eq? [ :main-menu pick-loadout start-game ] if
    dup "load-game" eq?  [ :load-game < > become ] if
    dup "quit" eq?  [ drop bye ] if
    :main-menu < > become
;

main-menu
