#

use strict;
use warnings;
use Math::Combinatorics; 

# configuration 
my $GramN = 4; 
my $NBestN = 20000; 
my $GRAM_TABLE_FILE = "./afp2010_ngrams/gram4.csv"; 
#my $GRAM_TABLE_FILE = "./afp2010_ngrams/gram5.csv"; 

# this is the target ... 
my @SCT = (
"IATSNEDBOONANYNOOOTSPROOLEDCCUODYOUFBOAHORRFWWKTHJEHDEENHUTISYNOCTEAFAOFLCSAONRLOIEUCHNATNULAAYDSUDMEIMATADUIMSYRHVOADETMMJTPIIN", 
"EOHYEYRHBOESOCTWUSSEVMHYLIDTHNOLEUSLEDAIRLOLEAEWAETEELKNBSEHTSNWNBNNETNMEELEMNHHRTTRIYIARMENCELBGSCIETEOEIEALESRAICETSLSHAELHIEL", 
"FSTEDTHGDESTPSSORRINFHNCCEAEEEEUEIARGREATEAHTTIEAEOSITNDHNCEINLUODTNHSXERASTIHITTSESRINTTAWEATAVDOAOOSILIEEHHCPYTNICMTTIITUEVTHO", 
"MCDAIERIBROOEDGEUDUIARRLEEENSPEEEIERENCFOETRDVRATSETRSCINLNMNEOENATOOLYBNURLAOOTSEAMEEAAEASECCEKRMCNNECRMSFPELSRRIEXTDHCSRNUDPRA", 
"AFTTEEGDOCISGEAHHRKNIEVTNNASEHOHBTTSNOEHAKTOADTHAETSHDIMEICMULOERHEEINUEOAINOTCSETNDSIOEBMVAKGWYYADADNOWTTUNTNMEEBNDAYADRSANSHRN", 
"EIERTDMHNMONAENIADLUDLGSALNISIHGLCTBARRNLEEHAREAPONEMTNWBSWEOLWYNHITOGOYEOEETLETBTDLEAHAOWOSTTEIOONRLOSETRINHAHHHWILSMPRYTIEWTSE", 
"HLABRSEOIAERRVDTNYAGAROWTILWNOGNAIINURGBROTHGETNDHIWODHINFIGONORRTFOOEHAAGWRESLRYSFENAREIEHLEOENUNRESONRTTWRAANISHTCANITPWMWWTVD", 
"STLIKNRTETDEEEIEHFTEPBCTHEAIALIWNTOROTRSIHHUIEAININNRRSEOTNNNETOODNHETSGPLTEXUIHILTIDAUSFHNTOTREITEGMHANSAHGGRRYUIEBMADFRCSEDDTB", 
"ILHHHRTDFPBEGOREEIXLWKTWCEDEIABTSGOOANIUFRDHAOFDSNCNHDTWVNTLERLNERASRAAUBVSSEEUPCSTENYDMELOWFTEEBAUEOISEAJOIDIOEEMNPOLGAANIOSTPT", 
"ALTANSGHIHRIESSUIONEINKIEGEMYMPTRELTOUBMEFLRHUNBUISOABTDWSSODEEAFDIAIULUDEANSEGYYANPOPREOWOCAOEARVARNHRSLELORWRYTDYTNFFKTYWUTAAO",
); 

# some datas in mem. 
my @SCTCHARS; 
my %gram_table; 

sub init_SCTCHARS
{
    for(my $j=0; $j < scalar(@SCT); $j++)
    {
	$SCTCHARS[$j] = []; 
	my $s = $SCT[$j]; 
	for(my $i = 0; $i < length ($s); $i++)
	{
	    $SCTCHARS[$j][$i] = substr($s, $i, 1); 
	}
    }
}

sub load_gramtable
{
    print STDERR "loading gram table ..."; 
    open CSV, "<", $GRAM_TABLE_FILE; 
    while(<CSV>)
    {
	/^([^,]+),([^,]+),/; 
	$gram_table{uc($1)} = $2;
	#print STDERR $1 . "\t" .  $2 . "\n"; 
    }
    close CSV; 
    print STDERR " done\n"; 
}

sub trial_loop; 
sub calc_obs_freq; 
sub take_only_best; 

# main 

init_SCTCHARS(); 
load_gramtable(); 

trial_loop; 

# my @n = get_char_pattern(125,43,94,75,6,25);
# print join(' ',@n); 
# die; 
#my $count = calc_obs_freq(3,2,1); 
#print $count, "\n"; 
#$count = calc_obs_freq(125,43,94); 
#print $count, "\n"; 


my %nbests; 
my $c=0; # simple count for number of permutations.  
# and now, calc best permutations 
{
    # prepare permutation candidates. 
    my @num;
    for (my $i=0; $i < 128; $i++)
    {  
	$num[$i] = $i;  
    }
    my $combinator = Math::Combinatorics->new(count => $GramN, data => [@num], );

    while (my @t = $combinator->next_combination)
    {
	#print STDERR join('-', @t), "\n"; 
	my @sel = permute(@t); 
	foreach(@sel)
	{
	    #print STDERR join ('-', @{$_}), "\n"; 
	    # now we have "one candidate" here in @sel. 
	    # get frequency count and store it. 
	    my $count = calc_obs_freq(@{$_}); 
	    $nbests{join('-', @{$_})} = $count; 
	    #dcode# print STDERR join('-', @{$_}), "\t", $count, "\n"; 
	    $c++; 
	}
	if ($c > 100000)
	{
	    # leave only top N...
	    my %new_nbests = take_only_best(); 
	    #print STDERR "size ", scalar(%nbests), " trimed to size, ", scalar(%new_nbests), "\n" ; 
	    print STDERR "."; 
	    %nbests = %new_nbests; 
	    $c = 0; 
	}
    }
}
%nbests = take_only_best(); 

# finish --- 
# now nbests holds the best patterns. print them out, say first 10? 
my @best_keys = sort {$nbests{$b} <=> $nbests{$a}} keys %nbests; 

for(my $i=0; $i < scalar(keys %nbests); $i++)
{
    print " ", $best_keys[$i], "\t", $nbests{$best_keys[$i]}, "\n"; 
}


# gets an array of "position num" 
# and returns 10 char-patterns, accoring to the locations. 
# (returns 10 strings, array). 
sub get_char_pattern
{
    my @pos = @_; 
    my @result; 
    for (my $i=0; $i < @SCTCHARS; $i++)
    {
	my $obs=""; 
	for(@pos)
	{
	    $obs .= $SCTCHARS[$i][$_]; 
	}
	push @result, $obs; 
    }
    return @result; 
}

sub calc_obs_freq
{
    my @pos = @_; 
    my @patterns = get_char_pattern(@pos); 
    my $count=0; 
    
    for my $s (@patterns)
    {
#	print STDERR $s, "\t"; 
	if (exists $gram_table{$s})
	{
	    $count += $gram_table{$s}; 
	}
#	print STDERR $gram_table{$s}, "\n"; 
    }
    return $count; 
}

# look nbest, pick top n (say, 2000) 
# return them as a new hash. 
sub take_only_best
{
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


sub trial_loop
{
    while(1)
    {
	print "> "; 
	my $line = <STDIN>; 
	my @val = split /,/, $line; 
	my @n = get_char_pattern(@val);
	print join(' ',@n), "\n"; 
    }    
    
}

