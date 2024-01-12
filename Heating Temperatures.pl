# category = HVAC
#
#
#
#  Aug 2014
#
#@This is everything to do with temperatures
#
#@  all the temp variable declares are here, 
#@  i have left the commented out versions in the .pl code where they
#@  originally where for clarity
#
#@ this code also does the datalogging to RRDtool for the graphs
#
# update 2018 , a new Rpi3 @ 192.168.1.25is communicating with the radiator valves ## didnt work junked 2019
#see the mihome_comms.pl
# 
#
my $eTRV_temps = '12,14,16,18,20,22,24,26,28';
$CodeTimings::CodeTimings{'Heatin_Temperatures Start'} = time();

$T_avg_House = new Generic_Item;   # calced in heating.pl
$T_avg_House_last = new Generic_Item;



set_label $T_avg_House 'Average House';
set_info $T_avg_House 'Average House';


$T_setpoint_House = new Generic_Item; 
set $T_setpoint_House  '20.0' if $T_setpoint_House eq "";
$V_setpoint_House_temp = new  Voice_Cmd "set House thermostat to [$eTRV_temps] deg C";
$V_setpoint_House_temp -> tie_event('set $T_setpoint_House $state');

$T_setpoint_Annex = new Generic_Item;
set $T_setpoint_Annex '20.5' if state $T_setpoint_Annex eq "";
$V_setpoint_Annex_temp = new  Voice_Cmd "set Annex thermostat to [$eTRV_temps] deg C";
$V_setpoint_Annex_temp -> tie_event('set $T_setpoint_Annex $state');






$T_setpoint_OilBoiler = new Generic_Item;
 set  $T_setpoint_OilBoiler '55' if state $T_setpoint_OilBoiler eq "";




$T_setpoint_houseDHW = new Generic_Item;
set $T_setpoint_houseDHW '50' if state $T_setpoint_houseDHW eq "";  # this is the basic, it is updqated from mh.private .ini


# puts the heating on if the temp gets below this value, stops house freezing.
$T_setpoint_House_Minimum = new Generic_Item;
set $T_setpoint_House_Minimum '10'; 



# populated by Barionet ctrl in Node 2 in annex boiler room


$T_AnnexRoom_GEN = new Generic_Item;				#T7 sensor
$T_GSHP_OWT_GEN = new Generic_Item;				#T5 sensor
$T_OilBoiler_OWT_GEN = new Generic_Item;			#T6 sensor
$T_HeatStore_Upper_GEN = new Generic_Item;			#T8 sensor
$T_HeatStore_Lower_GEN = new Generic_Item;			#T9 sensor
$T_House_cold_return_GEN = new Generic_Item;		        #T4 sensor

$T_GSHP_to_GroundLoop_GEN = new Generic_Item;			#T3 sensor
$T_GroundLoop_Return_Circuit_One_GEN = new Generic_Item;	#T1 sensor
$T_GroundLoop_Return_Circuit_Two_GEN = new Generic_Item;	#T2 sensor
$T_ANNEX_uFloor_Return = new Generic_Item;                      #T10
# these are to store the last read temp,
# then the web page can show if it is rising or falling from the last reading
$T_AnnexRoom_GEN_last = new Generic_Item;				#T7 sensor
$T_GSHP_OWT_GEN_last = new Generic_Item;				#T5 sensor
$T_OilBoiler_OWT_GEN_last = new Generic_Item;			#T6 sensor
$T_HeatStore_Upper_GEN_last = new Generic_Item;			#T8 sensor
$T_HeatStore_Lower_GEN_last = new Generic_Item;			#T9 sensor
$T_House_cold_return_GEN_last = new Generic_Item;		        #T4 sensor

$T_GSHP_to_GroundLoop_GEN_last = new Generic_Item;			#T3 sensor
$T_GroundLoop_Return_Circuit_One_GEN_last = new Generic_Item;	#T1 sensor
$T_GroundLoop_Return_Circuit_Two_GEN_last = new Generic_Item;	#T2 sensor
$T_ANNEX_uFloor_Return_last = new Generic_Item;                      #T10













#these two are not really needed, as they should be the same as the heatstore lower sensor
#
$T_GSHP_IWT_GEN = new Generic_Item;			 	#T? sensor

$T_OilBoiler_IWT_GEN = new Generic_Item;			#T? sensor

$T_oil_boilerSetpoint = new Generic_Item;                       # the temp for the buffer tank which the oil boiler comes on

# populated by barionet in node1 in the tack room
#
$T_entryGEN = new Generic_Item;
$T_entryGEN_last = new Generic_Item;

