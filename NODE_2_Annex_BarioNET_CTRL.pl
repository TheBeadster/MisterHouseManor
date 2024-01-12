# Category = BarioNET
#

$CodeTimings::CodeTimings{'NODE_2_Annex_BarioNET_CTRL Start'} = time();

#########################################################################
# 									#
#              		 BARIOnet interface for Annex and heating       #
#									#
#            		 see www.Barix.com				#
#									#
#	
#			update dec 2009					#
#									#	
#########################################################################

# update for new alarm system feb 2010

#@   this controls Comms between the Barionet device named 'ba2' by me  IP static at 192.168.1.201  : port 9010
#@  Located in the annex plant room
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
#					talks to a touch pads which are linklocators
#					      see linklocator files/details
#					         Archive\HomeAutomation\other\link locator for ibutton touch pad manual.pdf 
#			t
#
#					         anymore that might need addding  
#        Dinputs        1-4 are analog 5-8 are digital
#        		:	1 - 220v supply uses a 220v coil relay to detect power supply before the UPS
#        			2-  Office alarm
#        			3 - Annex smoke alarms all
#        			4 - not used
#        			5 - Annex Flat alarm
#        			6 - Workshop Alarm
#        			7 - PIR alarms tamper
#        			8 - GSHP water pump detect is running
#
#        			pin 9 is common , if inputs on 5-8 are over 5v then analogues might not work see data sheets
#
#        outputs                pin10-13 digit outputs : all control relays in the AUX consumer unit
#                               10  : oil boiler relay
#                               11  : Annex DHW relay
#                               12  :  water heater , for annex hot water,via relay in aux consumer unit(Jun 2014 on)
#                               13  : Ground source heat pump relay
#
#                               pin 14 is common for outputs
#
#        Relay A 		Front door latch open
#              B               
#
#        ibutton temps           7 x ibutton temps   read values and average them in Mh, to get correct outside air temp
#                                                   which is used by heating in house to set temps
#
#                                temp sensors varies over heating system in annex 
#
#                                The ibuttons get rearanged by the barionet after a reset/pwr cycle.
#                                so we have to read them in one by one and allocate them to the right sensor,
#                                I call then T1-7
#                                goto ini editor in MH to change ibutton serial number.
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
# testing cortana







# sub web_func1 {
 #    return "uptime = " . &time_diff($Time_Startup_time,$Time , undef, 'numeric');
 # }

 # sub web_func2 {
  #   my ($arg1, $arg2) = @_;
  #   return "results from function 2: $arg1, $arg2";
 # }


#my $TimeTest = timelocal( $Second,$Minute,0,1,1,$Year) if lc($config_parms{debug}) =~ /barionet/;



our  ($Temperature_ZoeRoom,$Temperature_XXX,$iButtonDataBA2,$LL_seqBA2);
my $IbutTemp;
my $NumAnnexTempSensors = $config_parms{Number_Of_Annex_Temp_Sensors};
my (%BarioTempIDs,%BarioTempIds_to_Tx);
my  $tmr_Annex_Smoke_debounce = new Timer;
my  $tmr_BarioNET_TEST_Exist = new Timer;
my  $tmr_temperatureReadDelay = new Timer;
#my $BarioNET_OUT_states = 'on,off';
#my $BarioNET_IN_states ="hi,lo"; 

# all declared in temperatures.pl from aug 2014

#$T_AnnexRoom_GEN = new Generic_Item;				#T7 sensor
#$T_GSHP_OWT_GEN = new Generic_Item;				#T5 sensor
#$T_OilBoiler_OWT_GEN = new Generic_Item;			#T6 sensor
#$T_HeatStore_Upper_GEN = new Generic_Item;			#T8 sensor
#$T_HeatStore_Lower_GEN = new Generic_Item;			#T9 sensor
#$T_House_cold_return_GEN = new Generic_Item;		        #T4 sensor

#$T_GSHP_to_GroundLoop_GEN = new Generic_Item;			#T? sensor
#$T_GroundLoop_Return_Circuit_One_GEN = new Generic_Item;	#T? sensor
#$T_GroundLoop_Return_Circuit_Two_GEN = new Generic_Item;	#T? sensor


#these two are not really needed, as they should be the same as the heatstore lower sensor
#
#$T_GSHP_IWT_GEN = new Generic_Item;			 	#T? sensor

#$T_OilBoiler_IWT_GEN = new Generic_Item;			#T? sensor






