
: moss/heal/enable? ( bag -- ? ) :moss has-tag? ; < :bag > # inject
: moss/heal { player bag -- }
    *bag :moss find-tagged bag-remove 
    *player [ 3 6 dLH + ] HP%
    "The moss reforms some of your broken skin" log
; < :player :bag > # inject # pred "Healing Moss" # label

: <mosswitch> 
    [ 
        "You vibe with mosses, slimes and lichens" it >description
        < :moss/heal > it >spells
    ] <dict>
; 

: coin/missile/enable? ( player -- ? ) .currency 10 gt? ; < :player > # inject
: coin/missile { target player -- }  
    *player [ 10 - ] currency%
    *target 4 8 dLH - hurt
    "The coin reforms into a dart, and flies with dread force" log
; < :target :player > # inject # pred # "Coin Missile" label 

: <aurumage> 
    [ 
       "You gain power from copper, silver and gold, and find spells in gems" it >description
       < :coin/missile > it >spells
    ] <dict>
;

: tele/fetch/enable? { player bag -- ? } 
    *player .mana 4 gt? 1 *bag has-room? and ; < :player :bag > # inject
: tele/fetch { player target bag -- } to-bag *target level-remove *player [ 4 - ] mana%
; < :player :target :bag > # inject  # pred 

: <telemancer> [ 
    "Your natural mana allows you to move things from a distance with your mind" it >description
    < :tele/fetch > it >spells
] <dict> ;