# populated by Homevison reads

 $T_LivingR = new Generic_Item;
 $T_Study = new Generic_Item;
 $T_Kitchen = new Generic_Item;
 $T_Utility = new Generic_Item;
 $T_Bed1 = new Generic_Item;
 $T_Bed2  = new Generic_Item;
 $T_Bed3 = new Generic_Item;
 $T_EnSuite = new Generic_Item;
 $T_MainBath = new Generic_Item;
 $T_NU1 = new Generic_Item;
 $T_NU2 = new Generic_Item;
 $T_NU3 = new Generic_Item;
 $T_GASBoilerOWT = new Generic_Item;
=begin
   
   2018-> mihome eTRV some are on the rads some are in the airing cupboard on the manifold
    to start with aug 2018 all are on the manifold
	we will see how it works on the homevison sensors and the bath rooms first
	as I dont want the big clumsy valves in the bathrooms
	and if it works then i will do the same for the rads


   valve        address     name
   Dining           7363    1.DINING
   hallway          7283    2.HALLWAY
   bed downstairs   7314    3.BED-DOWNSTAIRS
   bed chloe        7321    4.BED-CHLOE
   bed master 1     7323    5.BED-MASTER1
   bed master 2     7149    6.BED-MASTER2
   bathroom         7224    7.WC-MAIN
   ensuite          7348    8.WC-ENSUITE

 the study has no control it runs a manual TRV so there is always load onthe system to flow

see 
 
=cut



#ambient temps
 $eTRV_AT_Dining = new Generic_Item;
 $eTRV_AT_Hallway = new Generic_Item;
 $eTRV_AT_Bed_Downstairs = new Generic_Item;
 $eTRV_AT_Bed_Chloe = new Generic_Item;
 $eTRV_AT_Bed_Master = new Generic_Item;
 $eTRV_AT_Bed_Master2 = new Generic_Item;
 $eTRV_AT_Study  = new Generic_Item;
 $eTRV_AT_WC_main = new Generic_Item;
 $eTRV_AT_WC_Ensuite = new Generic_Item;
 $eTRV_AT_WC_utility = new Generic_Item;
  $eTRV_AT_WC_Downstairs = new Generic_Item;
# battery voltage
 $eTRV_BV_Dining = new Generic_Item;
 $eTRV_BV_Hallway = new Generic_Item;
 $eTRV_BV_Bed_Downstairs = new Generic_Item;
 $eTRV_BV_Bed_Chloe = new Generic_Item;
 $eTRV_BV_Bed_Master = new Generic_Item;
 $eTRV_BV_Bed_Master2 = new Generic_Item;
 $eTRV_BV_Study  = new Generic_Item;
 $eTRV_BV_WC_main = new Generic_Item;
 $eTRV_BV_WC_Ensuite = new Generic_Item;
 $eTRV_BV_WC_utility = new Generic_Item;
 $eTRV_BV_WC_Downstairs = new Generic_Item;
# set temperature
# we send these every 10 mins or bootup/reload to MiHome to update the valve set point
# they are stored in MH.py in the Mhome pi and updated to the valves

 $eTRV_ST_Hallway = new Generic_Item;
 $eTRV_ST_Dining = new Generic_Item;
 $V_Dining_room_temp = new  Voice_Cmd "Dining room/ Hallway set to [$eTRV_temps] deg C";
 $V_Dining_room_temp -> tie_event('set $eTRV_ST_Hallway $state');
 $V_Dining_room_temp -> tie_event('set $eTRV_ST_Dining $state');
 $eTRV_ST_Dining -> tie_event('print_log "Dining room/Hallway  temp set to ".$state');
 #$eTRV_ST_Hallway -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "1.DINING:".$state');
 #$eTRV_ST_Dining -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "2.HALLWAY:".$state');


 $eTRV_ST_Bed_Downstairs = new Generic_Item;
 $V_Bed_Downstairs_temp = new  Voice_Cmd "Bedroom downstairs set to [$eTRV_temps] deg C";
 $V_Bed_Downstairs_temp -> tie_event('print_log "Bedroom Downstairs temp set to ".$state');
 $V_Bed_Downstairs_temp -> tie_event('set $eTRV_ST_Bed_Downstairs $state');
# $eTRV_ST_Bed_Downstairs -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "3.BED-DOWNSTAIRS:".$state');




 $eTRV_ST_Bed_Chloe = new Generic_Item;
 $V_Bed_Chloe_temp = new  Voice_Cmd "Chloe Bedroom set to [$eTRV_temps] deg C";
 $V_Bed_Chloe_temp -> tie_event('print_log "Chloe Bedroom temp set to ".$state');
 $V_Bed_Chloe_temp -> tie_event('set  $eTRV_ST_Bed_Chloe $state');
 #$eTRV_ST_Bed_Chloe -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "4.BED-CHLOE:".$state');





 $eTRV_ST_Bed_Master = new Generic_Item;
 $eTRV_ST_Bed_Master2 = new Generic_Item;
 $V_Bed_Master_room_temp = new  Voice_Cmd "Master bedroom set to [$eTRV_temps] deg C";
 $V_Bed_Master_room_temp -> tie_event('print_log "Master bedroom room temp set to ".$state');
 $V_Bed_Master_room_temp -> tie_event('set  $eTRV_ST_Bed_Master $state');
 $V_Bed_Master_room_temp -> tie_event('set  $eTRV_ST_Bed_Master2 $state');
 #$eTRV_ST_Bed_Master -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "5.BED-MASTER:".$state');
