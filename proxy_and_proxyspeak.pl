# Category = Proxy
#@ sets up oproxie misterhouses, on is in the annex to speak in flat, the other is in kitchen to control the led lights
#@ Sends speak text and play wav files to proxy clients


$CodeTimings::CodeTimings{'proxy_and_proxyspeak Start'} = time();


=begin comment

Use this code to speak to distributed mh clients.  
Run mh_proxy on each target computer, enabling the voice_text parm.
Also use parms like these on your main mh box to enable the ports:
 
  speak_study_port  = proxy 192.168.0.4:8085
  speak_piano_port  = proxy 192.168.0.85:8085
  speak_art_port    = proxy 192.168.0.100:8085

See 'Use distributed MisterHouse proxies' in mh/docs/mh.*  for more info.


main misterhouse uses the proxy module to send data to other remote proxy mh
the kitchen proxy has an arduino on the serial port
any serial data sent using the'play' command is relayed to the arduino





=cut

# led kitchen proxy light control is done in light_kitchen.pl




# Log hook is not muted like speak hook is
&Speak_pre_add_hook( \&proxy_speak_play, 0, 'speak' ) if $Reload;


#&Log_Hooks_add_hook(\&proxy_speak_play, 0, 'speak') if $Reload;

&Play_pre_add_hook( \&proxy_speak_play, 0, 'play' ) if $Reload;

my %proxy_by_room = (annex => '192.168.1.28:8085' ,
                       kitchen => '192.168.1.24:8085',
                       office => '192.168.1.4:8085');



$test_voice_proxy = new Voice_Cmd 'Test proxy speak to [all,annex,kitchen,office]';
$test_voice_proxy->tie_event('speak "rooms=kitchen we are the borg,, you will be assimilated,, resistance is few tile"');#$state we are the borg,, you will be assimilated,, resistance is few tile"');
 #speak "rooms=all The time is $Time_Now" if new_second 15;




sub proxy_speak_play {
    my ($mode)  = pop @_;
    my (%parms) = @_;

    #return unless $Run_Members{speak_proxy};   # bd dont know what this does, were is the hask key speak_proxy coming from, and the has %run_Members
    
    return unless $parms{text} or $parms{file};
    return if $parms{card};

    print ",,,          --------------- proxy_play mode=$mode parms: @_\n" if $Debug{'proxy'};

    # Drop extra blanks and newlines
    $parms{text} =~ s/[\n\r ]+/ /gm;

    my @rooms = split ',', lc $parms{rooms};


    push @rooms, 'annex';    # Announce all stuff to the the Annex
    
    @rooms = sort keys %proxy_by_room if lc $parms{rooms} eq 'all';
    for my $room (@rooms) {
        next unless my $address = $proxy_by_room{$room};
        print "Sending speech to proxy room=$room address=$address\n"
          if $Debug{'proxy'};

        # Filter out the blank parms
        %parms = map { $_, $parms{$_} } grep $parms{$_} =~ /\S+/, keys %parms;
        undef $parms{room};
        $parms{nolog} = 1;

        # Allow for room by extra sound card or by proxy
        if ( $address =~ /card=(\S+)/ ) {
            return if $mode eq 'play';    # Can not play to specific card yet
            $parms{card} = $1;

            #           print "card=$1 speaking to room=$room t= $parms{text}\n";
            $Respond_Target = 'none';     # So common/speak_chime does not chime
            speak %parms;
        }
        else {
            &main::proxy_send( $address, $mode, %parms );
        }
    }
}

# The following loads up a remote proxy system to allow it to receive speech.

$proxy_register = new Socket_Item( undef, undef, 'server_proxy_register' );

if ( my $datapart = said $proxy_register) {
    my ( $pass, $ws, $port ) = split /,/, $datapart;
    my $client = $Socket_Ports{'server_proxy_register'}{client_ip_address};
    if ( my $user = password_check $pass, 'server_proxy_register' ) {
        print_log "Proxy accepted for:  $ws at $client";
        $proxy_by_room{$ws} = $client . ":$port";
        &add_proxy( $client . ":$port" );
    }
    else {
        print_log "Proxy denied for:  $ws at $client";
    }
    stop $proxy_register;
}
if ($New_Minute ) {   #and $Debug{'proxy'}) {
  for my $address (keys %proxy_servers) {
    if ($proxy_servers{$address}->active) {
      print_log "proxy_server: $address alive";
    }
    else {
      print_log "proxy_server: $address dead";
    }
  }
}

$CodeTimings::CodeTimings{'proxy_and_proxyspeak End'} = time();