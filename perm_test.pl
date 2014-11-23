#
use warnings;
use strict;

use Math::Combinatorics; 

# time & space 
# 2 (* 128 127), 16256, 2 sec 
# 3 (* 128 127 126), 2048256, 1.x min 
# 4 (* 128 127 126 125) 256032000, (93 min) 

my @data;
for (my $i=0; $i < 128; $i++)
{
    $data[$i] = $i 
}

my $combinator = Math::Combinatorics->new(count => 4, data => [@data], );

while (my @t = $combinator->next_combination)
{
    my @sel = permute(@t); 
   for (@sel)
   {
   	print join(' ', @{$_});  
   	print "\n"; 
   }
}
