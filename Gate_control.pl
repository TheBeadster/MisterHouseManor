# category=Gate
$CodeTimings::CodeTimings{'Gate_control Start'} = time();
=begin

 Revision and major update
 key data is retrieved using ibutton adapter link45 connected to a Barionet device in stables

 this also does other input outputs
 and is located at

    http://192.168.1.21

   misterhouse uses port 9009 to talk to the ilink/ds9097U adapter, everything sent is passed straight thru in both 
   direction

   port 9010 is  the tcp control port:  listed in the Barionet manual located in the archive/houseatuomation/other

 the ibutton id touched on the probe is passed using a global variable call $iBID ad the direction entry or exit
 is passsed in $Direction


Key ID (16 digit unique id),Customer number(for accurate identity),Customer/key holder name( for ease of reading log file),access allowed(1..5)

     customer number    1..500 are as Caravan database inc family
				makes it easier to track who has what key
				as one person could have two keys or two people with same name
				
     Access allowed      0..10 	0 - 8am to 8pm
				1 - 8am to 6pm
				2 - 7am to 9pm
				3 - 6am to 10pm
				4 - 24h
				5 - No access and dont announce
				6 - no access and anounce key tried.
				9 - disarm tack room and tool shed alarm for 30 and 15 mins.
			       10 - 24h announce gate opening( for family etc.)


AS of 2008 uses bARIONET IN tACK ROOM TO CONTROL SLIDING GATE
      feb 2010 added the ibutton access category 9 which disables the tack room and stables alarm if 
touched inside gate receptor or opens the gate if on the outside gate receptor.

jan 2013 added ocupanvy calculator so that the underground alarm is on in the dark when nobody is in the field 
if family are in the field then	


from march 2021

    the worskshop gaet is controlled by  modtronix @ 192.168.1.23
	 relay 1 & 2 power the lock
	 rly 1 locks it
	 rly 2 unlocks it

     ano input 0 (1?)  is from the elecrtic actualtor potentiemoer to indicate its position
      4.87 V is fully out ie locked
	  0.1V is fully in ie unlocked
	 DIO 6 is the gate micro siwtch at the top to indicate if the gate is shut up tight
   relay 3 & 4 are the LEd at the top.


=cut




my (@IB_List,$IB_Search,$ID,$Found,$Key_waited_for,$id2);

my $Wait_for_key='0';
my $Key_To_Find = "0100000546e3fc7a";
my  %access_info=( 0	=> "8am - 8pm",
		1	=> "8am - 6pm",
		2 	=> "7am - 9pm",
		3 	=> "5am - 11pm",
		4 	=> "24h",
		5 	=> "No access and don't announce but log use tried ",
		6 	=> "No access and announce key tried.",
		7       =>  "8am to 8pm and announce ",
		10	=>  "Announce gate opening( for family etc.)"
	);
	# alter actual times here to alter access
my $access_0_lo = '08:00';
my $access_0_hi = '20:15';

my $access_1_lo = '08:00';
my $access_1_hi = '18:15';

my $access_2_lo = '07:00';
my $access_2_hi = '21:15';

my $access_3_lo = '05:00';
my $access_3_hi = '23:15';

my $access_7_lo = '08:00';
my $access_7_hi = '20:15';

our (@key_data,@CustID_to_loc_data,$not_in);



my $Load_delay;
my $GateUseInfo;            # shows gate use count on CCTV
my $Gate_Shut_Timer = new Timer; # used to evercome gate staying open some times
my $Test_gate_shut = new Timer;  # check if gatei shut basicall y sam as above but for when a remote key is used to open gate
my $tmr_safe_Gate_opened_by_MH = new Timer;  # the gate open switch trigers an alarm if MH didnt open the gate
                                             # if this is running then the alarm is nulled
											 # alarm code is in security alarms code
											 # but is called by Node1_stable barionet code