$Status_Oil_Boiler = new Generic_Item;   				# barionet out 1
set_states $Status_Oil_Boiler split ',',$BarioNET_OUT_states;
set_info $Status_Oil_Boiler 'status of Oil Boiler status as read from Barionet';
#$Status_Oil_Boiler -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log","Oil Boiler now $state  setpoint ".state $T_oil_boilerSetpoint ." and heatstore avg ". state $T_HHS)');


$Status_Annex_DHW = new Generic_Item;	# barionet out 2
set_states $Status_Annex_DHW split ',',$BarioNET_OUT_states;
set_info $Status_Annex_DHW 'status Annex electric Hot water heater as red from Barionet';

$Status_Annex_Heating_pump = new Generic_Item;	# barionet out 3
set_states $Status_Annex_Heating_pump split ',',$BarioNET_OUT_states;
set_info $Status_Annex_Heating_pump 'Satus of Annex Heating pump as read from Barionet';

$Status_GSHP = new Generic_Item;	# barionet out 4
set_states $Status_GSHP split ',',$BarioNET_OUT_states;
set_info $Status_GSHP 'Status of Ground Source Heat Pump as read from Barionet';


# not used after buffer tank fitted in 2014

$Status_GSHP_internal_pump = new Generic_Item;
set_states $Status_GSHP_internal_pump split ',',$BarioNET_OUT_states;
set_info $Status_GSHP_internal_pump 'signal from GSHP interior pump signal, show GSHP is actually running';

# Workshop/annex  Smoke alarms dealt with in Alarms_smoke.pl
#

$BarioNet_ba2_IN8 = new Generic_Item;
set_states $BarioNet_ba2_IN8 split ',',$BarioNET_IN_states;

#  inputs not used yet jan 2010, but allocated see above

$BarioNet_BA2_IN4 = new Generic_Item;
set_states $BarioNet_BA2_IN4 split ',',$BarioNET_IN_states;



$V_open_Annex_door = new  Voice_Cmd("Open Annex door");
$V_open_Annex_door -> set_authority('anyone');   # this has password bypass for anyone to open it who know the ia5gate.htm URL

set $BarioNET_BA2_TCPctrl "setio,1,60"  if  said $V_open_Annex_door;

$v_test_client2_BA2 = new  Voice_Cmd("blip relay 2 in annex");
set $BarioNET_BA2_TCPctrl "setio,2,60"  if  said $v_test_client2_BA2;

#-----------------------------------------------------------------------------------------------------

sub open_the_annex {
	my $itWas = shift;
	set $BarioNET_BA2_TCPctrl "setio,1,60" ;
   	logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Annex door opened from Web App by $itWas");
	print_log "Annex door  opening , web app by $itWas";
	return "The annex door is unlocked for 60 seconds"
} # end open annex






$v_reboot_Barionet2 = new Voice_Cmd("Reboot BarioNET in Annex Node 2");
 
if( said $v_reboot_Barionet){
  my $html = get 'http://192.168.1.22/setup.cgi?L=uireboot2.html';
 	print_log $html;
  my  $timer2 = new Timer;
  set $timer2 12,sub {&restart_BA2_Barionet_TCP};

}

if ($Reload or $Startup){

 &open_TCP_to_Barionet_BA2_CTRL;
 
 }

 if ($Startup){

 
 &reset_temps
 }



 


my $BarioNET_BA2_TCPctrl_address = '192.168.1.22:9010'; 

$BarioNET_BA2_TCPctrl = new  Socket_Item(undef, undef, $BarioNET_BA2_TCPctrl_address, 'BarioNETctrl_BA2','tcp','raw',"\r\n");



#$BarioNET_TCPctrl -> add ('data to send ','state');
#

# relays
#
#


$BarioNET_BA2_TCPctrl -> add ('setio,1,0','OpenFrontDoor');

$BarioNET_BA2_TCPctrl -> add ('setio,1,1','LockFrontDoor');

$BarioNET_BA2_TCPctrl -> add ('setio,2,1','NOT used ON OCT 2014');

$BarioNET_BA2_TCPctrl -> add ('setio,2,0','NOT used OFF OCT 2014');


#outputs
#



$BarioNET_BA2_TCPctrl -> add ('setio,102,1','GSHP_on');
$BarioNET_BA2_TCPctrl -> add ('setio,102,0','GSHP_off');

