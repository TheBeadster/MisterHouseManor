# Category = BarioNET
#

$CodeTimings::CodeTimings{'NODE_1_Stables_BarioNET_VTRL Start'} = time();

##########################################################################
# 									                                     #
#              		 BARIOnet interface for Stables and Gate             #
#									                                     #
#            		 see www.Barix.com				                     #
#									                                     #
#			Beady Jan 2008
#			update dec 2009					                             #
#	update 2018 to remove the r8 interface and put in the modtronix code #
#        in a seperate file                                              #	
##########################################################################


#  note this header is the same as BARIONET_Ser>.pl

#@   This controls Comms between the Barionet device named 'ba1' by me  IP static at 192.168.1.21  : port 9009
#@   located in the stables office, 
#@   it Controls the Ibutton networkl for gate access using a LINK45 ibutton interface
#@   the alarm inputs directly into th DIO inputs ,
#@   the gate safety bypass relay relay B  
#@   and the  water change over valve using Ralay A NC and NO contacts
#@    see the .pl file for protocols and message defs
#
#
#
#     Barionet set to have Link45 in the serial port, some processing is done with the Barionet BCL language see
#      Archive\HomeAutomation\programs\Barionet LAN controller
#
#      for setups and sdk etc for the barionet device
#      the ports of the BArionet are setup like this
#
#	Serial rs232	:	LINk45 ibutton interface  details at 
#					         Archive\HomeAutomation\other\link ibutton improved ds9097u20V1.2.pdf
#
#					talks to 2x gate touch pads which are linklocators
#					      see linklocator files/details
#					         Archive\HomeAutomation\other\link locator for ibutton touch pad manual.pdf 
#					ibuttons on UG_alarm
#					      
#
#					         anymore that might need addding  
#        Dinputs        1-4 are analog 5-8 are digital
#        		:	1 - UG_alarm    Channel 1  alarm
#        			2 - UG_alarm	channel 2  alarm
#        			3 - Radar situated by water valves looking to front of one acre
#        			4 - 24V power at gate motor
#        			5 - Gate open
#        			6 - Gate Closed
#        			7 - smoke detector in workshop and office wires parralel
#        			8 - Gate emergency Sw detect
#
#        			pin 9 is common , if inputs on 5-8 are over 5v then analogues might not work see data sheets
#
#
#Change Feb 2010
#		A RX8 port extender was added giving 8 in/8out extension
#		            		1	 ch1 low pressure +ch2
#					2        Alarm_Stables_Alarm
#					3        ch1  pre alarm
#					4        ch2  pre alarm
#					5        UG tamper + fault
#					6        Radar_paddock_Tampe
#					7        tool shed PIR
#					8        tool Shed Smoke
#RX8 deleted for Modtronix board 2018
#				 
#				 
#					
#				 tool shed tamper
#				 Stables_Tamper 
##				 


##
#
#
#
#
#				
#
#
#        outputs                pin10-13 digit outputs
#                               10  : not used
#                               11  : not used yet
#                               12  : not used yet
#                               13  : not used yet
#
#                               pin 14 is common for outputs
#
#
#
#
#
#
#
#
#        Relay A 		            emergency switch bypass   ON = bypassed, must release relay to see if the switch is pressed or not
#              B                Gate access blip on to start get open sequence
#
#        ibutton temps           2 x ibutton temps   read values and average them in Mh, to get correct outside air temp
#                                                   which is used by heating in house to set temps
#
#                                2 x temp sensors in stables 1 n workshop and 1 in office
# 
#
#						***********************************
#
#		TCP protocol
#
#		the tcp protocol is kept simple so that the Barionet code is simple and all
#		clever processing is done by MH which keeps the coding / learning down to a minimum
#
#
#

#
#                            *********************************************************
#
#
#             data is sent by Barionet every (second at the moment)
#             unless data is recived by the Link 45 in which it is sent as soon as a complete message 
#             is recieved from link45 ibutton
#
#
#	functions  for global use
#
# 
#      the recieved from barionet routine
#            appends all recieved ibutton data into a var_ BarioNET_RCVD_from_Ib.
#            sets the values of the output ports and input ports
#
#
       
		

