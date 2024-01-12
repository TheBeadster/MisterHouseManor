# Category=Phone

# Add these entries to your mh.ini file:
#  serial_gsm_port=COM3  
#  serial_gsm_baudrate=9600
#  serial_gsm_handshake=none
$CodeTimings::CodeTimings{'GSM_sms Start'} = time();
=begin comment

From Roger Bille on 09/2001

 I have a quick and dirty perl script that I have used to play with SMS. It
is using a GSM modem (phone without keyboard and display but with a RS232
connector) but should work with any phone that has built in modem functions
and support the special AT+ commands for SMS. I think most Nokia phones
support it.

 The action_sms section is the place where you can get mh to do somthing. My
program only support 2 messages:

    mh 0        (turn off living_corner_light)
    mh 1        (turn on living_corenr_light)

 The action_sms also check who the sender is before it allows an action to
be done. get_gsm translate numbers to names.



$gsm_status   hold the current status of the phone

         valid is  a string containing non fatal or fatal errors
	             init fail
		     init1 



CMS ERROR code list (GSM Modem error codes): 

1 - "Unassigned (unallocated) number" 
This cause indicates that the destination requested by the Mobile Station cannot be reached because, although the number is in a valid format, it is not currently assigned (allocated). 

8 - "Operator determined barring" 
This cause indicates that the MS has tried to send a mobile originating short message when the MS's network operator or service provider has forbidden such transactions. 

10 - "Call barred" 
This cause indicates that the outgoing call barred service applies to the short message service for the called destination. 

21 - "Short message transfer rejected" 
This cause indicates that the equipment sending this cause does not wish to accept this short message, although it could have accepted the short message since the equipment sending this cause is neither busy nor incompatible. 

27 - "Destination out of service" 
This cause indicates that the destination indicated by the Mobile Station cannot be reached because the interface to the destination is not functioning correctly. The term "not functioning correctly" indicates that a signalling message was unable to be delivered to the remote user; e.g., a physical layer or data link layer failure at the remote user, user equipment off-line, etc. 

28 - "Unidentified subscriber" 
This cause indicates that the subscriber is not registered in the PLMN (i.e. IMSI not known). 

29 - "Facility rejected" 
This cause indicates that the facility requested by the Mobile Station is not supported by the PLMN. 

30 - "Unknown subscriber" 
This cause indicates that the subscriber is not registered in the HLR (i.e. IMSI or directory number is not allocated to a subscriber). 

38 - "Network out of order" 
This cause indicates that the network is not functioning correctly and that the condition is likely to last a relatively long period of time; e.g., immediately reattempting the short message transfer is not likely to be successful. 

41 - "Temporary failure" 
This cause indicates that the network is not functioning correctly and that the condition is not likely to last a long period of time; e.g., the Mobile Station may wish to try another short message transfer attempt almost immediately. 

42 - "Congestion" 
This cause indicates that the short message service cannot be serviced because of high traffic. 

47 - "Resources unavailable, unspecified" 
This cause is used to report a resource unavailable event only when no other cause applies. 

50 - "Requested facility not subscribed" 
This cause indicates that the requested short message service could not be provided by the network because the user has not completed the necessary administrative arrangements with its supporting networks. 

69 - "Requested facility not implemented" 
This cause indicates that the network is unable to provide the requested short message service. 

81 - "Invalid short message transfer reference value" 
This cause indicates that the equipment sending this cause has received a message with a short message reference which is not currently in use on the MS-network interface. 

95 - "Invalid message, unspecified" 
This cause is used to report an invalid message event only when no other cause in the invalid message class applies. 

96 - "Invalid mandatory information" 
This cause indicates that the equipment sending this cause has received a message where a mandatory information element is missing and/or has a content error (the two cases are indistinguishable). 

97 - "Message type non-existent or not implemented" 
This cause indicates that the equipment sending this cause has received a message with a message type it does not recognize either because this is a message not defined or defined but not implemented by the equipment sending this cause. 

