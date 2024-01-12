# category=HomeVision


$CodeTimings::CodeTimings::CodeTimings{'HomeVisionInterface Start'} = time();

=begin


   ######################################################################
   #									                                #
   #		HOMEVISION SETUP 					                        #
   #									                                #
   #		         FEB 2010		BeaDy				                #
   #									                                #
   #@	        Implemented when the heat pump was working 		        #
   #@		to make the heating controlled by one place		            #
   #@		The Homevision is now a basic in/out controler		        #
   #@		with little code in it	used to control			            #
   #@		not just the heating but everything connected to it	        #
   #		                                                 	        #
   ######################################################################
   





	1 st all the ports , input and outputs are defined
 	all HV stuff is preceded by HV so we know it goes though the HV
	controller 

	 any lights are declared in lights.pl, so they appear in the category lights

	2nd outputs
	3rd X10 are listed but are declared in lights
	4th IR slots
	5th temp sensors
        6th video commands.
	


        inputs 	B1 /00	Kitchen PIR
	B2 /01	Livin PIR
	B3	Study PIR
	B4	Not Used
	B5	Smoke Kitchen
	B6	Bed 1 PIR
	B7	Bed 2 PIR
	B8	Not Used

	D1  /8	Not used goes to shed	brown
	D2	Shed PIR		green
	D3	Shed Door		grey
	D4	Shed 24h Tamper		blue
	D5      window kitchen single
	D6 	back door
	D7	Front Door bell
	D8 /15	Back door bell

	E1 /16	Keyfob RX2   green / purple common
	E2  	AMP power sensor
	E3  	Dining window
	E4	Study Window Left
	E5	Kitchen sink Window
	E6	Study Right
	E7	 ? wh/gr  patio door?
	E8	Dining window
	

	F1 /24	Loft PIR
	F2	Loft Smoke alarm
	F3	Not used
	F4 	Keyfob ctrl Rx1   yellow /purple common
     buttons on NODE1 door
	F5      Enter key
	F6	Del Key
	F7	Down Key	
	F8 /31	Up Key
=cut

#@  controls direct to Homevision box, things like getting the room temperatures
#@ and putting messages on the TV screen, 

# this is used to overide the PIR in the living room turning the TV off
# by pressing the 4th button on NODE 0 door.

$TV_off_overide = new Generic_Item;

 if ($Reload or $Startup or $Reread){ 
	     #  set $TV_off_overide 'off'
       }


if (time_now("11:30 PM")){
	#set $TV_off_overide 'off';
	set $Smoke_Group "active"
}





# below stop unhandled serial, if you want to use them then they will need to
#be enabled in homevison first
$HV_not_used_1 = new Serial_Item('INPUT18low','off','Homevision');
$HV_not_used_2 = new Serial_Item('INPUT22low','off','Homevision');
$HV_not_used_3 = new Serial_Item('INPUT23low','off','Homevision');
$HV_not_used_4 = new Serial_Item('INPUT18high','off','Homevision');
$HV_not_used_5 = new Serial_Item('INPUT22high','off','Homevision');
$HV_not_used_6 = new Serial_Item('INPUT23high','off','Homevision');


$HV_Kitchen_PIR = new Serial_Item('INPUT0low','off','Homevision');
$HV_Kitchen_PIR->add('INPUT0high','on');
$HV_Kitchen_PIR->tie_event('&subKitchenPIR');
my  $Kettletimer = new Timer;
my  $Kitmoodtimer = new Timer;
my  $SparklesTimer = new Timer;


