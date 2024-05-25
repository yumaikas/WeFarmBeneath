: $ ( -- ) self .scene .get_node(*) ;

:: vm-bind { from sig to-call -- binding }
    VM *to-call VmCallBinding.new(**) =bind
     *sig *bind :trigger *from .connect(***)
     *bind
;

: /has? ( -- ) it .has(*) ;
: /ready? ( -- ) :weapon /has? :tool /has? and :magic /has? and ; 
: /check-state ( -- ) it print ready? not :Stuff/ExitButtons/Confirm $ >disabled ;
: /retain ( bind -- ) it .cleanup .append(*)! ;
: /drop-all ( -- ) it .cleanup .clear()! ;
: ->weapon ( btn -- ) .Value >>weapon check-state ;
: ->tool ( btn -- ) .Value >>tool check-state ;
: ->magic ( btn -- ) .Value >>magic check-state ;
:: pick-loadout { cancel-to -- form }
    "res://LoadoutPicker.tscn" switch-scene
    ( :Stuff/Weapons/BtnDagger self .scene .get_node(*} .group print )
    dict [ <> >>cleanup 
      :Stuff/Weapons/BtnDagger $ .group :pressed :->weapon vm-bind /retain
      :Stuff/Tools/BtnPot $ .group :pressed :->tool vm-bind /retain
      :Stuff/Magic/BtnMosswitch $ .group :pressed :->magic vm-bind /retain
      :Stuff/ExitButtons/Confirm $ .group ~pressed .Value "back" eq? [ *cancel-to < > become ] if
      /drop-all
    ] with
;
