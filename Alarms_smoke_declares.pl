# category=Alarms



my $Smoke_Control_States="active,idle,less_Kitchen";
my $Smoke_States ="yes,no";
my $Smoke_States2="ok,fault";
my $Smoke_States4="ok,alarm";

# Generic items declarations
# first notification methods
#

$Notify_method_Internal = new Generic_Item;
set_states $Notify_method_Internal split ',',$System_States;
set_info $Notify_method_Internal 'Notify all in house through the speakers';
set $Notify_method_Internal 'yes';

$Notify_Method_SMS = new Generic_Item;
set_states $Notify_Method_SMS split ',',$System_States;
set_info $Notify_Method_SMS 'notify of Alarms by SMS to the people in the Burglar list or Smoke list';
#set $Notify_Method_SMS 'no';


$Smoke_Group = new Generic_Item; 
set_states $Smoke_Group split ',',$Smoke_Control_States;
set $Smoke_Group "active";


$LastTestingSmoke=new Generic_Item;
set_states $LastTestingSmoke split ',',$Smoke_States2;



my $TTime = '13000';'18144000';
$TTime = time - $TTime;

$Smoke_ToolShed_Alarm = new Generic_Item;
set_states $Smoke_ToolShed_Alarm split ',',$Smoke_States4;
$Smoke_ToolShed_Alarm_LastTest = new Generic_Item;
#set $Smoke_ToolShed_Alarm_LastTest time if state $Smoke_ToolShed_Alarm_LastTest eq "";
set $Smoke_ToolShed_Alarm_LastTest $TTime if $New_Day;   # temp to show needed fixing  



$Smoke_Stables_Alarm = new Generic_Item;
set_states $Smoke_Stables_Alarm split ',',$Smoke_States4;
$Smoke_Stables_Alarm_LastTest = new Generic_Item;

$Smoke_Stables_Alarm-> tie_event('&Notify_Smoke_Stables_Alarm("$state")');

set $Smoke_Stables_Alarm_LastTest time if state $Smoke_Stables_Alarm_LastTest eq "alarm";
#set $Smoke_Stables_Alarm_LastTest $TTime if $New_Day;    # temp to show its needs fixing


$Smoke_Lroom_Alarm = new Generic_Item;
set_states $Smoke_Lroom_Alarm split ',',$Smoke_States4;




$Smoke_Kitchen_Alarm = new Generic_Item;
set_states $Smoke_Kitchen_Alarm split ',',$Smoke_States4;
# this is set by HV in homevisionInterface.pl
$Smoke_Kitchen_Alarm-> tie_event('&Notify_Smoke_Kitchen_Alarm("$state")');
$Smoke_Kitchen_Alarm_LastTest = new Generic_Item;

set $Smoke_Kitchen_Alarm_LastTest time if state $Smoke_Kitchen_Alarm_LastTest eq "";



$Smoke_Workshop_Annex = new Generic_Item;

set_states $Smoke_Workshop_Annex split ',',$Smoke_States4;
set_info $Smoke_Workshop_Annex 'Current state workshop / Office / annex flat Smoke detectors';
$Smoke_Workshop_Annex-> tie_event('&Notify_Smoke_Workshop_Annex("$state")');
$Smoke_Workshop_Annex_LastTest = new Generic_Item;
set $Smoke_Workshop_Annex_LastTest time if state $Smoke_Workshop_Annex_LastTest eq "";