$BarioNET_BA2_TCPctrl -> add ('setio,101,1','Annex Heating on');
$BarioNET_BA2_TCPctrl -> add ('setio,101,0','Annex Heating off');

$BarioNET_BA2_TCPctrl -> add ('setio,103,1','Oil_Boiler_on');
$BarioNET_BA2_TCPctrl -> add ('setio,103,0','Oil_Boiler_off');

$BarioNET_BA2_TCPctrl -> add ('setio,104,1','AnnexDHW_on');
$BarioNET_BA2_TCPctrl -> add ('setio,104,0','AnnexDHW_off');





# auto treport to the print log what was sent to the Annex barionet

$BarioNET_BA2_TCPctrl -> tie_event('print_log "Barionet Annex TCP control set to $state"');	 

 #  port for the direct control of inputs outputs etc
 #            .....................
 
sub open_TCP_to_Barionet_BA2_CTRL{
		stop $BarioNET_BA2_TCPctrl if active $BarioNET_BA2_TCPctrl;

		print_log "opening Barionet in Annex Node 2 TCP ctrl port";

		start $BarioNET_BA2_TCPctrl;

		# reset all temps to error at start
		for (keys %BarioTempIDs){
			$BarioTempIDs{$_} = 255
         	 }
 		 # get the unique Id s of the temp sensors and populate the %BarioTempIds_to_Tx hash
  
		set $BarioNET_BA2_TCPctrl "getio,651";
# Aug 2019
# added restart the Annex 2 serial to this code
         &restart_Barionet_TCP_Annex ;

}   # end open tcp conns to barionet


if (inactive_now $BarioNET_BA2_TCPctrl ){set $BarioNET2_Exists 'alarm'}
	if (active $BarioNET_BA2_TCPctrl and $BarioNET2_Exists ne 'ok') {
		set $BarioNET2_Exists 'ok';
			set $BarioNET2_Exists_LastTest time
}


if ($New_Second and new_second 120){

	set $BarioNET_BA2_TCPctrl "getio,601";
};
if ($New_Second and new_second 130){

	set $BarioNET_BA2_TCPctrl "getio,1";

	# see if barionet is still alive if not try to restart comms
    #the end of the temp routine sens 
    # set $BarioNET_BA2_TCPctrl "getio,649";
	# this sensor doesnt exist and the barix will reply wto say so
	# we use this reply to rest the timer that restarts the comms
	# is a 'IS it alive ping''

	    set $tmr_BarioNET_TEST_Exist 60,sub{
		    &open_TCP_to_Barionet_BA2_CTRL
	}
	}

#--------------------------------------------------------------------------------------------------

    # read and proccess the  control message from the barionet
    #
    #
    
