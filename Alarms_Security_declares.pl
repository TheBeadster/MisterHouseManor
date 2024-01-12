#category = Security

#######################################################################
#                                                                     #
#               Note          april 2022                              #
#      All declarations that are not local ie generics are now put in #
#                  the its own module.pl module                       #
#            this is so modules can be disabled for testing           #
#                                                                     #
#######################################################################



# Generic items declarations
# first notification methods
#

$Notify_method_Internal = new Generic_Item;
set_states $Notify_method_Internal split ',',$System_States;
set_info $Notify_method_Internal 'Notify all in house through the speakers';
set $Notify_method_Internal 'yes';

$Notify_Method_SMS = new Generic_Item;
set_states $Notify_Method_SMS split ',',$System_States;
set_info $Notify_Method_SMS 'notify of Alarms by SMS to the people in the Burglar list or Smoke list';
#set $Notify_Method_SMS 'no';





# This is the system STATUS
#  this says ok or fault, on when things where last tested, uG pressures, tampers, or other system faults.

$Alarm_System_Status= new Generic_Item;
set_states $Alarm_System_Status split ',',$System_States2;
$Alarm_System_Status-> tie_event('&Alarm_System_Status_change("$state")');
set_info $Alarm_System_Status 'Current state of the Alarm system';


#   note system needs a notify item ######################
#   #######################
#   #######################
#   ####################

$LastTestingBurglar=new Generic_Item;
set_states $LastTestingBurglar split ',',$System_States2;

$Alarm_System_Alarms= new Generic_Item;
set_states $Alarm_System_Alarms split ',',$System_States2;


#Alarm  Groups declared second 

$Alarm_Group_Field = new Generic_Item;
set_states $Alarm_Group_Field split ',',$Alarm_Control_States;
$Alarm_Group_Field-> tie_event('&Alarm_Group_Field_change("$state")');

$Alarm_Group_House = new Generic_Item;
set_states $Alarm_Group_House split ',',$Alarm_Control_States;
$Alarm_Group_House-> tie_event('&Alarm_Group_House_change("$state")');

$Alarm_Group_Annex = new Generic_Item;
set_states $Alarm_Group_Annex split ',',$Alarm_Control_States2;
$Alarm_Group_Annex-> tie_event('&Alarm_Group_Annex_change("$state")');

$Alarm_Group_Stables = new Generic_Item;
set_states $Alarm_Group_Stables split ',',$Alarm_Control_States2;
$Alarm_Group_Stables-> tie_event('&Alarm_Group_Stables_change("$state")');

$Alarm_Group_ToolShed = new Generic_Item;
set_states $Alarm_Group_ToolShed split ',',$Alarm_Control_States2;
$Alarm_Group_ToolShed-> tie_event('&Alarm_Group_ToolShed_change("$state")');


# now the actual sensors are given generic items and each one has a lasted tested generic item as well
#
# Underground alarm 



#             NOTE NOTE
#             use the GPs software attached to white box at node1 to force the relays to change to test the system 



#  tamper handled is indicated by the three channels presure,pre-alarm ch1 and ch2
#  if these are all set then the tamper flag is set as well.
$Alarm_Underground_sys1_Tamper = new Generic_Item;
set_states $Alarm_Underground_sys1_Tamper split ',',$System_States;
$Alarm_Underground_sys1_Tamper-> tie_event('&Notify_Underground_sys1_Tamper("$state")');
$Alarm_Underground_sys1_Tamper_LastTest = new Generic_Item;
set $Alarm_Underground_sys1_Tamper_LastTest time if state $Alarm_Underground_sys1_Tamper_LastTest eq '';
set_info $Alarm_Underground_sys1_Tamper "Tamper circuit on white box at Node 1, to test open the box by the key";