sub subKitchenPIR{
if (state $HV_Kitchen_PIR eq'on'){
	 set $Alarm_KitchenPIR_Alarm 'alarm' if state $Alarm_KitchenPIR_Alarm ne 'alarm';
	 
	 




    if( time_between '5 am', '10 am'){
   
            &main::proxy_send( $proxy_by_room{'kitchen'},'speak','K1');
			

			set $Kettletimer 60, sub {
				&main::proxy_send( $proxy_by_room{'kitchen'},'speak','K0');
			}

       }
    if( $Dark){  #time_between '12:30am', "$Time_Sunrise_Twilight"){
   
            &main::proxy_send( $proxy_by_room{'kitchen'},'speak','LGL1');
			&main::proxy_send( $proxy_by_room{'kitchen'},'speak','UGL1');

			set $Kitmoodtimer 500, sub {
              &main::proxy_send( $proxy_by_room{'kitchen'},'speak','LGL0');
			  &main::proxy_send( $proxy_by_room{'kitchen'},'speak','UGL0');
			}

       }
     # always flash the fridge
	 

    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SU1');
    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SL1');
    

	set $SparklesTimer 300 , sub {

    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SU0');
    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SL0');
    


	}


	 &main::proxy_send( $proxy_by_room{'kitchen'},'speak','FF1');

 }else{
	 set $Alarm_KitchenPIR_Alarm 'ok' if state $Alarm_KitchenPIR_Alarm ne 'ok' 
}
}




$HV_LivingR_PIR = new Serial_Item('INPUT1low','off','Homevision');
$HV_LivingR_PIR->add('INPUT1high','on');
$HV_LivingR_PIR->tie_event('&subLivingRPIR');
sub subLivingRPIR{
if (state $HV_LivingR_PIR eq'on'){
	 set $Alarm_LroomPIR_Alarm 'alarm'
 }else{
	 set $Alarm_LroomPIR_Alarm 'ok'
}
}





$HV_Study_PIR = new Serial_Item('INPUT2low','on','Homevision');
$HV_Study_PIR->add('INPUT2high','off');
$HV_Study_PIR->tie_event('&subSTUDYPIR');
sub subSTUDYPIR{
if (state $HV_Study_PIR eq'on'){
	 set $Alarm_StudyPIR_Alarm 'ok'
 }else{
	 set $Alarm_StudyPIR_Alarm 'alarm'
}
}


#03 not used

$HV_SmokeKitchen = new Serial_Item('INPUT4low','on','Homevision');
$HV_SmokeKitchen->add('INPUT4high','off');
# tie this state to the alarm state used in Alarms_smoke.pl
$HV_SmokeKitchen  ->tie_event('&subkitchsmoke');

sub subkitchsmoke{
if (state $HV_SmokeKitchen eq'on'){
	 set $Smoke_Kitchen_Alarm 'alarm' if state $Smoke_Kitchen_Alarm ne 'ok'
 }else{
	 set $Smoke_Kitchen_Alarm 'ok' if state $Smoke_Kitchen_Alarm ne 'alarm'
 }
 }


$HV_Bed1_PIR = new Serial_Item('INPUT5low','on','Homevision');
$HV_Bed1_PIR->add('INPUT5high','off');
$HV_Bed1_PIR->tie_event('&subBED1PIR');
sub subBED1PIR{
if (state $HV_Bed1_PIR eq'on'){
	 set $Alarm_Bed1PIR_Alarm 'alarm'
 }else{
	 set $Alarm_Bed1PIR_Alarm 'ok'
}
}




$HV_Bed2_PIR = new Serial_Item('INPUT6low','on','Homevision');
$HV_Bed2_PIR->add('INPUT6high','off');
$HV_Bed2_PIR->tie_event('&subBED2PIR');
sub subBED2PIR
{
if (state $HV_Bed2_PIR eq 'off'){
	 set $Alarm_Bed2PIR_Alarm 'alarm'
 }else{
	 set $Alarm_Bed2PIR_Alarm 'ok'
}
}




# input 07 + 08 not used
#

$HV_GardenShed_PIR = new Serial_Item('INPUT9low','on','Homevision');
$HV_GardenShed_PIR->add('INPUT9high','off');

$HV_GardenShed_PIR  ->tie_event('&subShedPIR');
	

=begin

#moved to security alarm
sub subShedPIR{
	if ( state $HV_GardenShed_PIR eq 'on'and $Dark){
		if (inactive $tmrShedPIR){
			set $Shed_light1 'on';
			 set $Shed_lightOS1 'on'
		 	};
 		set $tmrShedPIR 60,sub{
			      set $Shed_lightOS1 'off';
                              set $Shed_light1 'off'
				}
			}
}