my $bn2_data; 
if ($New_Second and active $BarioNET_BA2_TCPctrl and ($state = said $BarioNET_BA2_TCPctrl) )  {  
	# loop thru until no more data recieved.
    #print_log "TCP ctrl socket data for BarioNEt 2: $state\n";
	# loop around until all data read is processed.
  	$CodeTimings::CodeTimings{'Read_annex_bario_data Start'} = time();
 	$bn2_data= $bn2_data.$state;
    while($bn2_data ne ""){
	     
		if ( $bn2_data=~/(state\w*),(\d+),(-*\d+)/){

			#	 print_log 'Annex bario CTRL, data left in $bn2_data ='.$bn2_data;
			
			my	$type=$1;
			my	 $loc=$2;
			my	 $value=$3;
			logit("$config_parms{data_dir}/BarioNet201 Debug.log","\tType= ".$type."   \t  location=" . $loc."\t value=".$value."   \tRAW ". $bn2_data);
			$bn2_data = $';   #  put the left overs into $bn2_data
			# print_log "BA2 Type= ".$type."  location=" . $loc." value=".$value;
			#$type can be 'statechange' or 'state'



			if ($loc == 1){
	   
				#    print_log "Relay A changed state";
				# do whatever we need if the relay is ever used it is also used to ping the barix
				# if there is no reply after 25 seconds then the comms to 
				# the annex is rebooted
                print_log "Relay Annex 1 tested OK, cancel annex comms restart ";

				unset $tmr_BarioNET_TEST_Exist
			 }
			 if ($loc == 2){
				 # this is for the web page to show the real state of the bario relay 
				 print_log "Relay Annex DHW changed state ";
				  if ($value == 1  ){
					
				  	   set $Status_Annex_DHW 'On'
				  		 } else {
					     print_log "Off";
					     set $Status_Annex_DHW 'Off'
					}
					 }


  			 if ($loc== 103){
			    #print_log "s";
   				 if ($value == 1  ){
					 	#print_log "Oil boiler is ON";					 
	                		  if (state  $Status_Oil_Boiler ne 'on'){set $Status_Oil_Boiler 'on'}
					 }else {
						 	#print_log "Oil Boiler is OFF";	               			  
					 if (state  $Status_Oil_Boiler ne 'off'){set $Status_Oil_Boiler 'off'}
					 }
                			 }

  			if ($loc== 104){
	   			 #print_log "output 2";
   				 if ($value == 1  ){
					 #	 print_log "Annex DHW is ON";
	                		if ($Status_Annex_DHW ne 'on'){set $Status_Annex_DHW 'on'}
					 }else {
						 #	print_log "Annex DHW is OFF";						 
	                		if ($Status_Annex_DHW ne 'off'){ set $Status_Annex_DHW 'off'}
			              	}
                			 }

  			if ($loc== 101){
	  			  #print_log "output 3";
   				 if ($value == 1  ){
					 #	print_log "Annex Heating is ON";		$Status_Annex_Heating_pump			 
	                	 if (state $Status_Annex_Heating_pump ne 'on'){ set $Status_Annex_Heating_pump 'on'}
		 			}else {
						#	print_log "Annex Heating is OFF";
	                 	 if(state $Status_Annex_Heating_pump ne 'off'){set $Status_Annex_Heating_pump 'off'}
				
				}
                			 }

 			if ($loc== 102){

    				if ($value == 1  ){
					#	print_log "GSHP is on";
	                 	if(state  $Status_GSHP ne 'on'){set $Status_GSHP 'on'}
		 			}else {
						#		print_log "GSHP is OFF";
	                	 if (state  $Status_GSHP ne 'off'){ set $Status_GSHP 'off'}
                			 }
				 }
# state of the inputs inputs now dealt with


			  if ($loc == 201){
					unset $tmr_BarioNET_TEST_Exist;  # barionet is alive so stop the reset 
			        
			 	   if ($value == 1  ){
					 if (state $Mains_220V_Workshop_Annex ne 'off'){ set  $Mains_220V_Workshop_Annex 'off'}
			    			 }else {
			     		 if (state $Mains_220V_Workshop_Annex ne 'on'){set  $Mains_220V_Workshop_Annex 'on'}

			    			 }
					 }
				
			 if ($loc == 202){
					unset $tmr_BarioNET_TEST_Exist;  # barionet is alive so stop the reset 
			        
				   #print_log "office Alarm";
			    		  if ($value == 1  ){
				if (state $Alarm_Annex_Office_Alarm ne 'ok' ){set $Alarm_Annex_Office_Alarm 'ok'}
			    			 
				}else {
			     	if (state $Alarm_Annex_Office_Alarm ne 'alarm' ){set $Alarm_Annex_Office_Alarm 'alarm'}
			    
			    			 }
					 }

					 # Annex smoke alarm

			 if ($loc == 203){
					unset $tmr_BarioNET_TEST_Exist;  # barionet is alive so stop the reset 

			    		  if ($value == 1  ){
						  ##  logit("$config_parms{data_dir}/BarioNet201 Debug.log",  "SMOKE ALARM +++++++++++++++++++++++++++  \n");
						  # test if the smoke alarm is still active after 5 seconds to make sure
						 	if (state $Smoke_Workshop_Annex ne 'alarm' ){
								print_log "Smoke alarm annex alarm";
								set $Smoke_Workshop_Annex "alarm";
								set $tmr_Annex_Smoke_debounce 10, 'set $Smoke_Workshop_Annex "alarm"';									
								       # if the smoke alarm foesnt reset within 2 seconds then the alarm is triggered	
											

								}
						  
					
					}else {
						
			     			if (state $Smoke_Workshop_Annex ne 'ok'  ){
									print_log "Smoke alarm annex OK";	
									set $Smoke_Workshop_Annex 'ok'
										}
			    			set $tmr_Annex_Smoke_debounce 0; # the smoke alarm must of gone hi low in less than 3 seconds so it must be a spike
						#	'	logit("$config_parms{data_dir}/BarioNet201 Debug.log",  "SMOKE ALARM UNSET ----------------------------  \n");
			    			 }
					 }







			 if ($loc == 205){
				 #	   print_log "Annex Flat Alarm";
			    		  if ($value == 1  ){
				if (state $Alarm_Annex_Flat_Alarm ne 'ok' ){set $Alarm_Annex_Flat_Alarm 'ok'}
			    			 
				}else {
			     	if (state $Alarm_Annex_Flat_Alarm ne 'alarm' ){set $Alarm_Annex_Flat_Alarm 'alarm'}
			    
			    			 }
					 }

			 if ($loc == 206){
				 # print_log "Workshop Alarm";
			    		  if ($value == 1  ){
				if (state $Alarm_Annex_Workshop_Alarm ne 'ok' ){set $Alarm_Annex_Workshop_Alarm 'ok'}
			    			 
				}else {
			     	if (state $Alarm_Annex_Workshop_Alarm ne 'alarm' ){set $Alarm_Annex_Workshop_Alarm 'alarm'}
			    
			    			 }
					 }
			 if ($loc == 207){
				 #   print_log "Annex alarm Tamper or Fault";
			    		  if ($value == 1  ){
				if (state $Alarm_Annex_Tamper_or_Fault ne 'ok' ){set $Alarm_Annex_Tamper_or_Fault 'ok'}
			    			 
				}else {
			     	if (state $Alarm_Annex_Tamper_or_Fault ne 'fault' ){set $Alarm_Annex_Tamper_or_Fault 'fault'}
			    
			    			 }
					 }


				       
		          if ($loc == 208){
				  #  print_log "Ground source heat pump is";
			    		  if ($value == 1  ){
				if (state $Status_GSHP_internal_pump ne 'off'){ set $Status_GSHP_internal_pump 'off'}
			    			 
				}else {
			     	if (state $Status_GSHP_internal_pump ne 'on'){ set $Status_GSHP_internal_pump 'on'}

			    			 }		
				
					 }
 
	   
 #  Digital temp sensors
 #  add a bit of code to put in the average temp of the two as long
 #  as the difference between them is not > 3 degs
 #now puts temps into $Annex_Temps[$loc-600,1]
 # # I have used hashes, one for the temps and one for the x ref to the T? sesnors id
my $temp_temp;
            if ($loc >= 601 and $loc <= (600 + $NumAnnexTempSensors) ){
                     
			if ($value ne 4096){
		 	          if( $value<2001 ){
			           	 $temp_temp = $value/16
		  	    }  else {
			       		$temp_temp=((65535-$value)/16) * -1
		      			}
			}else{
			      	$temp_temp = 255;
			 }
                          
                        if( $temp_temp  < 85  and $temp_temp > -16){ 
				$BarioTempIDs{$loc} = $temp_temp
			}

			&Update_Annex_Temps;     # update the actual generic vars with temps
		        $loc = $loc + 1;   # set the next get io for the next sensor
	     	        set $BarioNET_BA2_TCPctrl "getio,$loc" if $loc <= (602 + $NumAnnexTempSensors)
 		       	
 
			}


			# set up the hashes for temps to ibuttons
			# this is done because the Barix reads the Ds1820 randomly
			# so we have to map them correctly as we read them from the barix
			
 	  if ($loc >= 651 and $loc <= (652 + $NumAnnexTempSensors) and $value ne 0 ){
			&Reconfig_val_Ib_addr($value);
		         my  $loc2 = $loc  - 50;

                            if (lc($config_parms{T1}) =~ /$IbutTemp/){
				    print_log" Found Ground loop return #1 temp sensor :".$IbutTemp; 
				    $BarioTempIds_to_Tx{$loc2}=1
			    		}
                            if (lc($config_parms{T2}) =~ /$IbutTemp/){
				print_log" Found Ground loop return #2 temp sensor :".$IbutTemp; 
				    $BarioTempIds_to_Tx{$loc2}=2
			   		 }
                            if (lc($config_parms{T3}) =~ /$IbutTemp/){
				    print_log" Found into ground from  GSHP :".$IbutTemp;
				    $BarioTempIds_to_Tx{$loc2}=3
			   		 }
                            if (lc($config_parms{T4}) =~ /$IbutTemp/){
				   print_log" Found House cold return temp sensor :".$IbutTemp;
				    $BarioTempIds_to_Tx{$loc2}=4
			   		 }
                            if (lc($config_parms{T5}) =~ /$IbutTemp/){
				   print_log" Found GSHP OWT temp sensor :".$IbutTemp;
				    $BarioTempIds_to_Tx{$loc2}=5
			   		 }
			    if (lc($config_parms{T6}) =~ /$IbutTemp/){
			    	    print_log" Found oil Boiler OWT temp sensor :".$IbutTemp;
			    		    $BarioTempIds_to_Tx{$loc2}=6
			    	    }
			    if (lc($config_parms{T7}) =~ /$IbutTemp/){
			    		    print_log" Found Annex flat temp sensor :".$IbutTemp;
			    	    $BarioTempIds_to_Tx{$loc2}=7
			       		}
			    if (lc($config_parms{T8}) =~ /$IbutTemp/){
			    		    print_log" Found heat store upper temp sensor :".$IbutTemp;
			    	    $BarioTempIds_to_Tx{$loc2}=8
			       		}

			    if (lc($config_parms{T9}) =~ /$IbutTemp/){
			    		    print_log" Found heat store lower temp sensor :".$IbutTemp;
			    	    $BarioTempIds_to_Tx{$loc2}=9
			       		}
			    if (lc($config_parms{T10}) =~ /$IbutTemp/){
			                    print_log" Found Annex ufloor return temp sensor :".$IbutTemp;
			    	    $BarioTempIds_to_Tx{$loc2}=10
			       		}

		        $loc = $loc + 1;   # set the next get io for the next sensor
	     	        set $BarioNET_BA2_TCPctrl "getio,$loc" if $loc <= (652 + $NumAnnexTempSensors);


			
                                
                   
 			}

		}else {
			$bn2_data=""
		}
    } # end while loop
 $CodeTimings::CodeTimings{'Read_annex_bario_data End'} = time();
}     # end of reading ctrl tcp port data

