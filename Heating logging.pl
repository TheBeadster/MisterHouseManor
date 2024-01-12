# Category = HVAC
#
##########################################################################
# 									                                     #
#                    HVAC logging                                        #
#                                                                        #
#                                                                        #
#                                                                        #
#              Beady 2018                                                #
#                                                                        #
##########################################################################

$CodeTimings::CodeTimings{'Heating_Logging Start'} = time();

# logs to a file in data dir nice and simple
# and logs to a database so we can make nice graphs at somepoint :-) maybe !! 2018


# Logging these two routines fill the logs in the data directory
# first adds heading to the log every hours to make it easier to read
# the second adds a line with the state of all the heating when anything changes

my %Heating_Status;   # a hash to contain all the heating status's


if ( $New_Hour){
logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log","_________________________________________________________________________________________________________________________");

$Log_Header ="|House | Rads | DHW  | DHW  |Ufloor |Ufloor |Annex |Annex |Buffer| GSHP | Oil  | Temps-> |O/side | House |Annex |Buffer |Bed 1 |";


logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",$Log_Header);
$Log_Header ="|heat  | pump |      | pump |       | pump  |      |pump  |Boost |      |boiler| Temps-> | Avg   | Avg   |      |       |      |";
 

logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",$Log_Header);
#force a line with all the current states
$Heating_Status{'House'} = 0;
$Heating_Status{'Rads'} = 0;
$Heating_Status{'DHW'} = 0;
$Heating_Status{'DHW_pump'} = 0;
$Heating_Status{'Ufloor'} = 0;
$Heating_Status{'Ufloor_pump'} = 0;
$Heating_Status{'Annex'} = 0;
$Heating_Status{'Annex_pump'} = 0;
$Heating_Status{'BufferBoost'} = 0;
$Heating_Status{'GSHP'} = 0;
$Heating_Status{'Oil_Boiler'} = 0;
}

#'---------------  LOG heating states --------------------------------------------------
if ($Reload or $Startup){
$Heating_Status{'House'} = 0;
$Heating_Status{'Rads'} = 0;
$Heating_Status{'DHW'} = 0;
$Heating_Status{'DHW_pump'} = 0;
$Heating_Status{'Ufloor'} = 0;
$Heating_Status{'Ufloor_pump'} = 0;
$Heating_Status{'Annex'} = 0;
$Heating_Status{'Annex_pump'} = 0;
$Heating_Status{'BufferBoost'} = 0;
$Heating_Status{'GSHP'} = 0;
$Heating_Status{'Oil_Boiler'} = 0;
}

