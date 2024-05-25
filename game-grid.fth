:: times/square { t block } *t [ *t [ *block do-block ] times ] times ;
:: each/square { arr block } *arr [ *arr [ *block do-block ] each ] each ;

< -1 0 1 > const: around
< around [ Vector2(**) ] each/square > const: cells-around

:: around-pt { pt block -- around } cells-around [ *pt + *block do-block ] each ;

: grid/set ( val cel grid -- ) dup .set_cell exec ;
: grid/get ( cel grid -- val ) dup .get_cell exec ;
: grid/has? ( cel grid -- val ) dup .has_cell exec ;

: /grid-proto ( name  -- ) dup :/has str(**) >>has_cell dup :/get str(**) >>get_cell :/set str(**) >>set_cell ;  

: tile-grid/set ( val cel grid -- ) u< swap u> .tiles .set_cellv(**)! ;
: tile-grid/get ( cel grid -- ) .tiles .get_cellv(*) ;
: tile-grid/has ( cel grid -- ) .tiles .get_cellv(*) @TileMap.INVALID_CELL neq? ;
: <tile-grid> ( init -- grid ) dict [
    TileMap.new() >>tiles :tile-grid /grid-proto
] with u< do-block u> ;

:: astar2d/add { point astar -- id }
    *astar .get_available_point_id() =id
    *id *point *astar .add_point(**)! *id
;

: /cell-keys ( -- keys ) it .cells .keys() ;
: /has? ( coord -- t/f ) it .cells .has(*) ;
: /id ( coord -- id ) it .cells get ;
: /connect-pts ( id1 id2 -- ) it .pathing .connect_points(**)! ;
:: nav-grid/connect-all ( grid -- ) [
    /cell-keys [ =coord *coord [ dup /has? [ /id *coord /id /connect-pts ] if ] around-pt ] each
] with! ;

:: nav-grid/set { val cel grid -- }  
    *cel *grid .cells .has(*) not [ 
        *cel *grid .pathing astar2d/add dup =id *cel *grid .cells put
    ] if
    *id *val not *grid .pathing .set_point_disabled(**)! ;
:: nav-grid/get ( cel grid -- enabled? ) .cells get ;
:: nav-grid/has ( cel grid -- has-cel? ) .cells .has(*) ;
: <nav-grid> ( init -- grid ) dict [ 
    dict  >>cells
    AStar2D.new() >>pathing
    :nav-grid /grid-proto
] with u< do-block u> ;

: /has? ( coord -- t/f ) dup it .cells .has(*) [ drop true ] [ "Cannot path to point: " swap str(**) err! false ] if-else ;
: /id ( coord -- id ) it .cells get ;
: /cells ( -- cells ) it .cells ;
: /path ( pt1 pt2 -- path ) /cells .get_point_path(**) ;
:: nav-grid/path { from to grid -- pts } *grid [
        *from /has? *to /has? and [ *from /id *to /id /path ] [ <> PoolVector2Array() ] if-else
    ] with!
;


: iota 1+ dup ;
: under-dup 

:: <>put { val key dict -- }
    *key *dict .has(*) not [ <> *dict *key put ] if
    *val *dict *key get .append(*)! ;

: /clear ( id -- id ) dup false swap it .blocked put ;
: /blocked ( id -- id ) dup false swap it .blocked put ;
: /spawn-tag ( id tag -- id ) dup-under swap it .spawn-tiles <>put put ;

dict [ dict >>blocked dict >>spawn_tiles ] with 
0 dup const: TILE_DIRT /clear
iota const: TILE_STONE  /clear
iota const: TILE_MOSS  /clear :moss /spawn-tag
iota const: TILE_PILLAR /blocked
     const: TILE_WATER  /clear :floor-water /spawn-tag
const: TILE_META

< 
TILE_DIRT TILE_DIRT TILE_DIRT TILE_STONE TILE_MOSS TILE_PILLAR TILE_WATER
> const: TILES

: d<tile> TILES d<> ;

: passble? TILE_PILLAR eq? ;
: /spawns? TILE_META .spawn_tiles .has(*) ;
: /tiles it .tiles ;
: /nav it .nav ;
: /init-floor-grids 
   10 range(*) [ =x
    10 range(*) [ =y 
        *x *y Vector2(**) =pos 
        d<tile> =t-id
        *t-id passable? *pos /nav grid/set
        *t-id *pos /tiles grid/set
        *t-id /spawns? [ *ti-id /spawn /mobs *pos put ] if
         
    ] each
   ] each ;

: <floor> ( -- )
    dict [
       [ ] <nav-grid> >>nav
       [ ] <tile-grid> >>tiles
       dict >>mobs
       /init-floor-grids
    ] with 
;  


