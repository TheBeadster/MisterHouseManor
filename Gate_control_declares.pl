# category=Gate


#######################################################################
#                                                                     #
#               Note          april 2022                              #
#      All declarations that are not local ie generics are now put in #
#                  the its own module.pl module                       #
#            this is so modules can be disabled for testing           #
#                                                                     #
#######################################################################



$LastGateUse = new Generic_Item;
$GateOpenedCount = new Generic_Item;
$GateUseMaxEver =new Generic_Item;
$Gate_workshop_lock_Status = new Generic_Item;
$Gate_workshop_Red_LED = new Generic_Item;
$Gate_workshop_Green_LED = new Generic_Item;
$Authorize_next_keys = new Generic_Item;
$Gate_emergency_sw_status = new Generic_Item;
set_states $Gate_emergency_sw_status split ',',$em_rl;
set_info $Gate_emergency_sw_status 'Status of the relay that bypassses the gate emergency switch safe = switch on gate will work, bypassed means switch on gate has been disabled';


$Field_occupancy = new Generic_Item;