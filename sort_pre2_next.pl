use strict;
use warnings;

open FILEIN, "<pl3.txt"; 

my %midpos; 
my $NBestN=20; 

while(<FILEIN>)
{
    /(\d+)-(\d+)-(\d+)-(\d+)\t\t(\d+)\n/;
    my $pre1 = $1;
    my $pre2 = $2;
    my $next1 = $3; 
    my $next2 = $4; 
    my $count = $5; 
    #dcode# 
    print STDERR "$pre1 - $pre2 - $next1 - $next2 : $count\n"; 

    my $key = "$pre1-$pre2"; 
    if (!exists $midpos{$key})
    {
	$midpos{$key} = {}; 
    }

    my $href = $midpos{$key};
    my $p = "$pre1-$pre2-$next1-$next2"; 
    $href->{$p} = $count; 
}
close FILEIN; 

# okay. Time to report. 
for (my $k=0; $k <128; $k++) 
{
    for (my $i=0; $i < 128; $i++)
    {
	next if ($k == $i); 
	my $href = $midpos{"$k-$i"}; 
	my %bests = take_only_best($href);
	my @best_keys = sort {$bests{$b} <=> $bests{$a}} keys %bests; 
	for(my $j=0; $j < scalar(keys %bests); $j++)
	{
	    print " ", $best_keys[$j], "\t", $bests{$best_keys[$j]}, "\n"; 
	}
    }
}

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
