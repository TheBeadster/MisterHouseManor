# category = HVAC
#
#@ Radiators and DHW timing for the whole house and annex etc
#@ including the ground source heat pump
#@ the system from Sept 2014 on, works on a "Supply and Demand" model
#@ these timers turn on/off the demands 
#@ ::see manor technics for layout and detail of the system:; 
#@ "Heating control.pl" is the code that controls of the "Supply" 
#@ it deals with all the actual on/off of the boilers and pumps
#@ and the thermostats as required by the "Demands" on the system  
#@ heating temperatures.pl   does the data gathering of temperatures 
#@ heating logging.pl deals with datalogging the temps


my $DHW_boost = new Timer;


$Summer_heating_Strategy = new Generic_Item;
$Summer_heating_Strategy_for_web = new Generic_Item;


if ($Month < 4 or $Month > 9){
		$house_adjust = 0;
		set $Summer_heating_Strategy 'off' if state $Summer_heating_Strategy ne 'off';
		set $Summer_heating_Strategy_for_web 'Winter heating strategy is being used ';
		#print_log "house adjust temp ".$house_adjust;
	}else{

		$house_adjust = 2;    # this is how close the heating will try to get to
		set $Summer_heating_Strategy 'on' if state $Summer_heating_Strategy ne 'on';
        set $Summer_heating_Strategy_for_web 'Summer heating strategy is live';
	}






#print "Not summer " if !$Summer_heating_Strategy;

#----------------------- DHW control ----------------------------

# in the summer only the immersion heater is used so we decide here which to turn on
# call this routine to turn on the hot water on/off
# if the immersion heater is being used then it only comes on at night on the economy seven

$V_DHW_Control = new Voice_Cmd("Hot water turn [on,off]");

 if ($state = said $V_DHW_Control){
   &DHW_control ($state) ;
    
 }
sub DHW_control{

	# if the command is off, then just turn both off
 
	if (state $Summer_heating_Strategy eq 'on'){
		# so only comes on at night if on immersion heater'
		print 'summer heat on DHW';
        if (@_[0] eq 'on'){
			if (time_between '1am','6am' or state $Status_DHW_Boost eq'on'){
				# so only comes on at night if on immersion heater'
				print_log "Setting immersion heater DHW to ". @_[0];
				set $HV_DHW_Immersion_relay @_[0] if state $Status_House_DHW_immersion ne  @_[0];
				#always turn off the water DHW pump
				set $House_DHW  'off' if state $House_DHW ne  'off';
			}
		}else{
			# can turn immersion heater off at anytime
				print_log "Setting immersion heater DHW to ". @_[0];
				set $HV_DHW_Immersion_relay @_[0] if state $Status_House_DHW_immersion ne  @_[0];
		}


	}else{
		#if (!time_between '1am','6am'){
		print_log "Setting GSHP and pump DHW to ". @_[0];
		set $House_DHW  @_[0] if state $House_DHW ne  @_[0];
		# turn off immersion heater always
		set $HV_DHW_Immersion_relay 'off' if state $Status_House_DHW_immersion ne  'off';

		#}
        # after 45 mins put the immersion heater on to help the hot water
		# and reset the timer to turn it off after another 45mins
		# unless its turned off when DHW 
        if (@_[0] eq 'on'){  
			set $DHW_boost 45*60, sub{
				set $HV_DHW_Immersion_relay 'on' if state $Status_House_DHW_immersion ne  'on';
				set $DHW_boost 45*60, sub{
					set $HV_DHW_Immersion_relay 'off' if state $Status_House_DHW_immersion ne  'off';
				}
			}
	   }
 
	}
}





#=--------------------------------------------------------------



# --------------------------- heat DEMAND control ------------------------------------------------
#
#
#             Radiators and DHW timings on/off are the heat demands






if (time_now("00:01") and state $T_avg_House < 18){

		set $Buffer_Tank_Boost_GSHP 'on'	 

		        }

if (time_now("01:00") ){

		set $Buffer_Tank_Boost_GSHP 'off';

		# give a little blip in the night if its cold 
	    if (state $T_avg_House < 16){set $House_Heating 'on'}; 
}				


if (time_now("02:00") ){
	set $House_Heating 'off';
	if (state $Summer_heating_Strategy eq 'on'){&DHW_control ('on') };   # set the dhw  to ON}; 
}


if (time_now("3:30") and state $Summer_heating_Strategy eq 'off'){
	
		set $Buffer_Tank_Boost_GSHP 'on'	 

}

if (time_now("04:00") ){
        &DHW_control ('on') ;   # set the dhw  to ON	       
		set $Buffer_Tank_Boost_GSHP 'off'		  
 }
				 # Turn on house rads early  if its cold,

				 
if (time_now("04:00" )and state $T_entryGEN < -2  ){
	 set $House_uFloor_Heating  'on';    

 }


if (time_now("04:59" )and state $T_entryGEN < -5  ){
	 set $House_Heating 'on';    
     &DHW_control ('off');
 }

