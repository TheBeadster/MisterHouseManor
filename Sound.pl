#category = Audio

# these Subr are triggered by varies means  , most from the alarms_Security.pl
$CodeTimings::CodeTimings{'Sound Start'} = time();

##############################################################
#
#
#            XMAS tunes
#
#            for the morning of xmas day.
#
my $Xmas_tune;
my $Xmas_tmr = new Timer;

$v_Play_Random_Xmas_sound = new Voice_Cmd 'Play random Xmas Sound';
&Xmas_tune if said  $v_Play_Random_Xmas_sound;

sub Xmas_tune {
	# rotates through the tunes when living room movement, every 10 mins
	$Xmas_tune = $Xmas_tune + 1;

   	 if (inactive $Xmas_tmr){
        print_log "Xmas tune playing randomly";
	    play "xmas/*.wav"; 
   	    set $Xmas_tmr 300
	}
}   # end xmas tune
#----------------------------------------------------------------------------
# Halloween

#----------------------------------------------------------------------------
my $Halloween_tmr = new Timer;

$v_Play_Random_Halloween_sound = new Voice_Cmd 'Play random Halloween Sound';
&Halloween_tune if $state = said  $v_Play_Random_Halloween_sound;
set_info $v_Play_Random_Halloween_sound "Plays a random halloween sound, will only repeat every 5 minutes";

sub Halloween_tune {
	# rotates through the tunes when living room movement, every 10 mins


   	 if (inactive $Halloween_tmr){
        print_log "Halloween tune playing randomly";
    	play "halloween/*.wav"; 
   		set $Halloween_tmr 300
	}
}


		# the living room play these also on halloween
		# in the Sur Notify_Alarm_LroomPIR_Alarm in alarmssecurity.pl





#
#          tunes for the day to chear us up
#
#            for the mornng of xmas day.
#

my $sound_nature_tmr = new Timer;


   $v_Play_Random_Nature_sound = new Voice_Cmd 'Play random Nature Sound';
   &Nature_Sound if $state = said  $v_Play_Random_Nature_sound;
   set_info $v_Play_Random_Nature_sound "Plays a random nature sound, will only repeat every 15 minutes";


sub Nature_Sound{

	# rotates through the tunes when living room movement, every 10 mins


   	 if (inactive $sound_nature_tmr and time_between '11am','10pm'){
			print_log "playing random nature tune ";
			play "sound_nature/*.wav"; 
			set $sound_nature_tmr 10000
		}
	}


#------------------------------------------------------------------------------
sub Rear_DoorBell {
	  	
                  print_log "Random rear door bells";
		  play "DoorBells/rear/*.wav"; 
   		 
		
		}   
#----------------------------------------------------------------
sub but_Enter_Pressed{
	      print_log "dont press the red button!! played";
		 if (time_between '10am','10pm'){
		  play "Fun/Red_One.WAV"
	}
	
	
}	
#----------------------------------------------------------------

#chloe bell 2020 tonsells

$v_Call_bell = new Voice_Cmd 'Ring call bell';
play "Fun/Bell.wav" if $state = said  $v_Call_bell;
set_info $v_Play_Random_Halloween_sound "rings a bell";


$CodeTimings::CodeTimings{'Sound End'} = time();
