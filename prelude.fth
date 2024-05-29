( put: abc -- b[c]=a )
: with! ( subj block -- ... ) swap u< do-block u> drop ;
: with ( subj block -- ... ) swap u< do-block u> ;
: with-us! ( that it block -- ) -rot swap u< u< do-block u> drop u> drop ;
: that ( u:[that it] -- u:[that it] that ) ;
: bye ( -- ) self .get_tree() .quit() suspend ;
: log ( text -- ) self ._log.append(*) ;
: decal ( text cell-pos -- ) self .decal(**)! ;
: <dict> ( block -- dict ) dict u< do-block u> ;
: <action> ( action name -- ) [ u@ >name u@ >action ] <dict> ;
: //game ( -- game ) self .game ;
: player-bag ( -- ) //game .player.bag ;
: splat ( < ... > -- ... ) [ ] each ;
: inject ( deps action -- )  self .action_injections swap put ;
: pred ( action -- ) dup :/enable? str(**) swap self .action_predicates swap put ;
: label ( name action -- ) self .action_names swap put ;
: v2 ( x y -- v ) Vector2(**) ;

: switch-scene ( scn-path -- ) self .switchScene(*)! ;
: dLH ( l h  -- rand ) ForthUtil.randi_range(**) ;
: d<LH> ( < l h > -- rand ) u< it 0 get u> 1 get dLH ;
: dX ( x -- r ) 0 swap ForthUtil.randi_range(**) ;
: d<> ( arr -- el ) dup .size() dX nth ; 

: drop-it ( -- ) VM .utilStack.pop_back()! ;
: UP 0 -1 Vector2(**) ; : DOWN 0 1 Vector2(**) ;
: RIGHT 1 0 Vector2(**) ; : LEFT -1 0 Vector2(**) ;

: has-room? ( amt bag -- ) [ slots>> ] with .items .size() ge? ;
:: any? 0 false { arr pred idx found? -- } [ 
    *arr *idx nth *pred do-block =found 
    [ 1+ ] %idx 
    *found? not *arr len *idx gt? and
] while *found? ;

:: filter <> { arr pred out -- out } 
    *arr [ dup =el *pred do-block [ *el *out .append(*) ] if ] each *out ;

:: find 0 false { arr pred idx found? -- } [ 
    *arr *idx nth *pred do-block =found 
    [ 1+ ] %idx 
    *found? not *arr len *idx gt? and
] while *arr *idx *nth ;

: +hurt ( amt obj -- ) dup .hurt exec ;
: +add ( item obj -- ) _s dup .add exec ;
: +remove ( item obj -- ) dup .remove exec ;
: +find-tagged ( tag bag -- ) dup .find_tagged exec ;
: +has-tag? ( tag bag -- ) dup .has_tag exec ;
: +move ( dir obj -- .. ) dup .move exec ;
: +tick ( obj -- ) dup .tick exec ;
: +is_alive ( obj -- ) dup .is_alive exec ;

: level-remove "level-remove not implemented!" err! 1 throw ;

