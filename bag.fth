
: //bag ( -- bag ) //game .player.bag ;

: /has-tag? ( tag -- ? ) it swap .tags .has(*) ;
: bag/has-tag? ( tag bag -- ? ) swap [ .items [ /has-tag? ] any? ] with! ;
: bag/find-tagged ( tag bag -- item ) swap [ .items [ /has-tag? ] find ] with! ;
: bag/remove ( item bag -- ) .items .erase(*) ;
: bag/add { item bag -- } 1 *bag has-room? [ *bag .items .append(*) ] [ drop ] if-else ;

: <bag> ( slots -- bag )
        dict [ >>slots < > >>items 
        :bag/add >>add
        :bag/remove >>remove
        :bag/has-tag? >>has_tag
        :bag/find-tagged >>find_tagged
    ] with ; 