98 - "Message not compatible with short message protocol state" 
This cause indicates that the equipment sending this cause has received a message such that the procedures do not indicate that this is a permissible message to receive while in the short message transfer state. 

99 - "Information element non-existent or not implemented" 
This cause indicates that the equipment sending this cause has received a message which includes information elements not recognized because the information element identifier is not defined or it is defined but not implemented by the equipment sending the cause. However, the information element is not required to be present in the message in order for the equipment sending the cause to process the message. 

111 - "Protocol error, unspecified" 
This cause is used to report a protocol error event only when no other cause applies. 

127 - "Interworking, unspecified" 
This cause indicates that there has been interworking with a network which does not provide causes for actions it takes; thus, the precise cause for a message which is being send cannot be ascertained. 

0...127 - Other values in this range are reserved, defined by GSM 04.11 Annex E-2 values 

128 - Telematic interworking not supported x 
129 - Short message Type 0 not supported x x 

130 - Cannot replace short message x x 
143 - Unspecified TP-PID error x x 
144 - Data coding scheme (alphabet) not supported x 
145 - Message class not supported x 
159 - Unspecified TP-DCS error x x 
160 - Command cannot be actioned x 
161 - Command unsupported x 
175 - Unspecified TP-Command error x 
176 - TPDU not supported x x 
192 - SC busy x 
193 - No SC subscription x 
194 - SC system failure x 
195 - Invalid SME address x 
196 - Destination SME barred x 
197 - SM Rejected-Duplicate SM x 
198 - TP-VPF not supported X 
199 - TP-VP not supported X 
208 - SIM SMS storage full x 
209 - No SMS storage capability in SIM x 
210 - Error in MS x 
211 - Memory Capacity Exceeded X 
212 - SIM Application Toolkit Busy x x 
255 - Unspecified error cause 

128...255 - Other values in this range are reserved, defined by GSM 03.40 subclause 9.2.3.22 values 

300 - ME failure 
301 - SMS service of ME reserved 
302 - operation not allowed 
303 - operation not supported 
304 - invalid PDU mode parameter 
305 - invalid text mode parameter 
310 - SIM not inserted 
311 - SIM PIN required 
312 - PH-SIM PIN required 
313 - SIM failure 
314 - SIM busy 
315 - SIM wrong 
316 - SIM PUK required 
317 - SIM PIN2 required 
318 - SIM PUK2 required 
320 - memory failure 
321 - invalid memory index 
322 - memory full 
330 - SMSC address unknown 
331 - no network service 
332 - network timeout 
340 - no +CNMA acknowledgement expected 
500 - unknown error 

256...511 - Other values in this range are reserved 

512... - manufacturer specific 


=cut



my ($gsm_mode, $gsm_message, $gsm_header,$gsm_status,$Phone_dead,$msg,$numberGSM1, $Sendmessage);

$timer_waitforanswer = new Timer;   # Timer that Waits for an Answer
$timer_sig_bat_timeout = new Timer; # means that checking for sig or ba t will only wait so long
$timer_gate_state  = new Timer;     # sends sms 15 secs after trying to open gate to tell what stae it's in
# these made as a new item so they are saved and restored so hopefully will report back when rebooted
#

$gsm = new Serial_Item ('AT+CMGF=1', 'init', 'serial_gsm');
#$gsm = new Serial_Item ('ATE0\r AT+CMGF=1', 'init', 'serial_gsm');
if ($Reload or $Startup) {
	print_log "\r";
    print_log "Restarting GSM SMS phone" ;
    #$gsm_mode = "init";
    #set $gsm 'init';           # Initialize MODEM 
# emp to stop the init process
#$gsm_mode = "";





    #set $timer_sig_bat_timeout 30,"&sig_bat_timeout_error";   # start checking that there is a response from the fone                                                       # if not it retries then raises an alarm
    $gsm_status="";
    $Phone_dead = 0;
    # $Debug{GSM} =1;
    # set $Main_220V_power_status 'on' if state $Main_220V_power_status ne 'on'


}
# this is used for the main loop monitoring of the phone modem