sub reset_temps {

   	set $T_GroundLoop_Return_Circuit_One_GEN  "error";
 	set $T_GroundLoop_Return_Circuit_Two_GEN  "error";
 	set $T_GSHP_IWT_GEN  "error";
	set $T_House_cold_return_GEN  "error";

 	set $T_GSHP_to_GroundLoop_GEN  "error";
 	set $T_GSHP_OWT_GEN  "error";
	set $T_OilBoiler_OWT_GEN  "error";
	set $T_AnnexRoom_GEN  "error";

	set $T_HeatStore_Upper_GEN  "error";
	set $T_HeatStore_Lower_GEN  "error";
        set $T_ANNEX_uFloor_Return "error";

}
	

sub Update_Annex_Temps {


	for (keys %BarioTempIDs){
		# print "Sensor id $_ and the value =".$BarioTempIDs{$_}."\n";
	#	#       values are the same as the T number in mh.private.ini  ie 1 = T1
		if ( $BarioTempIds_to_Tx{$_} == 1 ){  
			if(state $T_GroundLoop_Return_Circuit_One_GEN ne $BarioTempIDs{$_} or time_idle $T_GroundLoop_Return_Circuit_One_GEN_last '30 s' ){
				set $T_GroundLoop_Return_Circuit_One_GEN_last state $T_GroundLoop_Return_Circuit_One_GEN 
				};

			set $T_GroundLoop_Return_Circuit_One_GEN  $BarioTempIDs{$_}
			}
		if ( $BarioTempIds_to_Tx{$_} == 2 ){ 
			if(state $T_GroundLoop_Return_Circuit_Two_GEN ne $BarioTempIDs{$_} or time_idle $T_GroundLoop_Return_Circuit_Two_GEN_last '30 s'){
				set $T_GroundLoop_Return_Circuit_Two_GEN_last state $T_GroundLoop_Return_Circuit_Two_GEN 
				};
			set $T_GroundLoop_Return_Circuit_Two_GEN $BarioTempIDs{$_}
			}


		if ( $BarioTempIds_to_Tx{$_} == 3 ){ 
			if(state $T_GSHP_to_GroundLoop_GEN ne $BarioTempIDs{$_} or time_idle  $T_GSHP_to_GroundLoop_GEN_last   '30 s' ){
				set $T_GSHP_to_GroundLoop_GEN_last state $T_GSHP_to_GroundLoop_GEN
				};
			set $T_GSHP_to_GroundLoop_GEN $BarioTempIDs{$_}
			}

		if ( $BarioTempIds_to_Tx{$_} == 4 ){ 
			set $T_House_cold_return_GEN $BarioTempIDs{$_}
			}

			
		if ( $BarioTempIds_to_Tx{$_} == 5 ){ 
			if(state $T_GSHP_OWT_GEN ne $BarioTempIDs{$_} or time_idle   $T_GSHP_OWT_GEN_last  '30 s' ){
				set $T_GSHP_OWT_GEN_last state $T_GSHP_OWT_GEN
				};
				set $T_GSHP_OWT_GEN $BarioTempIDs{$_}
			}

		if ( $BarioTempIds_to_Tx{$_} == 6 ){ 
			# save old  temp if it has changed
			if (state $T_OilBoiler_OWT_GEN ne $BarioTempIDs{$_} or time_idle   $T_OilBoiler_OWT_GEN_last  '30 s'  ){
				set $T_OilBoiler_OWT_GEN_last state $T_OilBoiler_OWT_GEN
				};
			set $T_OilBoiler_OWT_GEN $BarioTempIDs{$_}
			}
		if ( $BarioTempIds_to_Tx{$_} == 7 ){  
			if (state $T_AnnexRoom_GEN ne $BarioTempIDs{$_}  or time_idle   $T_AnnexRoom_GEN_last  '30 s' ){
				set $T_AnnexRoom_GEN_last state $T_AnnexRoom_GEN};
			set $T_AnnexRoom_GEN $BarioTempIDs{$_};	# sensor sometimes error at 85
			#	print_log "ANNEX TEMP ~~~+++____   ".state $T_AnnexRoom_GEN;
				if (state $T_AnnexRoom_GEN gt '50'  ) {set $T_AnnexRoom_GEN  "1"};
			}

		if ( $BarioTempIds_to_Tx{$_} == 8 ){ 
			if (state $T_HeatStore_Upper_GEN ne $BarioTempIDs{$_}  or time_idle   $T_HeatStore_Upper_GEN_last  '30 s' ){
				set $T_HeatStore_Upper_GEN_last state $T_HeatStore_Upper_GEN
				};
				set $T_HeatStore_Upper_GEN $BarioTempIDs{$_}
				}
		if ( $BarioTempIds_to_Tx{$_} == 9 ){ 
			if (state $T_HeatStore_Lower_GEN ne $BarioTempIDs{$_} or time_idle  $T_HeatStore_Lower_GEN_last   '30 s'  ){
				set $T_HeatStore_Lower_GEN_last state $T_HeatStore_Lower_GEN
				};
			set $T_HeatStore_Lower_GEN $BarioTempIDs{$_}
			}
		if ( $BarioTempIds_to_Tx{$_} == 10 ){ 
			if (state $T_ANNEX_uFloor_Return ne $BarioTempIDs{$_} or time_idle  $T_ANNEX_uFloor_Return_last    '30 s'  ){
				set $T_ANNEX_uFloor_Return_last state $T_ANNEX_uFloor_Return
				};
			set $T_ANNEX_uFloor_Return $BarioTempIDs{$_}
			}
	}
	
	
#	set $T_AnnexRoom_GEN 10;  # TEMPORARY UNTIL SENSOR FIXED  

}
# end sub update annex temps

