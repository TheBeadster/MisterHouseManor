 # Category = BarioNET
#

$CodeTimings::CodeTimings{'NODE_2_Annex_BarioNET_Ser Start'} = time();

#########################################################################
# 									#
#              		 BARIOnet interface				#
#									#
#            		 see www.Barix.com				#
#									#
#			Beady Jan 2010					#
#									#	
#########################################################################




#@   this controls Comms between the Barionet device named 'ba2' by me  IP static at 192.168.1.22  : port 9009
#@   located in the plant room, 
#@   it Controls the Ibutton networkl for door access using a LINK45 ibutton interface
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
#					talks to front door touch pads which are linklocators
#					      see linklocator files/details
#					         Archive\HomeAutomation\other\link locator for ibutton touch pad manual.pdf 
#					
#
#
#		TCP protocol
#
#		the tcp protocol is kept simple so that the Barionet code is simple and all
#		clever processing is done by MH which keeps the coding / learning down to a minimum
#               
#	  #      Annex barionet deals with finding Linlocators as it is easier for it.
	  #      bario annex sends messages
	  #      1.   found xxxxxxxxxxxxxxx           			:  found ib on internal pad
	  #      2.   lost  xxxxxxxxxxxxxxx          		        :    ib lost from internal pad
	  #      3.   entry xxxxxxxxxxxxxxx           			:  ib presented to outside pad
	  #      4.   find  xxxxxxxxxxxxxxx   or find error        	:  return after a findLL request , 
	  #
	  #
	  #      this MH  code, sends a find to the barionet to look for the linclocators every  5 minutes, this also keeps the buttons on the pad inside upto date
	  #      so the system works on a interupt basis and a fall back polling system


#  Link locator stuff


my $LL_entry_adr_Annex; #='180000000493E8FE'; #   the address of the entry linclocator
# new LincLocator added here



$LincLocatorSearchTimer_Annex = new Timer;     #  timer to search for lincloctors, is variable to allow for resets etc
$LincLocatorTimeout_Annex = new Timer;


my ($LL_finder_count,$Pad1,$Pad2);

$LincLocators_Annex = new Generic_Item;

set_info $LincLocators_Annex 'Hold which linc locators are missing on the iButton network,  ok means both are present ';

my $LincLocator_find_error_Annex;               #

my $BarioNET_TCPser_address_Annex = '192.168.1.22:9009';

$BarioNET_TCPser_Annex = new  Socket_Item(undef, undef, $BarioNET_TCPser_address_Annex, 'BarioNETserAnnex','tcp','raw',"\r\n");


my ($unique_keyA,$cust_idA,$NameA,$accessA,$iBID_Annex,$iButtonDataAnnex,$IB_SearchA,$No_people_in_annex,$Annex_found,$iButtonDataAnnexEX);
#my $Mh_IbuttononAnnexPad_file = 'c:\houseautomation\misterhouse\MyMH\web\ia5\Gate\AnnexIbuttonpad.html';




#--------------------------------------------------------------------------------
#
#		some voice commands for testing debugging purposes
#

$v_t_Annex = new  Voice_Cmd("Restart TCP Barionet at Node 2 Serial");
&restart_Barionet_TCP_Annex if  said $v_t_Annex; 

$v_Fll_Annex = new  Voice_Cmd("Find Link Locators on Annex iButton network");

$v_En_LED_Annex = new Voice_Cmd("change Annex Entry LED to [Green,Red,Off]");
 
$v_Ex_LED_Annex = new Voice_Cmd("change Annex Exit LED to [Green,Red,Off]");
 



###################################################################################################################
#end of VAR decs
#
#.................................................................
#
# 		Runtime Code
# 		............
# ................................................................
#
#



#set $BarioNET_TCPser_Annex "Hello from ally" if (new_second 2 and active $BarioNET_TCPser_Annex) ;



#    open the TCP ports, this routine also checks the presence

if ($Reload or $Startup){
$Pad1="";
$Pad2="";
    start $BarioNET_TCPser_Annex if !(active $BarioNET_TCPser_Annex); 
  # this timer trys a restart if no connection made
   set  $LincLocatorSearchTimer_Annex 30, sub{&restart_Barionet_TCP_Annex};  
   set $LincLocators_Annex "NONE";   # clear ll
   set  $BarioNET_TCPser_Annex "FindLL" ;
   $No_people_in_annex = 0;
   set $LincLocatorTimeout_Annex 14400,sub{&find_lls};
   $LL_finder_count=0;          
   }

#------------------------------------------------------------------------------
 
#      search for Linkloctors

if  (said $v_Fll_Annex){

 set $BarioNET_TCPser_Annex 'FindLL'
}
    
       		    


	

#.........................................................
#
#     		Subr's and Funcs
#
#..........................................................

   # restarts the tcp connections if lost for any reason
