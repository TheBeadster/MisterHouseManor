# category=Lights

# lights control, mainly through homevison see homevision.pl for a list of homevision interfaces
# the homvision X10 accepts
#
#  on , off , Brighten once , Dim once
#  or for dimmers you can sen 0-100 for the intensity to set to directly.
#  -3   will dim it 3 times, and +10 will brightn 10 times etc.
#
#
#

$CodeTimings::CodeTimings{'Lights Start'} = time();


my $Light_states = 'on,off';
my $Light_states2 = 'on,off';#,Brighten,Dim,55%,25%';
my $old_Dark;




#$Security_Lighting = new Generic_Item;
#set_states $Security_Lighting split ',' $Light_states;
my $State;    # $old_dark is used to turn things on when it turns dark
my $Garden_Mood_states ='A,B,C,D,E';
my $Garden_Mood = new Generic_Item;
set_states $Garden_Mood split ',',$Garden_Mood_states;
$V_Garden_Mood = new Voice_Cmd("turn garden lights to mood  [$Garden_Mood_states]");
if($State= said $V_Garden_Mood){
set $Garden_Mood $State
}


$Rock_lights1 = new X10_Item('F5','homevision');

$Rock_lights = new Generic_Item;
set_states $Rock_lights split ',',$Light_states;
$V_Rock_lights = new Voice_Cmd("turn garden rock lights [$Light_states]");
$Rock_lights ->tie_items($Rock_lights1);
$V_Rock_lights ->tie_items($Rock_lights);


$Patio_lights1 = new X10_Item('A5','homevision');
$Patio_lights = new Generic_Item;
set_states $Patio_lights split ',',$Light_states;
$V_Patio_lights = new Voice_Cmd("turn patio lights [$Light_states]");
$Patio_lights ->tie_items($Patio_lights1);
$V_Patio_lights ->tie_items($Patio_lights);

$Ensuite_lights1 = new X10_Item('C1','homevision');
$Ensuite_lights = new Generic_Item;
set_states $Ensuite_lights split ',',$Light_states;
$V_Ensuite_lights = new Voice_Cmd("turn Ensuite lights [$Light_states]");
$Ensuite_lights ->tie_items($Ensuite_lights1);
$V_Ensuite_lights ->tie_items($Ensuite_lights);

$Hall_lights1 = new X10_Item('C2','homevision');
$Hall_lights = new Generic_Item;
set_states $Hall_lights split ',',$Light_states2;
$Hall_lights ->tie_items($Hall_lights1);
$V_Hall_lights = new Voice_Cmd("turn Hall lights [$Light_states2]");
$V_Hall_lights ->tie_items($Hall_lights);


$Kitchen_lights1 = new X10_Item('C3','homevision');
$Kitchen_lights = new Generic_Item;
set_states $Kitchen_lights split ',',$Light_states2;
$Kitchen_lights ->tie_items($Kitchen_lights1);
#$V_Kitchen_lights = new Voice_Cmd("turn Kitchen lights [$Light_states2]");
#$V_Kitchen_lights ->tie_items($Kitchen_lights);



$fourway_lights1 = new X10_Item('C4','homevision');
$fourway_lights = new Generic_Item;
set_states $fourway_lights split ',',$Light_states2;
$fourway_lights ->tie_items($fourway_lights1);
$V_fourway_lights = new Voice_Cmd("turn  4 way landing lights [$Light_states2]");
$V_fourway_lights ->tie_items($fourway_lights);

$Mainbath_lights1 = new X10_Item('C5','homevision');
$Mainbath_lights = new Generic_Item;
set_states $Mainbath_lights split ',',$Light_states;
$Mainbath_lights ->tie_items($Mainbath_lights1);
$V_Mainbath_lights = new Voice_Cmd("turn main bathroom lights [$Light_states]");
$V_Mainbath_lights ->tie_items($Mainbath_lights);

$Bed3_lights1 = new X10_Item('C6','homevision');
$Bed3_lights = new Generic_Item;
set_states $Bed3_lights split ',',$Light_states;
$Bed3_lights ->tie_items($Bed3_lights1);
$V_Bed3_lights = new Voice_Cmd("turn Chloe's lights [$Light_states]");
$V_Bed3_lights ->tie_items($Bed3_lights);

$Bed2_lights1 = new X10_Item('C15','homevision');
$Bed2_lights = new Generic_Item;
set_states $Bed2_lights split ',',$Light_states;
$Bed2_lights ->tie_items($Bed2_lights1);
$V_Bed2_lights = new Voice_Cmd("turn Zoe's main lights [$Light_states]");
$V_Bed2_lights ->tie_items($Bed2_lights);

