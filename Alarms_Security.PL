#category = Security
$CodeTimings::CodeTimings{'Alarms_Security Start'} = time();
=begin

	#####################################################################
	#                                                                   #
	#             Security intruder Alarm Module			    #
	#             							    #
	#             	Mike Jones Feb 2010				    #
	#             							    #
	#           SEE ALARM LAYOUTS IN MANOR TECHINICS webpage            #
	#                  click MyMh in top of misterhouse	            #
	#                                                                   #
	#                  handles all security alarms                      #
	#                   see AlarmsSmoke.pl for smoke alarms		    #
	#                                                                   #
	#                                                                   #
	#####################################################################

					README

  	Because the signals come in from many different hardware sources
 	The modules that handle the hardware change the respective "Generic items", 
        these Subroutines do the monitoring of the signals ,
	 handling what to do with the signal/state change is done here


	 the Barionet at Node 1 ( tack room) controls the UG alarms, stables and Tool shed,
                ( also controls the gate access but that is handled in GateControl.pl)
	the Barionet at Node 2 ( plant room) controls all things in the annex.
	Homevision controls all the main house internal signals  HomeVision.pl


	the alarm signal are grouped into 5 groups as of Feb 2010
              Field   : anything with the security of the field, gate, ug,radr
	      House   : securing the main house
	      annex   : securing the annex
	      stables : now just PIR is tack room
	      ToolShed: ex tiny's stable with Lawnmower in it.

	      these groups are used in the AlarmSmoke.pl mode as well

	  

        there are four parts to this module

         declarations  :Generic items declarations  : duh

	 Activation    : deals with which parts af the alarm are active and when
                       : also deals with inputs to activate and deactivate alarm
         
          System_test   : works out from current states if the system is Ok or Not

         Notification   : deals with who and how we are notified of the alarm
	                : ie internal on speakers or by sms or any other methods
                        : lights and other items are laso switched
                        : here, but check lights.pl also
     

=cut


##################################################################################

#######################################################################
#                                                                     #
#               Note          april 2022                              #
#      All declarations that are not local ie generics are now put in #
#                  the Declarations.pl module                         #
#            this is so modules can be disabled for testing           #
#                                                                     #
#######################################################################



my $Alarm_Control_States="active,idle";

my $Alarm_Control_States2="active,idle,T_idle";
my $System_States ="yes,no";
my $System_States2="ok,fault";


my $System_States3="on,off";
my $System_States4="ok,alarm";

my $tmr_backdoor = new Timer;
my $tmr_kitchen_lights = new Timer;
my $Ul_Al_state;
my $tmrShedPIR = new Timer          # keeps inside light on in the shed after \pir movement

$Timer_annex_delay = new Timer;     # re- arms the alarm after no movement in the annex for 30 mins
$Timer_workshop_delay   = new Timer;     #   if one of the big doors is opened, then you get 5 mins to touch a key on any of the pads.
my $floodtimer2 = new Timer;

$Tmr_TV_off_in_one_Minute = new Timer;   # used to turn TV of if no movement in living room
$Tmr_TV_off = new Timer ;                # same as above

# used to determine if a test is needed of a particular system
our $LastTest_Short = 12443;   # movement alarms  once a month
our $LastTest_Medium = 45678;  # smoke alarms   onve every 6 months
our $LastTest_Long =  78901;   # system , tampers , pressures etc once a year


# TEST TEST TEST TEST TEST LOG READER AND EMAILER
#
#
#report_weblog -mailto 'info@beady.com'  c:\houseautomation\misterhouse\mymh\data\log









 







# ---- system status generic item and test --------------------------------------



#test every day only
if ($New_Hour){
if(( &LastTester(state $Alarm_Underground_sys1_Tamper,12) eq '1') and (&LastTester(state $Alarm_Underground_sys1_Fault_LastTest,12) eq '1') and  (&LastTester(state $Alarm_Underground_Ch1_Alarm_LastTest,3) eq '1')and  (&LastTester(state $Alarm_Underground_Ch1_PreAlarm_LastTest,3) eq '1')and  (&LastTester(state $Alarm_Underground_Ch1_Pressure_LastTest,12) eq '1')and  (&LastTester(state $Alarm_Underground_Ch2_Alarm_LastTest,3) eq '1')and  (&LastTester(state $Alarm_Underground_Ch2_PreAlarm_LastTest,3) eq '1')and  (&LastTester(state $Alarm_Radar_paddock_Alarm_LastTest,3) eq '1')and  (&LastTester(state $Alarm_Radar_paddock_Tamper_LastTest,12) eq '1')){
        set $LastTestingBurglar 'ok'
	}else{
        set $LastTestingBurglar 'fault'
	}


	      
if ((&LastTester(state $Alarm_ToolShed_Alarm_LastTest,3) eq '1')and  (&LastTester(state $Alarm_ToolShed_Tamper_LastTest,12) eq '1')and  (&LastTester(state $Alarm_Stables_Alarm_LastTest,3) eq '1')and  (&LastTester(state $Alarm_Stables_Tamper_LastTest,12) eq '1')and  (&LastTester(state $Mains_220V_Workshop_Annex_LastTest,12) eq '1')and  (&LastTester(state $gate_24V_LastTest,12) eq '1') and  (&LastTester(state $Main_220V_power_status_LastTest,12) eq '1') and (state$LastTestingBurglar eq 'ok' )){

        set $LastTestingBurglar 'ok' if state $LastTestingBurglar ne 'fault'
	}else{
        set $LastTestingBurglar 'fault'
	}


if ( (&LastTester(state $Alarm_Underground_Ch1_Alarm_LastTest,0.03) ne '1') or (&LastTester(state $Alarm_Underground_Ch2_Alarm_LastTest,0.03) ne '1')){
	print_log "The underground alarm has not been tested within the last twenty four hours please check it it working"
	}
	



}	# end of hourly test	




if ((state $Alarm_Underground_sys1_Tamper ne 'no')  or (state $Alarm_Underground_Ch1_Pressure ne 'ok')  or (state $Alarm_Radar_paddock_Tamper ne 'no') or (state $Alarm_ToolShed_Tamper ne 'no')  or (state $Alarm_Stables_Tamper ne 'no') or (state $Alarm_Annex_Tamper_or_Fault ne 'ok')  or (state $gate_24V ne 'on') or (state $Node1_220V ne 'on') or (state $GSM_phoneStatus ne 'ok') or (state $Main_220V_power_status ne 'on') or (state $Mains_220V_Workshop_Annex ne 'on') or (state $BarioNET2_Exists ne 'ok')) {
#	    	     $als="UG tamper -".state $Alarm_Underground_sys1_Tamper." ug pressure -".state $Alarm_Underground_Ch1_Pressure." Radar tamper -".state $Alarm_Radar_paddock_Tamper." shed tamper- ".state $Alarm_ToolShed_Tamper." stables tamper -".state $Alarm_Stables_Tamper." 24v power gate- ".state $gate_24V." node1 220v -".state $Node1_220V." Gsm phone status -".state $GSM_phoneStatus." node 0 220v -".state $Main_220V_power_status." workshop 220v -".state $Mains_220V_Workshop_Annex;
#	     print_log "alarm status fault module at fault is  $als"; 

	     set $Alarm_System_Alarms  "fault" 
	}else{
	     set $Alarm_System_Alarms "ok"
	}


