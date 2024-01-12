# category=Lights

$CodeTimings::CodeTimings{'Light_kitchen Start'} = time();

=begin



@ controls the LED lights in the kitch
@ homevison still controls the PIR nd the main lights via X10
@ homevision send Mh the change in the PIR status so it can then change the LED  colours

@ LED control is via MH proxy in kitchen cabinet which is connected to a arduino teensy 2++
@ to do the actual control of the LEDS


Arduino in kitchen control of LED
    //  on  = allows all leds to run accoruing to other flags
    //  off = turn all leds off and ignores flags
    //  K0 / K1  = turn kettle leds off/on
    //  F0  / F1  =turns fridge Leds On/off
    //  FF1  = flashes fridge , even if fridge is on, fridge will the be on/off according to F flag
    //  C    = cylon
    //  H1  = heartbeat 1
    //  H2  = heartbeat 2
    //  LGL = lower glow yellow low
    //  LGH =  lower glow High
    //  UGL = upper glow yellow low
    //  UGH = upper glow yellow high
    //  SL  = sparkles lower
    //  SU  = sparkles upper

    // CA  clear all flages, just use <CA>

 sparkles , kettle and fridge, will  overlay heartbeat, glow and cylon
  flash fridge flashes it 5 tiem and will block code and overlay others

commands must be bracketted with < > ie <off> 
1 turns feature on, a 0 turn off


ie <SL1> turns on lower sparkles
<H10> turn heartbeat 1 off
=cut
#  if(new_minute 2){ 
#    print_log "sending to kitchen proxy";
#    &main::proxy_send( $proxy_by_room{'kitchen'},'play','sound_click1.wav')
#    }
my $KitchenLedStates ='on,off,CA,C1,C0,H11,H10,H21,H20,F1,F0,K1,K0,FF1,SU1,SU0,SL1,SL0,LGL1,LGL0,UGL1,UGL0,UGH1,UGH0';


$test_kitchen_proxy = new Voice_Cmd "Kitchen LED control [$KitchenLedStates]";

set_info $test_kitchen_proxy,"    //  on  = allows all leds to run accoruing to other flags
      off = turn all leds off and ignores flags
      K0 / K1  = turn kettle leds off/on
      F0  / F1  =turns fridge Leds On/off
      FF1  = flashes fridge , even if fridge is on, fridge will the be on/off according to F flag
      C    = cylon
      H1  = heartbeat 1
      H2  = heartbeat 2
      LGL = lower glow yellow low
      LGH =  lower glow High
      UGL = upper glow yellow low
      UGH = upper glow yellow high
      SL  = sparkles lower
      SU  = sparkles upper

     CA  clear all flages, just use <CA>";


## had to use the 'speak' control because cauldnt get the send serial to send , need to work on more
&main::proxy_send( $proxy_by_room{'kitchen'},'speak',$state) if $state = said $test_kitchen_proxy;


#speak "rooms=kitchen $State" if $state = said $test_kitchen_proxy;

if(new_minute 4 and !$Dark and  time_between "$Time_Sunset + 0:15", '11pm'){ 
    print_log"kitchen lights two min";
    #cylon
    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','C1')
    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','C0')
    #heartbeat 1
    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','H11')
    &main::proxy_send( $proxy_by_room{'kitchen'},'speak','H10')


    }



    if (time_now "$Time_Sunset + 0:15" ) {
          &main::proxy_send( $proxy_by_room{'kitchen'},'speak','LGL1')
          &main::proxy_send( $proxy_by_room{'kitchen'},'speak','UGL1')
    }


    my $KitchTimer1 = new Timer;
    my $KitchTimer2 = new Timer;


    if (time_now "11:01 AM" ){

          &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SU1')
          &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SL1')

    };


    if (time_now "15:01 AM" ){

          &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SU0')
          &main::proxy_send( $proxy_by_room{'kitchen'},'speak','SL0')

    };


$CodeTimings::CodeTimings{'Light_kitchen End'} = time();








