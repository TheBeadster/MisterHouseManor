# Category = MODTRONIX
#

$CodeTimings::CodeTimings{'NODE_3_CTRL_DoggerShed_Modtronix Start'} = time();


##########################################################################
# 									                                     #
#              		 Modtronix interface for Dogger shed            #
#									                                     #
#            		 see modtronix
#              sbc65 board on a ior5e expansion board                    #
#									                                     #
#			Beady may 2019                                               #	
##########################################################################


#  

#@   This controls Comms between the modtronix device named 'MOD1' by me  IP static at 192.168.1.27
#@

#@ see http://oldsite.modtronix.com/products/sbc68ec/websrvr68_v310/


=begin

you can view the direct webpages ont he device by going to its IP address, dont use firefox, doent work for some reason
un  dadmin and pw betchton
                 

  if fitting a new device, you must use the serial port to set the IP qaddress etc, see the documention in           
       \\server2\HomeAutomation\Other\Modtronix sbc65


	   
=cut

$Modtronix_NODE3_found = new Timer;

$T_DoggerShed_Fridge = new Generic_Item;
$T_DoggerShed_Freezer  = new Generic_Item;
my @T_DoggerShed_Fridge_list ;										# used to average the reading fromt he fridge and freezer
my @T_DoggerShed_Freezer_list;
my ($T_avgDogger,$T_Dogger);
$ReadNode3_Ano = new Generic_Item;



#the ctrl is used to send commands to the modtronix board
my $Modtronix_UDP_ctrl_Node3_address = '192.168.1.27:54123'; 
$Modtronix_UDPctrlNode3 = new  Socket_Item(undef, undef, $Modtronix_UDP_ctrl_Node3_address, 'ModtronixNode3ctrl','udp','raw');

# the event board is messaged recieved about events on the modtronix board
my $Modtronix_UDP_Event_Node3_address = '192.168.1.27:54124';

$Modtronix_UDPeventNode3 = new  Socket_Item(undef, undef, $Modtronix_UDP_Event_Node3_address, 'ModtronixNode3event','udp','raw');

sub Open_Modtronix_Node3_comms{
	   
		stop $Modtronix_UDPctrlNode3 if active $Modtronix_UDPctrlNode3;
        stop $Modtronix_UDPeventNode3 if active $Modtronix_UDPeventNode3;
		print_log "opening Modtronix ctrl/event UDP ports for for Node 3";
		start $Modtronix_UDPctrlNode3;
        start $Modtronix_UDPeventNode3 ;
		set $Modtronix_UDPeventNode3  "01\n\r";      	# tell modtronix to auto report state changes on inputs
		set $Modtronix_NODE3_found 60,sub{
	  	        &Open_Modtronix_Node3_comms    			# restart after 30 seconds if not recived a ACK from modtronix
	           	};
		set $ReadNode3_Ano 'an00';		   				# set start sequence for analogue reads
		@T_DoggerShed_Fridge_list =(4.5,4.5,4.5,4.5,4.5,4,4,4,4,4) ;  # init the average array
		@T_DoggerShed_Freezer_list=(-5.5,-5.5,-5,-5,-5,-5,-5,-5,-5,-5);
}



if ($Reload or $Startup){
	&Open_Modtronix_Node3_comms
}

sub Open_Modtronix_Node3_comms_because_its_missing{

  #speak "lost Node 3 in the dogger shed of the network";
  &Open_Modtronix_Node3_comms
}








if (new_minute 1 ){
	set $Modtronix_UDPeventNode3  "01\n\r";

    #set $Modtronix_UDPctrlNode3  "xr1=1"; #turn on relay 1
    #print_log "Sending xr1=1 to Modtronix node 3";
    #   set $Modtronix_NODE1_found 30,sub{
	#		set $Modtronix_UDPctrl  "a3=0";
	#	}
	if ( state $ReadNode3_Ano eq "an00"){
		    set $Modtronix_UDPctrlNode3  "%n20"   			#read anologue port 1 value
		}else{
			set $Modtronix_UDPctrlNode3  "%n21"			 	#read anologue prot 2 value
			}

logit("$config_parms{HVACLog_dir}/freezerFridgelog.$Year_Month_Now.log","Fridge ".state $T_DoggerShed_Fridge."Freezer ".state $T_DoggerShed_Freezer);
}

 


