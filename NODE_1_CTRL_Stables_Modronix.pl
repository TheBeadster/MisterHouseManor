# Category = MODTRONIX
#
##########################################################################
# 									                                     #
#              		 Modtronix interface for Stables and Gate            #
#									                                     #
#            		 see modtronix
#              sbc65 board on a ior5e expansion board                    #
#									                                     #
#			Beady Aug 2018                                               #	
##########################################################################
$CodeTimings::CodeTimings{'NODE_1_CTRL_Stables_Modtronix Start'} = time();

#  

#@   This controls Comms between the modtronix device named 'MOD1' by me  IP static at 192.168.1.23
#@

#@ see http://oldsite.modtronix.com/products/sbc68ec/websrvr68_v310/


=begin
you can view the direct webpages ont he device by going to its IP address, dont use firefox, doent work for some reason
un  dadmin and pw betchton

  if fitting a new device, you must use the serial port to set the IP qaddress etc, see the documention in           
       \\server2\HomeAutomation\Other\Modtronix sbc65


serial1 port is redirected to UDP port 2 ( must be enabled in the web pages config and the serial redirected to it) , to read the underground alarm signal volatges
the underground alarm can be unplugger from Modtroinix to ebable cofig with GPSstandrds Multiplex 2000 software

=cut

$tmrModtronix_NODE1_found = new Timer;

#the ctrl is used to send commands to the modtronix board
my $Modtronix_UDP_ctrl_Node1_address = '192.168.1.23:54123'; 
$Modtronix_UDPctrl = new  Socket_Item(undef, undef, $Modtronix_UDP_ctrl_Node1_address, 'ModtronixNode1ctrl','udp','raw');

# the event board is messaged recieved about events on the modtronix board
my $Modtronix_UDP_Event_Node1_address = '192.168.1.23:54124';
$Modtronix_UDPevent = new  Socket_Item(undef, undef, $Modtronix_UDP_Event_Node1_address, 'ModtronixNode1event','udp','raw');

my $Modtronix_UDP_SerialRS232_Node1_address = '192.168.1.23:54126';
$Modtronix_UDPSerialRS232 = new  Socket_Item(undef, undef, $Modtronix_UDP_SerialRS232_Node1_address, 'ModtronixNode1SerialRS232','udp','raw');


sub Open_Modtronix_Node1_comms{
		stop $Modtronix_UDPctrl if active $Modtronix_UDPctrl;
		stop $Modtronix_UDPevent if active $Modtronix_UDPevent;
		print_log "opening Modtronix ctrl/event UDP ports for for Node 1";
		start $Modtronix_UDPctrl;
        start $Modtronix_UDPevent ;
		set $Modtronix_UDPevent  "01\n\r";   # tell mddtronix to auto rpeort inout port state changes
		set $tmrModtronix_NODE1_found 30,sub{
	  	             &Open_Modtronix_Node1_comms    # restart after 30 seconds if not recived a ACK from moddtronix
	           	}
}

if ($Reload or $Startup){
	&Open_Modtronix_Node1_comms
}

sub Open_Modtronix_Node1_comms_because_missing{
	#speak" Lost mod tron ix at node 1 in TR shed off the network";

	&Open_Modtronix_Node1_comms
}






if (new_minute 1 ){
	set $Modtronix_UDPevent  "01\n\r"
#	set $Modtronix_UDPctrl  "a3=1";
   # print_log "Sending 01 to Modtronix"
   # set $Modtronix_NODE1_found 30,sub{
	#		set $Modtronix_UDPctrl  "a3=0";
	#	}
}
=begin
    Modtronix on UDP port 54124 needs 01 to be sent to start sending data it nust be the first thing sent
	the reply every second is heartbeart l40=2;

	we use this to make sure the board is there every 20 seconds or so

	then any event change will be transmiited
      normal inputs
	x40 : gate lock potentiometer 				was Radar Gate	
	x41	: Tamper radars
	x42	: Radar Field
	x43	: Radar Gate						not used as of 2018 :: bike shed alarm
	x44	: 						Mower shed PIR alarm 
	x45	: gate cloesed switch						Tack room PIR alarm



	opto inputs

	x20	: ch 1 Ug pre-alarm  one acre
	x21	: ch 2 UG pre-alarm bottom main field 
	x22	: not used
	x23	: not used





=cut

if (new_second 1){

    set $Modtronix_UDPctrl  "%n20" ;  #tell the modtronix to read the ano1 value and send it over udp  , 2= format of data wanted and 0 = An0
									# so %n22 would be ano2  ie 3rd ano chanel
	#print_log"requesting ano val from modtronix"
}



if  ($state = said $Modtronix_UDPctrl)  {
# will be a ano read from the 5 seconfd read'
  set $Gate_workShop_lock_pos_raw $state;
  #print_log "Ano read millys gate pos".state $Gate_workShop_lock_pos_raw
  




}



