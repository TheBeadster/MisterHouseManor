

#  used to try and work out which code is stalling misterhouse

# the hash   %CodeTimings     holds the code timing
#   like this
#   Gate_control start, 123121212
#   Gate_control end,  2323233

# the difference is the time it takes to execute
# we print it if the time exceed a few Ms


#my %CodeTimings ;  delcare in Codetiming in MH/lib/codetiming.pm module
#                         so that the variable is avable globally to all modules



my ($TimeStart,$TimeEnd,$CodeName,$TimeEndName,$CodeTimeDiff);
foreach my $key (keys %CodeTimings::CodeTimings){
       
    # do stuff
    if ($key =~ /(\w+) Start/ ){
      
      $TimeStart = $CodeTimings::CodeTimings{$key};
      $TimeEndName = $1." End";
      $TimeEnd = $CodeTimings::CodeTimings{$TimeEndName};
      $CodeTimeDiff = $TimeEnd-$TimeStart;
      if ($CodeTimeDiff > 1) {
            print "Code delay for $1 of $CodeTimeDiff\r\n";
            logit($config_parms{data_dir}."/Code_Delay_log.$Year_Month_Now.log","Code delay for $1 of $CodeTimeDiff");
          # now set the start as the same as the end otherwise the log file gets repat entries.
          $CodeTimings::CodeTimings{$key} = $CodeTimings::CodeTimings{$TimeEndName};
      }
     


    }
 
}