# setup the variable for object type code for the Digital outputs and relays on the Barionet
#
#
#




our  ($Temperature_entry,$Temperature_exit,$iButtonData,$LL_seq);

my $BarioNET_OUT_states = 'on,off';
my $BarioNET_IN_states ="hi,lo"; 
my $BarioNET_UG_states ="alarm,ok";
my $BarioNET_Radar_states ="alarm,ok";

my $tmr_24V_Buffer_on = new Timer;
my $tmr_24V_Buffer_off = new Timer;

# $T_entryGEN = new Generic_Item;   declared in temperaures.pl as of aug 2014

$BarioNet_ba1_OUT1 = new Generic_Item;
set_states $BarioNet_ba1_OUT1 split ',',$BarioNET_OUT_states;

$BarioNet_ba1_OUT2 = new Generic_Item;
set_states $BarioNet_ba1_OUT2 split ',',$BarioNET_OUT_states;

$BarioNet_ba1_OUT3 = new Generic_Item;
set_states $BarioNet_ba1_OUT3 split ',',$BarioNET_OUT_states;

$BarioNet_ba1_OUT4 = new Generic_Item;
set_states $BarioNet_ba1_OUT4 split ',',$BarioNET_OUT_states;


my $BarioNET_gate_states = 'lo,hi';     # Relay B
$BarioNet_ba1_gate_access = new Generic_Item;
set_states $BarioNet_ba1_gate_access split ',',$BarioNET_gate_states;


# declare inputs 
#  				1 - UG_alarm    Channel 1  alarm
#        			2 - UG_alarm	channel 2  alarm
#        			3 - Radar situated by water valves looking to front of one acre
#        			4 - 24V power at gate motor
#        			5 - Gate open
#        			6 - Gate Closed
#        			7 - smoke detector in workshop and office wires parralel
#        			8 - Gate emergency Sw detect
#


# these two below change the gate_postion_status , to Open,Closed, or In_middle
# do not read these use the gate postionstatus below


# delete not sdetected now, unreliable, changing to magnetics sensors for reliabilty, not done as of feb 2010

$Barionet_NODE1_found = new Timer;
$BarioNet_ba1_gate_open = new Generic_Item;

set_states $BarioNet_ba1_gate_open split ',',$BarioNET_IN_states;
set_info $BarioNet_ba1_gate_open 'status of the gate open switch';


$BarioNet_ba1_gate_closed = new Generic_Item;

set_states $BarioNet_ba1_gate_closed split ',',$BarioNET_IN_states;
set_info $BarioNet_ba1_gate_closed 'status of the gate closed switch';
$BarioNet_ba1_gate_closed -> tie_event(&Gate_status);

$Gate_position_status = new Generic_Item;

my $gate_states ="Open,Closed,In_middle,Fault";
set_states $Gate_position_status split ',',$gate_states;
set_info $Gate_position_status 'depicts where the gate is by sensing the open and closed switches,In middle means both open and closed switches are not set so gate can be anywhere in between';


 $states="pushed,not pushed";
 $gate_Emergency_STOP_sw = new Generic_Item;
 set_states $gate_Emergency_STOP_sw split ',',$states;
 set_info $gate_Emergency_STOP_sw 'This is the status of the emergency SW circuit, it maybe the button or a line brake in the safety circuit, check button first duuh';



# Workshop Smoke alarm




# NODE 0 power is detected in GSM_sms.pl  using the power supply to the phone
my $states="on,off";
$Node1_220V = new Generic_Item;
 set_states $Node1_220V split ',',$states;
 set_info $Node1_220V 'detects if power is on in stables, detected at the consumer unit before the UPS';
 #this is handles in security_alarms.pl as it is a security problem primary
 $Node1_220V-> tie_event('&Notify_Node1_220V("$state")');