my $als;

if ((state $LastTestingSmoke eq 'ok') and (state $Alarm_System_Alarms eq 'ok') and (state $LastTestingBurglar eq 'ok')){

	     set $Alarm_System_Status  "ok" if state $Alarm_System_Status ne 'ok';
	}else{
	     set $Alarm_System_Status  "fault" if state $Alarm_System_Status ne 'fault';
	     #	     $als= "Smoke ".state $LastTestingSmoke." system ".state $Alarm_System_Alarms." lasttesting ".state $LastTestingBurglar;

	}



#------check Last Tested times -------------------------
	#
	# 3 months for Burglar alarms sensors  = 
	# 6 months for smoke alarms
	# 1 year for tampers, sytems, and powers
	#   1month = 2592000 seconds


# subr to see if a test of the system is needed yet, second param is how many months ----------------------





sub LastTester {
 my ($lastime,$howlong) = @_;
 my $Mon=2592000;           # 1 month of seconds , if try 0.33 then it tests for 1 day, used to check underground alarms
 if ((($lastime)+($howlong * $Mon) ) gt time){

			return 1
			}else{ 
			return -1
	         	}

}

# alarm history for web security page
# shows a stream of either A P or T or just .   if nothing

$security_Histogram_OneAcre  = new Generic_Item;
$security_Histogram_MainField  = new Generic_Item;
$security_Histogram_GateRadar  = new Generic_Item;
$security_Histogram_FieldRadar   = new Generic_Item;
$security_Histogram_MowerShed    = new Generic_Item;
$security_Histogram_Stables    = new Generic_Item;
$security_Histogram_Annex    = new Generic_Item;
$security_Histogram_Office   = new Generic_Item;
$security_Histogram_GateOpen   = new Generic_Item;
$security_Histogram_GateIR   = new Generic_Item;


if ($Reread){

    
	set	$security_Histogram_OneAcre  "S.........";
	set	$security_Histogram_MainField  "S.........";
	set	$security_Histogram_GateRadar  "S.........";
	set	$security_Histogram_FieldRadar "S..........";
	set	$security_Histogram_MowerShed  "S..........";
	set	$security_Histogram_Stables  "S..........";
	set	$security_Histogram_Annex  "S..........";
	set	$security_Histogram_Office "S..........";
	set	$security_Histogram_GateOpen "S..........";
	set	$security_Histogram_GateIR  "S..........";
			

}


sub Alarm_Histogram{
	set	$security_Histogram_OneAcre  ".". substr state $security_Histogram_OneAcre,0,8;
	set	$security_Histogram_MainField   ".". substr state $security_Histogram_MainField,0,8;
	set	$security_Histogram_GateRadar    ".". substr  state $security_Histogram_GateRadar,0,8;
	set	$security_Histogram_FieldRadar   ".". substr  state $security_Histogram_FieldRadar,0,8;
	set	$security_Histogram_MowerShed    ".". substr  state $security_Histogram_MowerShed,0,8;
	set	$security_Histogram_Stables    ".". substr  state $security_Histogram_Stables,0,8;
	set	$security_Histogram_Annex    ".". substr  state $security_Histogram_Annex,0,8;
	set	$security_Histogram_Office   ".". substr  state $security_Histogram_Office,0,8;
	set	$security_Histogram_GateOpen   ".". substr  state $security_Histogram_GateOpen,0,8;
	set	$security_Histogram_GateIR    ".". substr  state $security_Histogram_GateIR,0,8;
        






}



if (new_second 2){&Alarm_Histogram}







# ------------------------ACTIVATION methods and time setting of alarms======================================


# SMS is done by the GSM smss.pl module

# put in here line to react to homevision input port from small radio remote button.


# set the alarm for the field in the dark if no one in the field

if (state $Field_occupancy eq '0' and $Dark and state $Alarm_Group_Field ne 'active') {
	set $Alarm_Group_Field 'active' if state $Alarm_Group_Field ne 'active' ;
        print_log " Field alarm set due to it is Dark and there are no customers in the field"
 		}

if (state $Field_occupancy ne '0' and state $Alarm_Group_Field eq 'active' and time_between '8 AM', '8 PM') {
	set $Alarm_Group_Field 'idle' if state $Alarm_Group_Field ne 'idle' ;
        print_log"field alarm set to IDLE as there is a customer in the field"
                }

if ( time_between '8 AM', '8 PM' and state $Field_occupancy eq '0' and state $Alarm_Group_Field eq 'active' and $Dark == 0) {
	set $Alarm_Group_Field 'idle' if state $Alarm_Group_Field ne 'idle' ;
        print_log"field alarm set to IDLE as it is not Dark"
                }

		


# set the underground alarm and 1 acre radar active by timer

if (time_now("8:15 PM")) {
	set $Alarm_Group_Field 'active';
	set $Field_occupancy '0'
      }

if (time_now("8:00 AM")) {
	set $Alarm_Group_Field 'idle';
        set $Field_occupancy '0'
	}


# The stables and the tool shed are active all the time
#
# on reload they are set to active

 if ($Reload or $Startup or $Reread){ 
my $Tdir;   
	$Tdir = $config_parms{data_dir}."/AlarmData/Field_Logs";
	        mkdir $Tdir unless -d $Tdir;

          mkdir $config_parms{data_dir}."/AlarmData/ToolShed_Logs" unless -d $config_parms{data_dir}."/AlarmData/ToolShed_Logs";
	      mkdir $config_parms{data_dir}."/AlarmData/Stables_Logs" unless -d $config_parms{data_dir}."/AlarmData/Stables_Logs";
	      mkdir $config_parms{data_dir}."/AlarmData/system_Logs" unless -d $config_parms{data_dir}."/AlarmData/system_Logs";
	      mkdir $config_parms{data_dir}."/AlarmData/House_Logs" unless -d $config_parms{data_dir}."/AlarmData/House_Logs";
	      mkdir $config_parms{data_dir}."/AlarmData/Annex_Logs" unless -d $config_parms{data_dir}."/AlarmData/Annex_Logs";
	      mkdir $config_parms{data_dir}."/AlarmData/Master_Logs" unless -d $config_parms{data_dir}."/AlarmData/Master_Logs";
          
	  $Xmas_tune = 1;

	  set $Alarm_Group_ToolShed 'active';
	  set $Alarm_Group_Stables 'active'
  }



