# this is now on the prox annex
# duw to RRDS messing with windows and no updates

=begin

#use RRDs;

if ($New_Minute and new_minute 65){
#update the RRD temperature databases every 5 minutes
	#
	# HEAT STORE

   $TTY = state $T_HeatStore_Upper_GEN if state $T_HeatStore_Upper_GEN ne "error";
   $TTY =round $TTY ,1;
   $TTY1 =state $T_HeatStore_Lower_GEN if state $T_HeatStore_Lower_GEN ne "error";
   $TTY1 =round $TTY1 ,1;



	# Outside
	#

   $TTY = state $T_entryGEN if state $T_entryGEN ne "error";
   $TTY =round $TTY ,1;
   # run "RRDtool update $RRD N:$TTY";     # faster to just use update

	# Annex flat
	#

   $TTY = 50;
   $TTY = state $T_AnnexRoom_GEN if state $T_AnnexRoom_GEN ne "error";
   $TTY =round $TTY ,1;
   $TTY1 = state $T_ANNEX_uFloor_Return if state $T_ANNEX_uFloor_Return ne "error";
   $TTY = $TTY .":". round $TTY1 ,1;
   #  run "RRDtool update $RRD N:$TTY";     # faster to just use update

	# To from House

   $TTY = state $T_GASBoilerOWT if state $T_GASBoilerOWT ne "error";
   $TTY =round $TTY ,1;
   $TTY1 =state $T_House_cold_return_GEN if state $T_House_cold_return_GEN ne "error";
   $TTY1 =round $TTY1 ,1;
   #  run "RRDtool update $RRD N:$TTY:$TTY1";     # faster to just use update leaves rrdtool for graphing

	# PUMPS and Boilers
	#

   $TTY = state $T_GSHP_OWT_GEN if state $T_GSHP_OWT_GEN ne "error";
   $TTY =round $TTY ,1;
   $TTY1 = state $T_OilBoiler_OWT_GEN if state $T_OilBoiler_OWT_GEN ne "error";
   $TTY = $TTY .":". round $TTY1 ,1;
   #  run "RRDtool update  $RRD N:$TTY";     # faster to just use update leaves rrdtool for graphing
        
    # house temps
   # $T_LivingR $T_Study  $T_Kitchen   $T_Utility  $T_Bed1  $T_Bed2  $T_Bed3  $T_EnSuite  $T_MainBath 


   $TTY = state $T_avg_House if state $T_avg_House ne "error";
   $TTY =round $TTY ,1;
   #  run "RRDtool update  $RRD N:$TTY";     # faster to just use update leaves rrdtool for graphing



	# PUMPS and Boilers on /off
	#
	# records on/off states of pumps and boiler
	#  80 = off
	#  on states
	#  78 = GSHP
	#  76 = Oil boiler
	#  74 = House Underfloor pump
	#  72 = House rads pump
	#  70 = House DHW pump
	#  68 annex heating pump
	#
	#  this is so they show at the top of the graph as on or off
	#
	#
   $RRD = $config_parms{RRD_bd_dir}.'temperature\PUMPSnBOILERS_Onoff.rrd';


   if (state $Status_GSHP eq 'on'){
	   $TTY= 78
   }else{
	   $TTY= 80
   }

   if (state $Status_Oil_Boiler eq 'on'){
	   $TTY1= 76
   }else{
	   $TTY1= 80
   }

   $TTY = $TTY.":".$TTY1;

   if (state $HV_uFloor_pump eq 'on'){
	   $TTY1= 74
   }else{
	   $TTY1= 80
   }

   $TTY = $TTY.":".$TTY1;

   if (state $HV_Rads_pump eq 'on'){
	   $TTY1= 72
   }else{
	   $TTY1= 80
   }

   $TTY = $TTY.":".$TTY1;

   if (state $HV_DHW_pump eq 'on'){
	   $TTY1= 70
   }else{
	   $TTY1= 80
   }

   $TTY = $TTY.":".$TTY1;

   if (state $Annex_Heating eq 'on'){
	   $TTY1= 68
   }else{
	   $TTY1= 80
   }
  $TTY = $TTY.":".$TTY1;

  # run "RRDtool update $RRD N:$TTY";     # faster to just use update leaves rrdtool for graphing


  


}







