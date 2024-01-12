# Category = BarioNET
#


$CodeTimings::CodeTimings{'NODE_1_Stables_BarioNET_Serial Start'} = time();

#########################################################################
# 									#
#              		 BARIOnet interface				#
#									#
#            		 see www.Barix.com				#
#									#
#			Beady Jan 2008					#
#									#	
#########################################################################




#@   this controls Comms between the Barionet device named 'ba1' by me  IP static at 192.168.1.21  : port 9009
#@   located in the stables office, 
#@   it Controls the Ibutton networkl for gate access using a LINK45 ibutton interface
#@   the UG alarm inputs directly into th DIO inputs ,
#@   the gate safety bypass relay relay B  
#@   and the  water change over valve using Ralay A NC and NO contacts
#@    see the .pl file for protocols and message defs
#
#
#
#     Barionet set to have Link45 in the serial port, some processing is done with the Barionet BCL language see
#      Archive\HomeAutomation\programs\Barionet LAN controller
#
#      for setups and sdk etc for the barionet device
#      the ports of the BArionet are setup like this
#
#	Serial rs232	:	LINk45 ibutton interface  details at 
#					         Archive\HomeAutomation\other\link ibutton improved ds9097u20V1.2.pdf
#
#					talks to 2x gate touch pads which are linklocators
#					      see linklocator files/details
#					         Archive\HomeAutomation\other\link locator for ibutton touch pad manual.pdf 
#					
      
#        Dinputs        1-4 are analog 5-8 are digital
#        		:	1 - UG_alarm    Channel 1  alarm
#        			2 - UG_alarm	channel 2  alarm
#        			3 - Radar situated by water valves looking to front of one acre
#        			4 - 24V power at gate motor
#        			5 - Gate open
#        			6 - Gate Closed
#        			7 - smoke detector in workshop and office wires parralel
#        			8 - Gate emergency Sw detect
#
#        			pin 9 is common , if inputs on 5-8 are over 5v then analogues might not work see data sheets





#
#        outputs                pin10-13 digit outputs
#                               10  : safety bypass relay out 1
#                               11  : noy used yet
#                               12  : not used yet
#                               13  : not used yet
#
#                               pin 14 is common for outputs
#
#        Relay A 		Water Change over , NC free water, NO . metered water
#              B                Gate access blip on to start get open sequence
#
#        ibutton temps           2 x ibutton temps   read values and average them in Mh, to get correct outside air temp
#                                                   which is used by heating in house to set temps
#
#                                1 x temp sensors in stables 
# 


##
#NOTE NOTE as of 2018 these inputs are on the MODTONIX or BARIX CTRL			   
#Change Feb 2010

#		A RX8 port extender was added giving 8 in/8out extension
#		            1	 ch1 low pressure +ch2
#					2        Alarm_Stables_Alarm
#					3        ch1  pre alarm
#					4        ch2  pre alarm
#					5        UG tamper + fault
#					6        Radar_paddock_Tampe
#					7        tool shed PIR
#					8        tool Shed Smoke
#
#				 
#				 
#					
#				 tool shed tamper
#				 Stables_Tamper 
#						***********************************
#
#		TCP protocol
#
#		the tcp protocol is kept simple so that the Barionet code is simple and all
#		clever processing is done by MH which keeps the coding / learning down to a minimum
#
#
#
#	the TCP connection are left stopped, and only started every second
#	this is because of massive memory leak on the MH server box   *** FIXED late 2008 ****
#
#                            *********************************************************
#
#
#             data is sent by Barionet every (second at the moment)
#             unless data is recived by the Link 45 in which it is sent as soon as a complete message 
#             is recieved from link45 ibutton
#
#
#	functions  for global use
#
# 
#      the recieved from barionet routine
#            appends all recieved ibutton data into a var_ BarioNET_RCVD_from_Ib.
#            sets the values of the output ports and input ports
#
#
       
		