# a touch on the outgoing gate ibutton pad, sets timer running to ignore the alarms
# current 15 mins for tool shed
# and 30 mins for tack room.


my $Tmr_Alarm_Ignore_ToolShed = new Timer;

sub Alarm_ToolShed_ignore{
	print_log" tool shed set by iButton to ignore alarm";
	set $Alarm_Group_ToolShed 'T_idle';
     logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Tool Room Alarm dis-Armed by iButton");
  
     # the PIR input from the alarm resets timer to 900 each time, if the timer is running

				}

my $Tmr_Alarm_Ignore_Stables = new Timer;

sub Alarm_Stables_ignore{
	print_log"Stables tack room set by iButton to Ignore alarm";
        set $Alarm_Group_Stables  'T_idle';
	logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Tack Alarm dis-Armed by iButton");
                            # the PIR input from the alarm resets timer to 1800 each time, if the timer is running
			}


			# ADD HOUSE AND ANNEX ALARM ACTIVATION HERE

##################################
sub Notify_by_SMS {
     my ($msgSMS,$msgPriority) = @_;

     my $dlySMS;
     $dlySMS = 1;
     if (($Notify_Method_SMS eq 'yes') or ($msgPriority eq 'hi')){
     # now SMS all in alarm warning list in ini file
     my @SMSpeople = split ",",$config_parms{burglar};
        foreach my $GSM (@SMSpeople){
	
			run_after_delay $dlySMS,sub {
					print_log "send $msgSMS to $GSM and number is $config_parms{$GSM}";
		       			&send_gsm_sms ($config_parms{$GSM},$msgSMS)
				};
    	    $dlySMS = $dlySMS + 10 ;   
	}
	}
}
##################################
#
#   logs all to one log file.
#
sub Master_log{
	
$Ul_Al_state = shift;
         
logit($config_parms{data_dir}."/AlarmData/Master_Logs/Master_log.$Year_Month_Now.log",$Ul_Al_state);

}



#------------------------------------ Notifications------------------------------------

#alarm inputs have a tied event to them to call these routines
#
#
#			FIRST notify of system faults to beady's Mobile and log to System folder.
#
#			&Alarm_System_Status_change
#
#
#---------------------------------------------------------------------------------------






sub Alarm_System_Status_change{
	
$Ul_Al_state = shift;
if ($Ul_Al_state eq "ok"){
&Master_log("System is now OK");          
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","System is now OK");


}else{

#      &Notify_by_SMS("Betchton Manor Alarm system has a fault or is due a service, at $Time_Now   $Date_Now",'hi')
&Master_log("System has a fault or is due a service");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","System has a fault or is due a service");




}

}




#
#
			#  second log activations/deactivations of groups

sub Alarm_Group_Field_change{
	
$Ul_Al_state = shift;

	if ($Ul_Al_state eq "active"){
&Master_log("Activating Field alarm"); 
logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Activating alarm");


		print_log "Field alarm active" 
	}

	if ($Ul_Al_state eq "idle"){
&Master_log("de-activating Field alarm"); 
logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","De-Activating alarm");

          #      run_voice_cmd 'list all Undeground Alarm ibuttons';
		print_log "Field alarm idle" 
	}


}  # end alarm group field_Alarm_Control


#----------------- group stables alarm ------------

sub Alarm_Group_Stables_change{
	
$Ul_Al_state = shift;

	if ($Ul_Al_state eq "active"){

&Master_log("Activating Stables alarm"); 
logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Activating alarm");


		print_log "Tack Room alarm active" 
	}

	if ($Ul_Al_state eq "idle"){

&Master_log("Activating Stables alarm"); 
logit($config_parms{data_dir}."/AlarmData/Stables/Sta_log.$Year_Month_Now.log","De-Activating alarm");

          #      run_voice_cmd 'list all Undeground Alarm ibuttons';
		print_log "Tack Room alarm idle" 
	}

if ($Ul_Al_state eq "t_idle"){
	    	 set $Tmr_Alarm_Ignore_Stables 1800, sub{
			 set $Alarm_Group_Stables 'active';
			 logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Tack room Alarm re-Armed")
		 }

	 }


}  # end alarm group stables _Alarm_Control




#---------------- group Toolshed activate --------------------------

sub Alarm_Group_ToolShed_change{
	
$Ul_Al_state = shift;

	if ($Ul_Al_state eq "active"){

&Master_log("Activating Toolshed alarm"); 
logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Activating alarm");


		print_log "tool Shed alarm active" 
	}

	if ($Ul_Al_state eq "idle"){

&Master_log("de-activating Toolshed alarm"); 
logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","De-Activating alarm");

          #      run_voice_cmd 'list all Undeground Alarm ibuttons';
		print_log "Tool Shed alarm idle" 
	}

	if ($Ul_Al_state eq 't_idle'){
		set $Tmr_Alarm_Ignore_ToolShed 900, sub{
         		 set $Alarm_Group_ToolShed 'active';
			logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Tool shed Alarm re-Armed")
		}
		}
}  # end alarm group field_Alarm_Control


#------------------------  HOUSE group status change -------------------------

sub Alarm_Group_House_change{
	
$Ul_Al_state = shift;

	if ($Ul_Al_state eq "active"){

&Master_log("Activating House alarm"); 
logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Activating alarm");


		print_log "House alarm active" 
	}

	if ($Ul_Al_state eq "idle"){

&Master_log("de-activating House alarm"); 
logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","De-Activating alarm");

          #      run_voice_cmd 'list all Undeground Alarm ibuttons';
		print_log "house alarm idle" 
	}


}  # end alarm group house_Alarm_Control


#------------------------- Annex alarm status change -----------------------------

sub Alarm_Group_Annex_change{
	
$Ul_Al_state = shift;

	if ($Ul_Al_state eq "active"){

&Master_log("Activating Annex alarm"); 
logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","Activating alarm");
 	print_log "Annex alarm active" 
	}

	if ($Ul_Al_state eq "idle"){

&Master_log("de-activating Annex alarm"); 
logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","De-Activating alarm");

          #      run_voice_cmd 'list all Undeground Alarm ibuttons';
		print_log "Annex alarm idle" 
	}


}  # end alarm group field_Alarm_Control




#-------------- notify of systems tamper and faults or problems --------------------------------------------
#
#-----------------------------------------------------------------------------------------------------------