=cut


#$HV_GardenShed_PIR->tie_items($HV_DoorBeeper);
# garden shed done by Node 3 PIR

$HV_GardenShed_Door = new Serial_Item('INPUT10low','on','Homevision');
$HV_GardenShed_Door->add('INPUT10high','off');
# subsheddoor in security
$HV_GardenShed_Door  ->tie_event('&subShedDoor');



$HV_GardenShedTamper = new Serial_Item('INPUT11low','on','Homevision');
$HV_GardenShedTamper->add('INPUT11high','off');

# input 12 not used
#


$HV_BackDoor = new Serial_Item('INPUT13low','off','Homevision');
$HV_BackDoor->add('INPUT13high','on');
$HV_BackDoor->tie_event('&subBackDoorPIR');          

sub subBackDoorPIR {
	# the alarms security, deal with what happens when the back door is open/closed
	#
if (state $HV_BackDoor eq 'on'){
     	print "Back door closed";
	   set $Alarm_BackDoor_Alarm 'closed' if state $Alarm_BackDoor_Alarm ne 'closed';
  }else{
#	 print "Back door open";
	 set $Alarm_BackDoor_Alarm 'alarm' if state $Alarm_BackDoor_Alarm ne 'alarm'
  }


} # end sub










$HV_FrontDoorBell = new Serial_Item('INPUT14low','on','Homevision');
$HV_FrontDoorBell->add('INPUT14high','off');
$HV_FrontDoorBell->tie_event('');



$HV_BackDoorBell = new Serial_Item('INPUT15low','on','Homevision');
$HV_BackDoorBell->add('INPUT15high','off');
$HV_BackDoorBell->tie_event('&RearDoorBell');



my $tmr_doorbell_debounce = new Timer;
 
sub RearDoorBell{ 
	if (state $HV_BackDoorBell eq 'on' and inactive $tmr_doorbell_debounce){
			set $tmr_doorbell_debounce 2;		
			#play $config_parms{Doorbell_rear}
			&Rear_DoorBell    # in sounds.pl plays random doo bell sound
			}
}





$HV_KeyFobRX2 = new Serial_Item('INPUT16low','on','Homevision');
$HV_KeyFobRX2->add('INPUT16high','off');
$HV_KeyFobRX2->tie_event('print_log "Alarm key Fob channel RX2 $state"');
$HV_KeyFobRX2->tie_items($HV_DoorBeeper);




$HV_MarantzAMP = new Serial_Item('INPUT17low','on','Homevision');
$HV_MarantzAMP->add('INPUT17high','off');



# 17-23 not used
#
#
#    BUT here to stop 
#
#
#

$HV_Loft_PIR = new Serial_Item('INPUT24low','on','Homevision');
$HV_Loft_PIR->add('INPUT24high','off');

# input 25 F2 is going to be living room heat alarm??

$HV_LivingR_smoke = new Serial_Item('INPUT25low','on','Homevision');
$HV_LivingR_smoke->add('INPUT25high','off');






#input 26 not used

$HV_KeyFobRX1 = new Serial_Item('INPUT27low','on','Homevision');
$HV_KeyFobRX1->add('INPUT27high','off');
$HV_KeyFobRX1->tie_event('print_log "Alarm Key fob channel RX1 $state"');
#$HV_KeyFobRX1->tie_items($HV_FloodLights_relay);
$HV_KeyFobRX1->tie_items($HV_DoorBeeper);


# buttons grey on the undr stair door

$HV_UP_button = new Serial_Item('INPUT28low','on','Homevision'); # 28 = up
$HV_UP_button->add('INPUT28high','off');
$HV_UP_button->tie_event('&open_the_gate3');	

$HV_ENTER_button = new Serial_Item('INPUT29low','on','Homevision');  # 29 = enter
$HV_ENTER_button->add('INPUT29high','off');
$HV_ENTER_button->tie_event('&Bed_Button');	    


$HV_DOWN_button = new Serial_Item('INPUT30low','on','Homevision');    # 30 = down
$HV_DOWN_button->add('INPUT30high','off');
$HV_DOWN_button->tie_event('&Toggle_Outside_Lights');


