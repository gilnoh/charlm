#

use strict;
use warnings;
use Math::Combinatorics; 

# configuration 
my $GramN = 5; 
#my $GRAM_TABLE_FILE = "./afp2010_ngrams/gram4.csv"; 
#my $GRAM_TABLE_FILE = "./afp2010_ngrams/gram5.csv"; 
my $GRAM_TABLE_FILE = "./afp2010_ngrams/ngram6.csv"; 

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
            print STDERR $key . "\t" .  $val . "\n"; 
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
	    # now we have "one candidate" here in @sel. 
	    # get frequency count and print it on STDOUT
	    my $count = calc_obs_freq(@{$_}); 
	    #my $count = calc_obs_logfreq(@{$_}); 
            print join('-', @{$_}), "\t\t", $count, "\n"; 
	    $c++; 
	}
    }
}

print STDERR "In total $c len-n patterns have been tried\n"; 

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

