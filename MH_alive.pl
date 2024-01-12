# category = mrhouse

#@
#Saves a file to show misterhouse has not stalled.
#the vb.net program monitors the file and restarts misterhouse if it falls over.
#  temproy until i fugure out what is stopping MH.
#  feb 2012
$CodeTimings::CodeTimings{'MH_alive Start'} = time();
my $Mh_alive_file = 'c:\houseautomation\MH_alive.txt';


if ($New_Minute){
	file_write($Mh_alive_file,"Alive at $Time_Now");
        print_log "Mh alive saved at $Time_Now"
}	

$CodeTimings::CodeTimings{'MH_alive End'} = time();




	