$HV_DEL_button = new Serial_Item('INPUT31low','on','Homevision');   #31 = del
$HV_DEL_button->add('INPUT31high','off');
$HV_DEL_button->tie_event('&but_Enter_Pressed');      # in sound.pl    


# Button actions
# grey button subr's some


sub Bed_Button{
	# homevision runs the ights go to bed routine 
	# because MH cant control the x10 properly
	# but this turns off all the other lights that Hoemvision doesnt control

	set $Outside 'off';
    print_log" GREY BUTTONS -> goto Bed button pressed";

	# the X10 lights control are done in homevision
	# this is because it is difficult to control the X10 dim functions via the serial interface to Homevision
	if (time_between '10:30 pm','3 am' and state $HV_ENTER_button eq 'on'){
           my $BedtimeDelay = new Timer;
		   set $BedtimeDelay 120 ,sub{
			   set $Garden1_light 'off'; 
            # add the stuff to do here that will do after 2 minutes
		   }
		}
	}










sub Toggle_Outside_Lights{

	# use the state of the main outside lights to decide what to change all the others to
     print_log "GREY BUTTONS -> Toggle lights pressed";
	if (state $OSFlood_light eq 'on'){

			set $Outside 'off'

		}else{
            set $Outside 'on'


			
		}
}







my $tmr_gatebtn_debounce = new Timer;
 
sub open_the_gate3{ 

	print_log "GREY BUTTONS -> Gate button pressed";
#if (state $HV_DOWN_button eq 'on' and inactive $tmr_gatebtn_debounce){
	if ( inactive $tmr_gatebtn_debounce){
			set $tmr_gatebtn_debounce 2;		
			speak "Opening the main field gate.";
			print_log "House gate button open pressed";
			&open_the_gate
	}
}


sub Smoke_detector_ignore{
	print_log "GREY BUTTONS ->  SMOKE detector ignor pressed";
	set $Smoke_Group "less_kitchen";
	speak 'The Kitchen Smoke Alarm has been disabled for today only'
    
}




=begin

Outputs

	A1 /0	Hot water relay
	A2	1 Central heating
	A3	2 U/floor heating
	A4	3 DHW immersion heater { the switch in the washing maching cupboard is a manual override}
	A5	4 Porch lights
	A6	5 Flood lights on main house
	A7	6 Back door sounder
	A8	7 Heating Rads Servo 5v relay
	

	C1 /8	MH tells HV it has control of heating by setting it on
	C2
	C3
	C4
	C5 /12	Kitchen PA relay
	C6	Living room PA relay
	C7	Bed 1 PA relay
	C8	Bed 2 PA relay
=cut

$HV_ReportOutputs = new Serial_Item('DIGITALTEMPUPDATE','Report_DigiTemp_States','Homevision');

$HV_ReportOutputs ->add('OUTPUTSTATES','Report_HV_OUTPUTS','Homevision');


$HV_DHW_pump = new Serial_Item('OUTPUT00low','off','Homevision');
$HV_DHW_pump->add('OUTPUT00high','on');

$HV_Rads_pump = new Serial_Item('OUTPUT01low','off','Homevision');
$HV_Rads_pump->add('OUTPUT01high','on');


$HV_uFloor_pump = new Serial_Item('OUTPUT02low','off','Homevision');
$HV_uFloor_pump->add('OUTPUT02high','on');



$HV_DHW_Immersion_relay = new Serial_Item('OUTPUT03low','off','Homevision');
$HV_DHW_Immersion_relay->add('OUTPUT03high','on');


#the above  serial items, have voice commands declared in Heating.pl or timing.pl


$OSporch_light = new Generic_Item;

$HV_Porch_Light = new Serial_Item('OUTPUT04low','off','Homevision');
$HV_Porch_Light->add('OUTPUT04high','on');


$HV_FloodLights_relay = new Serial_Item('OUTPUT05low','off','Homevision');
$HV_FloodLights_relay->add('OUTPUT05high','on');