$V_PlotTest = new Voice_Cmd("make graph");
if (said $V_PlotTest){
&plot_rrd
}



if ($New_Minute and new_minute 6){
#&plot_rrd

}

my ($RRD,$TTY,$TTY1,$Title_graph);
my ($targetdir,$curtime,$lastday,$RRDgraph,$plot_def1,$plot_def2,$plot_def3,$plot_def4,$plot_def5,$plot_def6,$plot_def7,$plot_def8,$plot_def9,$plot_def10,$plot_def11,$plot_def12,$plot_def13,$plot_def14,$plot_def15,$plot_def16,$Line1,$Line2,$Line3,$Line4,$Line5,$Line6,$Line7,$Line8,$Line9,$Line10,$Line11,$Line12,$Line13,$Line14,$Line15,$Line16,$comment,$CDEF_1,$CDEF_KWh,$VDEF_KwH_MAX,$VDEF_KwH_MIN,$VDEF_KwH_AVG);


my ($GR_Comment,$GR_Comment2,$GR_Comment3,$GR_Comment4,$GR_Comment5,$GR_Comment6,$GR_Comment7);
my ($VDEF_1,$VDEF_2,$VDEF_3,$VDEF_4,$VDEF_5,$VDEF_6,$VDEF_7,$VDEF_8,$VDEF_9,$VDEF_10,$VDEF_11,$VDEF_12,$VDEF_13,$VDEF_14,$VDEF_15,$VDEF_16,$VDEF_17,$VDEF_18);