sub restart_Barionet_TCP_Annex {

	print_log "restarting ANNEX TCP connections ";

	stop  $BarioNET_TCPser_Annex if active $BarioNET_TCPser_Annex;
my $timer1_annex = new Timer;
	set $timer1_annex 10 , sub{
				start  $BarioNET_TCPser_Annex;
	          	#set  $LincLocatorSearchTimer_Annex 30, sub{&restart_Barionet_TCP_Annex};  
                # no annex lincloctor on now
				#set  $BarioNET_TCPser_Annex "FindLL";
		        # $No_people_in_annex = 0;
		        $LL_finder_count++;
		        if($LL_finder_count=5){
			     	#	speak " The annex door access is not on the network";
		         	&Master_log(" The annex door access is not on the network");
				 	$LL_finder_count=0
			    	}

				set $LincLocatorTimeout_Annex 300,sub{&find_lls}


				}
	}
#----------------------------------------------------------------------------------
sub find_lls{
# linlocator doesnt work 2018

   set $LincLocators_Annex "NONE";   # clear ll
   #set  $BarioNET_TCPser_Annex "FindLL" ;
   # $No_people_in_annex = 0;
   #set $LincLocatorTimeout_Annex 14400,sub{&find_lls}





}



#--------------------------------------------------------------------------------------
  #
  # 
  #
  # remember to put cr,lfs onto outbound data or BARIO net gives a error
  #
  #
  # reads in the ibutton part of the data and proccesses it into the correct places
  #