my $tmr_Gate_Video = new Timer;   # turns off video 
$tmr_family_gate_access_alarm_pause = new Timer; # silences   alarm at gate when family acces it
$V_ibutton_list = new Voice_Cmd "List all the current ibuttons";
$V_Save_Key_File= new Voice_Cmd ('Save key file');
# these voice commands are MAINLY for the wap/menu browsing and the html control page
$V_Open_gate = new Voice_Cmd("Open Gate");
$V_Open_gate -> set_authority('anyone');   # this has password bypass for anyone to open it who know the ia5gate.htm URL
$V_Authorize_key= new Voice_Cmd("Authorize key [last,next]");
$V_who_is_in_field =  new Voice_Cmd("Who is in field");
$V_Last_entry = new Voice_Cmd("Last entry");
$V_Last_exit = new Voice_Cmd("Last exit");
$V_Change_access = new Voice_Cmd("Change access[0,1,2,3,4,5,6,9,10]");
$v_iButton_connect = new Voice_Cmd "[Connect,Disconnect] to the iButton bus";

#$LastGateUse = new Generic_Item;
#$GateOpenedCount = new Generic_Item;
#$GateUseMaxEver =new Generic_Item;
$LastIbuttonID_OnKeyPad   = new Generic_Item;

my $Gate_LED_states = 'on,off';
my $Workshop_Gate_actions ='Lock,Unlock';
my $Workshop_Gate_states ='Locked,unlocked,middle';
$tmr_Wshop_alarm_inhibit  = new Timer;

#$Gate_workshop_lock_Status = new Generic_Item;

set_states $Gate_workshop_lock_Status split ',',$Workshop_Gate_states;
$Gate_workShop_lock_pos_raw = new Generic_Item;
 



 
 if (state $Gate_workShop_lock_pos_raw < 1.5 and state $Gate_workshop_lock_Status ne 'unlocked' ){
   
	set $Gate_workshop_lock_Status 'unlocked';
    set $Modtronix_UDPctrl 'xr2=0' ;    # turn off the relay so it never burns out
    set $Modtronix_UDPctrl 'xr3=0';
	set  $Modtronix_UDPctrl 'xr4=1';
    print_log "The workshop gate is Unlocked"


 }
 if (state $Gate_workShop_lock_pos_raw > 4 and state $Gate_workshop_lock_Status ne 'locked'){
     
	 set $Gate_workshop_lock_Status 'locked';
	 set $Modtronix_UDPctrl 'xr1=0';     # turn off the relay so it never burns out
     set $Modtronix_UDPctrl 'xr3=1';
	 set $Modtronix_UDPctrl 'xr4=0';
     print_log "The workshop gate is Locked"


 }







#$Gate_workshop_Red_LED = new Generic_Item;
#$Gate_workshop_Green_LED = new Generic_Item;




set_states $Gate_workshop_Red_LED  split ',',$Gate_LED_states;     # light states are on/off
$V_Gate_workshop_Red_LED  = new Voice_Cmd("turn workshop Gate red LED  [$Gate_LED_states]");



$V_WorkShop_Gate_lock_unlock = new Voice_Cmd("[$Workshop_Gate_actions] the workshop gate");
$V_WorkShop_Gate_lock_unlock -> set_authority('anyone');

if ($state = said $V_WorkShop_Gate_lock_unlock){
	#print_log "$state";
	WorkshopGate_Lock_unlock($state)
}

$tmr_Stop_gate_lock = new Timer;
#set $Modtronix_UDPctrl 'xr1=1'
sub WorkshopGate_Lock_unlock {

  #print_log "recieved $_[0]";
  	if ($_[0] eq 'Lock'){
    #first check gate is shut by top switch

		if (state $Alarm_Milly_Gate_Alarm eq 'ok'){
			set $Modtronix_UDPctrl 'xr1=1';
			set $Modtronix_UDPctrl 'xr2=0';
			print_log "Locking the worskshop gate";
			logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Milly Wshop gate locked");
        
			set $tmr_Stop_gate_lock 40 ,sub {
									print_log"the worskshop gate is locked";
									set $Modtronix_UDPctrl 'xr1=0';
								};
			set $tmr_Wshop_alarm_inhibit 40 ,sub {
									
									set $Wshop_gate_alarm_inhibit 'Inactive';
								}


		}else{

        print_log " Cant lock Millys gate as it is not shut properly";
        logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Cant lock Millys gate because it is not shut properly");
        
		}
  	}else{
    # unlcok the gate
    set $Modtronix_UDPctrl 'xr1=0';
    set $Modtronix_UDPctrl 'xr2=1';
	print_log"Unlocking the workshop gate";
    # the routine above wil stop the lock when it is sensed to be open or closed'
	logit($config_parms{data_dir}."/AlarmData/Field_Logs/Field_log.$Year_Month_Now.log","Milly Wshop gate Unlocked");
        
    set $tmr_Stop_gate_lock 30 ,sub {
		print_log"The workshop gate is Unlocked";
        set $Modtronix_UDPctrl 'xr2=0';
        };
		set $tmr_Wshop_alarm_inhibit 40 ,sub {
						
						set $Wshop_gate_alarm_inhibit 'Inactive';
					}

  	}




}




