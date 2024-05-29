
: <player-card> [ :player atlased >>image ] <card> ;
: <equips> [
    "" >>mainhand
    "" >>offhand
    "" >>torso
    "" >>trinket
] <with> ;

: player/move ( dir player --  ) [
    that it .card +move ~done
    [ that + ] pos%
] with-us! ;

: /hp-not-full? hp>> max_hp>> lt? ;
: /heal ( amt -- ) dup [ + ] hp% "+" swap "HP" str(***) pos>> decal ;
: player/tick ( player -- ) [ 
    /hp-not-full? 10 dX 1 eq? and [ 1 /heal ] if 
    status>> .empty() not [ 
        status>> [ it swap +tick ~done ] each 
        [ [ +is_alive ] filter ] status% 
    ] if 
] with! ;

: //player.init [ 
      0 >>currency
      20 >>hp 
      20 >>max_hp
      <> >>status

      <equips> >>equips 
      10 <bag> >>bag 
      3 3 Vector2(**) >>pos
      pos>> <player-card> [ >>pos ] with >>card

      :player/move >>move
      :player/tick >>tick

] <dict> //game >player ;
