# category=Alarms
$CodeTimings::CodeTimings{'Alarms_Smake Start'} = time();
=begin

	#####################################################################
	#                                                                   #
	#            SMOKE Alarm Module			    #
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
 	The modules that handle the hardware change in the Generic items, 
        these modules do the monitoring of the signals ,
	 handling what to do with the change is done here


	 the Barionet at Node 1 ( tack room) controls the UG alarms, stables and Tool shed,
                ( also controls the gate access but that is handled in GateControl.pl)
	the BArionet at Node 2 ( plant room) controls all things in the annex.
	Homevision controls all the main house internal signals  HomeVision.pl is the interface code


	the alarm signal are grouped into 5 groups as of Feb 2010
              Field   : anything with the security of the field, gate, ug,radr
	      House   : securing the main house
	      annex   : securing the annex
	      stables : now just PIR is tack room
	      ToolShed: ex tiny's stable with Lawnmower in it.

	      these groups are used in the Alarm security.pl mode as well

	  

        there are three parts to this module 
         Generic items declarations  : duh

	 Activation   : deals with which parts af the alarm are active and when
                      : also deals with inputs to activate and deactivate alarm

         Notification   : deals with who and how we are notified of the alarm
	                : ie internal on speakers or by sms or any other methods

=cut


##################################################################################
my $Smoke_Control_States="active,idle,less_Kitchen";
my $Smoke_States ="yes,no";
my $Smoke_States2="ok,fault";
my $Smoke_States4="ok,alarm";
my $SM_Al_state;

$Smoke_Alarm_Silence_reset = new Timer;





$Smoke_Group->tie_event('&subSmoke_Group');

sub subSmoke_Group{
if (state $Smoke_Group eq 'less_Kitchen'){
set $Smoke_Alarm_Silence_reset 3600 , sub{
         		 set $Smoke_Group 'active'
		 }

}
}


if (   $Reload or $Startup ){

#silence all smoke alarms at startup to allow code to settle down , and relays devices, afetr a power up.
set $Smoke_Alarm_Silence_reset 30 , sub{
	            set $Smoke_Workshop_Annex 'ok';
				set $Smoke_ToolShed_Alarm 'ok';
				set $Smoke_Stables_Alarm 'ok';
				set $Smoke_Kitchen_Alarm 'ok';
         		 set $Smoke_Group 'active'
		 }
}









if($New_Hour){
if (  (&LastTester(state $Smoke_Stables_Alarm_LastTest,"6") eq '1') and 
       	(&LastTester(state $Smoke_ToolShed_Alarm_LastTest,"6") eq '1') ){

	    set	$LastTestingSmoke 'ok'if state $LastTestingSmoke ne 'ok'
    }else{
	    set $LastTestingSmoke 'fault' if $LastTestingSmoke ne 'fault'

}


}
#        #########################
#        #########################
#           need to put alert in for smoke needs testing, or use a overall system alert and then we can check
#           mh web for problem

##############################
###############################
################################
#
#

sub Notify_Smoke_Stables_Alarm{
	
 $SM_Al_state = shift;



	if ($SM_Al_state eq "alarm"){

&Master_log("Stables Smoke Alarm"); 
logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Stables Smoke Alarm");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Stables Smoke Alarm");

    speak "Warning Warning Stables Smoke Alarm Stables Smoke Alarm Stables Smoke Alarm";
     # now SMS all in alarm warning list in ini file
      &Notify_by_SMS("Betchton Manor Stables Smoke Alarm, at $Time_Now   $Date_Now",'hi')

	}else{
set $Smoke_Stables_Alarm_LastTest time		
&Master_log("Stables Smoke OK"); 

        
        #speak "Warning Warning Stables Smoke Alarm is now off , But I suggest you go and check";
	logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Stables Smoke Alarm OK");
	logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Stables Smoke Alarm now OK")
}
} 







sub Notify_Smoke_Kitchen_Alarm{
	
 $SM_Al_state = shift;



	if ($SM_Al_state eq "alarm"){

&Master_log("Kitchen Smoke Alarm"); 
logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Kitchen Smoke Alarm");
logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Kitchen Smoke Alarm");

    speak "Warning Warning Kitchen Smoke Alarm Kitchen Smoke Alarm Kitchen Smoke Alarm";
     # now SMS all in alarm warning list in ini file
      &Notify_by_SMS("Betchton Manor Kitchen Smoke Alarm, at $Time_Now   $Date_Now",'hi')

	}else{
set $Smoke_Kitchen_Alarm_LastTest time		
&Master_log("Kitchen Smoke OK"); 

# speak "Warning Warning Kitchen Smoke Alarm";
	logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Kitchen Smoke Alarm ok");
	logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Kitchen Smoke Alarmok ")
}
} 





sub Notify_Smoke_Workshop_Annex{
	
 $SM_Al_state = shift;



	if ($SM_Al_state eq "alarm"){
     		if (state $Smoke_Group eq 'active' or state $Smoke_Group eq 'less_Kitchen'){
			print_log "annex/Workshop /Office smoke alarm";
			
			&Master_log("workshop Smoke Alarm"); 
			logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","Workshop/Annex Smoke Alarm");
			logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","Workshop/Annex Smoke Alarm");

   			speak "Warning Warning workshop and Annex  Smoke Alarm workshop and annex Smoke Alarm workshop Smoke Alarm";
    			# now SMS all in alarm warning list in ini file
      			&Notify_by_SMS("Betchton Manor workshop/Annex Smoke Alarm, at $Time_Now   $Date_Now",'hi')
			}

	}else{
		 
     		if (state $Smoke_Group eq 'active'  or state $Smoke_Group eq 'less_Kitchen'){
   		 	
			&Master_log("workshop/Annex Smoke OK");
			#speak "Warning  workshop Smoke Alarm is now off , But I suggest you go and check";
			logit($config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log","workshop/Annex Smoke Alarm OK");
			logit($config_parms{data_dir}."/AlarmData/System_Logs/System_log.$Year_Month_Now.log","workshop/Annex Smoke Alarm now OK")
		}
	}
} 




$CodeTimings::CodeTimings{'Alarms_Smake End'} = time();