if ( $New_Minute and (
 $Heating_Status{'House'} ne state $House_Radiators or
 $Heating_Status{'Rads'}  ne state $Status_House_Radiators or
 
 (
 
 (($Heating_Status{'DHW'}   ne state $House_DHW ) and state $Summer_heating_Strategy eq 'off') or 
 (($Heating_Status{'DHW'}   ne state $Status_House_DHW_immersion) and state $Summer_heating_Strategy eq 'on' )

 ) or
 $Heating_Status{'DHW_pump'} ne state $Status_House_DHW or
 $Heating_Status{'Ufloor'} ne state $House_uFloor_Heating  or
 $Heating_Status{'Ufloor_pump'} ne state $Status_uFloor_Heating or
 $Heating_Status{'Annex'} ne state $Annex_Heating or
 $Heating_Status{'Annex_pump'} ne state $Status_Annex_Heating_pump or
 $Heating_Status{'BufferBoost'} ne $Buffer_Tank_Boost_GSHP or
 $Heating_Status{'GSHP'} ne state $Status_GSHP or
 $Heating_Status{'Oil_Boiler'} ne state $Status_Oil_Boiler)){

 #print_log " DHW is $Heating_Status{'DHW'}  and the immersion status is ". state $Status_House_DHW_immersion;
 if      ($Heating_Status{'House'} ne state $House_Radiators){ $Log_Header = "| ".(sprintf "%-5s",state $House_Radiators) . "|" } else {$Log_Header = "|      |"} ;
 if      ($Heating_Status{'Rads'}  ne state $Status_House_Radiators){ $Log_Header = $Log_Header ." ". (sprintf "%-5s",state $Status_House_Radiators) . "|" } else {$Log_Header =$Log_Header . "      |"} ;
 if ( state $Summer_heating_Strategy eq 'off'){
     if      ($Heating_Status{'DHW'}   ne state $House_DHW ) { $Log_Header = $Log_Header . " ".(sprintf "%-5s",state $House_DHW) . "|" } else {$Log_Header =$Log_Header . "      |"} ;
     }else{
     if      ($Heating_Status{'DHW'}   ne state $Status_House_DHW_immersion ) { $Log_Header = $Log_Header . " ".(sprintf "%-4s",state $Status_House_DHW_immersion ) . "i|" } else {$Log_Header =$Log_Header . "      |"} ;
  }
 if      ($Heating_Status{'DHW_pump'} ne state $Status_House_DHW) { $Log_Header = $Log_Header ." ". (sprintf "%-5s",state $Status_House_DHW) . "|" } else {$Log_Header =$Log_Header . "      |"} ;
 if      ($Heating_Status{'Ufloor'} ne state $House_uFloor_Heating) { $Log_Header = $Log_Header ." ". (sprintf "%-6s",state $House_uFloor_Heating). "|" } else {$Log_Header =$Log_Header . "       |"} ;
 if      ($Heating_Status{'Ufloor_pump'} ne state $Status_uFloor_Heating) { $Log_Header = $Log_Header ." ". (sprintf "%-6s",state $Status_uFloor_Heating) . "|" } else {$Log_Header =$Log_Header . "       |"} ;
 if      ($Heating_Status{'Annex'} ne state $Annex_Heating) { $Log_Header = $Log_Header ." ". (sprintf "%-5s",state $Annex_Heating) . "|" } else {$Log_Header =$Log_Header . "      |"} ;
 if      ($Heating_Status{'Annex_pump'} ne state $Status_Annex_Heating_pump) { $Log_Header = $Log_Header ." ". (sprintf "%-5s",state $Status_Annex_Heating_pump) . "|" } else {$Log_Header =$Log_Header . "      |"} ;
 if      ($Heating_Status{'BufferBoost'} ne state $Buffer_Tank_Boost_GSHP) { $Log_Header = $Log_Header ." ". (sprintf "%-5s",state $Buffer_Tank_Boost_GSHP) . "|" } else {$Log_Header =$Log_Header . "      |"} ;
 if      ($Heating_Status{'GSHP'} ne state $Status_GSHP) { $Log_Header = $Log_Header ." ". (sprintf "%-5s",state $Status_GSHP) . "|" } else {$Log_Header =$Log_Header . "      |"} ;
 if      ($Heating_Status{'Oil_Boiler'} ne state $Status_Oil_Boiler){ $Log_Header = $Log_Header ." ". (sprintf "%-5s",state $Status_Oil_Boiler) . "|" } else {$Log_Header =$Log_Header . "      |"} ;

$YY1 = state $T_entryGEN;
$YY1 = round $YY1,1;
$YY2 = state $T_avg_House;
$YY2 = round $YY2,1;
$YY3 = state $T_AnnexRoom_GEN;
$YY3 = round $YY3,1;
$YY4 = state $T_HHS;
$YY4 = round $YY4,1;
$YY5 = state $T_Bed1;
$YY5 = round $YY5,1;


$Log_Header =$Log_Header . "         | ". (sprintf "%-6s",$YY1) . "| " . (sprintf "%-6s",$YY2) . "| " . (sprintf "%-5s",$YY3) ."| " . (sprintf "%-6s",$YY4) ."|". (sprintf "%-6s",$YY5) ."|";

logit("$config_parms{HVACLog_dir}/HVAClog.$Year_Month_Now.log",$Log_Header);

 $Heating_Status{'House'} = state $House_Radiators ;
 $Heating_Status{'Rads'}  =state $Status_House_Radiators ;

if ( $Summer_heating_Strategy){
     $Heating_Status{'DHW'}   = state $Status_House_DHW_immersion;     
}else{

     $Heating_Status{'DHW'}   = state $House_DHW ;
}
 
 $Heating_Status{'DHW_pump'}= state $Status_House_DHW ;
 $Heating_Status{'Ufloor'} = state $House_uFloor_Heating  ;
 $Heating_Status{'Ufloor_pump'} =state $Status_uFloor_Heating ;
 $Heating_Status{'Annex'} = state $Annex_Heating ;
 $Heating_Status{'Annex_pump'} = state $Status_Annex_Heating_pump ;
 $Heating_Status{'BufferBoost'} = $Buffer_Tank_Boost_GSHP;
 $Heating_Status{'GSHP'} = state $Status_GSHP ;
 $Heating_Status{'Oil_Boiler'} = state $Status_Oil_Boiler;




   } 


   $CodeTimings::CodeTimings{'Heating_Logging End'} = time();
