:: base-hit { t w -- hit? } *t .armor *w .to_hit d<LH> gt? ;
:: calc-hit { t w -- hit } 
    dict [ 
        *w .to_crit splat { crit-at crit-range }
        *crit-at *crit-range dX le? >>did_crit
        did_crit>> [ true >>did_hit ] [ *t *w base-hit >>did_hit ] if-else 
    ] with ;

: <weakness-table> dict [ 
    1 >>stab
    1 >>slice
    1 >>fallback
] with ;

: <armor-table> dict [
    0 >>stab
    0 >>slice
    0 >>fallback
] with ;


:: DR-of { t w -- DR } 
  *w .damage_type *t .armor.has(*) [
    *w .damage_type *t .armor get - 
  ] [ 0 ] if-else
;

:: damage-of { t w crit -- HP }
  *w .damage_type *t .weakness.has(*) 
    [ *w .damage_type *t .weakness get *w .damage *crit * * ] 
    [ *w .damage ]
  if-else
  *t *w DR-of - 
  0 max(**)
;

: attack! { target game -- }
    *game .player.equips.mainhand =w
    *target *w calc-hit =h
    *h .did_crit 2 1 ? =crit
    *h .did_hit [ 
        *target *w *crit damage-of - *target +hurt 
    ] [ 
        ( todo: reactions? )
    ] if-else
; dict [
    :Attack >>label
    # >>action
    < :target :game > >>inject
] with const: attack

( Weapons )
: <dagger> dict [
    :Dagger >>name
    < :weapon > >>tags
    1        >>reach
    < 2 20 > >>to_crit
    < 8 12 > >>to_hit
    1        >>damage
    :stab    >>damage_type
    2        >>sockets
    < attack :throw > >>actions
] with ;

: <axe> dict [
    :Axe >>name
    < :weapon > >>tags
    1           >>reach
    2           >>damage
    < 1 30 >    >>to_crit
    < 10 12 >   >>to_hit
    :slash      >>damage_type
    1           >>sockets
    < attack :throw > >>actions
    ] with
;

: <spear> dict [
    :Spear >>name
    < :weapon > >>tags
    2  >>reach
    1  >>damage
    < 1 20 >  >>to_crit
    < 10 15 > >>to_hit
    :stab >>damage_type
    0     >>sockets
    < attack :throw > >>actions
    ] with
;

: /interacts ( name inject -- ) [ >>inject :/interacts? str(**) >>action  ] <dict> >>interacts ;

: /action ( name inject -- ) >>inject >>name ;
: /pred ( name inject -- ) [ >>inject :/enable? str(**) >>action ] <dict> >>pred ;

( Tools )
: pot/boil!/enable? ( bag -- ? ) :raw swap +has-tag? ; < :bag > # inject
: pot/boil! {  to-cook -- ( need to get the bag interactions in here ) } 
*to-cook food? [ *to-cook cook ] [ "Cannot cook " *to-cook .label str(**) log ]  if-else 
; [
    # < :bag > /pred
    # < :bag/item > /action
    :Cook >>label
] <dict> const: pot/boil

: <pot> [
    :Pot it >name
    < > it >tags
    :pot it >type
    1 it >level
    < pot/boil > it >actions 
] <dict> ;

< "The axe chips at the rock" "Flecks of stone bounce off"  > const: pickaxe-mine-desc

: pickaxe/mine!/interacts? ( item -- ) .tags :stone swap .has(*) ;
: pickaxe/mine! { me item bag coord -- }
    *item [ *me .mining_power - ] HP%
    *item .HP 0 gt? [ 
        "The rock gives way, revealing the " *item .contents.name " inside" str(***) log
        *item .contents [ 1 *bag has-room? [ *bag +add ] [   ] if-else ] each
    ] [
        pickaxe-mine-desc d<> log
    ] if-else
; [ 
    :Mine >>label
    # < :me :target :bag :coord > /action
    # < :target > /interacts
] <dict> const: pickaxe/mine

: <pickaxe> dict [ 
    :Pickaxe >>name
    < > >>tags
    1         >>mining_power
    < pickaxe/mine > >>actions
    < :stone :gem > >>interacts
] with ;

: lamp/douse!/enable? ( lamp -- ? ) .state :lit eq? ;
: lamp/douse! ( lamp -- )  [ :unlit >>state ] with! ; 
[ :Douse >>label
  # < :me > /action
  # < :me > /pred
] <dict> const: lamp/douse

: lamp/light!/enable? ( lamp -- ? ) .state :unlit eq? ;
: lamp/light! ( lamp -- ) [ :lit >>state ] with! ;
[ :Light >>label
  # < :me > /action
  # < :me > /pred
] <dict> const: lamp/light

: <lamp> [
    :Lamp >>name
    < >    >>tags
    4      >>brightness
    :unlit >>state
    1      >>level
    < lamp/light lamp/douse > >>actions
] <dict> ;
    