sub Notify_Underground_sys1_Tamper{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "yes"){

&Master_log("UG system tamper"); 
logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","System Tamper");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","UG sys1 Tamper");

    # speak " warning Underground Alarm system, is Tampered with.";
     # &Notify_by_SMS("Betchton Manor underground  Alarm has a fault or tampered with, at $Time_Now   $Date_Now",'hi')
	}else{

		        set $Alarm_Underground_sys1_Tamper_LastTest time
		}
	
}  



sub Notify_Underground_sys1_Fault{
	
 $Ul_Al_state = shift;



	if ($Ul_Al_state eq "yes"){

&Master_log("Ug System fault"); 
logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","System Fault");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","UG system Fault");

    speak "Warning Underground Alarm system has a Fault";
     # now SMS all in alarm warning list in ini file
      &Notify_by_SMS("Betchton Manor underground  Alarm has a fault, at $Time_Now   $Date_Now",'hi')

	}else{
set $Alarm_Underground_sys1_Fault_LastTest time		
&Master_log("Ug system OK"); 
		logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","System Fault now OK");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","UG system Fault now OK")
}
} 




sub Notify_Underground_Ch1_Pressure{
	
 $Ul_Al_state = shift;


	if ($Ul_Al_state eq "fault"){

&Master_log("UG ch1/ch2 pressure fault"); 

logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Ch 1/Ch 2 Pressure low");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","UG Channel 1 or 2 low pressure");

     speak "Warning Underground Alarm system channel one or two  pressure is low";
     &Notify_by_SMS("Betchton Manor underground  Alarm Ch 1/Ch 2 Pressure low, at $Time_Now   $Date_Now",'hi')

	}else{
		
&Master_log("UG CH1/Ch2 pressure OK"); 
set $Alarm_Underground_Ch1_Pressure_LastTest time;
		 speak "Warning Underground Alarm system channel one or two  pressure is Now OK but needs checking.";
logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Ch 1/Ch 2 Pressure now OK");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","UG Channel 1 or 2 pressure now OK")
}


 # check s if presure + pre alarm 1+2 are set then it is a tamper
 if ((state $Alarm_Underground_Ch1_Pressure eq "fault")and ( state $Alarm_Underground_Ch1_PreAlarm eq 'yes') and (state $Alarm_Underground_Ch2_PreAlarm eq 'yes')){
					set $Alarm_Underground_sys1_Tamper 'yes'
			}else {
					set $Alarm_Underground_sys1_Tamper 'no'
				}



} 



sub Notify_Underground_Ch2_Pressure{
# on one input channel with channel 1 pressure	

} 


sub Notify_Radar_paddock_Tamper{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "yes"){
		
&Master_log("Paddock Radar Tamper"); 


logit($config_parms{data_dir}."/AlarmData/Field_Logs/UGA_log.$Year_Month_Now.log","Paddock Radar tamper");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Paddock Radar Tamper");
     speak "Warning Radar sensor at front paddock tamper";
     &Notify_by_SMS("Betchton Manor radar sensor in front paddock tamper, at $Time_Now   $Date_Now",'hi')

	}else{
		
&Master_log("Paddock radar Tamper OK"); 
	set $Alarm_Radar_paddock_Tamper_LastTest time;
logit($config_parms{data_dir}."/AlarmData/Field_Logs/UGA_log.$Year_Month_Now.log","Paddock Radar tamper now OK");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Paddock Radar Tamper now OK")
}
} 

sub Notify_ToolShed_Tamper{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "yes"){

&Master_log("tool shed Tamper"); 
logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Tool shed PIR tamper");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Tool shed PIR tamper");
     speak "Warning tool shed alarm P I R tamper";
     &Notify_by_SMS("Betchton Manor tool shed alarm tamper, at $Time_Now   $Date_Now",'hi')

	}else{
		
&Master_log("toolshed Tamper OK");

set $Alarm_ToolShed_Tamper_LastTest time;
logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Tool shed PIR tamper now OK");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Tool shed PIR tamper now OK")
}
} 


sub Notify_Stables_Tamper{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "yes"){
		
&Master_log("Tack room Tamper"); 

 logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Tack room tamper");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Tack room tamper");
     &Notify_by_SMS("Betchton Manor tool shed alarm tamper, at $Time_Now   $Date_Now",'hi')

	}else{
		
&Master_log("Tackroom Tamper OK");
set $Alarm_Stables_Tamper_LastTest time;
logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Tack room tamper");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Tack room tamper")
}
} 





sub Notify_Alarm_Annex_Tamper_or_Fault{

	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "fault"){

&Master_log("Annex alarm Tamper");

logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","Annex PIR tamper or fault");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Annex PIR amper or fault");
     speak "Warning Annex alarm P I R tamper or one of the P. I. R. has a fault";
     &Notify_by_SMS("Betchton Manor Annex alarm tamper or fault, at $Time_Now   $Date_Now",'hi')

	}else{
		
&Master_log("Annex alarm Tamper OK"); 
set $Alarm_Annex_Tamper_or_Fault_LastTest time;
logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","Annex PIR tamper/fault now OK");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Annex PIR tamper/fault now OK")
}
} 





sub Notify_gate_24V{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "off"){

&Master_log("Gate 24v OFF"); 
#logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Gate 24V power fail");
    # speak "Warning Gate 24 volt power failed";
    # &Notify_by_SMS("Betchton Manor Gate 24 volt power failed, at $Time_Now   $Date_Now",'hi')

	}else{
		
&Master_log("Gate 24V ON");
set $gate_24V_LastTest time;
#logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Gate 24V power restored");
     #speak "The Gate 24 volt power has been RESTORED";
     #&Notify_by_SMS("Betchton Manor Gate 24 volt power RESTORED, at $Time_Now   $Date_Now",'hi')


	}
} 



sub Notify_Node1_220V{
# not tested yet may 2010	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "off"){

&Master_log("Node 1 Stables 220V OFF"); 
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 1  220V failed");
     speak "Warning power failure at Node 1 in Stables";
     &Notify_by_SMS("Betchton Manor Gate power failure at Node 1 in Stables, at $Time_Now   $Date_Now",'hi')

	}else{

&Master_log("Node 1 Stables 220V ON");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 1  220V Restored");
     speak "The power is  Restored at Node 1 in Stables";
     &Notify_by_SMS("Betchton Manor Gate power RESTORED at Node 1 in Stables, at $Time_Now   $Date_Now",'hi')

}


} 


sub Notify_Node0_220V{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "off"){
&Master_log("Node 0 house 220V OFF"); 
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 0  220V failed");
     speak "Warning power failure at Node zero in the house";
     &Notify_by_SMS("Betchton Manor power FAILED at Node 0 in the house, at $Time_Now   $Date_Now",'hi')

	}else{
&Master_log("Node 0 house 220V ON"); 
set $Main_220V_power_status_LastTest time;
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 0  220V Restored");
     speak "The power is  Restored at Node zero in the house";
     &Notify_by_SMS("Betchton Manor Power RESTORED at Node 0 in the house, at $Time_Now   $Date_Now",'hi')

}


} 