# $eTRV_ST_Bed_Master -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "6.BED-MASTER2:".$state');


 $eTRV_ST_Study  = new Generic_Item;

 
 $eTRV_ST_WC_main = new Generic_Item;
 $V_WC_main = new  Voice_Cmd "WC main set to [$eTRV_temps] deg C";
 $V_WC_main -> tie_event('print_log "Chloe Bedroom temp set to ".$state');
 $V_WC_main -> tie_event('set $eTRV_ST_WC_main $state');
 #$eTRV_ST_WC_main -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "7.WC-MAIN:".$state');


 $eTRV_ST_WC_Ensuite = new Generic_Item;
 $V_WC_Ensuite = new  Voice_Cmd "WC Ensuite set to [$eTRV_temps] deg C";
 $V_WC_Ensuite -> tie_event('print_log "Wc ensuite temp set to ".$state');
 $V_WC_Ensuite -> tie_event('set  $eTRV_ST_WC_Ensuite $state');
 #$eTRV_ST_WC_Ensuite -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "8.WC-ENSUITE:".$state');

 $eTRV_ST_WC_utility = new Generic_Item;
 $V_WC_utility = new  Voice_Cmd "Utility set to [$eTRV_temps] deg C";
 $V_WC_utility -> tie_event('print_log "Utility temp set to ".$state');
 $V_WC_utility -> tie_event('set $eTRV_ST_WC_utility $state');
 #$eTRV_ST_WC_utility -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "9.WC-UTILITY:".$state');


# valve position
 $eTRV_VP_Dining = new Generic_Item;
 $eTRV_VP_Hallway = new Generic_Item;
 $eTRV_VP_Bed_Downstairs = new Generic_Item;
 $eTRV_VP_Bed_Chloe = new Generic_Item;
 $eTRV_VP_Bed_Master = new Generic_Item;
 $eTRV_VP_Bed_Master2 = new Generic_Item;
 $eTRV_VP_Study  = new Generic_Item;
 $eTRV_VP_WC_main = new Generic_Item;
 $eTRV_VP_WC_Ensuite = new Generic_Item;
 $eTRV_VP_WC_utility = new Generic_Item;
# status flag
 $eTRV_DF_Dining = new Generic_Item;
 $eTRV_DF_Hallway = new Generic_Item;
 $eTRV_DF_Bed_Downstairs = new Generic_Item;
 $eTRV_DF_Bed_Chloe = new Generic_Item;
 $eTRV_DF_Bed_Master = new Generic_Item;
 $eTRV_DF_Bed_Master2 = new Generic_Item;
 $eTRV_DF_Study  = new Generic_Item;
 $eTRV_DF_WC_main = new Generic_Item;
 $eTRV_DF_WC_Ensuite = new Generic_Item;
 $eTRV_DF_WC_utility = new Generic_Item;

 # rest the flags , sometime picked up and wierd state and didnt clear often
 # set $eTRV_DF_Dining "none";
 #set  $eTRV_DF_Hallway "none";
 #set $eTRV_DF_Bed_Downstairs "none";
 #set $eTRV_DF_Bed_Chloe  "none";
 #set $eTRV_DF_Bed_Master "none";
 #set $eTRV_DF_Study   "none";
 #set  $eTRV_DF_WC_main  "none";
 #set  $eTRV_DF_WC_Ensuite  "none";
 #set  $eTRV_DF_WC_utility  "none";




 # last seeen timestamp
 $eTRV_LS_Dining = new Generic_Item;
 $eTRV_LS_Hallway = new Generic_Item;
 $eTRV_LS_Bed_Downstairs = new Generic_Item;
 $eTRV_LS_Bed_Chloe = new Generic_Item;
 $eTRV_LS_Bed_Master = new Generic_Item;
 $eTRV_LS_Bed_Master2 = new Generic_Item;
 $eTRV_LS_Study  = new Generic_Item;
 $eTRV_LS_WC_main = new Generic_Item;
 $eTRV_LS_WC_Ensuite = new Generic_Item;
 $eTRV_LS_WC_utility = new Generic_Item;


 # last seen time
 $eTRV_LST_Dining = new Generic_Item;
 $eTRV_LST_Hallway = new Generic_Item;
 $eTRV_LST_Bed_Downstairs = new Generic_Item;
 $eTRV_LST_Bed_Chloe = new Generic_Item;
 $eTRV_LST_Bed_Master = new Generic_Item;
 $eTRV_LST_Bed_Master2 = new Generic_Item;
 $eTRV_LST_Study  = new Generic_Item;
 $eTRV_LST_WC_main = new Generic_Item;
 $eTRV_LST_WC_Ensuite = new Generic_Item;
 $eTRV_LST_WC_utility = new Generic_Item;

