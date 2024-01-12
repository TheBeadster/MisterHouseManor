#category = Phone


# dials up oranges sms server to send a sms
# this is RUn as a seperate process so it doesn't hang MH while dialing etc
#
# #######################################################################################
# 											#
# 			sends sms via orange direct message centre			#
# 			at 07973 100602,						#
# 			use Subr as  send_sms(message,number,message2,number2,..	#
# 			there is a long delay after the 3rd message approx 20 secs     	#
# 			probably to stop SMS spam  calls charged at mob phone rate	#
# 			one sms = about 12 pence sterling.				#
#			bd@beady.com November 5th 2002					#
#											#
#########################################################################################
$CodeTimings::CodeTimings{'Send_sms Start'} = time();


$modem = new Serial_Item(undef,undef,'serial1');
if ($Startup and defined $modem) {stop $modem};

#   used to test send_sms as a seperate run process

$V_send_test_sms = new Voice_Cmd("Send test SMS");
if (said $V_send_test_sms){
print_log "running sms test";
my @testing=('SMS test from Betchton manor','07973440107');
&send_sms(@testing)
}

	

my ($data,$flag,$sending_sms,$NumberSMS,$Message,@SMS);
my $sms_timer = new Timer;


sub send_sms {	
        (@SMS) = @_;
	print_log "sms = @SMS";
	if (defined $modem ) {
	#start $modem; 
	#set $modem "AT";
	 $flag = 'false';
	 $sending_sms="true";
	 print_log " modem opened and AT sent"
 }
 else {

	 	print_log "cant open modem port";
		$sending_sms="false"
	}

}

if (( defined $modem) and ($data = said $modem) and $sending_sms eq "true") {
         print_log "recieved from modem -- $data";
	 
	 if ($data eq 'OK') {
	 			set $modem "ATD07973100602";
				print_log "sent ATD07973100602";
	 	 set $sms_timer 60,"&hang_up"
 				}	 
	if ($data =~ /Exit/)  { 
				$NumberSMS = pop @SMS;
				if ($NumberSMS ne ''){
	  			set $modem 'S'.$NumberSMS;   #'S07973440107';
	  			print_log "sent S ".$NumberSMS
	  			} 
				else
				{
				set $modem 'E';
	  			unset $sms_timer;  # just tidies up errors and messages
	  			stop $modem
			}
		}
	  # set $modem "07973440107" if ($data =~ /destination/);
	 
	if ($data =~ /Type your message/){
				$Message = pop @SMS;
				set $modem $Message;   #"Test from Mister house\n";
				print_log "sent message  ".$Message;
				$flag = 'true'
	  			}
  }

  
sub hang_up {

	 sleep 2;
	 stop $modem;
	 $flag ='false';
	 $sending_sms="false"
 }
	# hang up if not done in 30 secs change for more sms done

$CodeTimings::CodeTimings{'Send_sms End'} = time();



