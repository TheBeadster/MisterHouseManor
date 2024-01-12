# category  = Alarms
$CodeTimings::CodeTimings{'AlarmsMobileNotify Start'} = time();
=begin

	#####################################################################
	#                                                                   #
	#             Security intruder mobile notify Alarm Module			    #
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

 currently plays sound on mobile phone based on alarm status.

=cut
#@  Uses Alarmnotify program for window mobile to instantly send alarm information 
#@  has a server speak pot listening for connection, 
#@  sends two byte sequence, the meaning od them is coded into misterhouse and the phone program.
#@  see the visual studio program under archive\bd RnD\Programming_PR\SecurityViewer


#######################################################################
#                                                                     #
#               Note          april 2022                              #
#      All declarations that are not local ie generics are now put in #
#                  the Declarations.pl module                         #
#            this is so modules can be disabled for testing           #
#                                                                     #
#######################################################################



$MobileAlarm_tcp = new  Socket_Item(undef, undef, 'server_speak');



if(active $MobileAlarm_tcp and my $data = said $MobileAlarm_tcp ){
	print_log "MobileAlarm_tcp said : $data\n";
	 # open the gate
         if ($data =~/B1/){ 
		 &open_the_gate
	 }
         # or toggle the out side lights
	 if ($data =~/B2/){ set $OSFlood_light 'on'}

          if ($data =~/B3/){ set $OSFlood_light 'off'}


	 if ($data =~/B4/){ set $All_Lights 'on'}
	 
	 if ($data =~/B5/){ set $All_Lights 'off'}




}





$V_testMobileAlarm = new Voice_Cmd("test alarm [paddock,1_acre,Mainfield]");

if ( $state = said $V_testMobileAlarm ){
	if (active $MobileAlarm_tcp){
	if ($state eq "paddock"){
print_log "paddock testing";		
			set $MobileAlarm_tcp "A1"
		}elsif ($state eq "1_acre"){
	          	set $MobileAlarm_tcp "A2"}
          	else{
                      	set $MobileAlarm_tcp "A3"}
	}
}



if  ($New_Second ){

#send alarm state as
# A0  = all OK
# A1  = alarm 1
# A2  = alarm 2 etc etc
#
#
# the relavant alarms that are dealt with in the security .pl files send the messages to the phone

    if (active $MobileAlarm_tcp){set $MobileAlarm_tcp "A0"}

}

   if (active_now $MobileAlarm_tcp){print_log "connected to mobile phone"}

   if (inactive_now $MobileAlarm_tcp){print_log "Lost connection to mobile phone"}





$CodeTimings::CodeTimings{'AlarmsMobileNotify End'} = time();