if  ($New_Second and active $Modtronix_UDPevent and($state = said $Modtronix_UDPevent))  {

	#	print_log "Modtronix  Node 1 TR shed------------------------> " .$state;
# 		use regex to split up string at ;
# 		then use loop through them
# 		getting $value from last digit
	my @Node1Locs = split /;/,$state;
	foreach (@Node1Locs){

		#print_log " Modtronic Node 1 found $_";

       if ($_ eq"l40=2"){
           # this is the heartbeat so
		   #reset the timer that resets the coms to the Modtronix
		  #	print_log "reset Node1 modtronix timer";   #debug
		   	set $tmrModtronix_NODE1_found 30,sub{
	  	       &Open_Modtronix_Node1_comms_because_missing   # restart after 30 seconds if not recived a ACK from moddtronix
			   }

	   }else{
           # split the data to location and value
       		my ($loc,$value)=split /=/,$_;
	   
	   		#print_log "Modtronix loc $loc and value $value";
			 if ($loc eq "x40"){
	   			 #print_log "Input 1";
  				 if ($value == 0  )	 {
	                      #set $Alarm_Stables_Alarm 'ok' if state $Alarm_Stables_Alarm ne 'ok'
	                 }else{
		                  #set $Alarm_Stables_Alarm 'alarm' if state $Alarm_Stables_Alarm ne 'alarm'
	                 }
			 }

            if ($loc eq "x41"){
	   		#	 print_log "Modtronix Input 2  Padock tamper";
  				 if ($value == 0  ){
	                      set $Alarm_Radar_paddock_Tamper 'ok' if state $Alarm_Radar_paddock_Tamper ne 'ok'
	                 }else{
		                  set $Alarm_Radar_paddock_Tamper 'alarm' if state $Alarm_Radar_paddock_Tamper 'alarm'
	                 }
			 }
			if ($loc eq "x42"){
	   		#	 print_log "Modtronix Input 3 paddock alarm";
  				 if ($value == 0  ){
	                      set $Alarm_Radar_paddock_Alarm 'ok' if state $Alarm_Radar_paddock_Alarm ne 'ok'
	                 }else{
		                  set $Alarm_Radar_paddock_Alarm 'alarm' if state $Alarm_Radar_paddock_Alarm ne 'alarm'
	                 }
			 }
			if ($loc eq "x43"){
	   		#	 print_log "Modtronix Input 1  Main gate radar";
  				 if ($value == 0  ){
	                      set $Alarm_Radar_MainGate_Alarm 'ok' if state $Alarm_Radar_MainGate_Alarm ne 'ok'
	                 }else{
		                  set $Alarm_Radar_MainGate_Alarm 'alarm' if state $Alarm_Radar_MainGate_Alarm ne 'alarm'
	                 }
			 }

			 if ($loc eq "x44"){
	   		#	 print_log "Modtronix Input 5 milly gate top switchalarm";
  				 if ($value == 0  ){
	                      set $Alarm_Milly_Gate_Alarm 'ok' if state $Alarm_Milly_Gate_Alarm ne 'ok';
						  print_log "Millys workshop gate closed";
	                 }else{
						 print_log "Millys workshop gate opened";
		                  set $Alarm_Milly_Gate_Alarm 'alarm' if state $Alarm_Milly_Gate_Alarm ne 'alarm'
	                 }
			 }
			 if ($loc eq "x45"){
	   		#	 print_log "Modtronix Input 6 Stables alarm";
  				 if ($value == 0  ){
	                      set $Alarm_TR_Shed_Alarm 'ok' if state $Alarm_TR_Shed_Alarm ne 'ok'
	                 }else{
		                  set $Alarm_TR_Shed_Alarm 'alarm' if state $Alarm_TR_Shed_Alarm ne 'alarm'
	                 }

			 }

			#opto inputs, are high if OK

			if ($loc eq "x20"){
	   		#	 print_log "Modtronix opto Input 1 UG Ch1 Pre alarm";
  				 if ($value == 1  ){
	                      set $Alarm_Underground_Ch1_PreAlarm 'ok' if state $Alarm_Underground_Ch1_PreAlarm ne 'ok'
	                 }else{
		                  set $Alarm_Underground_Ch1_PreAlarm 'alarm' if state $Alarm_Underground_Ch1_PreAlarm ne 'alarm'
	                 }
			 }
			if ($loc eq "x21"){
	   		#	 print_log "Modtronix opto Input 2 UG Ch2 Prealarm";
  				 if ($value == 1  ){
	                      set $Alarm_Underground_Ch2_PreAlarm 'ok' if state $Alarm_Underground_Ch2_PreAlarm ne 'ok'
	                 }else{
		                  set $Alarm_Underground_Ch2_PreAlarm 'alarm' if state $Alarm_Underground_Ch2_PreAlarm ne 'alarm'
	                 }
			 }
			if ($loc eq "x22"){
	   			 print_log "opto Input 3  Gate IR beam = ".$value;
  				 if ($value == 1  ){
					   	   set $Status_Gate_IR_beam 'ok' if state $Status_Gate_IR_beam ne 'ok'
	                 }else{
		                  set $Status_Gate_IR_beam 'alarm' if state $Status_Gate_IR_beam ne 'alarm'

	                 }
			 }
			if ($loc eq "x23"){
	   			 #print_log "opto Input 4";
  				 if ($value == 1  ){
	                     # set $Alarm_Radar_MainGate_Alarm 'ok' if state $Alarm_Radar_MainGate_Alarm ne 'ok'
	                 }else{
		                 # set $Alarm_Radar_MainGate_Alarm 'alarm' if state $Alarm_Radar_MainGate_Alarm ne 'alarm'
	                 }
			 }





	   	}

	}











}



#---------------------------------------------------------------------------------------

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
	     	#'set $Modtronix_UDPctrl 'xr1=1' 
		}else{
			print_log "water is no UN metered";
	       	#set $Modtronix_UDPctrl 'xr1=0'
	}
}

$CodeTimings::CodeTimings{'NODE_1_CTRL_Stables_Modtronix End'} = time();