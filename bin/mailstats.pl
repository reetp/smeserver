#!/usr/bin/perl
# use strict;
#
# The script analyzes a log-file from qpsmtpd. Run it like
# $ sudo test.pl < /var/log/qpsmtpd/current
#
# Sample, standard deny-line from qpsmtpd/current:
#
# @4000000057e971280f9518fc 7923 logging::logterse plugin (deny): ` 192.241.146.6 mta-wk-2.mk1.enchantitect.com   mta-wk-2.mk1.enchantitect.com   <c736fb27-sio-2IEpgeKf9g1V1Z0D@mk1.enchantitect.com>     rhsbl   901     Blocked, enchantitect.com on lists [abuse], See: http://www.surbl.org/lists.html        msg denied before queued

# SMEOptimizer works by forcing a high spam score:
#
# @40000000582033e43560c98c 28003 smeoptimizer plugin (deny): SMEOptimizer SA hit: BAYES_00,DIGEST_MULTIPLE,HTML_MESSAGE,PYZOR_CHECK,RAZOR2_CF_RANGE_51_100,RAZOR2_CF_RANGE_E8_51_100,RAZOR2_CHECK,RCVD_IN_DNSWL_NONE,SMEOPTI_URI_SPAM,SPF_HELO_PASS,SPF_PASS
# @40000000582033e43560d92c 28003 logging::logterse plugin (deny): ` 46.21.172.157	vserver3.axc.nl	ashwinbihari.nl	<freja_olsen@ashwinbihari.nl>	<bg@skibsgaarden.dk>	spamassassin	901	spam score exceeded threshold (#5.6.1)	Yes, hits=13.1 required=3.0_
#
# @4000000058207d3c2be3f834 8548 smeoptimizer plugin (queue): SMEOptimizer SA hit: BAYES_00,DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_FONT_LOW_CONTRAST,HTML_MESSAGE,MIME_HTML_MOSTLY,MPART_ALT_DIFF,RCVD_IN_DNSWL_NONE,RCVD_IN_IADB_DK,RCVD_IN_IADB_LISTED,RCVD_IN_IADB_RDNS,RCVD_IN_IADB_SENDERID,RCVD_IN_IADB_SPF,RCVD_IN_IADB_VOUCHED,RP_MATCHES_RCVD,SMEOPTI_URI_SPAM,SPF_PASS
# @4000000058207d3c2be40fa4 8548 logging::logterse plugin (queue): ` 91.235.232.1	smtp2-1.mailmailmail.net	smtp2-1.mailmailmail.net	<return-b6984-b202471-helge.petersen=skibsgaarden.dk@mailmailmail.net>	<helge.petersen@skibsgaarden.dk>	queued		<72249250c81f557c67e6e65e6472b009@client2.mailmailmail.net>	Yes, hits=4.6 required=3.0_
       
use warnings;

my @denial = (
  [0, "SMEOptimizer", qr/SMEOptimizer SA hit/],   # Smeopti must be the first
  [0, "Failed Authentication",   qr/auth_cvm/],
  [0, "Relaying Denied",  qr/relaying/],
  [0, "Greylisting", qr/greylisting/],
  [0, "Naughty (DNSBL)", qr/naughty.*dnsbl/],
  [0, "Naughty", qr/naughty/],
  [0, "DNSBL",  qr/\sdnsbl\s/],
  [0, "RHSBL",  qr/\srhsbl\s/],
  [0, "URIBL",  qr/\suribl\s/],
  [0, "Resolvable FromHost", qr/resolvable_fromhost/],
  [0, "Invalid Host",   qr/believe that you are/],
  [0, "Spamassassin",   qr/exceeded threshold/],
  [0, "Virus",  qr/virus::clam/],
  [0, "Early Talker",  qr/earlytalk/],
  [0, "TLS/SSL Problem", qr/Negotiation Failed|Cannot establish SSL session/],
  [0, "Unrecognized Commands", qr/\scount_unrecognized_commands\s/],
  [0, "HELO/EHLO rfc",  qr/\shelo\s/],
  [0, "Server Overloaded", qr/\sloadcheck\s/]
);

my %bl;    # Hash - key is the blacklist name, value is the count
my $queued = 0; my $unknown = ""; my $spam = 0;
my ($line, $denied, $check, $smeoptimizer_plugin);

sub count_black_lists  {
  my $list = shift @_;
  $list =~ s!.*https?://!!;  # The blacklist's name is taken from the URL returned to the sender
  $list =~ s!/.*!!;
  $list =~ s!\w+\.(\w+)\..*!$1!;
 
  $bl{$list} ||= +0;
  $bl{$list}++;
}
 

Check: while ($line = <>) {
  chomp $line;

  if ($line =~ /smeoptimizer plugin/) {
    $smeoptimizer_plugin = 1;   # Remember this and read the next line
    $line = <>;
    chomp $line
  } else {
    $smeoptimizer_plugin = 0
  }
 
  $queued++ if ($line =~ /\(queue\)/);
  if ($line =~ /\(deny\)/) {
    $denied++;
    $ip = (split "`", $line)[1];
    $ip =~ s/^\s+//;
    $ip =~ s/\s.*//;
   
    unless ($ip =~ /\d/) {
      print "Line = $line\nIP = $ip\n";
      die
    }
    $attempts{$ip} ||= 0;
    $attempts{$ip}++;

    if ($smeoptimizer_plugin) {
      $check = $denial[0];
      $check->[0]++;
      next Check
    } else {
      foreach $check (@denial) {
        if ($line =~ $check->[2]) {
          $check->[0]++;
          if ($check->[1] =~ /BL/) {
            count_black_lists($line)
          }
          next Check
        }
      }
    }
    $line =~ s/.*`//;
    $unknown .= "  $line\n"  # Unidentified reason for deny
  } elsif ($line =~ /\(queue\)/) {
    if ($line =~ 'Yes, ') {
      $spam++     # Queued but marked as spam
    }
  }
   
}
print "\n\n";
printf "%-12s%5d",   "Queued:", $queued;
print " ($spam marked as spam)\n";
printf "%-12s%5d\n", "Denied:", $denied;

# foreach $check (@denial) {
foreach $check (sort { $b->[0] <=> $a->[0]}  @denial) {
  printf "  %-25s%5d (%2d %%)\n",  $check->[1].":", $check->[0], int(0.5 + $check->[0] / $denied * 100)
}

$bl_total = 0;
foreach $list (keys %bl) {
  $bl_total += $bl{$list}
}

print "\nBlacklists:\n";
foreach $list (sort {$bl{$b} <=> $bl{$a}} keys %bl) {
  printf "  %-18s%5d (%2d %%)\n", ucfirst($list).":", $bl{$list}, int(0.5 + $bl{$list} / $bl_total * 100)
}

print "\nMost active IP addresses:\n";
$n = 1;
foreach $ip (sort { $attempts{$b} <=> $attempts{$a} } keys %attempts) {
#  @bytes = split (/\./, $ip);
  printf "  %3d\.%3d\.%3d\.%3d", split(/\./, $ip);
  printf ": %5d\n", $attempts{$ip};
  $n++;
  last if ($n > 10)
}

print "\n\nUnknown reason for deny:\n", $unknown;