sub Notify_Mains_220V_Workshop_Annex{

 $Ul_Al_state = shift;


	if ($Ul_Al_state eq "off"){
&Master_log("Node 2 Annex 220V OFF"); 
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 2 Annex 220V failed");
     speak "Warning power failure at Node two in the annex .";
     &Notify_by_SMS("Betchton Manor power failure at Node 2 in the Annex , at $Time_Now   $Date_Now",'hi')

	}else{
&Master_log("Node 2 Annex 220V ON"); 
set $Mains_220V_Workshop_Annex_LastTest time;
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 2 Annex   220V Restored");
     speak "The power is  Restored at Node two , in the annex  .";
     &Notify_by_SMS("Betchton Manor power RESTORED at Node 2 in the Annex, at $Time_Now   $Date_Now",'hi')

}


}

sub Notify_BarioNET2_Exists{

 $Ul_Al_state = shift;


	if ($Ul_Al_state eq "alarm"){
&Master_log("Node 2 in Annex LAN comms to Barionet Off"); 
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 2 Annex LAN comms  failed");
     speak "Warning LAN network communicatins to Node two in the annex has failed.";
     &Notify_by_SMS("Betchton Manor LAN network comms to Node 2 in the Annex has Failed, at $Time_Now   $Date_Now",'hi')

	}else{
&Master_log("Node 2 in Annex LAN Comms ON"); 
set $BarioNET2_Exists_LastTest time;
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Node 2 Annex/ LAN comms  Restored");
     speak "The power is  Restored at Node two , in the annex  and the workshop.";
     &Notify_by_SMS("Betchton Manor LAN network comms to Node 2 in the Annex has been restored, at $Time_Now   $Date_Now",'hi')

}


}


sub GSM_phoneStatus_change{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "fault"){
		&Master_log("GSM Phone Fault"); 
     logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","GSM SMS phone Fault");
     # speak "GSM phone fault";
	}else{
		set $GSM_phoneStatus_LastTest time;
		# keeps adding too many entries in log	&Master_log("GSM Phone Now OK"); 
		# logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","GSM SMS phone now OK")
}
} 







#--------------NOW do the ALARM NOTIFICATIONS --------------------------------------

# these  notifications are turned on off as needed by time or remote control
#



sub Notify_Alarm_Radar_paddock_Alarm{
	
 	$Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		set $Alarm_Radar_paddock_Alarm_LastTest time;
       	&Master_log("Paddock Radar Movement"); 
	    if (active $tmr_family_gate_access_alarm_pause) { 
			 &Master_log("Alarm Pause timer active - due to valid key entry/exit")
			 };
	
	   	set	$security_Histogram_FieldRadar   "A". substr  state $security_Histogram_FieldRadar,0,8;
       	if (active $MobileAlarm_tcp){
	      	set $MobileAlarm_tcp "A1";
		  	logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","Paddock Radar Movement");
		  	logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","remote notifier Active")
	  	}else{
		  logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","Paddock Radar Movement");
		  if (active $tmr_family_gate_access_alarm_pause) { 
			   logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","Alarm Pause timer active - due to valid key entry/exit")
			   }
	
		}



		#  Show_on_tv('Paddock Radar Movement');


       	if(state $Alarm_Group_Field eq 'active'){


	      	speak " Movement in Front Paddock";



			# Show_on_tv('Front Paddock  Movement') if (time_greater_than("20:00"));
			set $OSFlood_light 'on';
			set $floodtimer2 40, sub{ set $OSFlood_light 'off' };
			&Notify_by_SMS("Betchton Manor Paddock Radar Movement, at $Time_Now   $Date_Now")
		}
	}


} 


sub Notify_Alarm_Radar_MainGate_Alarm{
	
 	$Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		set $Alarm_Radar_MainGate_Alarm_LastTest time;
       	&Master_log("Main Gate Radar Movement"); 
	    if (active $tmr_family_gate_access_alarm_pause) {  &Master_log("Alarm Pause timer active - due to valid key entry/exit");}
	
	   	set	$security_Histogram_GateRadar    "A". substr  state $security_Histogram_GateRadar,0,8;
  
       	if (active $MobileAlarm_tcp){
			set $MobileAlarm_tcp "A6";    # need to change prog for more.
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","Main gate Radar Movement");
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","remote notifier Active")
	  	}else{
		  logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","Main Gate Radar Movement");
		  if (active $tmr_family_gate_access_alarm_pause) {  logit($config_parms{data_dir}."/AlarmData/Field_Logs/radar_log.$Year_Month_Now.log","Alarm Pause timer active - due to valid key entry/exit");}
		}



		#  Show_on_tv('Paddock Radar Movement');


       if(state $Alarm_Group_Field eq 'active' and !(active $tmr_family_gate_access_alarm_pause)){

			speak " Movement at front gate";
	
			set $OSFlood_light 'on';
			set $floodtimer2 60, sub{ set $OSFlood_light 'off' };
			#    Show_on_tv('Front Gate  Movement') if (time_greater_than("20:00"));

			&Notify_by_SMS("Betchton Manor main gate Radar Movement, at $Time_Now   $Date_Now")



		}
	}


} 





sub Notify_Alarm_Underground_Ch2_Alarm{
	
 	$Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
        &Master_log("UG Ch2 bottom field Movement"); 
			set	$security_Histogram_MainField   "A". substr state $security_Histogram_MainField,0,8;
     	if (active $MobileAlarm_tcp) {
			set $MobileAlarm_tcp "A3";
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH2 bottom of main field alarm");
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","remote notifier Active");

	     }else{
	     	logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH2 bottom of main field alarm");
    	 }


		set $Alarm_Underground_Ch2_Alarm_LastTest time;
		
		if(state $Alarm_Group_Field eq 'active' ){
			Show_on_tv('Main field  Movement');



			speak "Someone at bottom of main field";



			&Notify_by_SMS("Betchton Manor movement bottom of main field , at $Time_Now   $Date_Now",'norm')
		}
	}
	
}




sub Notify_Alarm_Underground_Ch1_Alarm{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
        &Master_log("UG Ch1 one acre movement"); 
		set	$security_Histogram_OneAcre  "A". substr state $security_Histogram_OneAcre,0,8;
 	    if (active $MobileAlarm_tcp) {
			set $MobileAlarm_tcp "A2";
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH1 1 acre alarm");
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","remote notifier Active")
		}else{
        	logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH1 1 acre alarm")
  
		}
	set $Alarm_Underground_Ch1_Alarm_LastTest time;

    if(state $Alarm_Group_Field eq 'active'){
		Show_on_tv('One Acre Movement');
		speak "Someone is in the 1 Acre";
   	  	print_log"Someone is in the 1 Acre";
    	&Notify_by_SMS("Betchton Manor movement in 1 acre , at $Time_Now   $Date_Now",'norm')
     	}
	}
} 

