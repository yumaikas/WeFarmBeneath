( Goal is to be a "farm beneath" game, I think? )
( put: abc -- b[c]=a )
: bye ( -- ) self .get_tree() .quit() suspend ;
: log ( text -- ) self ._log.append(*) ;
: <dict> ( block -- dict ) dict u< do-block u> ;
: <action> ( action name -- ) [ u@ >name u@ >action ] <dict> ;
: game ( -- game ) self .game ;
: player-bag ( -- ) game .player.bag ;
: splat ( < ... > -- ... ) [ ] each ;
: inject ( deps action -- )  self .action_injections swap put ;
: pred ( action -- ) dup :/enable? str(**) swap self .action_predicates swap put ;
: label ( name action -- ) self .action_names swap put ;
: level-remove ( target ) drop "level-remove not implemented yet" log  ; 

: hurt ( mob amt -- ) [ swap - ] %HP ; ( TODO: Add more logic of on-hurt effects )



:: any? 0 false { arr pred idx found? -- } [ 
    *arr *idx nth *pred do-block =found 
    [ 1+ ] %idx 
    *found? not *arr len *idx gt? and
] while *found? ;

:: find 0 false { arr pred idx found? -- } [ 
    *arr *idx nth *pred do-block =found 
    [ 1+ ] %idx 
    *found? not *arr len *idx gt? and
] while *arr *idx *nth ;

:: has-tag? { bag tag -- ? } *bag .items [ *tag .tags .has(*) ] any? ;
: find-tagged ( bag tag ) u< .items [ .tags it swap .has(*) ] find u> drop ;
: bag-remove ( item -- ) game .player.bag .erase(*) ;

: switch-scene ( scn-path -- ) self .switchScene(*)! ;
: dLH ( l h  -- rand ) ForthUtil.randi_range(**) ;
: d<LH> ( < l h > -- rand ) u< it 0 get u> 1 get dLH ;
: dX ( x -- r ) 0 swap ForthUtil.randi_range(**) ;
: d<> ( arr -- el ) dup .size() dX nth ; 


: $ ( str -- node ) .get_node(*) ; 

: UP 0 -1 Vector2(**) ; : DOWN 0 1 Vector2(**) ;
: RIGHT 1 0 Vector2(**) ; : LEFT -1 0 Vector2(**) ;


: <equips> dict u<
    "" it >mainhand
    "" it >offhand
    "" it >torso
    "" it >trinket
    u>
;

: <bag> ( size -- bag ) [ 
    it >slots 
    < > it >items 
] <dict> ;

: has-room? ( amt bag -- ) u< u@ .slots u> .items .size() ge? ;
: to-mainhand ( item game -- ) .player.equips >mainhand ; 
: to-bag { item bag -- } 1 *bag has-room? [ *item *bag .items.append(*) ] if ;

:: start-game { loadout -- } 
    [ <equips> it >equips ( -- ) 10 <bag> it >bag ] <dict> game >player
    ( Cargo is how much stuff the player can carry )

    *loadout .weapon
        dup "dagger" eq? [ :<dagger> exec game to-mainhand ] if
        dup "spear" eq? [ :<spear> exec game to-mainhand ] if
        dup "axe" eq? [ :<axe> exec game to-mainhand  ] if
        drop
    *loadout .tool
        dup "pot" eq? [ :<pot> exec player-bag to-bag ] if
        dup "pickaxe" eq? [ :<pickaxe> exec player-bag to-bag ] if
        dup "lamp" eq? [ :<lamp> exec player-bag to-bag ] if
        drop
    *loadout .magic dup print
        dup "mosswitch" eq? [ :<mosswitch> exec game .player >magic ] if
        dup "aurumage" eq? [ :<aurumage> exec game .player >magic ] if
        dup "telemancer" eq? [ :<telemancer> exec game .player >magic ] if
        drop
    game print
;

: load-game bye ;

: init ( -- )
    "./cook.fth" dup print load
    "./items.fth" dup print load
    "./loadout-pick.fth" dup print load
    "./magic.fth" dup print load
;

:: main-menu ( -- ) 
    "res://MainMenu.tscn" switch-scene
    self .scene ~picked dup print
    dup "new-game" eq?  [ :main-menu :pick-loadout exec start-game ] if
    dup "load-game" eq?  [ :load-game < > become ] if
    dup "quit" eq?  [ drop bye ] if
    :main-menu < > become
;

init
main-menu
