# category=Lights
#

$CodeTimings::CodeTimings{'Lights_timings Start'} = time();


#@ as of Oct 2014
# @All the on/off at dark etc light controls
# @the declarations are in Lights_control.pl
# @ Some lights are turned on/off by the alarms_security.pl 
# @ when sensors trigger
#@ Homeviosn sends a 'go to bed' button pressed signal which can then turn of stuff like the garden lights'
#



#-----------------------------------------------------------------------------------------------------------
#garden light sequencing  changes every 10 minutes
my $Current_Scene;

$Current_Scene = 'A' if $Reload or $Startup;


#if  ($New_Minute and new_minute 3  and time_less_than('23:00') and time_greater_than('18:00')and ($Dark)){
#        print_log "scene changed to $Current_Scene $Time_Now "
#	set $Garden_Mood $Current_Scene;
#	$Current_Scene = 'A' if ($Current_Scene++ eq 'E')
#}


# TEMP TEMP garden POND !!!!


#if (time_now "3:00 PM" ){set $Mihome_eTRV_rPi_UDPctrl "#1.POND:on"}


#if (time_now "11:00 PM" ){set $Mihome_eTRV_rPi_UDPctrl "#1.POND:off"}




#--------------------------------------------------------------------------------------------------------
#
#

my $HV_lights_delay1 = new Timer;
my $HV_lights_delay2 = new Timer;
my $HV_lights_delay3 = new Timer;

if (time_now "$Time_Sunset + 0:15") {
        print_log "Turning on outside lights at sunset +15 minutes";
        set $OSporch_light 'on';
		set $Garden1_light 'on';
        set $HV_lights_delay1 5,sub {
		set $Glass_Box_Mood_lights 'on'
       	};
        set $HV_lights_delay2 15,sub {
	        set $Garden1_light 'on'
	};
	set $HV_lights_delay3 25,sub {
       		set $Glass_Box_Mood_lights 'on'
		}


}





#  these will be turned off by the goodnight button on Homevison or the line below which ever is sooner
#
if (time_now "11:59 PM" ){set $OSporch_light 'off'};

if (time_now "11:58 PM" ){set $Outside 'off'};

if (time_now "11:58 PM"){set $Glass_Box_Mood_lights 'off'};	

if (time_now "11:48 PM"){set $Glass_Box_Mood_lights 'off'};

set $Garden1_light 'off' if time_now "12:10";


if (time_now '6:30 AM'){set $Christmas_Lights 'on'};
if (time_now '6:32 AM'){set $Christmas_Lights 'on'};

set $Christmas_Lights_Outside 'on' if time_now (&time_add("$Time_Sunset + 0:15"));


if (time_now '00:32 AM'){
	set $Christmas_Lights_Outside 'off';
	set $Christmas_Lights 'off';
	set $Christmas_Lights_Moon 'off';
	set $Mihome_eTRV_rPi_UDPctrl "#1.POND:off"
	};

# the kitchen lights are 
#  still done in the homevision box code!!! must move it one day
#$tmr_Kitchen_Lights = new Timer;


#if (state_now $Alarm_KitchenPIR_Alarm eq 'alarm' and state $Alarm_Group_House eq 'idle' and $Dark){
#        if (inactive $tmr_Kitchen_Lights){
#	#set $Kitchen_lights1 'off';
#			set $Kitchen_lights1 'on';
#			print "setting kitchen lights on and setting 120 second timer\n"
#			}
        
#	set $tmr_Kitchen_Lights 120, sub {
#		set $Kitchen_lights1 'off';

#		print " Turning kitchen lights off after 120 seconds of delay\n"
#			}

	 

#}



#
#--------------------------------------------------------------------------------------------------------
#temp
#if (state $Security_Lighting eq 'on' and $Time_Now eq'





#       security lighting  use generic item Security_Ligthing (on,off)
#
#       security lighting falls into two stages evening and night time
#	evening  ( door lights stay as per homevision setting)
#	all states are obviosly 'if dark'
#	  turn zoes light on at 7.30 off at 8.00 +-10mins
#	      zoes light on .. main bath on 10 secs later wait 2mins+-1min off
#	      then 10 secs zoes light off
#	chloes light on 7.30 off at 8.00 +-15mins 
#	       also bathroom visit one every night random
#	 living lights set to a mood setting ... at 11.30+-30  landing lights on bed1 on
#	  all living off
#	  in night bath room light on 3 times a night for 1 mins
#
#	       
#	  turn outside floods on  twice at random for 2 mins
#
#	  turn bed1 light on , landing then kitchen wait 1 mins then reverse.
#		also in evening turn kitchen lights on and off random before going to bed
#	  all controlled by generic items
#
#	  sec_living, sec_zoe_bed, sec_zoe_toilet, sec_chloe_bed, sec_chloe_toilet, 
#	  sec_bed1, sec_bed1_toilet, sec_bed1_kitchen, sec_kitchen,sec_floods
#
#	  all  are tied to 'on' state of $Security_Lighting and have states of 'inactive,1,2,3,4,5,6'
#	  
#my sec_timer1 = new Timer;
#my sec_timer2 = new Timer;
#my sec_timer3 = new Timer;
#if ($time_now eq '23:00' and state $sec_living eq 'inactive') { set $sec_living 1}
	

	

$CodeTimings::CodeTimings{'Lights_timings End'} = time();