# send the set temps to the eTRV every 20 mins, becasue the pi doesnt store them and will lose them,
# also ensures the eTRV are up to date in case they missed last update
=begin
if( $New_Minute and new_minute 10 ){

	set $Mihome_eTRV_rPi_UDPctrl "9.WC-UTILITY:".state  $eTRV_ST_WC_utility;
	set $Mihome_eTRV_rPi_UDPctrl "8.WC-ENSUITE:".state  $eTRV_ST_WC_Ensuite;
	set $Mihome_eTRV_rPi_UDPctrl "7.WC-MAIN:".state  $eTRV_ST_WC_main;
	set $Mihome_eTRV_rPi_UDPctrl "5.BED-MASTER:".state  $eTRV_ST_Bed_Master;
	set $Mihome_eTRV_rPi_UDPctrl "6.BED-MASTER2:".state  $eTRV_ST_Bed_Master2;
	set $Mihome_eTRV_rPi_UDPctrl "4.BED-CHLOE:".state $eTRV_ST_Bed_Chloe;
	set $Mihome_eTRV_rPi_UDPctrl "3.BED-DOWNSTAIRS:".state  $eTRV_ST_Bed_Downstairs;
	set $Mihome_eTRV_rPi_UDPctrl "1.DINING:".state  $eTRV_ST_Dining;
	set $Mihome_eTRV_rPi_UDPctrl "2.HALLWAY:".state  $eTRV_ST_Hallway;

}	
=cut
# work out the average temp of the currently working temps sensors in the house.
#------------------------------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------------------------------#
my $calc;
my $calc2;
  #ensuite , kitchen, bed3, living r , utility and study
if ($New_Minute and new_minute 2){
	my $avg_cnt = 0;
	$calc2=0;

	if (state $T_Study > 0 and state $T_Study < 35){
		$calc2 = state $T_Study;
		$avg_cnt=1
		}

	if (state $T_Kitchen > 0 and state $T_Kitchen < 35){
		$calc2 = $calc2 + state $T_Kitchen;
		$avg_cnt=$avg_cnt+1
		}

	if (state $T_Utility > 0 and state $T_Utility < 35){
		$calc2 = $calc2 + state $T_Utility;
		$avg_cnt=$avg_cnt+1
		}

	if (state $T_Bed3 > 0 and state $T_Bed3 < 35){
		$calc2 = $calc2 + state $T_Bed3;
		$avg_cnt=$avg_cnt+1
		}
	if (state $T_Bed2 > 0 and state $T_Bed2 < 35){
		$calc2 = $calc2 + state $T_Bed2;
		$avg_cnt=$avg_cnt+1
		}
	if (state $T_EnSuite > 0 and state $T_EnSuite < 35){
		$calc2 = $calc2 + state $T_EnSuite;
		$avg_cnt=$avg_cnt+1
		}

	

	if (state $T_EnSuite > 0 and state $T_EnSuite < 35){
		$calc2 = $calc2 + state $T_EnSuite;
		$avg_cnt=$avg_cnt+1
		}

	if ($avg_cnt != 0) {$calc = $calc2 / $avg_cnt};
    # for the web page to show rising or falling temp
    if(state $T_avg_House ne $calc or time_idle $T_avg_House '10 m'){set $T_avg_House_last $calc}
    
	set $T_avg_House $calc;

}#  end of House temp averaging

$Temperatures =new Group($T_GASBoilerOWT,$T_MainBath,$T_EnSuite,$T_Bed3,$T_Bed2,$T_Bed1,$T_Utility,$T_Kitchen,$T_Study,$T_LivingR,$T_entryGEN,$T_OilBoiler_IWT_GEN,$T_GroundLoop_Return_Circuit_Two_GEN,$T_GroundLoop_Return_Circuit_One_GEN,$T_GSHP_to_GroundLoop_GEN,$T_AnnexRoom_GEN,$T_GSHP_OWT_GEN,$T_OilBoiler_OWT_GEN,$T_HeatStore_Upper_GEN,$T_HeatStore_Lower_GEN,$T_House_cold_return_GEN,$T_avg_House,$T_setpoint_House,$T_setpoint_OilBoiler,$T_setpoint_Annex,$T_setpoint_houseDHW,$T_setpoint_House_Minimum);






$CodeTimings::CodeTimings{'Heatin_Temperatures End'} = time();

















