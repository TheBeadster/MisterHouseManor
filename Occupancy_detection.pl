#category = Security

$CodeTimings::CodeTimings{'Occupancy_detection Start'} = time();

=begin

	#####################################################################
	#                                                                   #
	#             Security intruder Alarm Module			            #
	#             							                            #
	#             	Mike Jones Feb 2016				                    #
	#             							                            #
	#           SEE ALARM LAYOUTS IN MANOR TECHINICS webpage            #
	#                  click MyMh in top of misterhouse	                #
	#                                                                   #
	#                  works out who is in the houses                   #
	#                                                        		    #
	#                                                                   #
	#                                                                   #
	#####################################################################

					README
@This gives a answer to 'who is in the houses''
@it is not a accurate occupancy detector



# the generic items that hold the last movement times are updated in teh alarms securty.pl


=cut
$Last_House_Movement = new Generic_Item;
$Last_Annex_Movement = new Generic_Item;
$Last_Office_Movement = new Generic_Item;
my ($Last_Move ,$occupancy, $argaafa);
my $Houselog =$config_parms{data_dir}."/AlarmData/House_Logs/House_log.$Year_Month_Now.log";


sub WhoIsAtHome {
    # used by Cortana to give an answer to 'Who is At home?'
    # read the house alarm log last line to get the last movement in he house.
    
    $Last_Move = file_tail($Houselog,1);
   
    $Last_Move =~ /\w\w\w (\d\d\D\d\d\D\d\d \d\d:\d\d:\d\d) (.*)/;
   # print_log $1;
    if ($2 eq "Back door opened"){
     $occupancy = "The back door was opened "
    }else{
     $occupancy = "The last  ". $2;

    }
    #print_log str2time('10/02/2010 00:00:00');
    $argaafa = str2time($1);  
    #print_log " logged-----::$1::$argaafa::";
    $argaafa = state $Last_House_Movement;
    $Last_Move = time_diff  $argaafa,  $Time;

  

    $occupancy = $occupancy ." was ". $Last_Move  . " ago and the last movement in the annex was ";
    #print_log "last annex :".state $Last_Annex_Movement;
    $argaafa = state $Last_Annex_Movement;
    $Last_Move = time_diff  $argaafa,  $Time;
   # print_log "timediff ". $Last_Move;
    $occupancy = $occupancy . $Last_Move." ago and there was movement in the office ";
    $argaafa = state $Last_Office_Movement;
    $Last_Move = time_diff  $argaafa,  $Time;
    $occupancy = $occupancy . $Last_Move." ago";
    return $occupancy;

}

sub IsZoeAtHome {


    $argaafa = state $Last_Annex_Movement;
    $Last_Move = time_diff  $argaafa,  $Time;
   # print_log "timediff ". $Last_Move;
    $occupancy = "The last movement in the flat was " . $Last_Move." ago ";
    return $occupancy;

}

sub IsChloeAtHome {


    $argaafa = state $Last_Annex_Movement;
    $Last_Move = time_diff  $argaafa,  $Time;
   # print_log "timediff ". $Last_Move;
    $occupancy = "The last movement in the flat was " . $Last_Move." ago ";
    $occupancy = "Oh my god yes she is. quick Hide I can hear her coming down the stairs!";
    return $occupancy;

}



$CodeTimings::CodeTimings{'Occupancy_detection End'} = time();