$Alarm_Underground_sys1_Fault = new Generic_Item;
set_states $Alarm_Underground_sys1_Fault split ',',$System_States2;
$Alarm_Underground_sys1_Fault-> tie_event('&Notify_Underground_sys1_Fault("$state")');
$Alarm_Underground_sys1_Fault_LastTest = new Generic_Item;
set $Alarm_Underground_sys1_Fault_LastTest time if state $Alarm_Underground_sys1_Fault_LastTest eq '';
set_info $Alarm_Underground_sys1_Fault "Raised if the underground alarm control developes a fault, test by removing wh/green from the bottom of long green connector in box";


$Alarm_Underground_Ch1_Alarm = new Generic_Item;
set_states $Alarm_Underground_Ch1_Alarm split ',',$System_States4;
$Alarm_Underground_Ch1_Alarm-> tie_event('&Notify_Alarm_Underground_Ch1_Alarm("$state")');
$Alarm_Underground_Ch1_Alarm_LastTest = new Generic_Item;
set $Alarm_Underground_Ch1_Alarm_LastTest time if state $Alarm_Underground_Ch1_Alarm_LastTest eq '';



$Alarm_Underground_Ch1_PreAlarm = new Generic_Item;
set_states $Alarm_Underground_Ch1_PreAlarm split ',',$System_States;
$Alarm_Underground_Ch1_PreAlarm-> tie_event('&Notify_Alarm_Underground_Ch1_PreAlarm("$state")');
$Alarm_Underground_Ch1_PreAlarm_LastTest = new Generic_Item;
set $Alarm_Underground_Ch1_PreAlarm_LastTest time if state $Alarm_Underground_Ch1_PreAlarm_LastTest eq '';





$Alarm_Underground_Ch1_Pressure = new Generic_Item;
set_states $Alarm_Underground_Ch1_Pressure split ',',$System_States2;
$Alarm_Underground_Ch1_Pressure-> tie_event('&Notify_Underground_Ch1_Pressure("$state")');
$Alarm_Underground_Ch1_Pressure_LastTest = new Generic_Item;
set $Alarm_Underground_Ch1_Pressure_LastTest time if state $Alarm_Underground_Ch1_Pressure_LastTest eq '';



$Alarm_Underground_Ch2_Alarm = new Generic_Item;
set_states $Alarm_Underground_Ch2_Alarm split ',',$System_States4;
$Alarm_Underground_Ch2_Alarm-> tie_event('&Notify_Alarm_Underground_Ch2_Alarm("$state")');
$Alarm_Underground_Ch2_Alarm_LastTest = new Generic_Item;

set $Alarm_Underground_Ch2_Alarm_LastTest time if state $Alarm_Underground_Ch2_Alarm_LastTest eq '';



$Alarm_Underground_Ch2_PreAlarm = new Generic_Item;
set_states $Alarm_Underground_Ch2_PreAlarm split ',',$System_States;
$Alarm_Underground_Ch2_PreAlarm-> tie_event('&Notify_Alarm_Underground_Ch2_PreAlarm("$state")');
$Alarm_Underground_Ch2_PreAlarm_LastTest = new Generic_Item;

set $Alarm_Underground_Ch2_PreAlarm_LastTest time if state $Alarm_Underground_Ch2_PreAlarm_LastTest eq '';




$Alarm_Underground_Ch2_Pressure = new Generic_Item;
set_states $Alarm_Underground_Ch2_Pressure split ',',$System_States2;
# pressure handled on one input for Ch1 and 2
#$Alarm_Underground_Ch2_Pressure-> tie_event('&Notify_Underground_Ch2_Pressure("$state")');
#last test not meeded as on same channel as ch1 pressure

#	Radar in 1 acre looking at paddock
#
#

$Alarm_Radar_paddock_Alarm = new Generic_Item;
set_states $Alarm_Radar_paddock_Alarm split ',',$System_States4;
$Alarm_Radar_paddock_Alarm-> tie_event('&Notify_Alarm_Radar_paddock_Alarm("$state")');
$Alarm_Radar_paddock_Alarm_LastTest = new Generic_Item;

set $Alarm_Radar_paddock_Alarm_LastTest time if state $Alarm_Radar_paddock_Alarm_LastTest eq '';