#see if there is anything back from the ctrl port # and active $Modtronix_UDPctrlNode3 
if  ($state = said $Modtronix_UDPctrlNode3)  {
	#print_log" Dogger shed ano data $state ".state $ReadNode3_Ano;
    


	if (state $ReadNode3_Ano eq 'an00'){
		
		pop(@T_DoggerShed_Fridge_list);					# take off the last value from the list of temps
		
        unshift(@T_DoggerShed_Fridge_list,($state - 0.50) * 100);       # PUSh the new value onto the start of the list 
		$T_avgDogger = 0;
		foreach $T_Dogger (@T_DoggerShed_Fridge_list){
			$T_avgDogger = $T_avgDogger + $T_Dogger;
           # print_log "$T_avgDogger -- $T_Dogger ";
		}
		
		set $T_DoggerShed_Fridge $T_avgDogger / 10  ;      # should smooth the reading from the odd randoms that appear
		print_log "fridge ....... ".state $T_DoggerShed_Fridge;
		set $ReadNode3_Ano 'an01';
         


		if (state $T_DoggerShed_Fridge > 7){
			print_log "warning fridge to hot ".state $T_DoggerShed_Fridge
			# speak(" Warning Fridge in outside shed is to warm, it is all melting")
		}
	}

	if (state $ReadNode3_Ano eq 'an01'){

		pop(@T_DoggerShed_Freezer_list);					# take off the last value from the list of temps
		
        unshift(@T_DoggerShed_Freezer_list,($state - 0.50) * 100);       # PUSh the new value onto the start of the list 
		$T_avgDogger = 0;
		foreach $T_Dogger (@T_DoggerShed_Freezer_list){
			$T_avgDogger = $T_avgDogger + $T_Dogger;
           # print_log "$T_avgDogger -- $T_Dogger ";
		}
		
		set $T_DoggerShed_Freezer $T_avgDogger / 10  ;      # should smooth the reading from the odd randoms that appear
		print_log "freezer....... ".state $T_DoggerShed_Freezer;
		set $ReadNode3_Ano 'an00';
		if (state $T_DoggerShed_Freezer >-5){
			print_log "warning freezer to hot ".state $T_DoggerShed_Freezer;
			 #speak(" Warning Freezer in outside shed is to warm, it is all melting")
			}
	}

}






=begin
    Modtronix on UDP port 54124 needs 01 to be sent to start auto sending event data it must be the first thing sent
	the reply every second is heartbeart l40=2;

	we use this to make sure the board is there every 20 seconds or so

	then any event change will be transmiited
      normal inputs
	x40 : Smoke detector	
	x41	: big lights
	x42	: small lights
	x43	: not used as of 2018
	x44	: not used 
	x45	: not used

	opto inputs

	x20	: smoke detector
	x21	: big lights 
	x22	: small lights
	x23	: not used


	relay outputs
	XR1 = large LED lamp
	XR2 = small lamp
	XR3 = Crow eyes :-)   2019

freezer and fridge temps

using TMP36 temp sensor
-40 to +125 deg c
25degc = 750Mv
10Mv per deg c

I/O 1 (A0) is configured as an Analog Input	Analog Value = 0.55
I/O 2 (A1) is configured as an Analog Input	Analog Value = 0.44

trmp = -50 +( temp read as mv/10)

=cut