# not used , just left in to show how to make basic graph
sub plot_rrd {
	

	use Time::Local;
	use Date::Parse;

         # last 24 Hours
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyDay.png";
	 $curtime=time;
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heat Supply last 24 Hours : Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;

	          # day -1
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyDay1.png";
	 $curtime=(time - ($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heat Supply One day ago :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;

	          # day -2
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyDay2.png";
	 $curtime=(time - (24*60*60)-($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heat Supply 2 days ago :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;

	          # day -3
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyDay3.png";
	 $curtime=(time - (24*60*60*2)-($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heat Supply 3 days ago :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;

	          # day -4
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyDay4.png";
	 $curtime=(time- (24*60*60*3)-($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heat Supply 4 days ago :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;

	          # day -5
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyDay5.png";
	 $curtime=(time - (24*60*60*4)-($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heat Supply 5 days ago :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;

	          # day -6
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyDay6.png";
	 $curtime=(time - (24*60*60*5)-($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heat Supply 6 days ago :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;








	 # this week
         $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyweek.png";
	 $curtime=(time +((6-$Wday)*60*60*24)+ ($Hour*60*60)+($Minute*60)+$Second);
	 $lastday = ($curtime - (24*60*60*7));
         $Title_graph="Heat Supply this week :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;
	 # week -1
         $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyweek1.png";
	 $curtime=time;
	 $curtime=($curtime - (($Wday - 1) *60*60*24)-($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60*7));
         $Title_graph="Heat Supply last week :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;




	 	 # this
         $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyMonth.png";
	 $curtime=(time +((30-$Mday)*60*60*24)+ ($Hour*60*60)+($Minute*60)+$Second);
	 $lastday = ($curtime - (24*60*60*31));
         $Title_graph="Heat Supply this month  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;
	 	 	 # month -1
         $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyMonth1.png";
	 $curtime=time;
	 $curtime=($curtime - (($Mday - 1) *60*60*24)-($Hour*60*60)-($Minute*60)-$Second);
	 $lastday = ($curtime - (24*60*60*31));
         $Title_graph="Heat Supply last month :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;

	 	 # Last Year
         $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyYear.png";
	 $curtime=time;
	 $lastday = ($curtime - (24*60*60*365));
         $Title_graph="Heat Supply last Year :  Graph generated : ".$Date_Now." ".$Time_Now;
	 &Temperature_graph;


         # Energy store
	 $targetdir = "../../MyMh/web/ia5/rrd_graphs/Temperature/heatSupplyEnergyStore.png";
	 $curtime=time;
	 $lastday = ($curtime - (24*60*60));
         $Title_graph="Heatstore : energy in storage : Graph generated : ".$Date_Now." ".$Time_Now;
	 &Heat_Store_graph;






  }





sub Temperature_graph {
         $RRDgraph = $targetdir . " -s $lastday -e $curtime -a PNG -E -u 78 -r -t \"$Title_graph\" -n TITLE:13: -W ".' "BETCHTON MANOR" -c BACK#00A00030 -c SHADEA#C0C0C0 -c SHADEB#303030 -w 800 -h 400  -v "Deg C" ';
           
	 $plot_def1 = "DEF:HS_Upper="."$config_parms{RRD_bd_dir}Temperature\\HeatStore.rrd:HeatStore_Upper:LAST ";
	 $plot_def2 = "DEF:HS_Lower="."$config_parms{RRD_bd_dir}Temperature\\HeatStore.rrd:HeatStore_Lower:LAST ";
	 $plot_def3 = "DEF:GSHP_OWT="."$config_parms{RRD_bd_dir}Temperature\\GSHP_n_OilBoiler.rrd:GSHP_OWT:LAST ";
	 $plot_def4 = "DEF:OilBoiler_OWT="."$config_parms{RRD_bd_dir}Temperature\\GSHP_n_OilBoiler.rrd:OilBoilerOWT:LAST ";
	 $plot_def5 = "DEF:GSHP_OnOff="."$config_parms{RRD_bd_dir}Temperature\\PUMPSnBOILERS_Onoff.rrd:GSHP_OnOff:LAST ";
         $plot_def6 = "DEF:OilBoiler_OnOff="."$config_parms{RRD_bd_dir}Temperature\\PUMPSnBOILERS_Onoff.rrd:OilBoiler_OnOff:LAST ";
	 $plot_def7 = "DEF:Ufloor_OnOff="."$config_parms{RRD_bd_dir}Temperature\\PUMPSnBOILERS_Onoff.rrd:Ufloor_OnOff:LAST ";
	 $plot_def8 = "DEF:RADS_OnOff="."$config_parms{RRD_bd_dir}Temperature\\PUMPSnBOILERS_Onoff.rrd:RADS_OnOff:LAST ";
	 $plot_def9 = "DEF:Hose_DHW_OnOff="."$config_parms{RRD_bd_dir}Temperature\\PUMPSnBOILERS_Onoff.rrd:Hose_DHW_OnOff:LAST ";
	 $plot_def10 = "DEF:ANNEX_OnOff="."$config_parms{RRD_bd_dir}Temperature\\PUMPSnBOILERS_Onoff.rrd:ANNEX_OnOff:LAST ";
	 $plot_def11 = "DEF:Outside="."$config_parms{RRD_bd_dir}Temperature\\Outside.rrd:temp:AVERAGE ";
	 $plot_def12 = "DEF:RTN_fromHouse="."$config_parms{RRD_bd_dir}Temperature\\To_from_House.rrd:cold_from_house:AVERAGE ";
	 $plot_def13 = "DEF:Annex="."$config_parms{RRD_bd_dir}Temperature\\AnnexFlat.rrd:temp:AVERAGE ";
	 $plot_def14 = "DEF:HouseAVG="."$config_parms{RRD_bd_dir}Temperature\\HouseAVG.rrd:temp:AVERAGE ";
	 $plot_def15 = "DEF:AnnexRTN="."$config_parms{RRD_bd_dir}Temperature\\AnnexFlat.rrd:tRETURN:AVERAGE ";
	 $plot_def16 = "DEF:ElectricUse="."$config_parms{RRD_bd_dir}ElectricUse\\Electric.rrd:Watts:AVERAGE ";
	 $VDEF_1 = " VDEF:OutsideMax=Outside,MAXIMUM";
         $VDEF_2 = " VDEF:OutsideMin=Outside,MINIMUM";
	 $VDEF_3 = " VDEF:OutsideAVG=Outside,AVERAGE";
	 $CDEF_KWh =" CDEF:Kwh_adjust=ElectricUse,100,/";
	 $VDEF_KwH_MAX = " VDEF:Kwh_Max=ElectricUse,MAXIMUM";
         $VDEF_KwH_MIN = " VDEF:Kwh_Min=ElectricUse,MINIMUM";
	 $VDEF_KwH_AVG = " VDEF:Kwh_AVG=ElectricUse,AVERAGE";

	 $VDEF_4 = " VDEF:GSHP_OWT_Max=GSHP_OWT,MAXIMUM";
         $VDEF_5 = " VDEF:GSHP_OWT_Min=GSHP_OWT,MINIMUM";
	 $VDEF_6 = " VDEF:GSHP_OWT_AVG=GSHP_OWT,AVERAGE";

	 $VDEF_7 = " VDEF:Oil_Boiler_OWT_Max=OilBoiler_OWT,MAXIMUM";
         $VDEF_8 = " VDEF:Oil_Boiler_OWT_Min=OilBoiler_OWT,MINIMUM";
	 $VDEF_9 = " VDEF:Oil_Boiler_OWT_AVG=OilBoiler_OWT,AVERAGE";

	 $VDEF_10 = " VDEF:HS_UPPER_Max=HS_Upper,MAXIMUM";
         $VDEF_11 = " VDEF:HS_UPPER_Min=HS_Upper,MINIMUM";
	 $VDEF_12 = " VDEF:HS_UPPER_AVG=HS_Upper,AVERAGE";

	 $VDEF_13 = " VDEF:HS_Lower_Max=HS_Lower,MAXIMUM";
         $VDEF_14 = " VDEF:HS_Lower_Min=HS_Lower,MINIMUM";
	 $VDEF_15 = " VDEF:HS_Lower_AVG=HS_Lower,AVERAGE";

	 $VDEF_16 = " VDEF:House_Max=HouseAVG,MAXIMUM";
         $VDEF_17 = " VDEF:House_Min=HouseAVG,MINIMUM";
	 $VDEF_18 = " VDEF:House_AVG=HouseAVG,AVERAGE";


	 $Line1 = ' LINE1:HS_Upper#FF7542:"HeatStore Upper        "';
	 $Line2 = ' LINE1:HS_Lower#FF9700:"          Lower        "';
	 $Line3 = ' LINE1:GSHP_OWT#00FF00:"GSHP       OWT         "';
	 $Line4 = ' LINE1:OilBoiler_OWT#FF00FF:"Oil Boiler OWT         "';
	 $Line5 = ' LINE2:GSHP_OnOff#00FF00:"GSHP On/Off"';
	 $Line6 = ' LINE2:OilBoiler_OnOff#FF00FF:"Oil Boiler On/Off"';
	 $Line7 = ' LINE2:Ufloor_OnOff#FFFF00:"Ufloor On/Off"';
	 $Line8 = ' LINE2:RADS_OnOff#DD0000:"House RADS On/Off"';
	 $Line9 = ' LINE2:Hose_DHW_OnOff#FFB4FF:"House DHW On/Off"';
	 $Line10 =' LINE2:ANNEX_OnOff#0074FF:"ANNEX heating On/Off"\n';
         $Line11 =' LINE1:Outside#000000:"Outside                 "';
	 $Line12 =' LINE1:RTN_fromHouse#CCBCCC:"Return from House "\n';
	 $Line13 =' LINE1:Annex#0074FF:"Annex                     "\n';
	 $Line14 =' LINE1:HouseAVG#FFD000:"House (all rooms avg  )"';
	 $Line15 =' LINE1:AnnexRTN#00FFFF:"ANNEX return           "\n';
	 $Line16 =' LINE1:Kwh_adjust#FF0000:"Electric KwH/100       "';
	 $GR_Comment=' COMMENT:"    " GPRINT:Kwh_Max:"%2.1lf" COMMENT:"    " GPRINT:Kwh_Min:"%2.1lf" COMMENT:"    " GPRINT:Kwh_AVG:"%2.1lf\n"';
	 $GR_Comment2 =' COMMENT:"     " GPRINT:OutsideMax:"%2.1lf" COMMENT:"    " GPRINT:OutsideMin:"%2.1lf" COMMENT:"    " GPRINT:OutsideAVG:"%2.1lf\n" COMMENT:\n';
	 
	 $GR_Comment3 =' COMMENT:"    " GPRINT:GSHP_OWT_Max:"%2.1lf" COMMENT:"    " GPRINT:GSHP_OWT_Min:"%2.1lf" COMMENT:"    " GPRINT:GSHP_OWT_AVG:"%2.1lf\n"';
	 $GR_Comment4 =' COMMENT:"    " GPRINT:Oil_Boiler_OWT_Max:"%2.1lf" COMMENT:"    " GPRINT:Oil_Boiler_OWT_Min:"%2.1lf" COMMENT:"    " GPRINT:Oil_Boiler_OWT_AVG:"%2.1lf\n"';         
	 $GR_Comment5 =' COMMENT:"    " GPRINT:HS_UPPER_Max:"%2.1lf" COMMENT:"    " GPRINT:HS_UPPER_Min:"%2.1lf" COMMENT:"    " GPRINT:HS_UPPER_AVG:"%2.1lf\n"';	
	 $GR_Comment6 =' COMMENT:"    " GPRINT:HS_Lower_Max:"%2.1lf" COMMENT:"    " GPRINT:HS_Lower_Min:"%2.1lf" COMMENT:"    " GPRINT:HS_Lower_AVG:"%2.1lf\n"';
 	 $GR_Comment7 =' COMMENT:"    " GPRINT:House_Max:"%2.1lf" COMMENT:"    " GPRINT:House_Min:"%2.1lf" COMMENT:"    " GPRINT:House_AVG:"%2.1lf\n"';	 
	
	
	# run "RRDtool graph ".$RRDgraph.$plot_def1.$plot_def2.$plot_def3.$plot_def4.$plot_def5.$plot_def6.$plot_def7.$plot_def8.$plot_def9.$plot_def10.$plot_def11.$plot_def12.$plot_def13.$plot_def14.$plot_def15.$plot_def16.$VDEF_1.$VDEF_2.$VDEF_3.$VDEF_4.$VDEF_5.$VDEF_6.$VDEF_7.$VDEF_8.$VDEF_9.$VDEF_10.$VDEF_11.$VDEF_12.$VDEF_13.$VDEF_14.$VDEF_15.$VDEF_16.$VDEF_17.$VDEF_18.$CDEF_KWh.$VDEF_KwH_MAX.$VDEF_KwH_MIN.$VDEF_KwH_AVG.' COMMENT:"CONTROL "\n '.$Line5.$Line6.$Line7.$Line8.$Line9.$Line10.' COMMENT:\n COMMENT:"TEMPERATURES                      MAX         MIN         AVG "\n '.$Line3.$GR_Comment3.$Line4.$GR_Comment4.$Line1.$GR_Comment5.$Line2.$GR_Comment6.$Line14.$GR_Comment7.$Line12.$Line13.$Line15.$Line11.$GR_Comment2.$Line16.$GR_Comment;


	      
}

sub Heat_Store_graph {

         $RRDgraph = $targetdir . " -s $lastday -e $curtime -a PNG -E  -r -t \"$Title_graph\" -n TITLE:13: -W ".' "BETCHTON MANOR" -c BACK#00A00030 -c SHADEA#C0C0C0 -c SHADEB#303030 -w 800 -h 400  -v "Deg C" ';
           
	 $plot_def1 = "DEF:HS_Upper="."$config_parms{RRD_bd_dir}Temperature\\HeatStore.rrd:HeatStore_Upper:LAST ";
	 $plot_def2 = "DEF:HS_Lower="."$config_parms{RRD_bd_dir}Temperature\\HeatStore.rrd:HeatStore_Lower:LAST ";

	 $CDEF_1 = " CDEF:EnergyStored=HS_Upper,HS_Lower,2,HS_Lower,4.2,200,0.000277,-,/,+,*,*,*";
	 $VDEF_1 = " VDEF:EnergyMax=EnergyStored,MAXIMUM";
         $VDEF_2 = " VDEF:EnergyMin=EnergyStored,MINIMUM";
	 $Line1 = ' LINE2:HS_Upper#FF0000:"heatStore Upper"';
	 $Line2 = ' LINE2:HS_Lower#0000FF:"heatStore Lower"';
	 $Line3 = ' AREA:EnergyStored#00FF0010:""';
	 $Line4 = ' LINE2:EnergyStored#00FF00:"Energy Store kW-h "';

	 #         run "RRDtool graph ".$RRDgraph.$plot_def1.$plot_def2.$CDEF_1.$VDEF_1.$VDEF_2.$Line1.$Line2.$Line3.$Line4.' COMMENT:"  max " GPRINT:EnergyMax:"%2.1lf" COMMENT:"  min " GPRINT:EnergyMin:"%2.1lf"';



  }
=cut