my $Nop = "%%"; # used to tell the onn CCTV sub not to change a field
if ($New_Day){


	my $row;
	$row = file_read("$config_parms{key_dir}/GateUseMaxCount.txt");
		if (state $GateOpenedCount > $row){
		file_write("$config_parms{key_dir}/GateUseMaxCount.txt",state $GateOpenedCount);
		set $GateUseMaxEver $GateOpenedCount;
		}else{
       set $GateUseMaxEver $row;

		}
        set $GateOpenedCount 0;  # reset day counter
	    # and display it on the screen	



}

set $GateUseMaxEver (file_read("$config_parms{key_dir}/GateUseMaxCount.txt")) if $Startup or $Reload;



# this item is used to allow new unregisterd keys tpo be added to the key file
# it loads the new keys into the key file held in memory then if the timer expires , which is 30 seconds
# it saves the key file to disk
#$Authorize_next_keys = new Generic_Item;
$tmr_Authorize_next_keys = new Timer;
$V_AuthorizeKeys =  new Voice_Cmd("Authorize Keys At Gate");
if ($state = said $V_AuthorizeKeys){
	set $Authorize_next_keys 'on';
	print_log " Authorise gate keys at gate set to ON";
	set $tmr_Authorize_next_keys 300,sub{
		set $Authorize_next_keys "off";
		print_log " Authorise gate keys at gate turned OFF";
		}
	}
	# used by security allarms to turn on the field alarms when the field is empty
#$Field_occupancy = new Generic_Item;


# gate emergency switch pushed
# hi = pushed/latched
# lo= not pushed
#
my $em_rl = "safe,bypassed";
#$Gate_emergency_sw_status = new Generic_Item;
#set_states $Gate_emergency_sw_status split ',',$em_rl;
#set_info $Gate_emergency_sw_status 'Status of the relay that bypassses the gate emergency switch safe = switch on gate will work, bypassed means switch on gate has been disabled';

$v_emergency_Switch = new  Voice_Cmd("Set Gate Emergency Switch [safe,bypassed]");
if ($state = said $v_emergency_Switch){
	if($state eq "safe"){
		set $BarioNET_TCPctrl 'setio,1,0'
	}elsif($state eq "bypassed"){
		set $BarioNET_TCPctrl 'setio,1,1'
	}
 }



my ($unique_key,$cust_id,$Name,$access,@in_field_now,$state,$Diagnostic_Position,$fault,$power_count,$missing_count,$diag);



# open and load data when starting or code reload.
if ($Reread or $Startup or $Reload) {
	set $LastGateUse "No data yet";
	$Diagnostic_Position= '1';
	set $Authorize_next_keys 'off';
	set $Field_occupancy 0; 
	set  $Test_gate_shut 120,sub{  # start the timer to test for gate shut or open 
		#	if ( state $BarioNet_ba1_gate_closed eq 'lo' and  inactive $Gate_Shut_Timer ){
		#	print_log "Gate stuck open , trying to close it";
					#	&open_the_gate
					#	}else{
					#	print_log "Gate closed OK"  
					#     }			
			};   # end test gate open timer



   #  ------------------------------------------------------------------------------#

    #   Key file

	$F_DATA = new File_Item ("$config_parms{key_dir}/key_file.txt");
    @key_data = read_all $F_DATA or print_log "Error in opening $config_parms{Key_dir}/key_file.txt";
  	


   &Reload_keyFile;
   &Last_gate_use;
    # relofd the customer to loction data for showing on the cameras

   &Reload_Cust_to_Loc_Info;
    set $LastIbuttonID_OnKeyPad  'nothing on the keypad yet';

}

