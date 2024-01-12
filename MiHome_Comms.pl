# Category = MiHomeDevices
#

$CodeTimings::CodeTimings{'MiHomeComms Start'} = time();

##########################################################################
# 									                                     #
#          Comms for rasperry pi to control energenie eTRV               #
#                                                                        #
#             https://mihome4u.co.uk/                                    #
#                                                                        #
#              Beady 2018                                                #
#                                                                        #
##########################################################################


# comms with all MiHome devices

#@ Controls the radiator valves via UDP comms to the RaspeberryPi 
#@ as of 2020 it reads the etrv but they were usless so just use this for
#@ control of sockets insted of X10 modules
#@ raspberru pi is under in the kitchen in the tiny end cupboard , there is a backup SD card next to it
#@ the PI is 192.168.1.24 for wifi and 
#@ it also controls the kitchen LED lights using a proxy MH
#@  or MiHome_eTRV_rPI
#@ VNC into the rPI dadmin betchton  if you need to change a eTRV then
#@ 1. press ctrl C to stop the rotuine you will get a menu
#@ 2. delete the eTRV you are changing
#@ 3. then use miHome discovery mode , could be 5 mins for the
#@     eTRV to appear , put the batteries in the eTRV
#@ 4. wait could take 5 mins to appear
#@     when it appears press Y to register it
#@ 5. then CTRL c to exit
#@ 6. rename it using the names below, make sure its exact
#@ 7. then select MH_comms in the menu to restore communications to MH
#@ 8. NOTE the back SD card will not have this on , just in case you need to use it
#@    you may have to re register any , again, or boot the back up sd car and register it now!!
#@ Legacy device ie cheep energenie recieve only sockets etc
#@ use the legacy learn mode, press the button on the device for 5 seconds until light flashes slowly  then use menu 1
#@ give it a house number 1-9 and a code 1-4, if they share the same house and device code they will work together
#@ when they have paired the light will stay off 
#@ the code to use the legacy devices is like this
#@$Christmas_Lights -> tie_event('set $Mihome_eTRV_rPi_UDPctrl "#1.1:".$state'); 
#@ #1.1 is house code then device code





=begin
   valve                address     name
   Dining               7363        1.DINING
   hallway              7283        2.HALLWAY
   bed downstairs       7314    3.BED-DOWNSTAIRS
   bed chloe            7321    4.BED-CHLOE
   bed master           7323    5.BED-MASTER
   bed master by door   7149    6.STUDY now 6.BED-MASTER2
   bathroom             7224    7.WC-MAIN
   ensuite              7348    8.WC-ENSUITE


   toilet utilty rm         9.WC-DOWNSTAIRS



   Mihome others
   type        address     used for        name
     MH0005           6208        garden light    1.1 SWITCH
     MH0005                                     1.switch
     MH0005                        xmas light   1.switch


   legacy devices ie cheepo one way control

   MH002        

   not installed yet





  any commands sent to theeTRV can take 5 mins to work,
  the eTRV only recieves for a short time 200ms after it has transmitted it's temperature to the Rpi
  so only then can it accept a command
  however the commands can be queued , but generaly only one or two at a time due to the
  eTRV recieve time window
  

error messages
d0, motor current below expectation * (not implemented)
d1, motor current always high * (not implemented)
d2, motor taking too long to open/close *
d3, discrepancy between air and pipe sensors * (not implemented)
d4, air sensor out of expected range *
d5, pipe sensor out of expected range *
d6, low power mode is enabled (default is disabled)
d7, no target temperature has been set by host
Data high byte:
d0, valve may be sticking *
d1, valve exercise was successful *
d2, valve exercise was unsuccessful *
d3, driver micro has suffered a watchdog reset and needs data refresh *
d4, driver micro has suffered a noise reset and needs data refresh *
d5, battery voltage has fallen below 2.2V and valve has been opened *
d6, request for heat messaging is enabled (default is disabled)
d7, request for heat



=cut



$Mihome_eTRV_rPi_found = new Timer;
$Mihome_eTRV_reply = new Timer;


#the ctrl is used to send commands to the energenie board on the RasPi
my $Mihome_eTRV_rPi_UDP_ctrl_address = '192.168.1.24:45001'; 
$Mihome_eTRV_rPi_UDPctrl = new  Socket_Item(undef, undef, $Mihome_eTRV_rPi_UDP_ctrl_address, 'Mihome_eTRV_rPi_CTRL','udp','record');





sub Open_Mihome_eTRV_rPi_comms{
	 stop $Mihome_eTRV_rPi_UDPctrl if active $Mihome_eTRV_rPi_UDPctrl;
     start $Mihome_eTRV_rPi_UDPctrl;
     # start a UDP server, server_MiHome1 is set in mh.private.ini
$Mihome_eTRV_rPi_UDPevent_server = new  Socket_Item(undef, undef, 'server_MiHome1');
}

