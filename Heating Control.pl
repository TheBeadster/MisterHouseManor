# category = HVAC
#
#@ As from Sept 2014 on with the new buffer tank
#@ the heating system works on a "Supply and Demand" model
#@ this .pl controls all the "Supply" aspects of the system
#@ "heating timings.pl" controls the "Demands" on the sytem

#@ :: see manor technics for layout and detail of the system
$CodeTimings::CodeTimings{'Heating_control Start'} = time();
=begin
 see below for control of Annex heating and GSHP etc


		1st some basics declarations

		Heating_ON        yes /no   this is the overall control of the heating yes = on, no stops all systems
		Heat_tolerance
				this is set to 0 zero for winter and somehwere between 10 and 20 for summer
				it decide how har the heating trys to get the required temps.

				adjust this to get the heating to go  of in the summer.
              
          in the summer the DHw is done by the electric immersion heater
          the oild boiler and gshp are not run
          the gshp is run for an hour once a week to make sure it is OK

              
      ----------------------------------------

    these below  are declared in Homevison.pl the relays are controlled by homevison output port
 
      $HV_DHW_pump 

      $HV_Rads_pump

      $HV_uFloor_pump

      $HV_DHW_Immersion_relay

      set them either on of off

      ----------------------------------------

=cut





my $Heating_states = 'on,off';
my $T_target;
my $oilBoilersetpoint;
my $In_temp;
my $HHS ;
$T_HHS = new Generic_Item;
my $AnnexxSet;
my $house_adjust;
my $Log_Header;

my ($YY1,$YY2,$YY3,$YY4,$YY5);

## these are so we can enable disbale the heatsources in case there is a issue or maintanace work


# OIL boiler controls --------------------------------------------------------------

#$Oil_Boiler_restart_count = new Generic_Item;

my $Heating_Enable_States ='enabled,disabled';
$Oil_Boiler_Enable = new Generic_Item; 
set_states $Oil_Boiler_Enable split ',',$Heating_Enable_States; 

$Oil_Boiler_Enable -> tie_event('&enable_Oil_Boiler'); 
$V_OIL_Boiler_Enable = new Voice_Cmd("set the Oil Boiler to [enabled,disabled]");
if ($state = said $V_OIL_Boiler_Enable){set $Oil_Boiler_Enable $state};


sub enable_Oil_Boiler {
      
        if(state $Oil_Boiler_Enable eq 'enabled'){
            print_log " Enabling the Oil boiler and turning it on";
            set $OilBoilerMessageForWeb ' ';
            set $Status_oilBoilerTimer 'off';
           # set $tmr_OilBoiler_Delay 0;
            set $BarioNET_BA2_TCPctrl 'Oil_Boiler_on'

            
        }
}



#these lines put them in known state in case of a random state
if (state $Oil_Boiler_Enable ne 'enabled' and state $Oil_Boiler_Enable ne 'disabled'){set $Oil_Boiler_Enable 'enabled'}
if (state $GSHP_Enable ne 'enabled' and state $GSHP_Enable ne 'disabled'){set $GSHP_Enable 'enabled'}



#$tmr_OilBoiler_Delay = new Timer;   	 # stops the oil boiler comin on for 10 mins when heating come on.
$OilBoilerMessageForWeb = new Generic_Item;
$Status_oilBoilerTimer = new Generic_Item;   # becuase inactin doesnt appear to work all the time


# using the timer for 35600 second caused problems
# now done with generic variable , to do with restarts that loose the time 
$OilBoilerStartTime = new Generic_Item;

if (time_greater_or_equal (state $OilBoilerStartTime) and state $Status_oilBoilerTimer eq 'on'){
    set $Status_oilBoilerTimer 'off';
    set $OilBoilerMessageForWeb ' ';

}


sub setOilBoilerTimer{
    set $OilBoilerMessageForWeb 'on timer delay';
    set $Status_oilBoilerTimer 'on';
    set $OilBoilerStartTime  time_add "$Time_Now +0:30";
    
}