$Alarm_Radar_paddock_Tamper = new Generic_Item;
set_states $Alarm_Radar_paddock_Tamper split ',',$System_States;
$Alarm_Radar_paddock_Tamper-> tie_event('&Notify_Radar_paddock_Tamper("$state")');
$Alarm_Radar_paddock_Tamper_LastTest = new Generic_Item;

set $Alarm_Radar_paddock_Tamper_LastTest time if state $Alarm_Radar_paddock_Tamper_LastTest eq '';

$Alarm_Radar_MainGate_Alarm = new Generic_Item;
set_states $Alarm_Radar_MainGate_Alarm split ',',$System_States4;
$Alarm_Radar_MainGate_Alarm-> tie_event('&Notify_Alarm_Radar_MainGate_Alarm("$state")');
$Alarm_Radar_MainGate_Alarm_LastTest = new Generic_Item;

set $Alarm_Radar_MainGate_Alarm_LastTest time if state $Alarm_Radar_MainGate_Alarm_LastTest eq '';


#	tool shed

$Alarm_ToolShed_Alarm = new Generic_Item;
set_states $Alarm_ToolShed_Alarm  split ',',$System_States4;
$Alarm_ToolShed_Alarm-> tie_event('&Notify_Alarm_ToolShed_Alarm("$state")');
$Alarm_ToolShed_Alarm_LastTest = new Generic_Item;

set $Alarm_ToolShed_Alarm_LastTest time if state $Alarm_ToolShed_Alarm_LastTest eq '';


$Alarm_ToolShed_Tamper = new Generic_Item;
set_states $Alarm_ToolShed_Tamper split ',',$System_States;
$Alarm_ToolShed_Tamper-> tie_event('&Notify_ToolShed_Tamper("$state")');
$Alarm_ToolShed_Tamper_LastTest = new Generic_Item;

set $Alarm_ToolShed_Tamper_LastTest time if state $Alarm_ToolShed_Tamper_LastTest eq '';




#      Stables

$Alarm_Stables_Alarm = new Generic_Item;
set_states $Alarm_Stables_Alarm  split ',',$System_States4;
$Alarm_Stables_Alarm-> tie_event('&Notify_Alarm_Stables_Alarm("$state")');
$Alarm_Stables_Alarm_LastTest = new Generic_Item;

set $Alarm_Stables_Alarm_LastTest time if state $Alarm_Stables_Alarm_LastTest eq '';


$Alarm_Stables_Tamper = new Generic_Item;
set_states $Alarm_Stables_Tamper split ',',$System_States;
$Alarm_Stables_Tamper-> tie_event('&Notify_Stables_Tamper("$state")');
$Alarm_Stables_Tamper_LastTest = new Generic_Item;

set $Alarm_Stables_Tamper_LastTest time if state $Alarm_Stables_Tamper_LastTest eq '';



$Alarm_TR_Shed_Alarm = new Generic_Item;
set_states $Alarm_TR_Shed_Alarm split ',',$System_States4;
$Alarm_TR_Shed_Alarm-> tie_event('&Notify_Alarm_TR_Shed_Alarm("$state")');
$Alarm_TR_Shed_Alarm_LastTest = new Generic_Item;

set $Alarm_TR_Shed_Alarm_LastTest time if state $Alarm_TR_Shed_Alarm_LastTest eq '';







#	House
#
#	all need tieing to notify and a last test adding  feb 2010

$Alarm_KitchenPIR_Alarm = new Generic_Item;
set_states $Alarm_KitchenPIR_Alarm split ',',$System_States;
$Alarm_KitchenPIR_Alarm-> tie_event('&Notify_Alarm_KitchenPIR_Alarm("$state")');
$Alarm_KitchenPIR_Alarm_LastTest = new Generic_Item;
set $Alarm_KitchenPIR_Alarm_LastTest time if state $Alarm_KitchenPIR_Alarm_LastTest eq '';