#&read_all;


# check wether the power from mains has failed or not
#if (state $Main_220V_power_status eq 'on_u' and $gsm_mode eq ""){
	#        $msg ="Betchton manor  Electricity has been RESTORED\n\rThe stables power is ".state $Node1_220V;
	#	&send_SMS_to_all("$msg");
	# temp	set $Main_220V_power_status  "on"
#	}
	
#if (state $Main_220V_power_status eq 'off_u' and $gsm_mode eq ""){
	#	print_log" sending error for failed power";
	#  $msg="Betchton manor  Electricity has failed\n\rThe stables power is ".state $Node1_220V;
	#	&send_SMS_to_all( "$msg");
	#   temp	set $Main_220V_power_status  "off"
#	}

	    my $SMSdelaytimer = new Timer ;
		my $SMSdelaytimer2 = new Timer ;
		my $SMSdelaytimer3 = new Timer ;
		my $SMSdelaytimer4 = new Timer ;

sub send_SMS_to_all {
	my ( $message) = @_;
	    
		&send_gsm_sms ($config_parms{beady_gsm}, $message);
		
		set $SMSdelaytimer 5 ,sub {
		    &send_gsm_sms ($config_parms{zoe_gsm}, $message);
		};
		set $SMSdelaytimer2 10 ,sub {
		     &send_gsm_sms ($config_parms{milly_gsm}, $message);
		};
		set $SMSdelaytimer3 15 ,sub {
		 &send_gsm_sms ($config_parms{chloe_gsm}, $message)
		}
} # end sms_to_all




#   SMS to beady
$sms_beady   = new Generic_Item;
$sms_beady  -> set_authority('anyone');
&tk_entry('SMS to Beady', $sms_beady);
if ($state = state_now $sms_beady) {
	&send_gsm_sms ($config_parms{beady2_gsm}, $state);
}

#   SMS to milly
$sms_milly   = new Generic_Item;
$sms_milly  -> set_authority('anyone');
&tk_entry('SMS to milly ', $sms_milly);
if ($state = state_now $sms_milly) {
	&send_gsm_sms ($config_parms{milly_gsm}, $state);
}

#   SMS to MisterHouse
$sms_zoe   = new Generic_Item;
$sms_zoe  -> set_authority('anyone');
&tk_entry('SMS to Zoe ', $sms_zoe);
if ($state = state_now $sms_zoe) {
	&send_gsm_sms ($config_parms{zoe_gsm}, $state);
}

#   SMS to Chloe
$sms_chloe   = new Generic_Item;
$sms_chloe  -> set_authority('anyone');
&tk_entry('SMS to Chloe ', $sms_chloe);
if ($state = state_now $sms_chloe) {
	&send_gsm_sms ($config_parms{chloe_gsm}, $state);
}


#send a test sms to milly
#

$v_sms_testbd = new  Voice_Cmd('test SMS Messages to beady');
if (said $v_sms_testbd) {
		&send_gsm_sms ($config_parms{beady_gsm},'testing messages from Misterhouse ');
	}
	
$v_sms_testbd2 = new  Voice_Cmd('test SMS Messages to zoe number #2');
if (said $v_sms_testbd2) {
		&send_gsm_sms ($config_parms{zoe_gsm},'testing messages from Misterhouse ');
	}

$v_sms_testmil = new  Voice_Cmd('test SMS Messages to Milly');
if (said $v_sms_testmil) {
		&send_gsm_sms ($config_parms{milly_gsm},'testing messages from Misterhouse');
	}


$v_sms_testchloe = new  Voice_Cmd('test SMS Messages to Chloe');
if (said $v_sms_testchloe) {
		&send_gsm_sms ($config_parms{chloe_gsm},'testing messages from Misterhouse');
	}


	$v_sms_testmat = new  Voice_Cmd('test SMS Messages to mat');
