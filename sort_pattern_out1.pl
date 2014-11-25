use warnings;
use strict; 

# read STDIN (where each line is [pattern-string]\t\t[countnum])
# and output sorted result. ... (all in mem?) 

unless ($ARGV[0])
{
    die "requires one file name (output)"; 
}

#my %final_bestpat; 
my $NBestN = 20; 
sub take_only_best; 

for(my $i=0; $i < 128; $i++)
{
    my $target = "$i-"; 
    open FILEIN, "<", $ARGV[0];     
    print STDERR "look for best that start with \"$target\"\n"; 
    my %temp_pat; 
    while(my $line = <FILEIN>)
    {
        next unless $line =~ /^$target/; 
        $line =~ /^(.+)\t\t(.+)\n/; 
        $temp_pat{$1} = $2; 
    }
    close FILEIN; 
    my %bests = take_only_best(\%temp_pat); 
    
    my @best_keys = sort {$bests{$b} <=> $bests{$a}} keys %bests; 

    for(my $i=0; $i < scalar(keys %bests); $i++)
    {
        print " ", $best_keys[$i], "\t", $bests{$best_keys[$i]}, "\n"; 
    }

}


# look nbest, pick top n (say, 2000) 
# return them as a new hash. 
sub take_only_best
{
    my %nbests = %{$_[0]}; 

    my %result; 
    my @keys = keys %nbests; 
    my @sorted_keys = sort {$nbests{$b} <=> $nbests{$a}} @keys; 
    
    # copy only first NBestN
    for (my $i=0; ($i < $NBestN) and ($i < @sorted_keys); $i++)
    {
	my $k = $sorted_keys[$i]; 
	$result{$k} = $nbests{$k}; 
    }
#    print STDERR "size: ", scalar(%result), "\n"; 
    return %result; 
}