$Alarm_LroomPIR_Alarm = new Generic_Item;
set_states $Alarm_LroomPIR_Alarm split ',',$System_States;
$Alarm_LroomPIR_Alarm-> tie_event('&Notify_Alarm_LroomPIR_Alarm("$state")');
$Alarm_LroomPIR_Alarm_LastTest = new Generic_Item;
set $Alarm_LroomPIR_Alarm_LastTest time if state $Alarm_LroomPIR_Alarm_LastTest eq '';




$Alarm_BackDoor_Alarm = new Generic_Item;
set_states $Alarm_BackDoor_Alarm split ',',$System_States4;
$Alarm_BackDoor_Alarm-> tie_event('&Notify_Alarm_BackDoor_Alarm("$state")');
$Alarm_BackDoor_Alarm_LastTest = new Generic_Item;
set $Alarm_BackDoor_Alarm_LastTest time if state $Alarm_BackDoor_Alarm_LastTest eq '';




$Alarm_FrontDoor_Alarm = new Generic_Item;
set_states $Alarm_FrontDoor_Alarm split ',',$System_States4;
$Alarm_FrontDoor_Alarm-> tie_event('&Notify_Alarm_FrontDoor_Alarm("$state")');
$Alarm_FrontDoor_Alarm_LastTest = new Generic_Item;
set $Alarm_FrontDoor_Alarm_LastTest time if state $Alarm_FrontDoor_Alarm_LastTest eq '';



$Alarm_StudyPIR_Alarm = new Generic_Item;
set_states $Alarm_StudyPIR_Alarm split ',',$System_States4;
$Alarm_StudyPIR_Alarm-> tie_event('&Notify_Alarm_StudyPIR_Alarm("$state")');
$Alarm_StudyPIR_Alarm_LastTest = new Generic_Item;
set $Alarm_StudyPIR_Alarm_LastTest time if state $Alarm_StudyPIR_Alarm_LastTest eq '';




$Alarm_KitchenPIR_Alarm = new Generic_Item;
set_states $Alarm_KitchenPIR_Alarm split ',',$System_States4;
$Alarm_KitchenPIR_Alarm-> tie_event('&Notify_Alarm_KitchenPIR_Alarm("$state")');
$Alarm_KitchenPIR_Alarm_LastTest = new Generic_Item;
set $Alarm_KitchenPIR_Alarm_LastTest time if state $Alarm_KitchenPIR_Alarm_LastTest eq '';






$Alarm_Bed1PIR_Alarm = new Generic_Item;
set_states $Alarm_Bed1PIR_Alarm split ',',$System_States4;
$Alarm_Bed1PIR_Alarm-> tie_event('&Notify_Alarm_Bed1PIR_Alarm("$state")');
$Alarm_Bed1PIR_Alarm_LastTest = new Generic_Item;
set $Alarm_Bed1PIR_Alarm_LastTest time if state $Alarm_Bed1PIR_Alarm_LastTest eq '';






$Alarm_Bed2PIR_Alarm = new Generic_Item;
set_states $Alarm_Bed2PIR_Alarm split ',',$System_States4;
$Alarm_Bed2PIR_Alarm-> tie_event('&Notify_Alarm_Bed2PIR_Alarm("$state")');
$Alarm_Bed2PIR_Alarm_LastTest = new Generic_Item;
set $Alarm_Bed2PIR_Alarm_LastTest time if state $Alarm_Bed2PIR_Alarm_LastTest eq '';




#     ANNEX

$Alarm_Annex_Flat_Alarm = new Generic_Item;
set_states $Alarm_Annex_Flat_Alarm split ',',$System_States4;
$Alarm_Annex_Flat_Alarm-> tie_event('&Notify_Alarm_Annex_Flat_Alarm("$state")');
$Alarm_Annex_Flat_Alarm_LastTest = new Generic_Item;
set $Alarm_Annex_Flat_Alarm_LastTest time if state $Alarm_Annex_Flat_Alarm_LastTest eq '';