# setup the variable for object type code for the Digital outputs and relays on the Barionet
#
#
#
my $TimeTest = timelocal( $Second,$Minute,0,1,1,$Year) if lc($config_parms{debug}) =~ /delay/;


our ($iBID,$Direction,$iB);
# $IB # used to send which ibutton to read

my $ba1_IP ="192.168.1.21:9009"; # serial tunnel to ibutton adapter


#  Link locator stuff


my $LL_entry_adr ='180000000493E8FE'; #   the address of the entry linclocaot
my $LL_exit_adr  ='3C000000049404FE'; #    the addres of the exit lincloctor



# new LincLocator added here




$LincLocatorSearchTimer = new Timer;     #  timer to search for lincloctors, is variable to allow for resets etc
$LincLocatorTimeout = new Timer;
$tmr_FindingLL = new Timer;              # allows for slow networks when searching for link locator

# linc locator search tools , and check tcp connection
#   mar 09   the code below needs changing so that $linclocators olds OK if all are good , and fault if there is one or more missing,
#    a list can hold the locators that are missing. which can be veiwed if $linclocators <> OK
my $LL_states ="entry,exit,both,ok";
$LincLocators = new Generic_Item;
set_states $LincLocators split ',',$LL_states;
set_info $LincLocators 'Hold which linc locators are missing on the iButton network,  ok means both are present ';

my $LincLocator_find_error;               #
#my $temp;
#my $state;
#my $bn1_data;
# end linc locator stuff

# used to report state of gate and other systems


my $tmrButtonBounce = new Timer; # ibutton dbounce/ prevents people holding ibutton on pad.

## ####################################### 
my $BarioNET_TCPser_address = '192.168.1.21:9009';

my $bn1_data;



$BarioNET_TCPser = new  Socket_Item(undef, undef, $BarioNET_TCPser_address, 'BarioNETser','tcp','raw',"\r\n");

# add the standard commands for the link45 ibutton inteface
#

$BarioNET_TCPser ->add('r','Reset');    #answer to this should NOT be 's' which indicates a shorted bus
					# a P indicates one or more devices on bus
					# a N indicates no devices on the bus
$BarioNET_TCPser ->add('\L','LinkReportMode'); # repeats the linklocators id
$BarioNET_TCPser ->add('$','ReportMode'); # report mode does debounce etc for ibs





#--------------------------------------------------------------------------------
#
#		some voice commands for testing debugging purposes
#

$v_test_client1 = new  Voice_Cmd("Restart TCP Serial");
&restart_Barionet_TCP if  said $v_test_client1; 

$v_Find_LinkLocators = new  Voice_Cmd("Find Link Locators on iButton network");

$v_Entry_LED = new Voice_Cmd("change Entry LED to [Green,Red,Off]");
 
$v_Exit_LED = new Voice_Cmd("change Exit LED to [Green,Red,Off]");
 



###################################################################################################################
#end of VAr decs
#
#.................................................................
#
# 		Runtime Code
# 		............
# ................................................................
#
#





#-------------------------------------------------------------------------------------------------

#    open the TCP ports, this routine also checks the presence

if ($Reload or $Startup){
   $LL_seq=6;   # stop the link locator routine
   $LincLocator_find_error=1;
   set  $LincLocatorSearchTimer 20, sub{
	   &restart_Barionet_TCP
   };
}

#------------------------------------------------------------------------------
 
#          puts the link45 into extended mode'\X' then does a search to find which
#          link locators are on network, only extended mode devices listen to extended mode  ie linclocators

if  (said $v_Find_LinkLocators){
	&restart_Barionet_TCP;
	set $BarioNET_TCPser 'FIND';
	$LL_seq=1 ;
    $LincLocator_find_error=1
}
    


# timer to find linclocators