sub Reload_keyFile{
	if (open(F_DATA, "$config_parms{key_dir}/key_file.txt")){
	    @key_data = <F_DATA>;
        close F_DATA
	}else{
	    print_log "Can't open key data list $config_parms{key_dir}/key_file.txt"
	}
	set_watch $F_DATA;
}


	# if the key file has changed then reload the information and set the watch flag again

if (changed $F_DATA){
		$Load_delay = 15;
		speak "New key"
}

if ($Load_delay ne 0){--$Load_delay}


if ($Load_delay eq 1){ &Reload_keyFile}


	#---------------------------------------------------------------------------------------------------------

 

$CtoL_DATA = new File_Item ("$config_parms{key_dir}/CustID_to_location.txt");



&Reload_Cust_to_Loc_Info if changed $CtoL_DATA;



sub Reload_Cust_to_Loc_Info{
    
	print_log" reloading customer to location info $config_parms{key_dir}/CustID_to_location.txt";
	@CustID_to_loc_data = file_read("$config_parms{key_dir}/CustID_to_location.txt") or print_log "Error in opening $config_parms{Key_dir}/CustID_to_location.txt";

   	set_watch $CtoL_DATA;

	#print @CustID_to_loc_data;

}







if ($Reload){
	$Password_Allow{'&open_the_gate_Web'} = 1;
	 @in_field_now="";
	 $id2="";
	 print " Reloaded emptied file",@in_field_now, scalar @in_field_now;


 }

#------------------------------------------------------------------------------------------------------------

sub sort_key_file {
my ($id22,$id3,$id4,$keycount,$n,$m,$cust_id1,$cust_id2);
$keycount=1;
foreach $id22 (@key_data){++$keycount}
print_log " keycount = $keycount";

foreach $id22 (@key_data) {
	# print_log "$id22";
	 $cust_id1 = $2 if $id22= ~/(\w{12}):(\w+):([^:]+):(\w+)/;
	foreach $id3 (@key_data) {
		
		$cust_id2 = $2 if $id3=~/(\w{12}):(\w+):([^:]+):(\w+)/;
		if ( $cust_id1 > $cust_id2) { 
			$id4=$id3;
			$id3=$id22;
			$id22=$id4;
			
		}
	}
}
		
}

#------------------------------------------------------------------------------------------------------------
sub Save_key_file{



}  # end asve key file



#--------------------------------------------
#$Vt = new Voice_Cmd("testiB");

#$iB="040000001FD76512";
#  Bario_Rd_iB_SW if( said $Vt);


