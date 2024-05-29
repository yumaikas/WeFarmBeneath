17 17 v2 const: position_mult
16 16 v2 const: cell_size

: #cell ( x y -- v ) v2 position_mult * ;
[
    25 1 #cell >>player

] <dict> const: kenny_map

"res://monochrome_transparent.png" load(*) const: atlas

: /has? it kenny_map .has(*) ;
: #region ( pos -- rect ) cell_size Rect2(**) ;
: /make-atlas-tex 
    it kenny_map get #region AtlasTexture.new() [ >>region atlas >>texture ] with ;
: /err "Name " it " is not mapped to the texture atlas" str(***) err! ;
: atlased ( name -- image ) [ /has? [ /make-atlas-tex ] [ /err suspend ] if-else ] with! ;
