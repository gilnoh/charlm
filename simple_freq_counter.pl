# a simple frequency counter for english chars. 
# (corpus in from STDIN, char-seqeunce\tfrequncy lines out to STDOUT) 
# Note that, each line of STDIN is expected to be a "sentence". 
# gets one argument (length of char-n-gram) 

# how much unique entries per-len? 
# (* 26 26 26)  ;;  17576 
# (* 26 26 26 26) ;; 456976
# (* 26 26 26 26 26) ;; 11881376 --- this is the target for now. 
# (* 26 26 26 26 26 26) ;; 308915776 --- a bit too big for my aire mem? 

use warnings; 
use strict; 

my $CHARLEN = 3; 
my %table; 

if ($ARGV[0])
{
    $CHARLEN = $ARGV[0]; 
}

my $linecount = 0; 
while(<STDIN>)
{
    # remove anything not english char ... 
    my $line = $_; 
    $line =~ s/[^a-zA-Z]//g; 
    next if (length $line == 0); 

    # add "start - end" symbol 
    $line = '^' . $line . '$'; 
    #dcode# print $line; 
    
    # now count every possible sequence with $CHARLEN patterns. 
    for(my $i=0; $i <= (length $line) - $CHARLEN; $i++)
    {
	my $x = substr($line, $i, $CHARLEN);
	#dcode# print $x, "\t"; 

	$table{$x}++; # well, non-existing ones are treated as zero already. 
    }
    $linecount++; 
    print STDERR "." if ($linecount % 10000 == 0); 
}

foreach my $key (sort keys %table)
{
    print "$key,$table{$key},\n"; 
}