#------------------------------------------------------------------------------------------------------------
# check system every minute
#
# 
sub Gate_Access{
	my $IDacc ;
	my $LogItUsed;
	my $Templg;
	my $userDetails;
	$CodeTimings::CodeTimings{'Gate_Access Start'} = time();
	# $iBID is  ibutton incoming id from the barionet routines
	# print_log $iBID;
	$iBID =~ tr/A-Z/a-z/;    # change everything to lower case
	$IDacc = $iBID;          # stores actual key id for later use
	$Found=0;       # used detect if the key was valid or not 
	foreach $IB_Search(@key_data){
		#  print_log "looking for key ".$IDacc." In key ".$IB_Search;
		if ($IB_Search=~/$IDacc/){     # key found now check who and when gets access
			$unique_key = $1,$cust_id = $2,$Name = $3,$access=$4  if $IB_Search=~/(\w{12}):(\w+):([^:]+):(\w+)/;
			
			#	  print_log "Found Key ".$Name;
			#
			$Found = 1 ;   #stop the key being added to the keyfile if it is already in keyfile
			set $LastIbuttonID_OnKeyPad  $IDacc. "  " . $cust_id . "  " .$Name;
			if ($access eq 4){
				# silence the alarm for 5 mins
				set $tmr_family_gate_access_alarm_pause 300;
		
			}

			if ($access eq 6){
					speak "Attention       Attention      $Name has just tried to get into the field      $Name has just tried to get in the field";
					Show_on_tv ("Gate $Name  , Has just tried to get in the main gate, there Key is blocked , go and check")
			}

			if ($access eq 7){
					speak "Attention        $Name is at the gate you have asked to be notified ";
					Show_on_tv ("Gate $Name is at the gate you are waiting for this person")
			}
								
			if ($access eq 9){
				set $tmr_family_gate_access_alarm_pause 600;
				if ($Direction eq "entry"){
					&open_the_gate
				}else{
					# this is a toolshed/stables dis-arm iButton
					# on the exit ibutton pad so set diarm timers
					print_log "Alarm disarm key on exit pad";
					Show_on_tv ("Stables/Tool shed temp alarm disable");
					
					&Alarm_Stables_ignore;
					&Alarm_ToolShed_ignore
				}

			} 		 

			if ($access eq 10){
				set $tmr_family_gate_access_alarm_pause 300;
				if ($Direction eq "entry"){
					Show_on_tv ("$Name is entering the gate");

					speak "Attention        $Name is entering the main gate"
				}else{
					Show_on_tv ("$Name is leaving");
					speak "Attention        $Name is leaving"
				}
			}
			

			# adds which direction they where going
			# keeps compatability with old data
			# # add it now so it In and OUT are not spoken
			
			if ($cust_id ne "0"){
				$userDetails = &CaravanDatabaselookup($cust_id);
			}else{

				$userDetails ="";
			}


			$LogItUsed = $Name;


			if ($Direction eq "entry"){

					$Name="IN ".$Name
				}else{
					

				$Name="OUT ".$Name
				};
		
			#if access is 5or 6 show it on log file 

			if (($access eq 5) or ($access eq 6)) {
				Show_on_tv ("Gate $Name");	  
				logit("$config_parms{key_dir}/logs/Databaselog.txt",",$iBID $cust_id,Access Stopped") if $cust_id ne'00';
				logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","$cust_id STOPPED >$Name< access stopped $unique_key ")
				}
			print_log "$iBID Customer Name  $Name  access ID $access which is $access_info{$access}";
			
		
			$Found=1;

			# now work out what access to grant using $access  
			if ((($access eq 0) and (time_greater_than($access_0_lo) and  time_less_than($access_0_hi)))or(($access eq 1) and  (time_greater_than($access_1_lo) and time_less_than($access_1_hi)))
					or(($access eq 2) and  (time_greater_than($access_2_lo) and time_less_than($access_2_hi)))
					or(($access eq 3) and  (time_greater_than($access_3_lo) and time_less_than($access_3_hi))) 
					or ($access eq 4) or ($access eq 10) or(($access eq 7) and (time_greater_than($access_7_lo) and time_less_than($access_7_hi))))
					{

				&open_the_gate;   #

				set $LastGateUse $Name." ".$cust_id." at ".$Time_Now;  # for web page button and in the reply to cortana

				if ($Direction eq "entry"){
						# take snapshot from camera
						# we fork this to a seperate proccess so it doens slow down Mh
						# later we test to see if it has finished then we rename the file

						$Templg ="IN was ".$LogItUsed." at ".$Time_Now;
						&ShowInfoOnCCTV($GateUseInfo,$Templg,$userDetails,"","")

					}else{
						$Templg ="OUT was ".$LogItUsed." at ".$Time_Now;

						&ShowInfoOnCCTV($GateUseInfo,"","",$Templg,$userDetails)

					}
				file_write("$config_parms{key_dir}/last_access/last_access.txt",$Templg);

				#log normal use	 
				# take snapshot from camera


				if ($access ne 7) {
					logit("$config_parms{key_dir}/logs/Databaselog.txt",",$cust_id,-") if $cust_id ne'00';
					#logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","$unique_key  $cust_id $iBID $Name")
					logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","$unique_key  $cust_id $Name")
				} else{
					# log watched people
					logit("$config_parms{key_dir}/logs/Databaselog.txt",",$cust_id,Watching") if $cust_id ne'00';

					logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","$unique_key   $cust_id Watching >$Name< access allowed")
				}	 
			
				# work out who is in field and who has left 
		
				# dont put in friends
				if ($cust_id ne "00"){
					if ($Direction eq "exit"){
					set $Field_occupancy state $Field_occupancy -1 if state  $Field_occupancy ne '0' ;
						foreach (0..$#in_field_now){
							if ($in_field_now[$_]=~/$unique_key/){
									# if they are in the field delete them out 
									$in_field_now[$_]="";
									$not_in=1;
									last
								}
							} 
							}else {
							set $Field_occupancy state $Field_occupancy +1;

						push @in_field_now,"$Time_Now $unique_key $cust_id $Name"
							}
				}  # end of not family in field
		
			}else{
				#log out of hours use
				if ($access ne 7){
					logit("$config_parms{key_dir}/logs/Databaselog.txt",",$cust_id,Out of hours");
					logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","$unique_key  $cust_id Denied $Name Out of hours $access_info{$access}")
				}else{
					logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","$unique_key  $cust_id Watching >$Name Out of hours $access_info{$access}")
				}
						#speak" Access denied";

			}
		# end of who has access and who doesn't
				
		last    # end loop match has been found

		} 
	}# end of for each $IB_Search(@key_data



		#if its not found add it to the list if authorize_next keys is 'on' if not add it to unknown key list
	if ($Found eq 0){
		# this item is used to allow new unregisterd keys to be added to the key file
		# it loads the new keys into the key file held in memory then if the timer expires , which is 30 seconds
		# it saves the key file to disk
		if (state $Authorize_next_keys eq 'on'){
				#save last key tp keydata file, but don't save it yet.
				print_log"saving new key $IDacc to key file as a new customer";
				if (open(F_DATA, ">>$config_parms{key_dir}/key_file.txt")){
					print F_DATA "\r\n$IDacc:999:New Customer:0";
					close F_DATA;
					set $OSFlood_light 'on';
					my $tmr_flood_flash = new Timer;
					set $tmr_flood_flash 3,sub{
								set $OSFlood_light "off"
								};
					set $tmr_Authorize_next_keys 20,sub{ set $Authorize_next_keys "off"}

				}else{
					logit("$config_parms{key_dir}/unknown_keylog.txt","$IDacc");
                    set $LastIbuttonID_OnKeyPad 'new key' . $IDacc;
					play "sound_click1.wav"
				}
		}


	}   # end if found eq 0

	$CodeTimings::CodeTimings{'Gate_Access End'} = time();

}	  # end sub gate access
     #------------------------------------------------------------------------------------------------------------
	 # this checks at 8pm if there is an odd number off uses in the gate use 
	 # ie there is someone in the field or someone didn't use the gate or there gate key.