sub Notify_Alarm_Underground_Ch1_PreAlarm{
	
 $Ul_Al_state = shift;



        set $Alarm_Underground_Ch1_PreAlarm_LastTest time;

	if ($Ul_Al_state eq "yes"){
		&Master_log("Ug Ch1 one acre Pre-alarm"); 
		set	$security_Histogram_OneAcre  "P". substr state $security_Histogram_OneAcre,0,8;
		if (active $MobileAlarm_tcp) {

		set $MobileAlarm_tcp "A4"; 
		logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH1 1 acre Pre-alarm");
		logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","remote notifier Active")

	}else{
     		logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH1 1 acre Pre-alarm")
	}
	  Show_on_tv('One Acre PRE alarm') if (time_greater_than("20:00"));
  }

 # test for Ug tamper : if bothe prealarms and pressure are set then it is a tamper
  if ((state $Alarm_Underground_Ch1_Pressure eq "fault")and ( state $Alarm_Underground_Ch1_PreAlarm eq 'yes') and (state $Alarm_Underground_Ch2_PreAlarm eq 'yes')){
					set $Alarm_Underground_sys1_Tamper 'yes'
			}else {
					set $Alarm_Underground_sys1_Tamper 'no'
				}




} 

sub Notify_Alarm_Underground_Ch2_PreAlarm{
	
 	$Ul_Al_state = shift;



	set $Alarm_Underground_Ch2_PreAlarm_LastTest time;

	if ($Ul_Al_state eq "yes"){
	 	&Master_log("Ug Ch2 bottom main field Pre-alarm"); 
	 	set	$security_Histogram_MainField   "P". substr state $security_Histogram_MainField,0,8;
		if (active $MobileAlarm_tcp) {
			set $MobileAlarm_tcp "A5" ;
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH2 Bottom field Pre-alarm");
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","remote Notifier Active")

 		}else{

			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","UG CH2 Bottom field Pre-alarm")
		}
	}
	Show_on_tv('Main field Pre Alarm') if (time_greater_than("20:00"));
	# test for Ug tamper : if bothe prealarms and pressure are set then it is a tamper
	if ((state $Alarm_Underground_Ch1_Pressure eq "fault") and ( state $Alarm_Underground_Ch1_PreAlarm eq 'yes') and (state $Alarm_Underground_Ch2_PreAlarm eq 'yes')){
		set $Alarm_Underground_sys1_Tamper 'yes'
	}else {
		set $Alarm_Underground_sys1_Tamper 'no'
	}

} 


my $StablesDelay = new Timer;

sub Notify_Alarm_Stables_Alarm{
	
 	$Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		#Show_on_tv('Tack room movement');
		set $Alarm_Stables_Alarm_LastTest time;
        &Master_log("Tack room alarm"); 
		set	$security_Histogram_Stables    "A". substr  state $security_Histogram_Stables,0,8;
       	logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Tack room Movement");
	
		# allow for temp disable of alarm from web page as well as from ibutton   
		# 
		# see if the state is still temp idle 't_idle' if so recativate time for full time 
		if(state $Alarm_Group_Stables eq 't_idle'){
	    	 set $Tmr_Alarm_Ignore_Stables 1800, sub{
			 set $Alarm_Group_Stables 'active';
			 logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Tack room Alarm re-Armed")
		 	}	

	 	}

        if (active $MobileAlarm_tcp){
	       	set $MobileAlarm_tcp "A8";  #    see alarm remote notifier .net studio project
			logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","remote notifier Active")
	  	}
 
     	 if((state $Alarm_Group_Stables eq 'active')and (inactive $StablesDelay)){  
	      	 set $StablesDelay 360;
		 	logit($config_parms{data_dir}."/AlarmData/Stables_Logs/Sta_log.$Year_Month_Now.log","Movement in Tack room");
     	 	speak "Someone is in Stables Tack room";
     		print_log"Someone is in the Tack room";
		 	Show_on_tv('Tack room Movement');
     		&Notify_by_SMS("Betchton Manor movement in Stables Tack room , at $Time_Now   $Date_Now",'norm')
		}
	
	}
}





sub Notify_Alarm_TR_Shed_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		print_log"Someone is in  T R shed";
		   set $Alarm_Annex_Flat_Alarm_LastTest time;
       		&Master_log("Bike Shed PIR movement");
			set	$security_Histogram_Annex    "A". substr  state $security_Histogram_Annex,0,8;
		    #set $Last_Annex_Movement time; 
        	if(active $Timer_annex_delay) {
		       	set $Timer_annex_delay 1800,sub{ set $Alarm_Group_Annex  'active'}
		}
         
		logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","Movement in TR shed");

       	
		if(state $Alarm_Group_Field eq 'active'){
                speak "Movement in the T R shed";
     			
     			&Notify_by_SMS("Betchton Manor : T R shed movement alarm , at $Time_Now   $Date_Now",'hi')
			}
	}
} 










#------------------------------ shed alarm -----------------------


my $ShedDelay = new Timer;    

sub Notify_Alarm_ToolShed_Alarm{
	
 	$Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		Show_on_tv('Tool Shed Movement');
		set $Alarm_ToolShed_Alarm_LastTest time;
 		&Master_log("Toolshed alarm"); 
		set	$security_Histogram_MowerShed    "A". substr  state $security_Histogram_MowerShed,0,8;
		# see if the state is still temp idle 't_idle' if so recativate time for full time
		if (state $Alarm_Group_ToolShed eq 't_idle'){
			set $Tmr_Alarm_Ignore_ToolShed 900, sub{
				set $Alarm_Group_ToolShed 'active';
				logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Tool shed Alarm re-Armed")
				}
		}


        if (active $MobileAlarm_tcp){
			set $MobileAlarm_tcp "A7";  #    see alarm remot notifier .net studio project
			logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Tool shed Movement");
			logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","remote notifier Active")
	 	 }


     	if((state $Alarm_Group_ToolShed eq 'active') and (inactive $ShedDelay)){
			set $ShedDelay 360; 
			logit($config_parms{data_dir}."/AlarmData/ToolShed_Logs/TS_log.$Year_Month_Now.log","Movement in Tool Shed");
				
     		print_log"Someone is in the tool shed";
		 	if (time_between "$Time_Sunset", "$Time_Sunrise"){
     			&Notify_by_SMS("Betchton Manor : movement in tool Shed , at $Time_Now   $Date_Now",'hi');
				speak "Someone is in tool Shed";
			}
		}
	}

}


