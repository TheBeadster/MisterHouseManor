# category = HVAC
#
#@ Cintrol of extractor fan in roof
#@ 
$CodeTimings::CodeTimings{'Extractor_fan Start'} = time();
my $Fan_states = 'on,off';

$Extractor_Fan1 = new X10_Item('B1','homevision');

#$Extractor_Fan = new Generic_Item;
set_states $Extractor_Fan split ',',$Fan_states;     # light states are on/off
$V_Extractor_Fan = new Voice_Cmd("turn Extractor fan [$Fan_states]");
$Extractor_Fan ->tie_items($Extractor_Fan1);
$V_Extractor_Fan ->tie_items($Extractor_Fan);


# now for timed on off

if (time_now "9:00 AM" ){set $Extractor_Fan 'on'};

if (time_now "10:00 PM" ){set $Extractor_Fan 'off'};


if (time_now "9:00 PM" ){set $Extractor_Fan 'on'};

if (time_now "10:00 PM" ){set $Extractor_Fan 'off'};

$CodeTimings::CodeTimings{'Extractor_fan End'} = time();