if ($Reload or $Startup){

    &Open_Mihome_eTRV_rPi_comms;
    print_log" Mihome CTRL port open" if active $Mihome_eTRV_rPi_UDPctrl;
}

#if (new_second 12){

#set $Mihome_eTRV_rPi_UDPctrl "#1.POND:on";
#}


#if (new_second 45){
#set $Mihome_eTRV_rPi_UDPctrl "#1.POND:off";
#}





if (new_second 50){
    #set $Mihome_eTRV_rPi_UDPctrl "2.HALLWAY:25";
    set $Mihome_eTRV_rPi_UDPctrl "PING from MH";
   # print_log"Sending PING to ETRV pi";

    set $Mihome_eTRV_reply 45,sub{
        print_log "restarting pi @ $Mihome_eTRV_rPi_UDP_ctrl_address eTRV CTRL UDP port";
        stop $Mihome_eTRV_rPi_UDPctrl if active $Mihome_eTRV_rPi_UDPctrl;
        start $Mihome_eTRV_rPi_UDPctrl
    }
}





# ($New_Second and active $Mihome_eTRV_rPi_UDPevent and
if ( $state = said $Mihome_eTRV_rPi_UDPevent_server ){#and new_second 5)  {
    # stop the UDP soocket reset if we have had an 'ACK' back from client

   # print_log "recieved from Mihome_eTRV $state " ;
    if ($state eq"ACK" ){
           
            set $Mihome_eTRV_reply 45,sub{
                print_log "restarting pi @ $Mihome_eTRV_rPi_UDP_ctrl_address eTRV CTRL UDP port";
                stop $Mihome_eTRV_rPi_UDPctrl if active $Mihome_eTRV_rPi_UDPctrl;
                start $Mihome_eTRV_rPi_UDPctrl
            }
        #print_log "recieved ACK from Mihome_eTRV $state " 







        }

    # print_log "Mihome_eTRV_rPi ------------------------>\n " .$state;
        # eTRV_Name 6.Study
        # AT  ambient temp
        # BV  battery voltage
        # DF  error flag code
        # PT  pipe temperature
        # ST  setpoint temperature
        # VP  valve position

        # note only AT BV and DF are reported from eTRV , the others are what the Pi keeps in memory but loses all setting 
        # on restart hence the ignoring of none and the timestamp to check the age
        # if they = none, then MH will have to update them, ST should stay in the eTRV memory in theory


    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # maybe have to ad a timestamp from MH when a different timetamp is recieved so we can work out when it was last seen


    # SWITCH energy data comes like this

    # Power reporting

    # 1.SWITCH 1544037451.44 AP:None C:None F:49.8515625 RP:0 RP:0 S:False V:241


    

    my $remaining;
    my $time_recvd;
            # I have had to do it this way so the items are stored in generic items
            # so they persist on restarts otherwise they would be zero and force the sensors in the wrong temp
            # as the sensors only report every 5 mins
            # also the eTRV do not report the ST so we use misterhouse to keep track of the values
    while ($state =~/(\d\..*) (\d+\.\d*) (AT.*)/g){
        #print_log $state;
        $time_recvd = $2;
       # print_log " time recvd ............$time_recvd";
        $remaining = $3;
        # print_log "$1  Remaining $remaining";
        if($1 eq "1.DINING") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                # print_log " dining  $1 $2";
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_Dining  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_Dining  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_Dining  round($2,1) };
                # if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_Dining  round($2,1) };
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_Dining  round($2,1) };           
                if ( $1 eq 'LS' and  $2 ne 'None') {
                    
                    if ( state $eTRV_LS_Dining != $time_recvd){
                        set $eTRV_LST_Dining  round(($time_recvd - state $eTRV_LS_Dining));
                                
                        set $eTRV_LS_Dining  $2 ;
                        }
                    }
                }     
            }
        if($1 eq "2.HALLWAY") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                #print_log " hallway  $1 $2";
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_Hallway  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_Hallway  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_Hallway  round($2,1) };
                # if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_Hallway  round($2,1) };
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_Hallway  round($2,1) };           
                if ( $1 eq 'LS' and  $2 ne 'None') {  
                        if ( state $eTRV_LS_Hallway != $time_recvd){
                            set $eTRV_LST_Hallway  round(($time_recvd - state $eTRV_LS_Hallway));           
                            set $eTRV_LS_Hallway  $2 ;
                            }
                        }
                }
            }
        if($1 eq "3.BED-DOWNSTAIRS") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                #print_log " bed down  $1 $2";
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_Bed_Downstairs  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_Bed_Downstairs  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_Bed_Downstairs  round($2,1) };
                # if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_Bed_Downstairs  round($2,1) };;
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_Bed_Downstairs  round($2,1) }; 

                if ( $1 eq 'LS' and  $2 ne 'None') {   
                        if ( state $eTRV_LS_Bed_Downstairs != $time_recvd ){
                            set $eTRV_LST_Bed_Downstairs  round(($time_recvd - state $eTRV_LS_Bed_Downstairs));           
                            set $eTRV_LS_Bed_Downstairs  $2 ;
                            } }
                }
            }
        if($1 eq "4.BED-CHLOE") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                #print_log " bed chloe  $1 $2";
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_Bed_Chloe  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_Bed_Chloe  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_Bed_Chloe  round($2,1) };
                # if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_Bed_Chloe  round($2,1) };
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_Bed_Chloe  round($2,1) };           
                if ( $1 eq 'LS' and  $2 ne 'None') {  
                        if ( state $eTRV_LS_Bed_Chloe != $time_recvd){
                            set $eTRV_LST_Bed_Chloe   round(($time_recvd - state $eTRV_LS_Bed_Chloe));           
                            set $eTRV_LS_Bed_Chloe  $2 ;
                            } }
                }
            }
        if($1 eq "5.BED-MASTER") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                #print_log " bed master  $1 $2";
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_Bed_Master  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_Bed_Master  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_Bed_Master  round($2,1) };
                #if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_Bed_Master  round($2,1) };
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_Bed_Master  round($2,1) };           
                if ( $1 eq 'LS' and  $2 ne 'None') {   
                        if ( state $eTRV_LS_Bed_Master != $time_recvd){
                            set $eTRV_LST_Bed_Master  round(($time_recvd - state $eTRV_LS_Bed_Master));           
                            set $eTRV_LS_Bed_Master  $2 ;
                            }}
                }
            }
        if($1 eq "6.BED-MASTER2") {  # is now bed 1 radiator by the door, 
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                # print_log " study  $1 $2";Bed_Master2
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_Bed_Master2  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_Bed_Master2  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_Bed_Master2  round($2,1) };
                #if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_Bed_Master2  round($2,1) };
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_Bed_Master2  round($2,1) };           
                if ( $1 eq 'LS' and  $2 ne 'None') {   
                        if ( state $eTRV_LS_Bed_Master2 != $time_recvd){
                            set $eTRV_LST_Bed_Master2  round(($time_recvd  - state $eTRV_LS_Bed_Master2));           
                            set $eTRV_LS_Bed_Master2  $2 ;
                            } }
                }
            }
        if($1 eq "7.WC-MAIN") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                #print_log " wc main  $1 $2";
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_WC_main  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_WC_main  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_WC_main  round($2,1) };
                #if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_WC_main  round($2,1) };
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_WC_main  round($2,1) };           
                if ( $1 eq 'LS' and  $2 ne 'None') {   
                        if ( state $eTRV_LS_WC_main != $time_recvd){
                            set $eTRV_LST_WC_main  round(($time_recvd  - state $eTRV_LS_WC_main));           
                            set $eTRV_LS_WC_main  $2 ;
                            } }
                }
            }
        if($1 eq "8.WC-ENSUITE") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                #print_log " wc ensuite  $1 $2";
                if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_WC_Ensuite  round($2,1) };
                if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_WC_Ensuite  round($2,3) };
                if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_WC_Ensuite  round($2,1) };
                #if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_WC_Ensuite  round($2,1) };
                if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_WC_Ensuite  round($2,1) };           
                if ( $1 eq 'LS' and  $2 ne 'None') {   
                        if ( state $eTRV_LS_WC_Ensuite != $time_recvd){
                            set $eTRV_LST_WC_Ensuite  round(($time_recvd  - state $eTRV_LS_WC_Ensuite));           
                            set $eTRV_LS_WC_Ensuite  $2 ;
                            } }
                }
            }
        if($1 eq "9.WC-DOWNSTAIRS") {
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                #print_log " wc downstairs  $1 $2"
                # if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_WC_downstairs  round($2,1) };
                #if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_WC_downstairs  round($2,1) };
                # if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_WC_downstairs  round($2,1) };
                #if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_WC_downstairs  round($2,1) };
                # if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_WC_downstairs  round($2,1) };           
                # if ( $1 eq 'LS' and  $2 ne 'None') {   
                #           if ( state $eTRV_LS_WC_downstairs != $time_recvd){
                #             set $eTRV_LST_WC_downstairs  round(($time_recvd  - state $eTRV_LS_WC_downstairs));           
                #             set $eTRV_LS_WC_downstairs  $2 ;
                #             } 
                # }
                }
            }                                                                              
        if($1 eq "1.POND") {
            print_log"POND power :-)";
            while ($remaining =~/(\w\w):([a-zA-Z0-9\.]*)/g){
                print_log " POND  $1 $2"
                # if ( $1 eq 'AT' and  $2 ne 'None') { set $eTRV_AT_WC_downstairs  round($2,1) };
                #if ( $1 eq 'BV' and  $2 ne 'None') { set $eTRV_BV_WC_downstairs  round($2,1) };
                # if ( $1 eq 'DF' and  $2 ne 'None') { set $eTRV_DF_WC_downstairs  round($2,1) };
                #if ( $1 eq 'ST' and  $2 ne 'None') { set $eTRV_ST_WC_downstairs  round($2,1) };
                # if ( $1 eq 'VP' and  $2 ne 'None') { set $eTRV_VP_WC_downstairs  round($2,1) };           
                # if ( $1 eq 'LS' and  $2 ne 'None') {   
                #           if ( state $eTRV_LS_WC_downstairs != $time_recvd){
                #             set $eTRV_LST_WC_downstairs  round(($time_recvd  - state $eTRV_LS_WC_downstairs));           
                #             set $eTRV_LS_WC_downstairs  $2 ;
                #             } 
                # }
                }
            }  




        } 