sub Notify_Gate_Attack_Alarm{
# if the gate closed switch goes open circuit and Mh didnt open the gate then it must
# be being forced open
=begin =================================================================================================================================

#========================================================================
        	   logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Gate forced open")

	           &Notify_by_SMS("Gate forced open, at $Time_Now   $Date_Now");
               &Master_log("Gate forced open : gate closed switch open circuit and MH has not opened the gate");
               speak " Gate attack, gate attack, the gate has been opened by a intruder";
               print_log" Gate attack, gate attack, the gate has been opened by a intruder"
#===================================================================================================================================
=cut


}

sub Notify_Gate_IRBeam_Alarm{
# if the gate IR beam is broken then work out if it need notiying
	$IR_Beam_state = shift;
           # the stretegy for the IR beam is that is must be broken for at least 3 seconds
		   # this should stop random braks from leaves and rain etc





	    
        if ($IR_Beam_state eq "alarm" ){
			
                  	set $tmr_gate_IR_beam_bounce 3;
	        	  	$gate_IR_beam_bounce_flag = 1;
                	set $tmr_gate_IR_beam_long_break 60,sub{
                    
                         &Master_log("Gate IR Beam broken : gate closed but beam has been interupted for more than 60 seconds");
                         #speak " The gate Infra red beam has been interupted for more than 60 seconds"
					}
		
		}else{
               # beam must now be unbroken so deal with how long it was broken for 

			$gate_IR_beam_bounce_flag = 1;     # unset the flag because it was less than 3 seconds break

            set $tmr_gate_IR_beam_long_break 0;

		  	if (inactive $tmr_gate_IR_beam_bounce and $gate_IR_beam_bounce_flag == 1 and inactive $tmr_safe_Gate_opened_by_MH ){
				$gate_IR_beam_bounce_flag == 0;   #reset flag, as the beam was broken for more than 3 seconds
				logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Gate IR beam");
				&Notify_by_SMS("Gate IR beam broken, at $Time_Now   $Date_Now");
				&Master_log("Gate IR Beam broken : gate closed but beam has been interupted formore than 3 seconds");
				#speak " The gate Infra red beam has been interupted for more than 3 seconds";
				print_log"The gate IR beam has been interupted for more than 3 seconds"
		  	}




		}
		
 
}








#######################################
#
#
#         Annex alarms notifies
#  the time Timer_annex_delay     is set by the ibutton in Naironet_SER_Node2 annex.pl

sub Notify_Alarm_Annex_Flat_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		   set $Alarm_Annex_Flat_Alarm_LastTest time;
       		&Master_log("Annex Flat PIR movement");
			set	$security_Histogram_Annex    "A". substr  state $security_Histogram_Annex,0,8;
		    set $Last_Annex_Movement time; 
        	if(active $Timer_annex_delay) {
		       	set $Timer_annex_delay 1800,sub{ set $Alarm_Group_Annex  'active'}
		}
         
		logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","Movement in Flat");

       		if(state $Alarm_Group_Annex eq 'active'){
			Show_on_tv('Annex flat Movement');
                	speak "Movement in the Annex";
     			print_log"Someone is in Annex flat";
     			&Notify_by_SMS("Betchton Manor : Annex flat movement alarm , at $Time_Now   $Date_Now",'hi')
			}
	}
} 


sub Notify_Alarm_Annex_Workshop_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		  
		set $Alarm_Annex_Workshop_Alarm_LastTest time;
      	 	&Master_log("Annex downstairs PIR movement"); 
    		 if (active $Timer_annex_delay) {
			 set $Timer_annex_delay 1800,sub{ set $Alarm_Group_Annex  'active'}
		 }
		logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","Movement in annex downstairs");

      		 if(state $Alarm_Group_Annex eq 'active'){
                        #Show_on_tv('WorkShop Movement');
			set $Timer_workshop_delay 300, sub{
                	speak"movement in the Annex downstairs"   ;  
           		print_log"Someone is in the annex downstairs";
     			&Notify_by_SMS("Betchton Manor : Annex downstairs movement alarm , at $Time_Now   $Date_Now",'hi')
		}
		}
	}
} 


sub Notify_Alarm_Annex_Office_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
            set	$security_Histogram_Office   "A". substr  state $security_Histogram_Office,0,8;
         	set $Alarm_Annex_Office_Alarm_LastTest time;
				set $Last_Office_Movement $Time;
                &Master_log("Office PIR movement"); 
                if(active $Timer_annex_delay) {
		       	set $Timer_annex_delay 1800,sub{ set $Alarm_Group_Annex  'active' }
		}	
		logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","Movement in Office");

         if(state $Alarm_Group_Annex eq 'active'){
                        Show_on_tv('Office Movement');
              	 	speak "movement in the Office";
     			print_log"Someone is in the Office in the annex";
     			&Notify_by_SMS("Betchton Manor : Annex Office movement alarm , at $Time_Now   $Date_Now",'hi')
		}
	}
} 

sub subShedDoor{

	logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Garden Shed door");


}

sub subShedPIR{
	if ( state $HV_GardenShed_PIR eq 'on'){
	    &Master_log("Dogger shed PIR movement"); 
        #  Show_on_tv('Garden Shed Movement');
	    logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Movement in Dogger Shed");

       if(state $Alarm_Group_House eq 'active'){
          

#                         DO house alarm
#
#
#
		}else{
		# turn the lights on and off as the alarm is not active
			if (inactive $tmrShedPIR and time_between "$Time_Sunset", "$Time_Sunrise"){
			  	        	set $tmrShedPIR 60,sub{
							set $Shed_light_OS 'off'
			                			}
							}
		}  # end of   if(state $Alarm_Group_House eq 'active'){

    }else{    	                # when pir goes off turn lights off as well
        # set $tmrShedPIR 120,sub{
	    #set $Shed_light_OS 'off';
        # if (time_between "$Time_Sunset", "11:59 PM" ) {set $Shed_light_OS '+65'}else{set $Shed_light 'off'}
	}
}   # end of sub







########################################
#
#       house alarms generally controlled/inputed by Homevision see homevisioninterface.pl
# these can also be used to do things in the day like turn lights on etc,
#
# put all that stuff here in the notify so that if the alarms are set then they don't
# do turning the lights on etc.
#
#
#
#


