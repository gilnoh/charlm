#

use strict;
use warnings;
use Math::Combinatorics; 

# configuration 
my $GramN = 4; 
my $NBestN = 20; 
#my $GRAM_TABLE_FILE = "./afp2010_ngrams/gram4.csv";  # for 3 gram (head+3=4)
my $GRAM_TABLE_FILE = "./afp2010_ngrams/gram5.csv";  # for 4 gram (head+4=5)
#my $GRAM_TABLE_FILE = "./afp2010_ngrams/ngram6.csv"; # for 5 gram (head+5=6)

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

sub load_gramtable_headonly
{
    print STDERR "loading gram table ..."; 
    open CSV, "<", $GRAM_TABLE_FILE; 
    while(<CSV>)
    {
	/^([^,]+),([^,]+),/; 
        my $key = $1; 
        my $val = $2; 
	#$gram_table{uc($1)} = $2;
        if ($key =~ /^\^/)
        { 
            $key =~ s/^\^//;
            $gram_table{uc($key)} = $val;
#            print STDERR $key . "\t" .  $val . "\n"; 
        }
    }
    close CSV; 
    print STDERR " done\n"; 
}

sub trial_loop; 
sub calc_obs_freq; 
sub take_only_best; 

# main 

init_SCTCHARS(); 
load_gramtable_headonly(); 

#trial_loop; 

# my @n = get_char_pattern(125,43,94,75,6,25);
# print join(' ',@n); 
# die; 
#my $count = calc_obs_freq(3,2,1); 
#print $count, "\n"; 
#$count = calc_obs_freq(125,43,94); 
#print $count, "\n"; 

my %nbests;  # nbest will be stored here ... 
my $c=0; # simple count for number of permutations.  
my $clear_count=0;  
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
	    # now we have "one candidate" here in @sel. 
	    # get frequency count and print it on STDOUT
	    my $count = calc_obs_freq(@{$_}); 
	    #my $count = calc_obs_logfreq(@{$_}); 
	    $nbests{join('-', @{$_})} = $count;             
            #print STDERR join('-', @{$_}), "\t\t", $count, "\n"; 
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
            $clear_count++; 
            if ($clear_count > 10)
            {
                last; 
            }
	}
    }
}

print STDERR "In total, about ", 100000 * $clear_count + $c, "len-n patterns have been tried\n"; 

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

sub calc_obs_logfreq
{
    my @pos = @_; 
    my @patterns = get_char_pattern(@pos); 
    my $count=0; 
    
    for my $s (@patterns)
    {
#	print STDERR $s, "\t"; 
	if (exists $gram_table{$s})
	{
	    $count += log($gram_table{$s}); 
	}
#	print STDERR $gram_table{$s}, "\n"; 
    }
    return $count; 

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