$V_OilBoilerTimer = new Voice_Cmd("Turn oil delay timer [on,off]");
 if ($state = said $V_OilBoilerTimer){
    set $Status_oilBoilerTimer $state;
    print "oil boiler delay timer turned to $state";
    set $OilBoilerMessageForWeb ' ';

 }

     

   #   GSHP stuff ----------------------------------------------------------------------------------------------------------   



$GSHP_Enable = new Generic_Item;
set_states $GSHP_Enable split ',',$Heating_Enable_States;


$tmr_DHW_heat = new Timer;		 # runs the dhw for 1.5 hours
$tmr_uFloor = new Timer;		 # for running the underfloor heating

$Status_DHW_Boost = new Generic_Item;
$DHW_boostEndTime = new Generic_Item;

$DHW_boost_for_web = new Generic_Item;
set_states $Status_DHW_Boost split ',',$Heating_states;


$V_DHW_Boost = new Voice_Cmd("Boost the main House hot water [on,off]");

 if ($state = said $V_DHW_Boost){
    set $Status_DHW_Boost $state;
    print "DHW setboost set to $state";
    set $DHW_boostEndTime time_add "$Time_Now +1:30";
    &DHW_control ('on') ;
    set $DHW_boost_for_web " On boost"
    
 }

if (time_greater_or_equal (state $DHW_boostEndTime) and state $Status_DHW_Boost eq 'on' ) {
    set $Status_DHW_Boost 'off';
    set $DHW_boost_for_web "";
    &DHW_control ('off') 
}


#If off then the auto control is off, ie its on manual, this allows manual control via voice command to turn on/off physical items
$HVAC_Auto =new Generic_Item;
set_states $HVAC_Auto split ',',$Heating_states;

if ($Reload or $Startup or $Reread){
    
    # defaults to auto control after startup or reboot
    set $HVAC_Auto 'on';


    set $T_setpoint_houseDHW  $config_parms{OilBoilerDHWSetPoint};#55;#; # from mh.private.ini
    set $T_setpoint_Annex $config_parms{AnnexTempSetpoint};
    set $T_setpoint_House $config_parms{HouseTempSetpoint};
 
    # defaults to auto control after startup or reboot
}










# overall control of all heat demand
# these are what you change to turn ON/off the heat demands
$House_Heating = new Generic_Item;
set_states $House_Heating split ',',$Heating_states;
# this controls the radiators




$Annex_Heating = new Generic_Item;
set_states $Annex_Heating split ',',$Heating_states;
#$Annex_Heating  -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log","Annex Heating now     $state")');




$House_Radiators = new Generic_Item;         # wether the house RADIATORS are on or off.
set_states $House_Radiators split ',',$Heating_states; # status of the ufloor in the house
#$House_Radiators  -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log","House Heating now      $state")');

$Status_House_Radiators = new Generic_Item;    #this is set by the homevision read of the ports
set_states $Status_House_Radiators split ',',$Heating_states;
#$Status_House_Radiators -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",    "HV report Rads pump now   $state")');

my $HVRDS;
if((state $House_Radiators ne state $Status_House_Radiators)and ( $New_Second and new_second 3)){
  
    $HVRDS = state $House_Radiators;
      print_log " turning rads $HVRDS";
    set  $HV_Rads_pump  $HVRDS;
}


$House_DHW = new Generic_Item;  	# wether the DHW in the house is on or not
set_states $House_DHW split ',',$Heating_states;
#$House_DHW -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",    "House DHW now      $state")');


#these are set by the homevision read of the ports

$Status_House_DHW = new Generic_Item;    
set_states $Status_House_DHW split ',',$Heating_states;
#$Status_House_DHW -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",    "HV report DHW pump now   $state")');

$Status_House_DHW_immersion = new Generic_Item;
set_states $Status_House_DHW_immersion split ',',$Heating_states;



#---------------------------  hot water stuff --------------------------------------------------------




my $DHWSS;
# this code track the state we want the DHW to be in, it checks consatntly to see if Homevison reports the actual relay state 
# is the same as we want, if not it trys again to set the relay via Homevison
# a simple tie_state wouldnt keep trying to set the relay
if ((state $House_DHW ne state $Status_House_DHW) and ( $New_Second and new_second 3)){
	   $DHWSS = state $House_DHW;
       set $HV_DHW_pump $DHWSS;
       }