if (time_now("05:00") ){
	   if (state $Summer_heating_Strategy eq 'off'){set $House_uFloor_Heating 'on'}; 
	  &DHW_control ('off');
 }
if (time_now("05:01") ){
  &DHW_control ('off');
 }






if (time_now("06:00" )and state $T_entryGEN < -2  ){
	 set $House_Heating 'on';    
     &DHW_control ('off');
 }


if (time_now("06:30") ){
	 set $House_Heating 'on';    
	 set $Annex_Heating 'on';
     set $House_uFloor_Heating 'off';  
     #set $eTRV_ST_Bed_Master 17 ;            # turn the rads down in the main bedroom.  # add if windows open 
	 #set $eTRV_ST_Bed_Master2 17
}



#all off in late morning
if (time_now("8:00") and $Weekday and state $T_entryGEN > 10 ){
		set $Annex_Heating 'off';
		set $House_Heating 'off';
 
}

if (time_now("9:30") and $Weekday and state $T_entryGEN > 6  ){
		set $Annex_Heating 'off';
		set $House_Heating 'off'
}
                     
if (time_now("10:30" )and state $T_entryGEN > 2  ){  # if its less than freezing then leave it on 
	  set $House_Heating 'off';
	  set $Annex_Heating 'off'
 }	


			# dhw on in afternoon
			


if (time_now("10:30") and state $Summer_heating_Strategy eq 'off' ){

    set $Buffer_Tank_Boost_GSHP 'on'

#puts some heat into the tank to allow the GSHP to catch up when doing the DHW
}


if (state $T_HeatStore_Upper_GEN gt 43 and state $T_HeatStore_Upper_GEN ne "error" and state $Buffer_Tank_Boost_GSHP eq 'on'){

  &DHW_control ('on') ;   # set the dhw on early because the buffer tank is upt to temp
  set $Buffer_Tank_Boost_GSHP 'off'

}

if (time_now("11:10") ){
	    &DHW_control ('on') ;   # set the dhw indictor to ON
	 	set $House_Heating 'off';  # turn them off in case of outside temp <0
	    set $Annex_Heating 'off';
		set $Buffer_Tank_Boost_GSHP 'off'
}


		 # Radiators on / dhw off, cycle between the rads and the underfloor Radiators
		
if (time_now("12:00") ){
        if (state $Summer_heating_Strategy eq 'off'){set $House_uFloor_Heating 'on'};
        set $Annex_Heating 'on';         
       	&DHW_control ('off') if state $Summer_heating_Strategy eq 'off';  #leave immersion heater on in winter
        set $Buffer_Tank_Boost_GSHP 'off'
}



if (time_now("13:00") ){
	  set $House_Heating 'on';
	  &DHW_control ('off');
      set $House_uFloor_Heating 'off'
}


		 

if (time_now("14:30") ){
	  if (state $Summer_heating_Strategy eq 'off'){
          set $House_uFloor_Heating 'on';
     	  set $House_Heating 'off'
      }
}		
# blip the DHW
if (time_now("15:30") ){
       &DHW_control ('on') ;
	   
}




if (time_now("16:00") ){
	  &DHW_control ('off') ;
	  set $House_Heating 'on';
	 # set $House_uFloor_Heating 'on';
	  	 
	 #set $eTRV_ST_Bed_Master 25;            # turn the rads up in the main bedroom.
	 #set $eTRV_ST_Bed_Master2 25  
}

if (time_now("18:30") ){
      
	   set $House_uFloor_Heating 'off'
}



if (time_now("21:30") and state $T_entryGEN > 4 ){
	  set $House_Heating 'off';
	  set $Annex_Heating 'off'
}

if (time_now("22:30") ){
	  set $Annex_Heating 'off';
	  set $House_Heating 'off';
	  	 

}
# rad valves for unused rooms
# chloes bedroom and down stairs bathroom

# if movement twice in a day then turn on heating until no movement for 1 whole day

$Bed_Chloe_movement_Cntr = new Generic_Item;
$Bed_Downstairs_movement_Cntr = new Generic_Item; 
 
# these counters are dne by the securiy code
# but acted upon here







#    --------------     Annex DHW electric water heater   -----------------------------
#              requires the key on the pad in the annex, which sets the state of $Annex_water_heater_allowed_on eq
#              see mh.private.ini under HVAC

$Annex_DHW -> tie_time("06:45",'on',"Annex DHW turned On"); 
#if (time_now("06:45") ){ #and state $Annex_water_heater_allowed_on eq 'on'){
	#                set $Annex_DHW 'on'

  #                      }
if (time_now("09:30") ){
	               set $Annex_DHW 'off'
                        }

if (time_now("12:00") ){ #and state $Annex_water_heater_allowed_on eq 'on'){
	                set $Annex_DHW 'on'
                       }
if (time_now("12:30") ){
	                set $Annex_DHW 'off'
                        }

if (time_now("18:30")){ # and state $Annex_water_heater_allowed_on eq 'on'){
	               set $Annex_DHW 'on'
                       }

if (time_now("21:00") ){
	                set $Annex_DHW 'off'
                        }	