if (said $v_sms_testmat) {
		&send_gsm_sms ($config_parms{mat_gsm},'testing messages from Misterhouse');
	}
	
	
#	List SMS Messages
$v_sms_list_Unread = new  Voice_Cmd('List unread SMS Messages');
if (said $v_sms_list_Unread) {
	$gsm_mode = "list";
    set $gsm "AT+CMGL=\"REC UNREAD\"\r";
    ;
    print_log "Reading unread SMS List" ;# if $Debug{gsm};
}

#	List SMS Messages
$v_sms_list_All = new  Voice_Cmd('List all SMS Messages');
if (said $v_sms_list_All) {
	$gsm_mode = "list";
    set $gsm "AT+CMGL=\"ALL\"\r";
    ;
    print_log "Reading all SMS List" ;# if $Debug{gsm};
}

# GSM modem goes into hex mode every so often, which gives a framing error from the serial_item code
# this routine sends a AT evey ten seconds which reset it
# a bodge but it works

#if ($gsm_mode eq "" and new_second 10){ set $gsm "AT"};


#------------------------ read all incoming data and process it --------------------------------------

sub read_all {

	my $gsm_in;
	if ($gsm_in = said $gsm) {
#print_log "PHONE --->>> $gsm_in";#########################################################
		if ($gsm_mode ne "fail" ) {
			#print_log " recieved from GSM phone = $gsm_in";# if $Debug{gsm};
	
			if ($gsm_in =~ /^\n(.+)/) {
				print_log "GSM removed blank line";
				$gsm_in = $1
			}  # just trap random new lines

               		if ($gsm_in =~ /^\r(.+)/) {
				print_log "GSM removed blank line";
				$gsm_in = $1
			}
		
		#	if ($gsm_in =~ /^AT/) {
		#		print_log "SMS: AT command sent to phone trapped ($gsm_in)";# if $Debug{gsm}
	
			if ($gsm_in =~ /^OK/ and $gsm_mode eq "init") {
				print_log "GSM init OK";  # if $Debug{gsm};
				$gsm_mode = "init1";
				print_log " sent GSM  AT+CNMI=2,2,0,0,0";
				set $gsm 'AT+CNMI=2,2,0,0,0'    # set NEwMEssageIndicator  , set how to recieve a message from the network
			
			}
			elsif ($gsm_in =~ /^OK/ and $gsm_mode eq "init1") {
				print_log "sent GSM call signal quality AT_CSQ"; #if $Debug{gsm};
				set $gsm 'AT+CSQ';  	# should result in +cbc: pp/bb  pp = how powered 0 = battery 
							# 1 = mains/with battery on 2= mains and now battery 
							#  3= power fault now NO calls
							#  bb= percent bat level
				$gsm_mode = "init2"

			
			}
			elsif ($gsm_in =~ /^\+CSQ:/ and $gsm_mode eq "init2") {
				my ($gsm_signal,$sig_Unknown) = split (",", $gsm_in);
				$gsm_signal =~ s/^\+CSQ: //g;
				print_log "Gsm signal strength = $gsm_signal (0-30)"; # if $Debug{gsm};
			#	set $gsm 'AT+CNMI set here for any init 4';
				$gsm_mode = "";
				unset $timer_sig_bat_timeout;
				print_log "GSM init phone Is ok"; 		
				set $GSM_phoneStatus "ok";
				run_voice_cmd("List SMS Messages");
     				$Phone_dead = 0;

		


			#this bit traps the OK that comes with the init info	
			#	} elsif ($gsm_in=~/^OK/ and ($gsm_mode eq "init2" or $gsm_mode eq "init3" or $gsm_mode eq "init4")){
			
			}
			elsif ($gsm_in=~/^ERROR/ and ($gsm_mode eq "init" or $gsm_mode eq "init2" or $gsm_mode eq "init3" or $gsm_mode eq "init4")) {
				print_log "GSM init failed   :-  $gsm_mode";
				if ($gsm_mode eq "init") {
					$gsm_status="Init fail";
					 print_log " failed to do first init"; 
				 
				} elsif ($gsm_mode eq "init1") {
					$gsm_status="report to TE fail";
					print_log " failed at setting report info +CNMI";
				
	
				} elsif ($gsm_mode eq "init2") {
					$gsm_status="Signal strength fail";
					print_log " failed at reading Signal strength";
				
				} elsif ($gsm_mode eq "init4") {
					$gsm_status="phone ID fail";
					print_log " failed at reading phone ID";
				}
				$gsm_mode = "fail";
			
#			} elsif ($gsm_in ne ~/^ERROR/ and $gsm_in ne ~ /^OK/ and $gsm_mode eq "init") {
#				print_log "GSM init failed   :-  $gsm_in";
#				$gsm_mode = "";

		
			}
			elsif ($gsm_in =~ />/ and $gsm_mode eq "send1") {
				# after the request to send a SMS
				# ?? Module sends a 4 characters sequence: 0x0D 0x0A 0x3E 0x20

				set $gsm "$Sendmessage\cZ";
				# print_log "Part 2 - Sending message = $Sendmessage"; #  if $Debug{gsm};
				$gsm_mode = "send2"

			
			}
			elsif ($gsm_in =~ /^\+CMGS:/ and $gsm_mode eq "send2") {
				$gsm_in =~ s/^\+CMGS: //g;
				print_log "SMS Message $gsm_in sent";
			        $gsm_mode = ""

			}
			elsif ($gsm_in =~ /^ERROR/ and $gsm_mode eq "list") {		# List Empty
				$gsm_mode = "";
			
			}
			elsif ($gsm_in =~ /^OK/ and $gsm_mode eq "list") {
				print_log "SMS message List completed";# if $Debug{gsm};
				$gsm_mode = "";

			
			}
			elsif ($gsm_in =~ /^\+CMT/) {				# New message received
				$gsm_header = $gsm_in;				# first bit is the header 
				$gsm_mode = "new_message";
				print_log "new_message  :::  $gsm_in";
			}
			
			elsif ($gsm_in =~ /^\+CMGL/) {
				print_log "SMS Message Recieved: $gsm_in" ;# if $Debug{gsm};
				$gsm_header = $gsm_in;
				$gsm_mode = "message";
			}
			elsif ($gsm_mode eq "message") {
				print_log "SMS Message: $gsm_in" ;# if $Debug{gsm};
			#	print "$gsm_header    $gsm_in \n";
				&action_sms ($gsm_header, $gsm_in);
				$gsm_mode = "list";
			}
	        elsif ($gsm_mode eq "new_message") {
				$gsm_mode="";
				set $gsm "AT";
				&action_sms_1 ($gsm_header, $gsm_in)
			}

			#    check the status of the battery and signal strength started by the timer $timer_gsm_chk


			
			elsif ($gsm_in =~ /^\+CSQ:/ and $gsm_mode eq "sig_ck") {
				set $GSM_phoneStatus "ok";
				my ($gsm_signal,$sig_Unknown) = split (",", $gsm_in);
				$gsm_signal =~ s/^\+CSQ: //g;
				print_log "GSM chk signal strength = $gsm_signal (0-30)";# if $Debug{gsm};	
				if ($gsm_signal eq "0" ){
					$gsm_status=$gsm_status.",No signal";
					print_log " no phone signal";
				}elsif ($gsm_signal gt "3"){
				#	print_log " low phone signal";
					$gsm_status = $gsm_status.",low signal";
				}
				$gsm_mode = "";
				unset $timer_sig_bat_timeout    # unset the re init bit as a valid check was done
			}
    # if an error occurs when trying to check th bat or signal try to reinitilize
    # will loop until is Ok every 30 secs
			elsif ($gsm_in =~/^ERROR/ and $gsm_mode = "sig_ck") {
			
				print_log "GSM major fault   :-  trying to re initilize";
				set $gsm 'init';
				$gsm_mode = "init";		

		
			}
			 elsif ($gsm_in =~ /^\>/) {					# Remove > lines during send
			}
			 elsif ($gsm_in =~ /^OK/) {					# Remove extra OK
			}
			 elsif ($gsm_in eq "\r") {					# Remove empty lines

            }
			 elsif ($gsm_in =~ /^AT/) {					# Remove AT resets
			}
		
			elsif ($gsm_in =~ /\+CMS ERROR: 29/) {
				print_log " GSM phone out of Money? Error 29 returned from system while trying to send SMS";
	       			 &Master_log(" GSM phone out of Money? Error 29 returned from system while trying to send SMS") 	
			
			} 
			
			else {
			print_log "SMS Message not trapped: $gsm_in";
			}
		}	# end if GSM init has failed
    }  # end if anything in buffer to read

}  # end subr

				# action subr called from new sms
				# two needed becuase incoming data different