$Alarm_Annex_Workshop_Alarm = new Generic_Item;
set_states $Alarm_Annex_Workshop_Alarm split ',',$System_States4;
$Alarm_Annex_Workshop_Alarm-> tie_event('&Notify_Alarm_Annex_Workshop_Alarm("$state")');
$Alarm_Annex_Workshop_Alarm_LastTest = new Generic_Item;
set $Alarm_Annex_Workshop_Alarm_LastTest time if state $Alarm_Annex_Workshop_Alarm_LastTest eq '';




$Alarm_Annex_Office_Alarm = new Generic_Item;
set_states $Alarm_Annex_Office_Alarm split ',',$System_States4;
$Alarm_Annex_Office_Alarm-> tie_event('&Notify_Alarm_Annex_Office_Alarm("$state")');
$Alarm_Annex_Office_Alarm_LastTest = new Generic_Item;
set $Alarm_Annex_Office_Alarm_LastTest time if state $Alarm_Annex_Office_Alarm_LastTest eq '';




$Alarm_Annex_Tamper_or_Fault = new Generic_Item;
set_states $Alarm_Annex_Tamper_or_Fault split ',',$System_States2;
$Alarm_Annex_Tamper_or_Fault-> tie_event('&Notify_Alarm_Annex_Tamper_or_Fault("$state")');
$Alarm_Annex_Tamper_or_Fault_LastTest = new Generic_Item;
set $Alarm_Annex_Tamper_or_Fault_LastTest time if state $Alarm_Annex_Tamper_or_Fault_LastTest eq '';



$Mains_220V_Workshop_Annex = new Generic_Item;
set_states $Mains_220V_Workshop_Annex split ',',$System_States3;
set_info $Mains_220V_Workshop_Annex 'Indicates if the mains 220V power is on in the Annex';
$Mains_220V_Workshop_Annex-> tie_event('&Notify_Mains_220V_Workshop_Annex("$state")');
$Mains_220V_Workshop_Annex_LastTest = new Generic_Item;
set $Mains_220V_Workshop_Annex_LastTest time if state $Mains_220V_Workshop_Annex_LastTest eq "";




$BarioNET2_Exists= new Generic_Item; # used to keep tabs that comms to barionet 2 is OK
set_states $BarioNET2_Exists split ',',$BarioNET_IN_states;
$BarioNET2_Exists_LastTest = new Generic_Item;
if (state $BarioNET2_Exists_LastTest eq''){set $BarioNET2_Exists_LastTest time}
set_info $Mains_220V_Workshop_Annex 'Indicates if the LAN comms to the BArionet controller is OK';
$Mains_220V_Workshop_Annex-> tie_event('&Notify_BarioNET2_Exists("$state")');




$Status_Gate_IR_beam = new Generic_Item;
set_states $Status_Gate_IR_beam $System_States4;
set_info $Status_Gate_IR_beam 'OK = nothing interupting the beam, Alarm = beam is broken by something';
$Status_Gate_IR_beam-> tie_event('&Notify_Gate_IRBeam_Alarm("$state")');
my $IR_Beam_state ;
$tmr_gate_IR_beam_bounce = new Timer;
$tmr_gate_IR_beam_long_break = new Timer;
my $gate_IR_beam_bounce_flag;


#Millys garage gate

# detects the switch at the top of the gate'

$Alarm_Milly_Gate_Alarm = new Generic_Item;
set_states $Alarm_Milly_Gate_Alarm split ',',$System_States4;
$Alarm_Milly_Gate_Alarm-> tie_event('&Notify_Alarm_Milly_Gate_Alarm("$state")');
$Alarm_Milly_Gate_Alarm_LastTest = new Generic_Item;
set $Alarm_Milly_Gate_Alarm_LastTest time if state $Alarm_Milly_Gate_Alarm_LastTest eq '';
$Wshop_gate_alarm_inhibit = new Generic_Item;
set_states $Wshop_gate_alarm_inhibit split ',',$Alarm_Control_States;