#=begin




    if ($state =~ /(.*) (\w\w):(.*) (\w\w):(.*) (\w\w):(.*) (\w\w):(.*) (\w\w):(.*) (\w\w):(.*) (\w\w):(.*)/){ 
        #my ($eTRV_Name, $AT, $BV,$DF,$PT,$ST,$VP) =
        #print_log "$eTRV_Name $AT   $BV $DF  $PT  $ST $VP"
        #print_log $_ ."  ".$1."  ".$2."  ".$3."  ".$4."  ".$5;


        

            if($1 eq "1.DINING") {
                if ( $2 ne 'None') { set $eTRV_AT_Dining  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_Dining  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_Dining  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_Dining  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_Dining  $7 }
                } 
            elsif($1 eq  "2.HALLWAY") {
                if ( $2 ne 'None') { set $eTRV_AT_Hallway  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_Hallway  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_Hallway  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_Hallway  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_Hallway  $7 }
                }
            elsif($1 eq  "3.BED-DOWNSTAIRS") {
                if ( $2 ne 'None') { set $eTRV_AT_Bed_Downstairs  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_Bed_Downstairs  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_Bed_Downstairs  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_Bed_Downstairs  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_Bed_Downstairs  $7 }
                }
            elsif($1 eq   "4.BED-CHLOE") {
                if ( $2 ne 'None') { set $eTRV_AT_Bed_Chloe  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_Bed_Chloe  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_Bed_Chloe  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_Bed_Chloe  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_Bed_Chloe  $7 };
                }
            elsif($1 eq   "5.BED-MASTER") {
                if ( $2 ne 'None') { set $eTRV_AT_Bed_Master  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_Bed_Master  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_Bed_Master  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_Bed_Master  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_Bed_Master  $7 }
                }
            elsif($1 eq   "6.STUDY") {
                if ( $2 ne 'None') { set $eTRV_AT_Study  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_Study  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_Study  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_Study  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_Study  $7 }
                }
            elsif($1 eq   "7.WC-MAIN") {
                if ( $2 ne 'None') { set $eTRV_AT_WC_main  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_WC_main  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_WC_main  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_WC_main  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_WC_main  $7 }
                }
            elsif($1 eq   "8.WC-ENSUITE") {
                if ( $2 ne 'None') { set $eTRV_AT_WC_Ensuite  round($2,1) };
                if ( $3 ne 'None') { set $eTRV_BV_WC_Ensuite  $3 };
                if ( $4 ne 'None') { set $eTRV_DF_WC_Ensuite  $4 };
                if ( $6 ne 'None') { set $eTRV_ST_WC_Ensuite  $6 };
                if ( $7 ne 'None') { set $eTRV_VP_WC_Ensuite  $7 }
                }
            elsif($1 eq   "9.WC-DOWNSTAIRS") {
                # if ( $2 ne 'None') { set $eTRV_AT_Dining $2;
                # if ( $3 ne 'None') { set $eTRV_BV_Dining  $3;
                # if ( $4 ne 'None') { set $eTRV_DF_Dining  $4;
                # if ( $6 ne 'None') { set $eTRV_ST_Dining  $6;
                # if ( $7 ne 'None') { set $eTRV_VP_Dining  $7
                }
    

        }
            
   # =cut
}


$CodeTimings::CodeTimings{'MiHomeComms End'} = time();