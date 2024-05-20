: $ ( -- ) self .scene .get_node(*) ;

:: vm-bind { from sig to-call -- binding }
    VM *to-call VmCallBinding.new(**) =bind
     *sig *bind :trigger *from .connect(***)
     *bind
;

: ready? ( -- ) 
    :weapon it .has(*)
    :tool it .has(*) and
    :magic it .has(*) and 
; 
: check-state ( -- ) it print ready? not :Stuff/ExitButtons/Confirm $ >disabled ;

: pick-weapon ( btn -- ) .Value u@ >weapon check-state ;
: pick-tool ( btn -- ) .Value u@ >tool check-state ;
: pick-magic ( btn -- ) .Value u@ >magic check-state ;

: u@cleanup ( bind -- ) u@ .cleanup .append(*)! ;
:: pick-loadout { cancel-to -- form }
    "res://LoadoutPicker.tscn" switch-scene
    ( :Stuff/Weapons/BtnDagger self .scene .get_node(*} .group print )
    dict u<
    <> u@ >cleanup

    :Stuff/Weapons/BtnDagger $ .group :pressed :pick-weapon vm-bind u@cleanup
    :Stuff/Tools/BtnPot $ .group :pressed :pick-tool vm-bind u@cleanup
    :Stuff/Magic/BtnMosswitch $ .group :pressed :pick-magic vm-bind u@cleanup
    :Stuff/ExitButtons/Confirm $ .group ~pressed "back" eq? [ *cancel-to < > become ] if
    u@ .cleanup.clear() ( drop the bind references now that we're done with them )
    u>
;