$V_Test_the_DHW = new Voice_Cmd("Turn the DHW [on,off]");

if ($state = said $V_Test_the_DHW){
    &DHW_control($state);
} 



# ----------------------------------- underfloor heating stuff ------------------------------------------------------------



$House_uFloor_Heating = new Generic_Item;  	# wether the underfloor heating  in the house is on or not
set_states $House_uFloor_Heating split ',',$Heating_states;
#$House_uFloor_Heating -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",    "House uFloor now   $state")');

$House_uFloor_Heating -> tie_items($HV_uFloor_pump);   # this adds a layer ,but makes the operation clearer

$Status_uFloor_Heating = new Generic_Item;    #this is set by the homevision read of the ports
set_states $Status_uFloor_Heating split ',',$Heating_states;
#$Status_uFloor_Heating -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",    "HV report Ufloor pump now   $state")');


# this code track the state we want the DHW to be in, it checks consatntly to see if Homevison reports the actual relay state 
# is the same as we want, if not it trys again to set the relay via Homevison
if ((state $House_uFloor_Heating ne state $Status_uFloor_Heating )and ( $New_Second and new_second 3)){
	   $DHWSS = state $House_uFloor_Heating;
       set $HV_uFloor_pump $DHWSS;
       }


$Buffer_Tank_Boost_GSHP = new Generic_Item;
set_states $Buffer_Tank_Boost_GSHP split ',',$Heating_states;
 #$Buffer_Tank_Boost_GSHP -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log","Buffer tank boost now $state")');

 $V_HVAC_Auto= new Voice_Cmd("Turn heating Auto Control  [on,off]");
if ($state = said $V_HVAC_Auto){
	if ($state eq "on"){
	
	      set $HVAC_Auto $state
	
    }
     
}







#$House_avg_Temp = new Generic_Item;   # calced in heating.pl
#$House_Desired_temp = new Generic_Item; 
#set $House_Desired_temp  '20.5';
#$OilBoilerTemperatureSetPoint = new Generic_Item;
# set  $OilBoilerTemperatureSetPoint '65';
#$Annex_DHW = new Generic_Item;  declared in Barionet ctrl node2.pl
## set by Node2 bario Ctrl.pl when a message from the barionet says the relay is on or off



$Annex_DHW = new Generic_Item;
$Annex_water_heater_allowed_on = new Generic_Item;


set_states $Annex_water_heater_allowed_on split ',',$Heating_states;
set_states $Annex_DHW split ',',$Heating_states;



#$Annex_water_heater_allowed_on -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log","Annex DHW allowed now $state")');


$Tmr_AnnexWater_heater_boost = new Timer;   # used to allow the annx water heater to boost for 2 hours out of its normal hours

$V_AnnexDHW = new Voice_Cmd("set Annex DHW [on,off]");

if ($state = said $V_AnnexDHW){
	if ($state eq "on"){
	    set $Annex_DHW 'on'
	}else{
	
        set $Annex_DHW 'off'
    }
}

if ((state $Annex_DHW ne state $Status_Annex_DHW) and $New_Second){
	   if (state $Annex_DHW eq 'on'){
           set $BarioNET_BA2_TCPctrl 'AnnexDHW_on'
       }else{
           set $BarioNET_BA2_TCPctrl 'AnnexDHW_off'
       }
}


$V_Annex_heating_pump= new Voice_Cmd("set Annex heating pump [on,off]");

if ($state = said $V_Annex_heating_pump){
	if ($state eq "on"){
	
	      set $BarioNET_BA2_TCPctrl 'Annex Heating on'
	}else{
	
          set $BarioNET_BA2_TCPctrl 'Annex Heating off'
    }
     
}


$V_GSHP= new Voice_Cmd("Turn GSHP [on,off]");

if ($state = said $V_GSHP){
	if ($state eq "on"){
	
	      set $BarioNET_BA2_TCPctrl 'GSHP_on'
	}else{
	
          set $BarioNET_BA2_TCPctrl 'GSHP_off'
    }
     
}



$V_OIL_Boiler= new Voice_Cmd("Turn Oil Boiler [on,off]");

