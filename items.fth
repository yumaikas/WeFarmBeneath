
:: base-hit { t w -- hit? } *t .armor *w .to_hit d<LH> gt? ;
:: calc-hit { t w -- hit } 
    [ 
        *w .to_crit splat { crit-at crit-range }
        *crit-at *crit-range dX le? it >did_crit
        it .did_crit [ true it >did_hit ] [ *t *w base-hit it >did_hit ] if-else 
    ] <dict>
;

: <weakness-table> [ 
    1 u@ >stab
    1 u@ >slice
    1 u@ >fallback
] <dict> ;

: <armor-table> [
    0 u@ >stab
    0 u@ >slice
    0 u@ >fallback
] <dict> ;


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

: attack { target game -- }
    *game .player.equips.mainhand =w
    *target *w calc-hit =h
    *h .did_crit 2 1 ? =crit
    *h .did_hit [ 
        *target [ *target *w *crit damage-of - ] HP%
    ] [ 
        ( todo: reactions? )
    ] if-else
;

( Weapons )
: <dagger> [
    :Dagger it >name
    < :weapon > u@ >tags
    1        u@ >reach
    < 2 20 > u@ >to_crit
    < 8 12 > u@ >to_hit
    1        u@ >damage
    :stab    u@ >damage_type
    2        u@ >sockets
    < :attack :throw > u@ >actions
] <dict> ;

: <axe> [
    :Axe it >name
    < :weapon > u@ >tags
    1      u@ >reach
    2      u@ >damage
    < 1 30 > u@ >to_crit
    < 10 12 >  u@ >to_hit
    :slash u@ >damage_type
    1      u@ >sockets
    < :attack :throw > u@ >actions
    ] <dict>
;

: <spear> [
    :Spear it >name
    < :weapon > it >tags
    2     it >reach
    1     it >damage
    < 1 20 > it >to_crit
    < 10 15 >   it >to_hit
    :stab it >damage_type
    0     it >sockets
    < :attack :throw > it >actions
    ] <dict>
;

( Tools )

: pot/boil/enable? ( bag -- ? ) :raw has-tag? ; < :bag > # inject
: pot/boil {  to-cook -- result cooked? } 
    *to-cook food? [ *to-cook cook true ] [ *to-cook false ]  if-else 
; < :bag/item > # inject # pred :Cook # label

: <pot> [
    :Pot it >name
    < > it >tags
    :pot it >type
    1 it >level
    < :pot/boil > it >actions 
] <dict> ;

: pickaxe-mine-desc ( -- ) < "The axe chips at the rock" "Flecks of stone bounce off" > d<> ;

: pickaxe/mine/interacts? ( item -- ) .tags :stone swap .has(*) ; < :target > # inject
: pickaxe/mine { me item bag coord -- }
    *item .HP *me .mining_power - *item >HP
    *item .HP 0 gt? [ 
        "The rock gives way, revealing the " *item .contents.name " inside" str(***) log
        *item .contents [ to-bag [ ] [ ] if-else ] each
    ] [
        pickaxe-mine-desc log
    ] if-else
; < :me :target :bag :coord > # inject # pred :Mine # label

: <pickaxe> [ 
    :Pickaxe it >name
    < > u@ >tags
    1         u@ >mining_power
    < :pickaxe/mine > u@ >actions
    < :stone :gem > u@ >interacts
] <dict> ;

: lamp/douse/enable? ( lamp -- ? ) .state :lit eq? ; < :me > # inject
: lamp/douse ( lamp -- ) :unlit swap >state ; < :me > # inject # pred :Douse # label

: lamp/light/enable? ( lamp -- ? ) .state :unlit eq? ; < :me > # inject 
: lamp/light ( lamp -- ) :lit swap >state ; < :me > # inject # pred :Light # label

: <lamp> [
    :Lamp it >name
    < >    u@ >tags
    4      u@ >brightness
    :unlit u@ >state
    1      u@ >level
    < :lamp/light :lamp/douse > u@ >actions
] <dict> ;
    