sub action_sms_1 {
	my ($header, $message) = @_;
 	my ($sms_from,$sms_nbr,$sms_date) = split (",", $header);
	my $SMS_command_code="";
	my $gtst;
    $sms_nbr =~ s/^\+CMGL: //;
	#$sms_status =~ s/\"//g;
	$sms_from =~ s/\+CMT: \"//g;
	$sms_from =~ s/\"//g;
# 	print ".$sms_nbr.";
	set $gsm "AT+CMGD=$sms_nbr\r";
 	print_log  "Deleting GSM SMS # $sms_nbr\n";

	my $name = &get_gsm ($sms_from);
	print_log "SMS from $name\: $message";
	if ($message =~ /^Mh /i and $name =~ /Beady|milly|zoe|chloe|caravans/) {
		$message =~ s/^Mh //ig;
		$SMS_command_code=$message;
		if ($message =~ /^(\d+)/){
		$SMS_command_code =$1};

		if ($SMS_command_code eq ""){
		 speak $message
       	

		}elsif  ($SMS_command_code eq "1") {
		# set the heating on|off|Hon|hoff|st  status  on  off / holiday heat on / holiday heat off
			if ($message =~/on/)
			           { speak " turned heating on";
			   }
			elsif ($message =~/off/)
			           { speak" turned heating off"}
			elsif ($message =~/st/)
			           { speak "Heating status returned to $sms_from ";
		                   	&send_gsm_sms ("$sms_from", "heating is ON/OFF at the Manor")
			        }
			
		} elsif ($SMS_command_code eq "2") {
		#2 gate  stuff    MH 2 st = status open = open gate
			if ($message =~/open/)
			   { speak "releasing gate for $name";
			   &send_gsm_sms("$sms_from","Opened the Gate, MH");
			  # set $timer_gate_state 15,sub{ &send_gsm_sms("$sms_from","gate is in ". state $gate_open_state." situation")};
			   &open_the_gate
			   }
  			 
   			  elsif ($message =~/bypass/){
				  speak " bypassing the Gate emergency switch for $name";
				  set $BarioNET_TCPctrl 'bypass gate Emergency SW'
			  }
 			  elsif ($message =~/safe/){
				  speak "Gate emergency switch mad safe for $name";
				  set $BarioNET_TCPctrl 'safe gate Emergency SW'
                            }


			   elsif ($message =~/st/){
			
			            speak"Returning the status of the field gate to $name on their phone";
			          $gtst="Gate Status\n";

				  if ( state $LincLocators eq 'entry'){$gtst=$gtst." Exit pad missing"
			         }elsif ( state $LincLocators eq 'exit'){$gtst=$gtst." Entry pad missing"
				 }elsif ( state $LincLocators eq 'ok'){$gtst=$gtst."Button pads both OK"
			          }else {
					  $gtst=$gtst."problem with button pads ";
					  if ($Temperature_entry gt "-10" and $Temperature_entry lt "55"){
					  $gtst=$gtst."but there is a temp reading of ". $Temperature_entry. " so Barionet working"

				         }else {$gtst=$gtst.$Temperature_entry}
				 }
  				 $gtst=$gtst ."\nStables 220V ". state $Node1_220V;
				 $gtst=$gtst ."\nEmergency Switch ". state $gate_Emergency_STOP_sw;
				 $gtst=$gtst ."\nGate motor 220V ".  state $gate_24V;
                                 
                                 $gtst=$gtst."\nlast used by\n". state $LastGateUse;


				&send_gsm_sms("$sms_from",$gtst)



				#
				# read the status of the gate in gate   
			     }
 		        
			

		}elsif ($SMS_command_code eq "11") {
			$message=~/(.{3})(.*)/;
			print_log $1,'  2 ',$2,'    3 ',$3;
			
			speak "Listen UP, message from $name  ";
			speak $2;
			speak "                     What I said was    ";
			speak $2;
		} elsif ($SMS_command_code eq "4862") {
			if ($message =~/on/)
			           { speak "alarm turned on"}
			elsif ($message =~/off/)
			           { speak" alarm turned off"}
			elsif ($message =~/st/)
			           { speak "alarm status returned to $sms_from ";
					   #
					   #
					   #
					   # Put here all the status for the alarms underground etc
		                   	&send_gsm_sms ("$sms_from", "alarm is ON/OFF at the Manor")
			        }
			
		}else{# ($SMS_command_code eq "99") {
			print_log "SMS not  uderstood so sending help SMS";
	&send_gsm_sms("$sms_from","SMS control Help\nThis will only work from phones registered with misterhouse\n 1 = heating\n  Mh 1 on  = heating ON\n   Mh 1 off  = heating off\n");
	sleep 2;
	&send_gsm_sms("$sms_from","help cont->\n 2 = gate\n  2 open = open gate\n  2 st = report status of gate\n  2 bypass  = bypass emerg SW\n  2 safe  = make emerg sw safe\n  11 = speak message in house\n Mh 11 speak this\n  xxxx = alarm PIN\n Mh xxxx on = alarm On\n  Mh xxxx off = alarm off	")


		} #else {
		#print_log "SMS Command to mh received in Error";
	#}		
	}else{# ($SMS_command_code eq "99") {
		 print_log "SMS not  understood so sending help SMS";
		

	     set $SMSdelaytimer3 5 ,sub {
				     &send_gsm_sms("$sms_from","SMS control Help\nThis will only work from phones registered with misterhouse\n 1 = heating\n  Mh 1 on  = heating ON\n   Mh 1 off  = heating off\n");
     };

	     set $SMSdelaytimer 10 ,sub {
			 &send_gsm_sms("$sms_from","help cont->\n 2 = gate\n  2 open = open gate\n  2 st = report status of gate\n  2 bypass  = bypass emerg SW\n  2 safe  = make emerg sw safe\n")
	                             };
	     set $SMSdelaytimer2 15 ,sub {
			 &send_gsm_sms("$sms_from","help cont ->\n11 = speak message in house\n Mh 11 speak this\n  xxxx = alarm PIN\n Mh xxxx on = alarm On\n  Mh xxxx off = alarm off	")
	                             }
		}

    #Delete the message so it doesnt clog the system


}
	# action subr used if called from the list sms
	