if (new_minute 2 ){
    set $BarioNET_TCPser 'FIND';
	set  $LincLocatorSearchTimer 5, sub{
										&restart_Barionet_TCP;
										set $BarioNET_TCPser 'FIND'
										} ; # set the lincloctor finder to 2 seconds again
}



	

#.........................................................
#
#     		Subr's and Funcs
#
#..........................................................

   # restarts the tcp connections if lost for any reason
sub restart_Barionet_TCP{

	print_log "restarting Stables TCP connections tunnel";
        stop  $BarioNET_TCPser if active $BarioNET_TCPser;
         my $timer1 = new Timer;
	     set $timer1 2 , sub{
							start  $BarioNET_TCPser; 
							set $BarioNET_TCPser 'FIND'  
	           				 };

     
       stop $BarioNET_TCPctrl if active $BarioNET_TCPctrl;
       start  $BarioNET_TCPctrl 
      	
		}




#--------------------------------------------------------------------------------------
  #
  # 
  #
  # remeber to put cr,lfs onto outbound data or BARIO net gives a error
  #
  #
  # reads in the ibutton part of the data and proccesses it into the correct places
  #




if ($New_Second and ($bn1_data = said $BarioNET_TCPser)) {

	#print_log " Node 1 stables serial raw data from Barionet : ".$bn1_data;



	  $iButtonData = $bn1_data;   #can be used other parts of code ie findlinc locators, if its not a entry or exit as below
	  #        ug tamper is 3,4 and 1 at same time


# 					1	 ch1 low pressure +ch2	// $Alarm_Underground_Ch1_Pressure
#					2        Alarm_Stables_Alarm	// $Alarm_Stables_Alarm
#					3        ch1  pre alarm		// $Alarm_Underground_Ch1_PreAlarm
#					4        ch2  pre alarm		// $Alarm_Underground_Ch2_PreAlarm
#					5        UG 	 fault    	// $Alarm_Underground_sys1_Tamper
#					6        Radar_paddock_Tamper	// $Alarm_Radar_paddock_Tamper
#					7        tool shed PIR		// $Alarm_ToolShed_Alarm
#					8        tool Shed Smoke	// $Smoke_ToolShed_Alarm

	  #$Alarm_ToolShed_Tamper

=begin

	  #print_log 'new line found $bn1_data='.$bn1_data."  and ibuttondata is now ".$iButtonData;

      # use the 'f' in linclocators Voice cmd to search for address,
      # these are at jan 2008
#  exit   ,3C000000049404FE
#  entry  180000000493E8FE

      #   1st see if the data is a lincloctor reporting an iButton on a touch pad
      #
      
=cut

    if ($iButtonData =~ /(ENTRY)\w\w(\w{12})(\w{2})/ or $iButtonData =~ /(EXIT)_\w\w(\w{12})(\w{2})/){
		$Direction =lc($1); 
        $iBID =  $2;
		my $iBFamily = $3;
		#print_log "ib ID = ".$iBID;
		
		if (inactive $tmrButtonBounce){

	 		set $tmrButtonBounce 4;  # stop multiple button reads stopping the gate.
			print_log"Access $Direction to compound by IB $iBID";
                        
		  	# ok so now check them out on key file and let them in or not
		  	
	  		&Gate_Access
          }
    }


    if ($iButtonData =~ /ok/){
	    print_log "Node 1(stables) reports both gate linclocators ok";
        unset $LincLocatorSearchTimer

    }

	    if ($iButtonData =~ /error/){
				print_log "Node 1 (stables) reports error with the iButton linclocators";
				print_log "Run Syslog daemon and then use Mh-> barionet-> find link locators";
        		set $LincLocators 'error'
    
		}





}  # end of check for incoming data from tcp serial barionet



 
sub NoLincLocators{
#   if the timer timesout or the linc locators are not found then this is whats decided to do
#
#

unset $LincLocatorTimeout;    # stop the timer

if  (state $LincLocators ne "ok" and !(active $tmr_FindingLL)){

        if ($LincLocator_find_error  == 4){
		#temp for testing both lines below
                 print_log" stopped subr Linclocators are missing, restarting TCP connection to NODE1";
		 #  speak"gate ibutton pads not found on network";
                 set  $LincLocatorSearchTimer 30, sub{&restart_Barionet_TCP} ; # set the lincloctor finder to 30 seconds again
                  $LincLocator_find_error=1


	     }elsif ($LincLocator_find_error  == 1){
		     	set $LincLocators "Both Missing";
   # try again to read them
		$LincLocator_find_error=2
		}
             
  }else{
	  set  $LincLocatorSearchTimer 300, sub{
		  	set $LincLocators "Both Missing";
		        set $tmr_FindingLL 5;
	  		set $BarioNET_TCPser 'FIND'
	          } ; # set the lincloctor finder to 30 seconds again

          $LincLocator_find_error=1;
          print_log"link locators found ok"
  } # end unless link = ok

} # end no linklocators




  
 #---------------------------------------------------------------------------------