if ((time_now '20:00' ) and ($in_field_now[0] ne "")){
	my ($criminal,$p);
	$p=scalar @in_field_now;
	$p=--$p;
	print_log "saving list of people that maybe still in the field";
	speak (rate=>-10,text=> "There may be $p  people in the field please check the computer");  
	foreach $criminal(@in_field_now){

		logit("$config_parms{key_dir}/logs/Still_in_field.$Year_Month_Now.log","$criminal\n",11) 
			}
	@in_field_now=""; # clears the list;
}


#-----------------------------------------------------------------------------------------------------
sub ShowInfoOnCCTV{
	my $blueIris;
	#@ gate contol and displays data on the Video CCTv cameras
=begin

 this takes the params and puts them in blue iris MACRO fields
 these field are then displayed automatically on the 
 video feeds 
 the feeds achange by editing video feed under video/overlays,
  if macro one want filling then only first needs sending ie
  NOTE:the gate use count is always sent as it is always displayed
  &ShowInfoOnCCTV($GateUseInfo,"beady")

  if only second needs sending
  then 

  ShowInfoOnCCTV("","Milly")
  if you want to keep the other fields and change only one then use %% or the var $Nop

  	&ShowInfoOnCCTV("%%","info");   or &ShowInfoOnCCTV($Nop,"info");



if you dont send others then they will remain the same ( like adding $Nop to the fields), to clear them send a empty string
   Gate use counter  
    macro 1 : always send this in the sub call.
 Entry screen
    macro 2: is the name 
	      3 : the ciustomer id ,location and reg number if it is a normal ciustomer empty if it is family
 exit screen
    macro 4 : name
	      5 : customer id,location and reg number if it is  normal customer
		  1 : gate use count and over all count

=cut

	my $ParamCount= 1;

	foreach (@_) {
        #print_log "Sending http://$config_parms{BlueIrisIPandPort}/admin?macro=$ParamCount&text=$_&user=dadmin&pw=betchton";

		$blueIris = get "http://$config_parms{BlueIrisIPandPort}/admin?macro=$ParamCount&text=$_&user=dadmin&pw=betchton" if $_ ne "%%";
        $ParamCount++;
	}




}