if ($state = said $V_OIL_Boiler){
	if ($state eq "on"){
	
	      set $BarioNET_BA2_TCPctrl 'Oil_Boiler_on'
	}else{
	
          set $BarioNET_BA2_TCPctrl 'Oil_Boiler_off'
    }
     
}

    
#      $HV_DHW_pump 

#      $HV_Rads_pump

#      $HV_uFloor_pump
#
 

 $V_DHW_pump= new Voice_Cmd("Turn house DHW pump [on,off]");
if ($state = said $V_DHW_pump){
	if ($state eq "on"){
	
	      set $HV_DHW_pump 'on'
	}else{
	
          set $HV_DHW_pump 'off'
    }
     
}

 $V_Rads_pump= new Voice_Cmd("Turn House Radiator pump [on,off]");
if ($state = said $V_Rads_pump){
	if ($state eq "on"){
	
	      set $House_Radiators 'on'
	}else{
	
          set $House_Radiators 'off'
    }
     
}

 $V_uFloor_pump= new Voice_Cmd("Turn Underfloor pump [on,off]");
if ($state = said $V_uFloor_pump){

	if ($state eq "on"){
	
	      set $HV_uFloor_pump 'on'
	}else{
	
              set $HV_uFloor_pump 'off'
             }
     
     }
    







#$Annex_Desired_temp = new Generic_Item;
#set $Annex_Desired_temp '20.5';
#the temp sensor for annex is on the roof so i scale it to outside temp
my $annexT_temp;

if (state $T_entryGEN < 9) {
     $annexT_temp = 8 - state $T_entryGEN
} else {
     $annexT_temp = 0
}
$annexT_temp = $config_parms{AnnexTempSetpoint} + $annexT_temp;

set $T_setpoint_Annex $annexT_temp;

#$DHW_Desired_temp = new Generic_Item;
#set $DHW_Desired_temp '55';

# puts the heating on if the temp gets below this value, stops house freezing.
#$Minimum_temp = new Generic_Item;
#set $Minimum_temp '10';


$Heating_Booster_House = new Generic_Item;
set_states $Heating_Booster_House split ',',$Heating_states;
$Heating_Booster_House -> tie_event(' logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log","Heating Booster now $state")');

$tmr_Heating_Booster_House = new Timer;
set $Heating_Booster_House 'off' if state $Heating_Booster_House eq '';

#$Heating_Booster_House-> tie_event('&Heating_Booster_House_change');

$tmr_Heating_Booster_House_remain= new Generic_Item;  # used on web page to show how long timer is running for

$tmr_DHW_Booster_House_remain= new Generic_Item;  # used on web page to show how long timer is running for

$V_Heating_boost= new Voice_Cmd("Turn Heating Boost [on,off]");
if ($state = said $V_Heating_boost){
	if ($state eq "on"){
	
	     
        set_with_timer $Heating_Booster_House 'on',14400,'off';
        #speak 'The HEATING boost is ON,      The House will melt down in Tee minus four hours, you have been warned';
        set $House_Radiators 'on';   # turned off with normal process timings
        &setOilBoilerTimer;
	}else{
	
        set $Heating_Booster_House 'off'
       
             }
     
}
    
 if (active $tmr_Heating_Booster_House and new_minute){
 # set $tmr_Heating_Booster_House_remain = hours_remaining ($tmr_Heating_Booster_House);
  print_log hours_remaining $tmr_Heating_Booster_House
  #for the webpage
  
 }
	

# force a read of the barionet output states?

if( $New_Minute and new_minute 10 ){
        set $BarioNET_TCPctrl "getio,601";

}


# ------------------------------ Heat Supply control -------------------------------------------