sub action_sms {
	my ($header, $message) = @_;
 	my ($sms_nbr, $sms_status, $sms_from, $sms_date) = split (",", $header);
        my $SMS_command_code = "";
	$sms_nbr =~ s/^\+CMGL: //;
	$sms_status =~ s/\"//g;
	$sms_from =~ s/\"//g;
# 	print ".$sms_nbr.";
	my $name = &get_gsm ($sms_from);
	print_log "SMS from $name:$message";
	if ($name =~ /Beady|Milly|zoe/) {
#	if ($message =~ /^Mh/i and $name =~ /Beady|Milly|zoe/) {
		$message =~ s/^mh //ig;
	
		$SMS_command_code=~/^\d\d/;
		
		print_log"SMS_command_code";
		
		if ($SMS_command_code eq ""){$SMS_command_code=~/^\d/};

		if ($SMS_command_code eq ""){
		 speak $message
		}elsif  ($SMS_command_code eq "1") {
			speak " message recieved was a code ONE"
		} elsif ($SMS_command_code eq "2") {
			speak " message recived was code TWO"
		} elsif ($SMS_command_code eq "11") {
			speak " message recived was code ELEVEN"			
		} else {
			print_log "SMS Command to mh received in Error";
		}	
	}
# delete the command sms
	set $gsm "AT+CMGD=$sms_nbr\r";
 	print_log  "Deleting GSM SMS $sms_nbr\n";
}
#  all the  numbers are held in mh_parms as SMS_phone_1,2 etc
#
#
#
sub get_gsm {
	my ($numberGSM) = @_;
	print_log "Looking for known GSM phone number $numberGSM";
	my $name;
	if ($numberGSM eq $config_parms{beady_gsm}) {
		$name = "Beady";
	} elsif ($numberGSM eq $config_parms{milly_gsm}) {
		$name = "Milly";
	} elsif ($numberGSM eq $config_parms{zoe_gsm}) {
		$name = "zoe";
	} elsif ($numberGSM eq $config_parms{chloe_gsm}) {
		$name = "Chloe";
	} elsif ($numberGSM eq "+447388168968") {
		$name = "MisterHouse";
	} elsif ($numberGSM eq "133") {
		$name = "Voicemail";
	} else {
		$name = "Unknown number ->$numberGSM";
	}
	return $name;
}