$HV_DoorBeeper = new Serial_Item('OUTPUT06low','off','Homevision');
$HV_DoorBeeper->add('OUTPUT06high','on');


$HV_Servo5v_relay = new Serial_Item('OUTPUT07low','off','Homevision');
$HV_Servo5v_relay->add('OUTPUT07high','on');

$HV_MH_Controls_Heating = new Serial_Item('OUTPUT08low','off','Homevision');
$HV_MH_Controls_Heating->add('OUTPUT08high','on');

$V_PA_ALL = new Voice_Cmd("Turn ALL the PA [on,off]");


if ($state = said $V_PA_ALL){
   	if ($state eq "on"){

     		set $HV_Kitchen_PA 'on';     		
		    set $HV_LivingR_PA 'on';
     		set $HV_Bed1_PA 'on';
    		set $HV_Bed2_PA 'on'
      			 }else{
     		set $HV_Kitchen_PA 'off';     		
		set $HV_LivingR_PA 'off';
    		set $HV_Bed1_PA 'off';
    		set $HV_Bed2_PA 'off'
	 }
 }


$V_PA_bedrooms = new Voice_Cmd("Turn the Bedrooms PA [on,off]");


if ($state= said $V_PA_bedrooms){
   	if ($state eq "on"){
     		set $HV_Bed1_PA 'on';
    		set $HV_Bed2_PA 'on'
      			 }else{
    		set $HV_Bed1_PA 'off';
    		set $HV_Bed2_PA 'off'
	 }
 }

 
$V_PA_bedroom_one = new Voice_Cmd("Turn the Bedroom 1 PA [on,off]");


if ($state= said $V_PA_bedroom_two){
   	if ($state eq "on"){
    		set $HV_Bed1_PA 'on'
      			 }else{
    		set $HV_Bed1_PA 'off'
	 }
 }



$V_PA_bedroom_two = new Voice_Cmd("Turn the Bedroom 2 PA [on,off]");


if ($state= said $V_PA_bedroom_two){
   	if ($state eq "on"){
    		set $HV_Bed2_PA 'on'
      			 }else{
    		set $HV_Bed2_PA 'off'
	 }
 }

$V_PA_kitchen = new Voice_Cmd("Turn the Kitchen PA [on,off]");


if ($state= said $V_PA_kitchen){
   	if ($state eq "on"){
    		set $HV_Kitchen_PA 'on'
      			 }else{
    		 set $HV_Kitchen_PA 'off'
	 }
 }
 

$V_PA_LivingR = new Voice_Cmd("Turn the Living Room PA [on,off]");


if ($state= said $V_PA_LivingR){
   	if ($state eq "on"){
    		set $HV_LivingR_PA 'on'
      			 }else{
    		set $HV_LivingR_PA 'off'
	 }
 }
  
 



$HV_Kitchen_PA = new Serial_Item('OUTPUT12low','off','Homevision');
$HV_Kitchen_PA->add('OUTPUT12high','on');


$HV_LivingR_PA = new Serial_Item('OUTPUT13low','off','Homevision');
$HV_LivingR_PA->add('OUTPUT39high','on');


$HV_Bed1_PA = new Serial_Item('OUTPUT14low','off','Homevision');
$HV_Bed1_PA->add('OUTPUT14high','on');

$HV_Bed2_PA = new Serial_Item('OUTPUT15low','off','Homevision');
$HV_Bed2_PA->add('OUTPUT15high','on');

my $HV_Outputs1;
#if ( $New_Second and new_second 10){

#$HV_Outputs1 = $Homevision::HV_outputs
#print_log "Outputs $HV_Outputs1";
#}