sub Reconfig_val_Ib_addr{
	$IbutTemp = shift;

	# the barionet sends the ibutton addres as a decimal number and only the first 4 bytes
	# 1st covert to hex,
	# then invert the bytes
	# ie 771246632 = 0x2DF84A28
	# treat as bytes 0x2D f8 4A 28      SWAP AROUND to 28 4A F8 2D
	#  this represent the first 4 bytes of the ibutton address. the 28 is the family and the 4a f8 2d
	#   are some of the address
	#
        $IbutTemp = sprintf("%x", $IbutTemp);
	$IbutTemp=~/(\w\w)(\w\w)(\w\w)(\w\w)/;
#	$IbutTemp=$4.$3.$2.$1 # dont swap around, changed mh.private.ini file, so that reading the ibuttons is easier.

#@Ibuttons for the sensors on thr Annex Barionet <br>
	#@ if you use the "temp" tab under sttings on the barionet <br>
	#@ then revers the bytes i.e.  <br>
	#@ 28 4A F8 2D 02 00 00 9E  becomes 9E 00 00 02 2D F8 4A 28 <BR>
	#@ with out spaces, put the value in the mh.private.ini <br>
	#@ found in c:\houseautomation\misterhouse\mh\bin 


}


$CodeTimings::CodeTimings{'NODE_2_Annex_BarioNET_CTRL End'} = time();

