if ($New_Second and active $BarioNET_TCPser_Annex and ($iButtonDataAnnexEX = said $BarioNET_TCPser_Annex)){

         
           $iButtonDataAnnex = $iButtonDataAnnex.$iButtonDataAnnexEX;
           print_log " Annex iButton keypad data : $iButtonDataAnnex"; 
	  #      Annex barionet deals with finding Linlocators as it is easier for it.
	  #      bario annex sends messages
	  #      1.   found xxxxxxxxxxxxxxx           			:  found ib on internal pad
	  #      2.   lost  xxxxxxxxxxxxxxx          		        :    ib lost from internal pad
	  #      3.   entry xxxxxxxxxxxxxxx           			:  ib presented to outside pad
	  #      4.   find  xxxxxxxxxxxxxxx   or find error        	:  return after a findLL request , 
     do{       # chomp through the messages from annex barionet
	                      
        $Annex_found =0;


	     if ($iButtonDataAnnex =~ /Find (\w{16})(.*)/s){

		 $iBID_Annex =  $1;
		 $iButtonDataAnnex=$2;
		 $Annex_found =1;
         set $LincLocators_Annex $iBID_Annex;
		
		 if ($iBID_Annex eq "error"){
			 print_log "Annex link locators not found"


		    } else {
               unset $LincLocatorSearchTimer_Annex;
			   set $LincLocatorTimeout_Annex 300,sub{&find_lls};
				$LL_finder_count=0;
		        print_log "Annex outside touchpad (linclocator) found OK $iBID_Annex"
		    }
	     }
	if ($iButtonDataAnnex =~ /Found \w\w(\w{12})(.*)/s){
            my $IB_ann = $1;
			$iButtonDataAnnex=$2;
			$Annex_found =1;
			my $Found_key = "0";
			 $IB_ann =~ tr/A-Z/a-z/;    # change everything to lower case
                         
			 # check if the key to turn on the hot water heater in the annex is on the internal pad
			 

			 if ($IB_ann eq $config_parms{Annex_hot_Water_Key} ){

				if (state $Annex_water_heater_allowed_on ne 'on'){
                     set $Annex_water_heater_allowed_on 'on'
                }
				print_log "Annex water heater is now allowed ON ".state $Annex_water_heater_allowed_on
			}


            foreach $IB_SearchA(@key_data){
				#  print_log "New key added to Annex internal pad $IB_ann ";
		           if ($IB_SearchA=~/$IB_ann/){     # key found now check who and when gets access
			  		   	$unique_keyA = $1,$cust_idA = $2,$NameA = $3,$accessA=$4  if $IB_SearchA=~/(\w{12}):(\w+):([^:]+):(\w+)/;
			 		 	$Found_key="1";
					 	print_log "iButton on Annex pad ID ".$IB_ann;
					 	print_log " this belongs to ".$NameA;
					 	if ($cust_idA eq "0"){
							set $Alarm_Group_Annex 'idle' if state $Alarm_Group_Annex ne  'idle';
							unset $Timer_workshop_delay;
				        	if ($Pad1 ne $unique_keyA and $Pad2 ne $unique_keyA){	 
						 
							#	 print_log "$NameA added key to the annex internal pad";
					
								if ($Pad1 eq ""){
						 	 		$Pad1 = $unique_keyA
					 	  		}else{
						 	 		$Pad2  =$unique_keyA
					  			}
								#   print_log "pad1 has $Pad1 on it";
								#	 print_log "pad2 had $Pad2 on it";
					 			$No_people_in_annex = 0;
								$No_people_in_annex = 1 if  ($Pad1 ne "");
								++$No_people_in_annex if ($Pad2 ne "");
					 	 		logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","$unique_keyA  $cust_idA $NameA key added to pad");

					     		set $Alarm_Group_Annex 'idle';
                         		unset $Timer_workshop_delay;                                         	 				

					          }
                                          

					   }
					 last
				 }

			 }
			 # put in a file for use in a html page the unknown button
			 # not implemented yet
			    if($Found_key != "1"){
                        
					 	logit($config_parms{IbuttononAnnexPad_file},"$IB_ann<br>");
                        
                        print_log "------------------------- Unknown Key on Annex pad : $IB_ann";
				 }

				 
			 print_log " ibuttons on the pad $No_people_in_annex ";
		  }


	if ($New_Day){
    # clear the list of unknow buttonsi inthe annex button reader file
     file_write($config_parms{IbuttononAnnexPad_file}, "Beady 2018");


	}	  

	if ($iButtonDataAnnex =~ /Lost \w\w(\w{12})(.*)/s){
		    my $IB_ann1 = $1;
            $iButtonDataAnnex = $2;
			$Annex_found =1;
			my $Found_key1 = "0";
			$IB_ann1 =~ tr/A-Z/a-z/;    # change everything to lower case
            foreach $IB_SearchA(@key_data){
					# print_log " looking for $IB_ann1  in $IB_SearchA";
		           	if ($IB_SearchA=~/$IB_ann1/){     # key found now check who and when gets access
			  		$unique_keyA = $1,$cust_idA = $2,$NameA = $3,$accessA=$4  if $IB_SearchA=~/(\w{12}):(\w+):([^:]+):(\w+)/;
			 		$Found_key1="1";
					if ($cust_idA eq "0"){
				    	print_log "removed from annex internal pad $NameA";
					    if ($Pad1 eq $unique_keyA){
						 	 $Pad1=""
					 	 }else{
						 	 $Pad2=""
					  	}
                                               # check if the key to turn on the hot water heater in the annex is still on the internal pad
			        if ($Pad1 ne $config_parms{Annex_hot_Water_Key} and $Pad2 ne $config_parms{Annex_hot_Water_Key} and inactive $Tmr_AnnexWater_heater_boost   ){

				               if (state $Annex_water_heater_allowed_on ne 'off'){
                                    set $Annex_water_heater_allowed_on 'off'
                               }
						print_log "Annex water heater is now  not allowed to turn on";
		                         	}



						$No_people_in_annex=0;
						$No_people_in_annex=1 if  ($Pad1 ne "");
						++$No_people_in_annex if ($Pad2 ne "");
					        if ($No_people_in_annex gt 0){$No_people_in_annex = $No_people_in_annex-1} ;
                                            	 if ($No_people_in_annex ==0){
                                		 logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","$unique_keyA  $cust_idA $NameA key removed from pad");
						# set timer to set alarm in 30 secs if no movement.
                                       		set $Timer_annex_delay 30,sub{ set $Alarm_Group_Annex  'active'};
				
					         }
					      last
				               }

			 }     
	 	 }
	             print_log "lost a button ? ibuttons on the pad now $No_people_in_annex ";
		  }



	if ($iButtonDataAnnex =~ /Entry \w\w(\w{12})(.*)/s){
                        my $IB_ann = $1;
                        $iButtonDataAnnex=$2;
			$Annex_found =1;
			my $Found_key = "0";

			
			 $IB_ann =~ tr/A-Z/a-z/;    # change everything to lower case
                        foreach $IB_SearchA(@key_data){
				#	   print_log " looking for $IB_ann  in $IB_SearchA";
		           if ($IB_SearchA=~/$IB_ann/){     # key found now check who and when gets access
			  		$unique_keyA = $1,$cust_idA = $2,$NameA = $3,$accessA=$4  if $IB_SearchA=~/(\w{12}):(\w+):([^:]+):(\w+)/;
			 		 # open the door if it is a family member
					 # print_log " Found key gjhgjkhgjhg";
			 		 $Found_key="1";
					 if ($cust_idA eq "0"){
				  		set $BarioNET_TCPser_Annex "Open";
						print_log " annex door opened for $NameA";
						set $Alarm_Group_Annex 'idle';
						unset $Timer_workshop_delay;   # stop the workshop alarm if accesed by the big door.
 					         # set timer to re-arm annex after 30 mins of no movement
 						set $Timer_annex_delay 1800,sub{ set $Alarm_Group_Annex 'active'};
 			  			logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","$unique_keyA  $cust_idA $NameA Annex access")
			  				}else{

                    				logit($config_parms{data_dir}."/AlarmData/Annex_Logs/Annex_log.$Year_Month_Now.log","$unique_keyA  $cust_idA $NameA Annex access Failed not family or friend")

		 				 } 
                                last           # stops the looping thru the rest if it was found

	  			}

		  }
		  if ($Found_key eq "0"){
			  	 logit("$config_parms{key_dir}/unknown_keylog.txt","$IB_ann  on Annex pad");
                     print_log " unknown key entered onto annex $IB_ann"
	     }


	  }
    }while ($Annex_found eq 1)
}  # end of check for incoming data from tcp serial barionet




$CodeTimings::CodeTimings{'NODE_2_Annex_BarioNET_Ser End'} = time();