=begin
 declared in lights pl, this is here just for info
 X10
	A1	Radio remote sw 1  (mood)
	A2	Radio remote sw 2  9 flood lights toggle)
	A3	Radio remote sw 3
	
	A4	Bed 1 Bedside lights
	A5 	Patio lights
	A6	Living room lights??

	B1	Extractor fan in loft
	B2	Upstairs xmas lights
	B3	Xmas tree and window lights
	B4	Xmas tree lights Front

	C1 	Ensuite
	C2	Hall	
	C3	Kitchen
	C4	4 way Landing lights
	C5	Main Bath
	C6	Bed 3
	C7	Bed 2
	C8	Bed 1
	C9 	100W flood living room
	C10	Study
	C11	Mood Living room
	C12     Garden shed Inside
	C13	Fish Tank
	C14	Garden Shed Outside
	C15 	Glass box mood lights

	F1 	Garden lights circuit 1
	F2	Garden lights circuit 2
	F3	Garden Lights circuit 3
	F4	POND pump
=cut




=begin

	
IRslots ' not correst as of dec 2016 run HV prog on server to reprogram'
	1	Amp toggle power
	2	AMP tv input
	3	AMp DSS satalie
	4	AMP DVD
	5	AMP vol UP
	6	AMP vol Down
	7 	SKY Power
	8	SKY #1
	9	SKY #2

=cut


$HV_IR_AMP = new Serial_Item("IRSlot1","AmpPower","Homevision");
$HV_IR_AMP ->add("IRSlot2","AMPinputTV");
$HV_IR_AMP ->add("IRSlot3","AMPinputSAT");
$HV_IR_AMP ->add("IRSlot4","AMPinputDVD");
$HV_IR_AMP ->add("IRSlot5","AMPinputVOLup");
$HV_IR_AMP ->add("IRSlot6","AMPinputVOLdwn");

$HV_IR_SKY = new Serial_Item("IRSSlot7","SKYPower","Homevision");
$HV_IR_SKY ->add("IRSlot8","AMPSKY1");
$HV_IR_SKY ->add("IRSlot9","AMPSKY2");




=begin

   TEMP sensors and IDs
   	0 	Living room 		16,42,155,68,0,0,0,171
	1 	Study			16,66,154,68,0,0,0,4
	2	Kitchen / dining	16,224,119,68,0,0,0,0
	3	Utility			16,51,189,68,0,0,0,2
	4	Bed1 
	5	Bed 2
	6	Bed 3
	7	En suite
	8	Main Bath
	9	Outside
	10	N/a
	11	n/a
	12 	Boiler OWT
if you alter the number of temp ds1820 then alter the regex below


=cut
# now declared in temperatures.pl as of aug 2014

# $T_LivingR = new Generic_Item;
# $T_Study = new Generic_Item;
# $T_Kitchen = new Generic_Item;
# $T_Utility = new Generic_Item;
# $T_Bed1 = new Generic_Item;
# $T_Bed2  = new Generic_Item;
# $T_Bed3 = new Generic_Item;
# $T_EnSuite = new Generic_Item;
# $T_MainBath = new Generic_Item;
# $T_NU1 = new Generic_Item;
# $T_NU2 = new Generic_Item;
# $T_NU3 = new Generic_Item;
# $T_GASBoilerOWT = new Generic_Item;



my $HV_temp_comp = 0.95;
my $HV_Temps1;

if ( $New_Minute and new_minute 5){
	 set $HV_ReportOutputs 'Report_DigiTemp_States';

	 $HV_Temps1 = $Homevision::HV_temps;
     #print_log "HV temps.....$HV_Temps1";
     if($HV_Temps1 =~/([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])/){
	     #print_log "Homevision Temps   $1 $2 $3 $4 $5 $6 $7 $8 $9 $10  ";
	     $HV_Temps1 = convert_f2c(hex($1));
	      print_log " converted $HV_Temps1";
	     set $T_LivingR (convert_f2c(hex($1)* $HV_temp_comp));
	     set $T_Study (convert_f2c(hex($2)* $HV_temp_comp));
	     set $T_Kitchen (convert_f2c(hex($3)* $HV_temp_comp));
	     set $T_Utility (convert_f2c(hex($4)* $HV_temp_comp));
	     set $T_Bed1 (convert_f2c(hex($5)* $HV_temp_comp));
	     set $T_Bed2  (convert_f2c(hex($6)* $HV_temp_comp));
	     set $T_Bed3 (convert_f2c(hex($7)* $HV_temp_comp));
	     set $T_EnSuite (convert_f2c(hex($8)* $HV_temp_comp));
	     set $T_MainBath (convert_f2c(hex($9)* $HV_temp_comp));
	     set $T_GASBoilerOWT (convert_f2c(hex($10)* $HV_temp_comp))
         }

     }