$Bed1_lights1 = new X10_Item('C8','homevision');
$Bed1_lights = new Generic_Item;
set_states $Bed1_lights split ',',$Light_states;
$Bed1_lights ->tie_items($Bed1_lights1);
$V_Bed1_lights = new Voice_Cmd("turn Master bedroom lights [$Light_states]");
$V_Bed1_lights ->tie_items($Bed1_lights);

$flood100_lights1 = new X10_Item('C9','homevision');
$flood100_lights = new Generic_Item;
set_states $flood100_lights split ',',$Light_states;
$flood100_lights ->tie_items($flood100_lights1);
$V_flood100_lights = new Voice_Cmd("turn living room 100 flood lights [$Light_states]");
$V_flood100_lights ->tie_items($flood100_lights);

$Study_lights1 = new X10_Item('C10','homevision');
$Study_lights = new Generic_Item;
set_states $Study_lights split ',',$Light_states;
$Study_lights ->tie_items($Study_lights1);
$V_Study_lights = new Voice_Cmd("turn Study lights [$Light_states]");
$V_Study_lights ->tie_items($Study_lights);

$Mood_lights1 = new X10_Item('C11','homevision');
$Mood_lights = new Generic_Item;
set_states $Mood_lights split ',',$Light_states;
$Mood_lights ->tie_items($Mood_lights1);
$V_Mood_lights = new Voice_Cmd("turn mood lights [$Light_states]");
$V_Mood_lights ->tie_items($Mood_lights);




$Shed_light_small = new Generic_Item;
set_states $Shed_light_small split ',',$Light_states;
$Shed_light_small ->tie_event('&SubShedLightSmallCtrl');
$V_Shed_light_small = new Voice_Cmd("turn dogger shed small lights [$Light_states]");
$V_Shed_light_small ->tie_items($Shed_light_small);

sub SubShedLightSmallCtrl {
  if (state $Shed_light_small eq 'on'){
         set $Modtronix_UDPctrlNode3  "xr2=1" #turn on relay 1

  }else{
        set $Modtronix_UDPctrlNode3  "xr2=0"

  }
}



$Shed_light_OS = new Generic_Item;
set_states $Shed_light_OS split ',',$Light_states;

$V_Shed_lightOS = new Voice_Cmd("turn dogger shed main light [$Light_states]");
$V_Shed_lightOS ->tie_items($Shed_light_OS);
$Shed_light_OS ->tie_event('&SubShedLightCtrl');

sub SubShedLightCtrl{
  if (state $Shed_light_OS eq 'on'){
      print_log" turn on shed OS";
         set $Modtronix_UDPctrlNode3  "xr1=1" #turn on relay 1

  }else{
        set $Modtronix_UDPctrlNode3  "xr1=0"

  }
}




$Glass_Box_Mood_HV = new X10_Item('C7','homevision');
$Glass_Box_Mood_lights = new Generic_Item;
set_states $Glass_Box_Mood_lights split ',',$Light_states;
$Glass_Box_Mood_lights ->tie_items($Glass_Box_Mood_HV);
$V_Glass_Box_Mood = new Voice_Cmd("turn Glass box Mood lights [$Light_states]");
$V_Glass_Box_Mood ->tie_items($Glass_Box_Mood_lights);



# xmas lights are now on a Mihome device Mh0005
# see MiHome_Comms.pl for more info
$Christmas_Lights_HV = new X10_Item('B3','homevision');
$Christmas_Lights = new Generic_Item;
set_states $Christmas_Lights split ',',$Light_states;
$V_Christmas_Lights = new Voice_Cmd("turn Christmas lights [$Light_states]");
$V_Christmas_Lights ->tie_items($Christmas_Lights);

$Christmas_Lights -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "#1.2:".$state'); 
#this is a legacy device a Mihome 2 way comms has to have its name registered see mihome_comm.pl
$Christmas_Lights -> tie_event(' set $Christmas_Lights_HV $state '); 

$Christmas_Lights  -> tie_event('print_log "Turning Xmas lights ".$state');
$Christmas_Lights  -> tie_event('print_log "chrismas lights changed to $state ------------------------------------------------------------------------------------------"');










#$Christmas_Lights_Moon_HV = new X10_Item('K2','homevision');

$Christmas_Lights_Moon = new Generic_Item;
set_states $Christmas_Lights_Moon split ',',$Light_states;
$V_Christmas_Lights_Moon = new Voice_Cmd("turn Christmas Moon light [$Light_states]");
$V_Christmas_Lights_Moon ->tie_items($Christmas_Lights_Moon);
$Christmas_Lights_Moon  -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "#1.2:".$state'); 


$Christmas_Lights_Outside = new Generic_Item;
set_states $Christmas_Lights_Outside split ',',$Light_states;
$V_Christmas_Lights_Outside = new Voice_Cmd("turn Christmas Outside lights [$Light_states]");
$V_Christmas_Lights_Outside ->tie_items($Christmas_Lights_Outside);
$Christmas_Lights_Outside  -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "#1.2:".$state'); 



