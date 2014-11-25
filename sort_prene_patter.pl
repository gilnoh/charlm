use strict;
use warnings;

open FILEIN, "<pl3.txt"; 

my %midpos; 
my $NBestN=50; 

while(<FILEIN>)
{
    /(\d+)-(\d+)-(\d+)\t\t(\d+)\n/;
    my $pre = $1;
    my $this = $2;
    my $ne = $3; 
    my $count = $4; 

    #dcode# print STDERR "$pre - $this - $ne : $count\n"; 
    if (!exists $midpos{$this})
    {
	$midpos{$this} = {}; 
    }

    my $href = $midpos{$this};
    my $key = "$pre-$this-$ne"; 
    $href->{$key} = $count; 
}
close FILEIN; 

# okay. Time to report. 
for (my $i=0; $i < 128; $i++)
{
    my $href = $midpos{$i}; 
    my %bests = take_only_best($href);
    my @best_keys = sort {$bests{$b} <=> $bests{$a}} keys %bests; 
    for(my $j=0; $j < scalar(keys %bests); $j++)
    {
        print " ", $best_keys[$j], "\t", $bests{$best_keys[$j]}, "\n"; 
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