if (state $HVAC_Auto eq 'on'){
        
        
        # allows the auto control of items to be off so we can test the control circuits
        
=begin

            heat supply is the GSHP and the Oil boiler
                    if there is demand
                $House_Radiators or $Annex_Heating or $House_DHW  is ON
            then
            $GSHP is ON
                    
            when the GSHP is turned ON a delay timer for the oil boiler is started
                    while this is running the oil boiler cannot start
                    this is to allow the GSHP to do get warm 
                    the timer runs for 2 hours
            if after two hours the return temp from the house or annex is low
            then the oil boiler is used to help the GSHP




    if (state $House_DHW eq 'on' or state $House_Radiators eq 'on' or state $House_U_floor eq 'on' or state $Annex_Heating eq 'on'){

     changed from turning on the heat sources based on the overall control to 
     turning on based on any of the pumps being on, or the GSHP will cycle often when the buffer tanks is up to temp.

       -----------------------  Thermostatic control --------------------------------------------------------
        
     control house temp by radiators
=cut

    if (state  $House_Heating eq 'off' and state $Heating_Booster_House eq 'off'){
        # print_log "rads OFF";
        set $House_Radiators 'off'
        
            
    }else{
        # print_log "rads on";  
        # so heating is on , so control the temperature
        if   (state $T_avg_House > ( state $T_setpoint_House)){  #  -  $house_adjust) ){
                if (state $Status_House_Radiators ne 'off'){ set $House_Radiators 'off'}
            }else{   
        #print_log "rads ON";
                if (state $T_avg_House < (state $T_setpoint_House - 1 -  $house_adjust)){
                    if (state $Status_House_Radiators ne 'on') { set $House_Radiators 'on'}
                }
        }

    }

    #the house DHW is left to run its time; 
    
    
    
    
    
        #control the annex temp

    if ((state $T_AnnexRoom_GEN <  (state $T_setpoint_Annex - 1 )#- $house_adjust)
                                        or state $T_AnnexRoom_GEN eq 'error' 
                                        or state $T_AnnexRoom_GEN eq '255') 
                                        and (state $Annex_Heating eq 'on' or state $Heating_Booster_House eq 'on') )
    {
        set $BarioNET_BA2_TCPctrl 'Annex Heating on' if (state $Status_Annex_Heating_pump eq 'off')
    }else{
        if (state $T_AnnexRoom_GEN >  (state $T_setpoint_Annex ) or (state $Annex_Heating eq 'off' and state $Heating_Booster_House eq 'off')){
            set $BarioNET_BA2_TCPctrl 'Annex Heating off' if (state $Status_Annex_Heating_pump eq 'on')
        }
    }



    my ($HHS_u,$HHS_l);

        # calc the buffer tank/heatstore avg temp, the code will use the avg of both if they are working or either one
        # if both are not working then 0 is used to show error
    if (state $T_HeatStore_Lower_GEN == 255 or  state $T_HeatStore_Lower_GEN eq 'error'){$HHS_l = 0} else {$HHS_l = 1};
    if (state $T_HeatStore_Upper_GEN == 255 or  state $T_HeatStore_Upper_GEN eq 'error'){$HHS_u = 0} else {$HHS_u = 1};


    $HHS = state $T_HeatStore_Lower_GEN  * $HHS_l;
    $HHS = $HHS + (state $T_HeatStore_Upper_GEN * $HHS_u);
    if ($HHS_l != 0 and $HHS_u != 0 ){
        $HHS = $HHS / 2} 
        

        # if a zero in hhs then indicates and error

    set $T_HHS $HHS;
            
            
            
            
    #  if there is a demand then turn on the heat supplies , 
    # for DHW this is for winter only it uses the immersion heater in summer
    #    see sub DHW_control{ in heating timing for  descions on DHW supply
    # first the GSHP
    if ((state $Status_House_DHW eq 'on' and state $Summer_heating_Strategy eq 'off') 
                        or state $HV_Rads_pump eq 'on' 
                        or state $HV_uFloor_pump eq 'on' 
                        or state $Status_Annex_Heating_pump eq 'on' 
                        or state $Buffer_Tank_Boost_GSHP eq 'on' 
                        or state $Heating_Booster_House eq 'on'){
                
        if (state $Status_GSHP eq 'off' and state $GSHP_Enable eq 'enabled'  ){   			# only do this if the GSHP is not already ON and if the heatstore is cold
            set $BarioNET_BA2_TCPctrl 'GSHP_on';    	# start the heat pump

            if (state $Status_House_DHW ne 'on' and state $Status_oilBoilerTimer eq 'off'){&setOilBoilerTimer}  		# set delay to 1 hour if 	DHW is not wanted
        
        }






                
        #-------------------------  OIL BOILER control ----------------------------
        #





        $In_temp = state $T_entryGEN;
        if($In_temp > 20 ){
            $In_temp = 20
        }
        if($In_temp < 0 ){
        $In_temp = $In_temp - 4
        }


        $oilBoilersetpoint = 28 + ( 26 - $In_temp);   # varies the oil boiler on temp relative to the ambient temp
            
        #was 31 dropped to 28 in oct 2022 when oil went expensive


        # boost oil boiler water temp for hot water
        if (state $HV_DHW_pump eq 'on'){
            $oilBoilersetpoint = state $T_setpoint_houseDHW    # 55 deg
        }

        set $T_oil_boilerSetpoint $oilBoilersetpoint;


        if( state $T_entryGEN < 2 ){
            #  if it cold outside then dont delay the oil boiler coming on
            set $OilBoilerStartTime $Time_Now;
        }     


         #print_log "Oil Boiler Tmr status  ".state $Status_oilBoilerTimer."  ".state $OilBoilerStartTime."   ".state $Oil_Boiler_Enable;

        if (state $Status_oilBoilerTimer eq 'off' and
            $HHS < $oilBoilersetpoint -2  and   # if heatstore is below the oil boiler setpoint
            (   ((state $HV_Rads_pump eq 'on'
                or
                    state $HV_uFloor_pump eq 'on'
                or
                    state $Status_Annex_Heating_pump eq 'on') 
                and 
                (state $Summer_heating_Strategy eq 'off')
            ) 
                    
                or
                    state $Status_House_DHW eq 'on'
                    
            ) 
                or
                state $Heating_Booster_House eq 'on'
            #or 
                #($HHS = 0 and  state $T_entryGEN <3)   # zero indicates and error in the sensors so we put on the oil boiler if its cold out side
            )
                
                {
                
                ## ADD in control oil boiler for DHW boost if its not working in the cold days
                    if (state $Status_Oil_Boiler ne 'on' and state $Oil_Boiler_Enable eq 'enabled'){
                         set $BarioNET_BA2_TCPctrl 'Oil_Boiler_on';
                        # do a restart of aoil boiler after 5 mins incase it doesnt fire up first time , this is a stacked version see mh/code/examples/test_states_stacked.pl for examples
                        #print_log "-------------------------------------------- Oil boiler set to on";
                        #set_with_timer $BarioNET_BA2_TCPctrl ('Oil_Boiler_on~300~Oil_Boiler_off~20~Oil_Boiler_on~300~Oil_Boiler_off~20~Oil_Boiler_on');


                    	
                }

                #print_log"oil boiler on";
        } else {
               if ($HHS >= $oilBoilersetpoint){ 
                    if (state $Status_Oil_Boiler ne 'off'){
                        set $BarioNET_BA2_TCPctrl 'Oil_Boiler_off'
                    }  # turn off the oil boiler if its ON
               }
                # print_log"oil boiler OFF";	    
        }

    }else{
        # turn off the heat supplies if there is no demand
        
        set $BarioNET_BA2_TCPctrl 'Oil_Boiler_off' if state $Status_Oil_Boiler ne 'off';  # turn off the oil boiler if its ON
        set $BarioNET_BA2_TCPctrl 'GSHP_off' if state $Status_GSHP ne 'off';;    	# stop the heat pump if its on

    }

    #  -------------------- END of heats supply control nased on Demand

    # a final catch to safely turn off the supplys if they are disabled

    if(state $Oil_Boiler_Enable eq 'disabled' and state $Status_Oil_Boiler ne 'off'){
        set $BarioNET_BA2_TCPctrl 'Oil_Boiler_off'
    }
    if (state $Status_GSHP ne 'off' and state $GSHP_Enable eq 'disabled'  ){   			# only do this if the GSHP is not already ON and if the heatstore is cold
        set $BarioNET_BA2_TCPctrl 'GSHP_off';
    }



}  # end of $HVAC_Auto control loop





$CodeTimings::CodeTimings{'Heating_control End'} = time();


