#-------------------------------------------------------------------------------------------------------------

# get pitch number from access caravan database


sub CaravanDatabaselookup {
	my $custloc="";
	print_log "looking for $_[0] in customer to loc file";

	my ($CID,$Place,$CID2,$firstName,$Surname,$Phone,$Make,$Model,$RegNo,$Size);
	foreach (@CustID_to_loc_data){


		($CID,$Place,$RegNo,$Phone) = split(/\t/, $_);

		#print "CID=$CID\tPlace = $Place\tReg No =$RegNo \tPhone= $Phone\n";

		if	($_[0] eq $CID) {
			$custloc = $Place . "  " .$RegNo;
			last;   # done so exit early
		}
		

	}

	$custloc = "ID: ". $_[0]." loc: ".$custloc;
	print_log "returning from cust to  loc db $custloc";
	return $custloc;
}



#-----------------------------------------------------------------------------------------------------
#    MAIN routine that is called by all other routies to actualyy open the gate 


sub open_the_gate {
#check state of switch

$CodeTimings::CodeTimings{'sub_Open_the_Gate Start'} = time();




	if (state $BarioNet_ba1_gate_closed eq 'lo'){
			logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","Gate was OPEN")
		#only make a log entry if the gate was already open
	}else{
			#logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","Gate  was closed")
				}
		
	set $tmr_safe_Gate_opened_by_MH 120;    # stop the closed switch change from triggering an alarm

	set $tmr_family_gate_access_alarm_pause 120;	# silence the alarms for 2 mins because a valid gae open was performed

	set $BarioNET_TCPctrl "setio,2,0";
	set $BarioNET_TCPctrl "setio,2,30";


	set $GateOpenedCount  (state $GateOpenedCount+1);

	$GateUseInfo = state $GateOpenedCount  .":". state $GateUseMaxEver;

	my  $timer = new Timer;
		set $timer 5, sub {
			&ShowInfoOnCCTV($GateUseInfo);    # dont need others here beacause they will not be modified if params are empty
		};


	set $Gate_Shut_Timer 300,sub{
					if ( state $BarioNet_ba1_gate_closed eq 'lo' and state $Gate_position_status ne 'fault'){
						print_log "Gate stuck open , trying to close it";
						#&open_the_gate
					}else{
						print_log "Gate closed OK"  
								}			
				};
	$CodeTimings::CodeTimings{'sub_Open_the_Gate End'} = time();
	return "The gate is opening";

} # end open gate
#-----------------------------------------------------------------------------------------------------
sub close_the_gate{
	#same as open the gate except reports back to cortana
	# that the gate is closing
set $BarioNET_TCPctrl "setio,2,0";
set $BarioNET_TCPctrl "setio,2,30";


	return "the gate is closing";



}
#-----------------------------------------------------------------------------------------------------

# used to reply to Cortana

sub gate_state{
my $response;
    if (state $BarioNet_ba1_gate_closed eq 'hi'){

        $response = "the gate is closed ";
    }else{
       $response = "the gate is open";

}
    if (state $gate_24V eq "on"){

        $response =$response. ",there is power at the gate motor";
    }else{
       $response  ="There is NO power at the gate, ".$response;

}
    if (state $gate_Emergency_STOP_sw eq 'pushed'){

        $response  =$response." and the emergency switch is pushed";
    }else{
       $response  =$response." and the emergency switch is OK";

}


}