if  ($New_Second and active $Modtronix_UDPeventNode3 and ($state = said $Modtronix_UDPeventNode3))  {

		#print_log "Modtronix Node 3 ------------------------> " .$state;# if ( $state ne "l40=2;");   # debug
# 		use regex to split up string at ;
# 		then use loop through them
# 		getting $value from last digit
    my @Locs = split /;/,$state;
	foreach (@Locs){

		#print_log " Modtronic node 3 modtronix found $_";

       if ($_ eq "l40=2" ){
           # this is the heartbeat so
		   #reset the timer that resets the coms to the Modtronix
		   #print_log "reset Node3 timer";   #debug
		   	set $Modtronix_NODE3_found 60,sub{
	  	        &Open_Modtronix_Node3_comms_because_its_missing    # restart after 30 seconds if not recived a ACK from moddtronix
	           	}

	   }else{
           # split the data to location and value
       		my ($loc,$value)=split /=/,$_;
	   
	   		#print_log "Modtronix loc $loc and value $value";

			 if ($loc eq "x40"){
	   		#	 print_log "Modtronix Input 1  ";
  				 if ($value == 0  ){
	                     # set $Alarm_Radar_MainGate_Alarm 'ok' if state $Alarm_Radar_MainGate_Alarm ne 'ok'
	                 }else{
		                #  set $Alarm_Radar_MainGate_Alarm 'alarm' if state $Alarm_Radar_MainGate_Alarm ne 'alarm'
	                 }
			 }
            if ($loc eq "x41"){
	   		#	 print_log "Modtronix Input 2  ";

			 }
			if ($loc eq "x42"){
	   		#	 print_log "Modtronix Input 3 ";

			 }
			 if ($loc eq "x43"){
	   			 #print_log "Input 4";

			 }
			 if ($loc eq "x44"){
	   		#	 print_log "Modtronix Input 5 ";

			 }
			 if ($loc eq "x45"){
	   		#	 print_log "Modtronix Input 6 ";

			 }

			#opto inputs, are high if OK

			if ($loc eq "x20"){
	   		#	 print_log "Modtronix opto Input 1 Smoke detector";
  				 if ($value == 1  ){
	                    #  set $Alarm_Underground_Ch1_PreAlarm 'ok' if state $Alarm_Underground_Ch1_PreAlarm ne 'ok'
	                 }else{
		                #  set $Alarm_Underground_Ch1_PreAlarm 'alarm' if state $Alarm_Underground_Ch1_PreAlarm ne 'alarm'
	                 }
			 }
			if ($loc eq "x21"){
	   		#	 print_log "Modtronix opto Input 2 Main lights which indicates movement";
  				 if ($value == 1  ){
	                     # set $Alarm_Underground_Ch2_PreAlarm 'ok' if state $Alarm_Underground_Ch2_PreAlarm ne 'ok'
	                 }else{
		                 # set $Alarm_Underground_Ch2_PreAlarm 'alarm' if state $Alarm_Underground_Ch2_PreAlarm ne 'alarm'
	                 }
			 }
			if ($loc eq "x22"){
	   			 #print_log "opto Input 3   small lights just for detection";
  				 if ($value == 1  ){
	                     # set $Alarm_Radar_MainGate_Alarm 'ok' if state $Alarm_Radar_MainGate_Alarm ne 'ok'
	                 }else{
		                 # set $Alarm_Radar_MainGate_Alarm 'alarm' if state $Alarm_Radar_MainGate_Alarm ne 'alarm'
	                 }
			 }
			if ($loc eq "x23"){
	   			 #print_log "opto Input 4";
 
			 }





	   	}

	}











}



#---------------------------------------------------------------------------------------
=begin
#             commands to control relays etc

my $watervalve_states = 'Metered,Unmetered';     # Relay A
$MainsWater_Valve = new Generic_Item;

set_states $MainsWater_Valve split ',',$watervalve_states;
$V_waterValve = new Voice_Cmd("set water valve to [Metered,Unmetered]");
if ($state = said $V_waterValve){
	set $MainsWater_Valve $state;

 }


# set the water valve at the modtronix to the correct state
if (state_changed $MainsWater_Valve){
	if (state $MainsWater_Valve eq "metered"){
		    print_log "Water is now metered";
	     	set $Modtronix_UDPctrlnode3 'xr1=1' 
		}else{
			print_log "water is no UN metered";
	       	set $Modtronix_UDPctrlnode3 'xr1=0'
	}
}
=cut
#


$CodeTimings::CodeTimings{'NODE_3_CTRL_DoggerShed_Modtronix End'} = time();