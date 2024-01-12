# Category=Gate

$CodeTimings::CodeTimings{'Field_logs Start'} = time();
# this is a reworked copy of phone_logs.pl
                                # Show Field logs via a popup or web page
$v_field_log  = new  Voice_Cmd 'Display recent gate activity';
$v_field_log -> set_info('Show recent gate use.');

my $field_dir = "$config_parms{key_dir}";
if ($state = said $v_field_log) {
    display text =>  &field_log('in', 999, 'text'), font => 'fixed'; #if $state eq 'incoming' or $state eq ' ';
   
}

                                # This function returns field logs to menus
sub field_log {
    my ($log, $count, $format) = @_;
    $count = 9 unless $count;
    $log = 'fieldlog' if $log eq 'in';
    $log = 'use for other type of log'    if $log eq 'out';
    my @members = &read_field_logs1($log);
    my @calls   = &read_field_logs2($count, @members);
    $format = $Menus{response_format} unless $format;
	print_log" $format $log log @calls";
    return &menu_format_list($format, "$log log", @calls);
}

                                # This function will read the members in the phone log dir
sub read_field_logs1 { 

    my ($file_qual) = @_;
                               # Read directory for list of detailed field logs ... default to the lastest one. 
    opendir(DIR, "$field_dir/logs") or die "Could not open directory $field_dir/logs: $!\n"; 
    my @members  = readdir(DIR); 
    # Default to just the latest 2 members 
    @members = reverse sort grep(/$file_qual.*\.log$/, @members);
    return ($members[0], $members[1]) ; 
}

                                # This function will read in or out field logs and return
                                # a list array of all the calls.
my %custid_by_number;

sub read_field_logs2 { 
    my ($count1, @files) = @_;
                                # Sort by date, so most recent file is first
    my (@calls,@a);
    my $count2 = 1;
    my($time_date, $keyID, $cust_number, $name);
    my($day, $date, $time);
    print "Reading @files\n";
    for my $log_file (@files) { 
#       print "db lf=$log_file\n";
        $log_file = "$field_dir/logs/$log_file";
        open(DAT1,$log_file) or print_log "Error, could not open file $log_file: \n"; 
	    binmode DAT1;       # In case bad (binary) data is logged 
        @a = reverse <DAT1>;
        while ($_ = shift @a) { 
            tr/\x20-\x7e//cd; # Translate bad characters or else TK will mess up 

              #print "$_\n";
            if ($log_file=~/fieldlog/){
            
                if ($_=~ /(.{21}) (\w+)  (\w+) (.+)/){ 
                    $time_date = $1;
                    $keyID = $2;
                    $cust_number = $3;
                    $name = $4;
                   # print "=+++++++++++++++++++++ ".$time_date." ". $cust_number." ". $name."\n";
                    $cust_number="Family" if $cust_number == 0;
                }
                #report app use
                # and rpeort ANPR hits
        
 

                elsif ($_=~ /(.{21}) ANPR -> (.+)/){ 
                    $time_date=$1;
                    $keyID="1";
                    $cust_number="ANPR";
                    $name = $2
                }

                # webapp
                elsif ($_=~ /(.{21}) WebApp opened by (.+)/){ 
                    $time_date=$1;
                    $keyID="1";
                    $cust_number="WEB_app";
                    $name = $2
                }else{

                    $keyID="";   # creates a ignore anything else
                }



            }	
            next unless $keyID;

           ($day, $date, $time) = split ' ', $time_date;
            $time = time_to_ampm $time;
            if ($count1 < 10) {
                push @calls, sprintf("%s %s\n %s\n %s",  $day, $time, $cust_number, $name);
            }
            else {
                push @calls, sprintf("%20s %-12s %s",  $time_date, $cust_number, $name);
                # print "------------- ".$time_date." ". $cust_number." ". $name."\n";
            }
            last if ++$count2 > $count1;
        }# end of while 
    }


    for my $temp_print(@calls){
       # print $temp_print."\n";
    }

    print "Read ", scalar @calls, " calls\n";
    return @calls;
}
$CodeTimings::CodeTimings{'Field_logs End'} = time();