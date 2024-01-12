#category = misterhouse
#
#
#   make a file the same name as the code with declares at the end
# the generic item declarations
#   put in here so i can disable code and detect error
#   ie memory leak / and the module that delays it
# pt them i a section for each code



#copy and paste this part intot he code to remind me that all the declares are in one place

#######################################################################
#                                                                     #
#               Note          april 2022                              #
#      All declarations that are not local ie generics are now put in #
#                  the its own module.pl module                       #
#            this is so modules can be disabled for testing           #
#                                                                     #
#######################################################################




my $gsmstates ="ok,fault";
$GSM_phoneStatus = new Generic_Item;
set_states $GSM_phoneStatus split ',', $gsmstates;
$GSM_phoneStatus-> tie_event('&GSM_phoneStatus_change("$state")');

$GSM_phoneStatus_LastTest = new Generic_Item;
set $GSM_phoneStatus_LastTest time if state $GSM_phoneStatus_LastTest eq "";

my $Main_220V_power_status_states="on,off,ON_U,OFF_U";
$Main_220V_power_status = new Generic_Item;
set_states $Main_220V_power_status split ',',$Main_220V_power_status_states;
$Main_220V_power_status-> tie_event('&Notify_Node0_220V("$state")');

#Notify_Node0_220V
$Main_220V_power_status_LastTest = new Generic_Item;
set $Main_220V_power_status_LastTest time if state $Main_220V_power_status_LastTest eq "";