#- Garden lights ------------------------------------------
$Garden1_light = new Generic_Item;
set_states $Garden1_light split ',',$Light_states;
$V_Garden1_light = new Voice_Cmd("turn Garden lights [$Light_states]");
$V_Garden1_light ->tie_items($Garden1_light);
$Garden1_light -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "#1.1:".$state');

$Garden2_light = new Generic_Item;
$Garden3_light = new Generic_Item;

# OUTSIDE Flood lights control --------------------------------------------------

# basic generis is the status we want the object to be in
$OSFlood_light = new Generic_Item;
$OSFlood_light ->  set_authority('anyone');
set_states $OSFlood_light split ',',$Light_states;

# status is the actual read status the output is in as read from its controller

$Status_OSFlood_light = new Generic_Item;
set_states $Status_OSFlood_light split ',',$Light_states;
$Status_OSFlood_light ->tie_event('logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Outdoor flood lights turned ".$state)');
# allow mh to keep in step with HVis
my $Lstat;
if (state $Status_OSFlood_light  ne state $OSFlood_light){
    $Lstat = state $OSFlood_light;
   set $HV_FloodLights_relay $Lstat;

}

#log outdoor flood lights changed to the security lalarm log files




# spoken command to change the value
$V_OSFlood_light = new Voice_Cmd("turn outside flood lights [$Light_states]");
$V_OSFlood_light ->tie_items($OSFlood_light);
$V_OSFlood_light -> set_authority('anyone');   # this has password bypass for anyone to open it who know the ia5gate.htm URL







# these subr for cortana, gives a return anser as confirmation the action has happened
# you must add the subr name to the password allow file in mh dir
sub turn_outside_flood_lights_on {
    set $OSFlood_light 'on';
    return "Flood lights are on";
}

sub turn_outside_flood_lights_off {
    set $OSFlood_light 'off';
    return "Flood lights are off";
}


#--------------------------------   back door lights control; --------------------------------------
my $OutsideCourtesyTimer = new Timer;
my $OutsideCourtesyTimer1 = new Timer;
my $OutsideCourtesyTimer2 = new Timer;
# the timer to say shut the back door is done in the alarms security.pl to make it tidy



# porch lights control =============================================================






#$OSporch_light = new Generic_Item;


set_states $OSporch_light split ',',$Light_states;

$V_OSporch_light = new Voice_Cmd("Turn porch lights [$Light_states]");
$V_OSporch_light ->tie_items($OSporch_light);

$Status_Porch_light = new Generic_Item;
set_states $Status_Porch_light split ',',$Light_states;

# ensure status of lights outside 
my $ospl;
if ( (state $Status_Porch_light ne state $OSporch_light) and  ($New_Second and new_second 1)      ) {
    # resend the change command until it is the same
    $ospl = state $OSporch_light;
    set $HV_Porch_Light $ospl
}


#------------
#put all in a group called lights

$All_Lights = new Group($OSFlood_light,$OSporch_light,$Garden1_light,$Garden2_light,$Garden3_light,$Shed_light_OS);
$All_Lights ->add($Rock_lights,$Patio_lights,$Ensuite_lights,$Hall_lights,$Kitchen_lights,$fourway_lights,$Mainbath_lights);
$All_Lights ->add($Bed3_lights,$Bed2_lights,$Bed1_lights,$flood100_lights,$Study_lights,$Mood_lights,$Shed_light_small,$Glass_Box_Mood_lights);
$All_Lights ->add($Christmas_Lights);

$Bedroom = new Group($Bed1_lights,$Ensuite_lights);
$Bedroom2 = new Group($Bed2_lights);
$Bedroom3 = new Group($Bed3_lights);
$Living_room = new Group($fourway_lights,$Hall_lights,$Mood_lights,$flood100_lights,$Christmas_Lights);
$Outside = new Group($Christmas_Lights_Outside,$Rock_lights,$Patio_lights,$OSFlood_light,$OSporch_light,$Garden1_light,$Garden2_light,$Garden3_light,$Shed_light_small,$Shed_light_OS);
$Outside_M = new Group($OSFlood_light,$OSporch_light,$Shed_light_small,$Shed_light_OS);

$Mainfloor = new Group($Bed1_lights,$Bed2_lights,$Bed3_lights,$Ensuite_lights,$Mainbath_lights,$fourway_lights);
$Downstairs = new Group($Kitchen_lights,$fourway_lights,$Hall_lights,$Mood_lights,$Study_lights,$flood100_lights,$Glass_Box_Mood_lights);

$Christmas = new Group($Christmas_Lights_Outside,$Christmas_Lights,$Christmas_Lights_Moon);

$Shed_move = new Timer; # keeps light on while no movement
$Shed_light_off = new Timer; # turns off light 30 secs after door shut





$CodeTimings::CodeTimings{'Lights Start'} = time();