#-----------------------------------------------------------------------------------------------------
sub Last_gate_use{

my $row;
$row = file_read("$config_parms{key_dir}/last_access/last_access.txt");
$row="Last person ".$row;
# send the last gate use to the blue iris server
# for display on the cameras

return $row;

}





#-----------------------------------------------------------------------------------------------------


sub open_the_gate_webApp{
	my $WasMe = shift;


	&open_the_gate;
        logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","WebApp opened by $WasMe");
	print "Gate opening , web app by $WasMe";
	set $LastGateUse "Webapp by $WasMe at $Time_Now";  # for web page button
    &ShowInfoOnCCTV($GateUseInfo,"Webapp by $WasMe at $Time_Now","","","");
}



#------------------------------------------------------------------------------------------------------


if (said $V_Open_gate){
	# silence the alarms for 5 mins
	set $tmr_family_gate_access_alarm_pause 300;
   &CaravanDatabaselookup(918); # for testing
	&open_the_gate;
        logit("$config_parms{key_dir}/logs/fieldlog.$Year_Month_Now.log","Gate open by house Button / or Mr House web page");
	print "Gate opening";
	set $LastGateUse "Button in House";  # for web page button	
    &ShowInfoOnCCTV($GateUseInfo, "Button in House at $Time_Now","","","");
 
}



#------------------------------------------------------------------------------------------------------






#------------------------------------------------------------------------------------------------------

# main loop bit
  if ($Key_waited_for ne ""){
	        $Key_waited_for=~/ID:(\w+)/;
		$ID=$1;
		$Key_waited_for='';
	        push @key_data ,"$ID\:xxx\:NEW KEY WAP Authorized\:0\n";
		run_voice_cmd  "Save key file" ;
		print_log "$ID authorized";
	   

	}	


#-----------------------------------------------------------------------------------------------------
if ($state=said $V_Change_access){
	
$Found="0";
	foreach $IB_Search(@key_data){
		 if ($IB_Search=~/$ID/){
			 $unique_key = $1,$cust_id = $2,$Name = $3,$access=$4  if $IB_Search=~/(\w{12}):(\w+):([^:]+):(\w+)/;
			 $IB_Search = "$unique_key\:$cust_id\:$Name\:$state\n";

			  run_voice_cmd "save key file";
			 $Found=1;
		         print_log " Access for $Name Changed from $access_info{$access} to $access_info{$state}";
			 last
		 }
	 }
		 if ($Found ne "1"){
			 print_log "last key not found on system. check key and try again"}
			

	 
 }
#-----------------------------------------------------------------------------------------------------

if (said $V_Last_entry or said $V_Last_exit){
	my @logs   = &read_field_logs1('fieldlog');
        my @calls  = &read_field_logs2(1, @logs);
	print_log @calls;
               my ($time, $num, $name) = $calls[0] =~ /(.{21}) (\S+) (.+)/;
   print_log "Gate was used by $Name at $time. Customer No $num";
   }
  

#-----------------------------------------------------------------------------------------------------



=begin

 checks sytem integrity and tries to log and/or make sense of faults
   $Diagnostic_Position keeps track of what this routine is up to
    	ok = system is currently ok so check every thing- called every minute further up this code
    	Power1 = detected power failure on one DS2407 timer set for recall if still only one power failure
             then it must be that bit.
	     if more have power failures then power down. log it, speak it and SMS it. set to POWER2 and timer every 20 secs
	Power2   = waiting for power recovery after one hour send a message sms and Speak keep checking
	Missing  = set if one DS goes missing checked after 10 seconds 3 times if still missing logit and announce fault
=cut
	     
	     
sub diagnostic_check {
	# turns off the lock solenoid if there has been a power failure and reset that has been quick
	# turns it off  if the timer is not running
	#	&relock if inactive $relock_gate

	

}



#------------------------------------------------------------------------------------------------------------	 
	 #just returns the array to show as html
	 # voice cmd mainly used by wap wml menu
&whos_in_field_now if (said $V_who_is_in_field);

sub whos_in_field_now {
	return @in_field_now
}





$CodeTimings::CodeTimings{'Gate_control End'} = time();