$gate_24V = new Generic_Item;
 set_states  $gate_24V split ',',$states;
 set_info $gate_24V ' uses Barionet to detect power actually at the motor itself using the 24v feed sent back to Node1 barionet device';
 #this is handles in security_alarms.pl as it is a security problem primary
 $gate_24V-> tie_event('&Notify_gate_24V("$state")');

$gate_24V_LastTest = new Generic_Item;
set $gate_24V_LastTest time if state $gate_24V_LastTest eq "";

$gate_ano_24V = new Generic_Item;     # actual anologue value'


#  inputs not used yet jan 2008

#$BarioNet_ba1_IN4 = new Generic_Item;
#set_states $BarioNet_ba1_IN4 split ',',$BarioNET_IN_states;



$v_test_client2 = new  Voice_Cmd("blip relay 1");
set $BarioNET_TCPctrl "setio,2,30"  if  said $v_test_client2;

$v_get_Outside_temp = new  Voice_Cmd("Get Outside Temperature");
 if  (said $v_get_Outside_temp){
	 $Temperature_entry="No Barionet detected at Node1"; # set silly value to detect none read
	 set $BarioNET_TCPctrl "getio,601"
 }




$v_reboot_Barionet = new Voice_Cmd("Reboot BarioNET");
 
if( said $v_reboot_Barionet){
  my $html = get 'http://192.168.1.21/setup.cgi?L=uireboot2.html';
 	print_log $html;
  my  $timer = new Timer;
  set $timer 12,sub {&restart_Barionet_TCP};
  # set  $LincLocatorSearchTimer 30, sub{$LL_seq = 1};
}



if ($Reload or $Startup){

 &open_TCP_to_Barionet_CTRL;
 
 set $Barionet_NODE1_found 600,sub{
				 &open_TCP_to_Barionet_CTRL
					 }
}


my $BarioNET_TCPctrl_address = '192.168.1.21:9010'; 

$BarioNET_TCPctrl = new  Socket_Item(undef, undef, $BarioNET_TCPctrl_address, 'BarioNETctrl','tcp','raw',"\r\n");



#$BarioNET_TCPctrl -> add ('data to send ','state');
#

# relays
#
#
#$Gate_position_status
#



#Relays

$BarioNET_TCPctrl -> add ('setio,1,1','safe gate Emergency SW');
$BarioNET_TCPctrl -> add ('setio,1,0','bypass gate Emergency SW');   # shorts terminal 2 & 8 on Q60 gate board


$BarioNET_TCPctrl -> add ('setio,2,1','GateAccessON');
$BarioNET_TCPctrl -> add ('setio,2,0','GateAccessOFF');
$BarioNET_TCPctrl -> add ('setio,2,5','Gateopen');


#outputs
#

$BarioNET_TCPctrl -> add ('setio,101,1','Out1hi');
$BarioNET_TCPctrl -> add ('setio,101,0','Out1lo');
$BarioNET_TCPctrl -> add ('setio,101,9999','Out1toggle');


$BarioNET_TCPctrl -> add ('setio,102,1','Out2hi');
$BarioNET_TCPctrl -> add ('setio,102,0','Out2lo');
$BarioNET_TCPctrl -> add ('setio,102,9999','Out2toggle');


$BarioNET_TCPctrl -> add ('setio,103,1','Out3hi');
$BarioNET_TCPctrl -> add ('setio,103,0','Out3lo');
$BarioNET_TCPctrl -> add ('setio,103,9999','Out3toggle');


$BarioNET_TCPctrl -> add ('setio,104,1','Out3hi');
$BarioNET_TCPctrl -> add ('setio,104,0','Out3lo');


$BarioNET_TCPctrl -> add ('getio,601','GetTempAtEntry');
$BarioNET_TCPctrl -> add ('getio,602','GetTempAtExit');

# force a read of gate motor voltage
#

$BarioNET_TCPctrl -> add ('getio,504','GetGateMotorVolts');



#-------------------------------------------------------------------------------------------------	 

 #  port for the direct control of inputs outputs etc
 #            .....................
 