sub Notify_Alarm_KitchenPIR_Alarm{
	
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
	set $Alarm_KitchenPIR_Alarm_LastTest time;
 	set $Last_House_Movement $Time;
	   &Master_log("Kitchen PIR movement"); 
        if ((time_between '11 am','9 pm') and ($Month == 12 ) and  ( ($Mday == 21 )or ($Mday == 19)  )){
		# print_log "Playing nature sounds tune";    	     
		       &Nature_Sound
	      }
	      if ((time_between '11 am','9 pm') and ($Month == 12 ) and  ( ($Mday == 24 )or ($Mday == 26)  )){
		      #     print_log "Playing nature sounds tune";    	     
		       &Nature_Sound
	      }
	logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Movement in Kitchen");

       if(state $Alarm_Group_House eq 'active'){
          

#                         DO house alarm
#
#
#
	}
} # end is in alarm state
#                               Lights activated by kitchen PIR are done by lights.pl 
}   # end sub



sub Notify_Alarm_LroomPIR_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
        set $Last_House_Movement $Time;
        set $Alarm_LroomPIR_Alarm_LastTest time;
        &Master_log("living room PIR movement"); 
	    # print_log "Month ". $Mday."  Day ".$Month;
	    if ((time_between '8 am','11 am') and ($Month == 12 ) and ($Mday == 25 )){
	   	    print_log "Playing christmas tune";    	     
		    &Xmas_tune;
			  
	    }
		  
		  
		  
	    if ((time_between '10 pm','12 pm') and ($Month == 10 ) and ($Mday == 31 ) ){
	   	    print_log "Playing halloween tune";      	     
		    &Halloween_tune
	    }

	      #put any xmas or halloween tunes in the folder sounds/xmas or sounds/halloween they will get played randomly, they must be .wav files



	     logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Movement in Living Room");
             # turns tv off in daytime if no movement in living room for 5 mins, the up button disbles this feature for a day.
	    if ((time_between '4 am','5 pm') and state $TV_off_overide eq 'off' and state $HV_MarantzAMP eq 'on'){
		                print_log " living room PIR set TV off timer";
		                unset $Tmr_TV_off_in_one_Minute if active $Tmr_TV_off_in_one_Minute;
		    		set $Tmr_TV_off 300,sub{
					                
                             				Show_on_tv('TV off in 1 Minute');
			   				set $Tmr_TV_off_in_one_Minute 60,sub{
                            								# set $HV_IR_AMP "AmpPower"
			    									}
											
		   							 }
								 }

       if(state $Alarm_Group_House eq 'active'){
          

#                         DO house alarm
#
#
#
	}
	}


}




sub Notify_Alarm_BackDoor_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
	    set $Alarm_BackDoor_Alarm_LastTest time;
        &Master_log("Back door opened"); 
        set $Last_House_Movement $Time;
	    logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Back door opened");
        logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Back door opened"); 

#         

       if(state $Alarm_Group_House eq 'active'){


#                         DO house alarm
#
#
#
		}else{
			# house alarm not on so do courtesy lights
            if (time_between "$Time_Sunset", "$Time_Sunrise") {
        			set $OSporch_light 'on'	;
					set $OutsideCourtesyTimer1 2,sub {
					set $Shed_light_OS 'on'
					};
                         # now set a timer to turn them off after 90 deconds
	                set $OutsideCourtesyTimer 90,sub{         	
						print_log " Turned Courtesy lights off"; 
					 	set $Shed_light_OS 'off';
       					if (time_between '11 pm', "$Time_Sunrise"){
							set $OutsideCourtesyTimer1 10, sub { 
								set $OSporch_light 'off'  
							};
						}
					}

			}
			# set the timer to tell people to shut the back door.
			set  $tmr_backdoor 180,sub { 
				          play $config_parms{Door_rear}
						  };	     
			   
		}  # end alarm not active
 
	}else{
		print_log" back door has been shut.";
		 logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Back door shut");
		 logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Back door shut"); 
		if (active $tmr_backdoor){
			print_log "Back door Timer reset";
			set $tmr_backdoor 0
		}

	}  # end not a alarm



}   #end sub


sub Notify_Alarm_FrontDoor_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
	    set $Alarm_FrontDoor_Alarm_LastTest time;
        &Master_log("Front door opened"); 
        set $Last_House_Movement $Time;
	    logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Front door opened");

        if(state $Alarm_Group_House eq 'active'){
          

#                         DO house alarm
#
#
#
	}
	}


}


sub Notify_Alarm_StudyPIR_Alarm{

	#study is now bed_downstairs from 2016 on
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
	     set $Alarm_StudyPIR_Alarm_LastTest time;
         &Master_log("Study PIR movement"); 
         set $Last_House_Movement $Time;
	     logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Movement in Study");
         if(state $Alarm_Group_House eq 'active'){
          

#                         DO house alarm
#
#
#
     	 }
         # for the heating add to the counter 
         if (state $Bed_Chloe_movement_Cntr <=2){set $Bed_Chloe_movement_Cntr  state $Bed_Chloe_movement_Cntr+1 }
         if (state $Bed_Downstairs_movement_Cntr <=2){set $Bed_Downstairs_movement_Cntr  state $Bed_Downstairs_movement_Cntr + 1 }


$Bed_Downstairs_movement_Cntr
	 }


}




sub Notify_Alarm_Bed1PIR_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
	set $Alarm_Bed1PIR_Alarm_LastTest time;
             &Master_log("Bed 1 PIR movement"); 
    set $Last_House_Movement $Time;
	logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Movement in Bed 1");

       if(state $Alarm_Group_House eq 'active'){
          

#                         DO house alarm
#
#
#
	}
	}


}
sub Notify_Alarm_Bed2PIR_Alarm{
 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
	set $Alarm_Bed2PIR_Alarm_LastTest time;
             &Master_log("Bed 2 PIR movement"); 
    set $Last_House_Movement $Time;
	logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Movement in Bed 2");

       if(state $Alarm_Group_House eq 'active'){
          

#                         DO house alarm
#
#
#
	}
	}



}

#Millys gate alarm

sub Notify_Alarm_Milly_Gate_Alarm{

 $Ul_Al_state = shift;

	if ($Ul_Al_state eq "alarm"){
		# 10 second debounce
		if ( time - state  $Alarm_Milly_Gate_Alarm_LastTest > 10){
			set $Alarm_Milly_Gate_Alarm_LastTest time;
			&Master_log("Millys Wshop gate opened"); 
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Milly Wshop gate opened");
			
			if(state $Alarm_Group_Field eq 'active' and state $Wshop_gate_alarm_inhibit eq 'inactive'){
				speak "Milly workshop Gate has just opened" if time_less_than ('7:00 AM');
				&Notify_by_SMS("Millys Workshop gate opened, at $Time_Now   $Date_Now",'hi')
			}
		}
	}else{

        logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Milly Wshop Gate closed")

	}
}






$CodeTimings::CodeTimings{'Alarms_Security End'} = time();