sub send_gsm_sms {
 	($numberGSM1, $Sendmessage) = @_;
 	my $gsm_response;
	if (state $GSM_phoneStatus  ne  "fault"){
		$gsm_mode = "send1";
			print_log "Sending SMS to $numberGSM1: $Sendmessage";
    		set $gsm "AT+CMGS=\"$numberGSM1\"\r";
			print_log "Part 1 - Sending number = $numberGSM1"; # if $Debug{gsm};

               #the rest of the message sending is handled in the read subr
	       # we have to wait for the 
	       # Module to  send a 4 characters sequence: 0x0D 0x0A 0x3E 0x20
	}
}
#   battery not read from new mode as its always plugged in the USB !!
#if ($New_Minute and $gsm_mode eq ""){     # make sure it's not doing anything else
#	       set $gsm "AT+CBC";             # start by checking the battery and charge status
#	       $gsm_mode="bat_ck";
#	       #   print_log " checking sig and bat";
#	       set $timer_sig_bat_timeout 20,"&sig_bat_timeout_error";
	       
#      }
	       
sub sig_bat_timeout_error {
     #    set $gsm 'init';
	# $gsm_mode = "init";

	 print_log "++++ phone dead? or not connected ++++\n     trying to re init again\n";
	 #sort out a counter hear that sounds an alarm after five? goes at re initing
	 $Phone_dead=++$Phone_dead;
	 set $GSM_phoneStatus "fault";    # for alarm security.pl
	 print_log " phone has been dead for $Phone_dead tries";
	# speak "attention      Attention     the Mo bile SMS phone appears to be dead or Not connected please check it,      the phone is under the stairs next to the house phone                             " if ($Phone_dead == 5);
	 #	 speak "attention      Attention     the Mobile SMS phone appears to be dead or Not connected please check it,      the phone is under the stairs next to the house phone                      " if ($Phone_dead == 5);
	# set $timer_sig_bat_timeout 40,"&sig_bat_timeout_error";
 }

	

	
	
#    set $timer_waitforanswer 10;
#    do {
#		$gsm_response = said $gsm;
#   		if ($gsm_response =~ /OK/) {
#    		print_log "Part 3 - DONE";
#    	}
#	} until (expired $timer_waitforanswer or $gsm_response =~ /OK/);
#
#



$CodeTimings::CodeTimings{'GSM_sms End'} = time();