sub open_TCP_to_Barionet_CTRL{
stop $BarioNET_TCPctrl if active $BarioNET_TCPctrl;

print_log "opening Barionet TCP ctrl por for Node 1";

start $BarioNET_TCPctrl;
		 
}   # end open tcp conns to barionet


# force a read of the temperature at the gate every 3 mins to check coms to the Node1 barionet is OK

if (new_minute 3 ){
	set $BarioNET_TCPctrl "getio,601";
	set $BarioNET_TCPctrl "getio,504"
}




#--------------------------------------------------------------------------------------------------

    # read and proccess the  control message from the barionet
    #
    #
    
my $bndata; 
if ($New_Second and active $BarioNET_TCPctrl and ($state = said $BarioNET_TCPctrl))  {                   # loop thru until no more data recieved.
	#print_log "''''''''''''''''''''''''''''''' TCP ctrl socket data: $state\n";
	 # loop around until all data read is processed.
 set $Barionet_NODE1_found 600,sub{
	             print_log "no data recieved from Node 1 barionet in the last 19 minutes so trying restart of TCP";
				 speak "Warning Node 0 is missing of the network, The gate and the field alarm may not be working";
				 &open_TCP_to_Barionet_CTRL
					 };
 $bndata=$state;
      while($bndata ne ""){
	     
	if ( $bndata=~/(\w+),(\d+),(-*\d+)/){
		$bndata=$';   #  put the left overs into $bndata
		# print_log 'descending data left in $bndata ='.$bndata;
	     my	$type=$1;
             my	 $loc=$2;
       	     my	 $value=$3;

#	print_log "Type= ".$type."  location=" . $loc." value=".$value;
#	       $type can be 'statechange' or 'state'



   			 if ($loc == 1){
	   
	  	 	 #    print_log "Relay A changed state";
   				 if ($value == 1 ){set $Gate_emergency_sw_status 'ByPassed';
					 print_log "Gate safety switch is set to ByPassed"

              				 }else{
						 print_log "Gate Safety Switch is SAFE";
		      			 set $Gate_emergency_sw_status 'SAFE'}
                 				}


    			if ($loc== 2){
	  			  #print_log "Relay B changed state";
   				 if ($value == 1  ){
					
	                 		set $BarioNet_ba1_gate_access 'lo'
					 }else {
					 # print_log"set hi";
	                 		set $BarioNet_ba1_gate_access 'hi'}
                			 }


  			 if ($loc== 101){
			    #print_log "s";
   				 if ($value == 1  ){
					 
	                		 set $BarioNet_ba1_OUT1 'on'
					 }else {
	               			  set $BarioNet_ba1_OUT1 'off'}
                			 }

  			if ($loc== 102){
	   			 #print_log "output 2";
   				 if ($value == 1  ){
	                		 set $BarioNet_ba1_OUT2 'on'
					 }else {
	                		 set $BarioNet_ba1_OUT2 'off'}
                			 }

  			if ($loc== 103){
	  			  #print_log "output 3";
   				 if ($value == 1  ){
	                		 set $BarioNet_ba1_OUT3 'on'
		 			}else {
	                 		set $BarioNet_ba1_OUT3 'off'}
                			 }

 			if ($loc== 104){
	   			 #print_log "output 4";
				 # OUT 4 
    				if ($value == 1  ){
				  		        set $BarioNet_ba1_OUT4 'on'
		 			}else {
	                 		set $BarioNet_ba1_OUT4 'off'}
                			 }

# state of the inputs inputs now dealt with


			 if ($loc== 201){
			    #print_log "Input 1";
  				  if ($value == 1  ){
	               			 if ( $Alarm_Underground_Ch1_Alarm ne 'ok'){ set  $Alarm_Underground_Ch1_Alarm 'ok'} 
					 }else {
                       			 if ( $Alarm_Underground_Ch1_Alarm ne 'alarm'){ set  $Alarm_Underground_Ch1_Alarm 'alarm'}

					 }
					 # print_log " Ch1 undeground alarm state ".state $Alarm_Underground_Ch1_Alarm;
                		 }


			 if ($loc== 202){
				 #print_log "Input 2";
   				 if ($value == 1  ){
	                		 if ( $Alarm_Underground_Ch2_Alarm ne 'ok'){ set $Alarm_Underground_Ch2_Alarm 'ok'}
					 }else {
                       			  if ( $Alarm_Underground_Ch2_Alarm ne 'alarm'){ set $Alarm_Underground_Ch2_Alarm 'alarm'}

					 }
					 #	 print_log " Ch2 undeground alarm state ".state $Alarm_Underground_Ch2_Alarm;
                		 }

			 if ($loc== 203){
	   			 #print_log "Input 3";
   				 if ($value == 1  ){

		     				set $Alarm_Underground_Ch1_Pressure 'ok' if state $Alarm_Underground_Ch1_Pressure ne 'ok'
	    		 }else{
		    				 set $Alarm_Underground_Ch1_Pressure 'fault' if state $Alarm_Underground_Ch1_Pressure ne 'fault'

				 }  



					#	print_log " Radar ".state $Alarm_Underground_Ch1_Pressure;
                }

			  if ($loc== 504){            #($loc== 204){  ANO 4 input  0-1023  520 = 28V = 0.054 counts /V
			  											# so @ 20V =370   which we alarm at
				    set $gate_ano_24V $value * 0.054; 
		    		print_log "Gate volts ".state $gate_ano_24V ;#. "Value is $value";
					
					if ($value < 370  ){

					# uses timers to stop bad/dirty power estartes making MH report on, off again and again 
						print_log"POWER failure at gate Motor";
						if (inactive $tmr_24V_Buffer_off){
							unset $tmr_24V_Buffer_on;
					        	set $tmr_24V_Buffer_off 30, sub {
									if (state $gate_24V ne "off"){set $gate_24V 'off'}
								}
								 
							}
					 }else{
					 	 print_log"Power at Gate motor Ok";	
				   if (inactive $tmr_24V_Buffer_on){
						unset $tmr_24V_Buffer_off ;
					 	set $tmr_24V_Buffer_on 30,sub {
					 						if (state $gate_24V ne "on"){set $gate_24V 'on'}
					 								}
						
							}
					}
							
				}









#     gate can be Open,Closed,In_middle,Fault


			 if ($loc== 205){
	  			  print_log "Input 5 Gate OPEN switch";
   				 if ($value == 1  ){
						   print_log "gate is fully OPEN";
						# if the closed switch is hi the it must be fault
							if (inactive $tmr_safe_Gate_opened_by_MH){
                                     &Notify_Gate_Attack_Alarm;   # the gate must have not been opened by MH, ie broken into
      						     }

						    if (state $BarioNet_ba1_gate_closed eq 'hi'){
								set $Gate_position_status 'fault';

							}else{
                              set $Gate_position_status 'open'

							} 
							set $BarioNet_ba1_gate_open 'hi'

					 }else {
						if (state $BarioNet_ba1_gate_closed eq 'lo'){
								set $Gate_position_status 'middle'
							}else{
                              set $Gate_position_status 'fault'   # if the gate sclosed switch is high and open just changed then must a fault'

							    } 
	                		 set $BarioNet_ba1_gate_open 'lo'
							}
                 	}

			 if ($loc== 206){
				  print_log "Input 6 gate closed switch";
    				if ($value == 1  ){
						    if (state $BarioNet_ba1_gate_open eq 'hi'){
								set $Gate_position_status 'fault'
							}else{
                              set $Gate_position_status 'closed'

							} 

					     print_log "gate is fully CLOSED";
	                 	 set $BarioNet_ba1_gate_closed 'hi'
					 }else {
						 	if (state $BarioNet_ba1_gate_open eq 'lo'){
								set $Gate_position_status 'middle'
							}else{
                               set $Gate_position_status 'fault'   # if the gate sclosed switch is high and open just changed then must a fault'

							    } 

                          if (inactive $tmr_safe_Gate_opened_by_MH){
                              &Notify_Gate_Attack_Alarm;   # the gate must have not benn opened by MH, ie broken

						  }
					      print_log "gate is NOT fully closed";
				
				          set $BarioNet_ba1_gate_closed 'lo'
						}
                	}
                                             


			 if ($loc== 207){
	   			 #print_log "Input7";
   				 if ($value == 0  ){
						 print_log"Stables smoke alarm : OK";
					   	 set $Smoke_Stables_Alarm  'ok' if state $Smoke_Stables_Alarm ne 'ok'
	                 		
					 }else {
						 print_log"Stables smoke alarm : ALARM";
	                 			set $Smoke_Stables_Alarm 'alarm' if state $Smoke_Stables_Alarm ne 'alarm'
				        }
                			 }

		

			if ($loc== 208){
				# print_log "Input 8";
   				 if ($value == 1  ){
					 if (state $gate_Emergency_STOP_sw eq 'not pushed'){&send_SMS_to_all( "Gate Emergency Switch has just been pushed")};
					 print_log"Gate emergency Switch PUSHED";
	                		 set $gate_Emergency_STOP_sw  'pushed'
					 }else {
				         if (state $gate_Emergency_STOP_sw eq 'pushed'){&send_SMS_to_all( "Gate Emergency Switch has just been Released")};
					print_log"Gate emergency Switch NOT pushed";
	                		 set $gate_Emergency_STOP_sw  'not pushed'}
    				 }

				 #-------------------------------------------------------------------
				 #
				 #------------new sensors added to the barionet in NODE1 by the RX8 module
				 # uses MODBUS on the barionet to communicate with RX8 then adds
				 #  211 > 218 as input ports for notification
				 #	 set $Alarm_Underground_sys1_Tamper 'no';
				 #	 set $Alarm_Underground_Ch1_Pressure 'ok';
				 #	 set $Alarm_Radar_paddock_Tamper 'no';
				 set $Alarm_ToolShed_Tamper 'no' if state $Alarm_ToolShed_Tamper  ne 'no';
				 set $Alarm_Stables_Tamper 'no' if state  $Alarm_Stables_Tamper ne 'no';

				 #	 set $Alarm_Stables_Alarm 'ok'; # or ok
				 #	 set $Alarm_ToolShed_Alarm 'ok'; # or ok
				 #	 set $Smoke_ToolShed_Alarm 'ok';
				 #	 set $Smoke_Stables_Alarm 'ok';
				 #	 set $Alarm_Underground_Ch1_PreAlarm 'no';
				 #	 set $Alarm_Underground_Ch2_PreAlarm 'no';
	   
 #  Digital temp sensors
 #  add a bit of code to put inthe average temp of the two as long
 #  as the difference between them is not > 3 degs
 #
			if ($loc == 601){

          			 if ($value ne 4096){
		 			 if( $value<2001 ){
			  			$Temperature_entry=$value/16
		  				}  else {
			     			 $Temperature_entry=((65535-$value)/16) * -1
		      					}
	   
							 print_log "temperature at gate entry ". $Temperature_entry;

							if (state $T_entryGEN ne $Temperature_entry or time_idle $T_entryGEN_last '20 '){set $T_entryGEN_last state $T_entryGEN}; 
							set $T_entryGEN $Temperature_entry;
						}else{
						       	$Temperature_entry="Barionet gave a reading but temp sensor faulty"
							# this puts 100 deg to indicate an error
						}

			}

			if ($loc== 602){
          			 if ( $value ne 4096 ){
		  	  		if( $value<2001 ){
				  		$Temperature_exit=$value/16
			 			 } else {
			     			 $Temperature_exit=((65535-$value)/16)*-1
		     				 } 
		      
		      #  print_log "temp at exit ". $Temperature_exit
					}


			}

	}else {
		$bndata=""
	}
      } # end while loop
    }     # end of reading ctrl tcp port data


   

  

    #-------------------------------------------------------------------------------

sub Gate_status{

}

$CodeTimings::CodeTimings{'NODE_1_Stables_BarioNET_VTRL End'} = time();






