sub BarioIb_change_status{


}


if ($LL_seq eq 7) {
	$LL_seq=8;
	set $BarioNET_TCPser "\L";
}
#---------------------------------------------------------------------------------------
#
#            Reads the state of a switch and returns true or false
#
#Bario_Rd_iB_SW($);
#


sub Bario_Rd_iB_SW{
my $reviB;
my $T1 = new Timer;
my $T2 = new Timer;
my $T3 = new Timer;
my $T4 = new Timer;
my $T5 = new Timer;

if ( $iB=~/(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)/){

	 $reviB = $8.$7.$6.$5.$4.$3.$2.$1};
print_log $reviB."  ".$iB;

	set $BarioNET_TCPser "r";							# reset the ibutton bus
#	set $T1  1 ,sub { set $BarioNET_TCPser "\\X"};                                
	set $T2  1 ,sub { set $BarioNET_TCPser "bF5".$reviB."58".$reviB};     # byte mode and send read rom
	set $T4  2 ,sub { set $BarioNET_TCPser "ff".$reviB."ff".$reviB.chr(13)};
       set $T5 5,sub { set $BarioNET_TCPser "\$"}			# set back to autoreport again




} #end sub

#----------------------------------------------------------------------------------------
#
#                write the state to the ibutton ds2406 sw
#
#

sub Bario_Wr_iB_SW{




}  # end sub



#--------------------------------------------------------------------------------------
#
#		Change the LED on the linklocator at the entry point.
#
#



if (my $state= said $v_Entry_LED){
my $led;
	$led ="12" if $state eq 'Green';
	$led ="13" if $state eq 'Red';
	$led ="14" if $state eq 'Off';



		set $BarioNET_TCPser "r";
	set $T1  1 ,sub { set $BarioNET_TCPser "\\X"};
	set $T2  3 ,sub { set $BarioNET_TCPser "b55FE0494040000003C"};
	set $T4  4 ,sub { set $BarioNET_TCPser $led."FE0494040000003C".chr(13)."\\O"};
       set $T5 5,sub { set $BarioNET_TCPser "\$"}


#,3C 00 00 00 04 94 04 FE
}


#------------------------------------------------------------------------------------------
#

if (my $state= said $v_Exit_LED){

	$led ="12" if $state eq 'Green';
	$led ="13" if $state eq 'Red';
	$led ="14" if $state eq 'Off';


		set $BarioNET_TCPser "r";
	set $T1  1 ,sub { set $BarioNET_TCPser "\\Xb55FEDF930400000025".$led."FEDF930400000025".chr(13)."\\O"};
#	set $T5  4 ,sub { set $BarioNET_TCPser "\\O"};
       set $T4 2 ,sub { set $BarioNET_TCPser "\$"}


#,25 00 00 00 04 93 DF FE
}



$CodeTimings::CodeTimings{'NODE_1_Stables_BarioNET_Serial End'} = time();