#------------------- OUTPUTS UPDATE ---------------------------------
=begin

Outputs

	A1 /0	Hot water relay
	A2	Central heating
	A3	U/floor heating
	A4	DHW immersion heater
	A5	?? lights on main house
	A6	flood lights
	A7	Back door sounder
	A8	Heatin Rads Servo 5v relay# this reads the update from HV and sets the staus flags in MH
=cut
# this ensures what mh thinks the HV states are is real
my $HV_OUTPUTS;

if($Reload or $Startup){
# Align the satus at start or reebbot to#stop MH swamping HV#with updates

	set $Status_House_DHW state $House_DHW;
	set $Status_House_Radiators state $House_Radiators;
	set $Status_uFloor_Heating state $House_uFloor_Heating;
	set $Status_Porch_light state $OSporch_light;
	set $Status_OSFlood_light state $OSFlood_light;

#they will be relaigned when a valid OUTPUSTATES below is registered

}



if ( $New_Second and new_second 10){
	set $HV_ReportOutputs 'Report_HV_OUTPUTS';
	$HV_OUTPUTS = $Homevision::HV_outputs;
	#print_log "Homevision outputs $HV_OUTPUTS";
	if ($HV_OUTPUTS =~/([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])([0-1])/){

	#print_log "Homevision outputs decoded   1:$1 2:$2 3:$3 4:$4 5:$5 6:$6 7:$7 8:$8 9:$9 10:$10 $11 $12 $13 $14 $15 $16  ";
	if ($1 eq '1'){
		set $Status_House_DHW 'on' if state $Status_House_DHW ne 'on'
	}else{
		set $Status_House_DHW 'off' if state $Status_House_DHW ne 'off'
	}

if ($2 eq '1'){
		set $Status_House_Radiators 'on' if state $Status_House_Radiators ne 'on'
	}else{
		set $Status_House_Radiators 'off' if state $Status_House_Radiators ne 'off'
}



if ($3 eq '1'){
		set $Status_uFloor_Heating 'on' if state $Status_uFloor_Heating ne 'on'
	}else{
		set $Status_uFloor_Heating 'off' if state $Status_uFloor_Heating ne 'off'
	}


if ($4 eq '1'){
		set $Status_House_DHW_immersion 'on' if state $Status_House_DHW_immersion ne 'on'
	}else{
		set $Status_House_DHW_immersion 'off' if state $Status_House_DHW_immersion ne 'off'
	}


if ($5 eq '1'){
		set $Status_Porch_light 'on' if state $Status_Porch_light ne 'on'
	}else{
		set $Status_Porch_light 'off' if state $Status_Porch_light ne 'off'
	}


if ($6 eq '1'){
		set $Status_OSFlood_light 'on' if state $Status_OSFlood_light ne 'on'
	}else{
		set $Status_OSFlood_light 'off' if state $Status_OSFlood_light ne 'off'
	}



	

# ???????????????????????????????????????????????????????????????????????????????????

#add more in to report the actual status of the ports on Homevision

#???????????????????????????????????????????????????????????

}

}


# VIDEO COMMANDS FOR MAIN TV.
#

#$HV_VIDEO = new Serial_Item("VIDEOoff","off","Homevision");
#$HV_VIDEO ->add("VIDEOon","on");
#$HV_VIDEO ->add("VIDEOcls","clear");
#$HV_VIDEO ->add("VIDEO1","VideoLine1");



#------------------------- show messages on the TV in the living room --------------------
#

$V_Show_on_tv = new Voice_Cmd("Show on TV a test message");

 if ( said $V_Show_on_tv){

#	 print_log "running show on tv";
	# &Show_on_tv ("  TV Test message again")
 }

#
my $tmr_TV_alarm = new Timer;


sub Show_on_tv {


}

$CodeTimings::CodeTimings::CodeTimings{'HomeVisionInterface End'} = time();