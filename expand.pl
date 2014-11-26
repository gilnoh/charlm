
# this small script will start from best len-3 
# candidates, and expand them in a beam-search fashion. 

# e.g. beam size: n 
# len-3 : n
# len-4 : n*n
# len-5 : n*n*n
# len-6 : n*n*n*n
# # (* 20 20 20 20)
# len 6 would have something like 160k candidates, if n = 20 
# but we can handle that number, and we can sort them pretty easily. 
# let's see what we will see with that.  

use warnings; 
use strict; 

# config 
my $NBestN = 20; 

# some global data
my %seed; 
my %gram_table; 
my @SCTCHARS; 

# some subs 
sub load_seeds; 
sub expand_one_cand;
sub load_gram_tables;  
sub init_SCTCHARS; 
sub eval_pattern; 
sub print_hash_sorted; 
sub pattern_array_to_string; 
sub pattern_string_to_array; 

##
## INIT
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

# some inits, loading gram tables and seeds.. 
init_SCTCHARS(); 
load_seeds(); 
load_gram_tables(); 

##
## TEST some sub tests 

#
#print "$_\n" foreach (expand_one_cand("125-43-94")); 
#print "$_\n" foreach (expand_one_cand("125-43-94-5")); 
# die; 

# my @n = get_char_pattern(125,43,94,75,6,25);
# print join(' ',@n), "\n"; 
# print calc_obs_freq(125,43,94), "\n";
# print calc_obs_freq(93,43,94), "\n";  
# die; 

# my @n1 = (125,43,94,75,6,25); 
# my @n2 = (66,125,43,94,75,6,25); 
# print eval_pattern(@n1), "\n";
# print eval_pattern(@n2), "\n"; 
# die; 

# my $s = "125-43-94"; 
# my %temp = expand_one_cand_and_select($s); 
# print_hash_sorted(\%temp); 
# die; 

# my @s = ("125-43-94", "82-79-68"); 
# my @result = sort_pattern_array(expand_one_length(@s)); 
# print join(' ', @result), "\n"; 
# die; 

##
## MAIN 

# one expansion test for len-6 ... 
# my @r1 = expand_one_length(keys %seed); 
# my @r2 = expand_one_length(@r1); 
# my @r3 = expand_one_length(@r2); 
# my @result = sort_pattern_array(@r3); 
# print "$_\n" foreach (@result); 

# let's try, say, 10-piece segment? 
my @r1 = expand_one_length(keys %seed);  #l4
my @r2 = expand_one_length(@r1);  # l5
my @r3 = expand_one_length(@r2);  # l6
# now it is about 400k. reduce. 
my @temp = sort_pattern_array(@r3); 
splice @temp, 50;  
#print "$_\n" foreach (@temp); 
#die; 
my @r4 = expand_one_length(@temp);  # l7
#print "$_\n" foreach (sort_pattern_array(@r4)); 
my @r5 = expand_one_length(@r4); # l8
my @r6 = expand_one_length(@r5); # l9 
my @result1 = sort_pattern_array(@r6); 
splice @result1, 50; 
#print "$_\n" foreach (@result1); 
my @r7 = expand_one_length(@result1); #l10
my @r8 = expand_one_length(@r7); # l11
my @result2 = sort_pattern_array(@r8);
splice @result2, 50; 
print "$_\n" foreach (@result2); 




# a list of candidates comes (string array) ---  ["125-43-94", "99-33-66", ...] 
# a list of expanded (l = original_l + 1) candidates comes out.  --- [ ... ] 
# total count of expanded candidates would be count_original * NBestN
sub expand_one_length
{
    my @result; 
    foreach my $c (@_)
    {
        print STDERR "$c\n"; 
        #print STDERR "."; 
        my %r = expand_one_cand_and_select($c);
        push @result, (keys %r); 
    }
    return @result; 
}

sub take_only_best; 
sub pattern_string_to_array; 
# expand the given (one) candidate pattern, and returns 
# NBestN good patterns among returned expanded, new candidates. 
sub expand_one_cand_and_select
{
    my @all_results = expand_one_cand($_[0]); 
    
    my %candidates; 
    for my $p (@all_results)
    {
        my $val = eval_pattern(pattern_string_to_array($p)); 
        $candidates{$p} = $val; 
    }    

    my %top = take_only_best(\%candidates); 
}

sub sort_pattern_array
{
    my %temp; 
    foreach my $p (@_)
    {
        $temp{$p} = eval_pattern(pattern_string_to_array($p)); 
    }    
    my @sorted_keys = sort {$temp{$b} <=> $temp{$a}} (keys %temp); 
    return @sorted_keys; 
}

sub print_hash_sorted
{
    my %nbests = %{$_[0]}; 
    my @best_keys = sort {$nbests{$b} <=> $nbests{$a}} keys %nbests; 

    for(my $i=0; $i < scalar(keys %nbests); $i++)
    {
        print " ", $best_keys[$i], "\t", $nbests{$best_keys[$i]}, "\n"; 
    }
    
}



# utility function used by load_gram_tables() 
sub load_gramtable
{
    print STDERR "loading gram table $_[0] ..."; 
    open CSV, "<", $_[0]; 
    while(<CSV>)
    {
	/^([^,]+),([^,]+),/; 
	$gram_table{uc($1)} = $2;
	#dcode# print STDERR $1 . "\t" .  $2 . "\n"; 
    }
    close CSV; 
    print STDERR " done\n"; 
}

# load gram tables, fill 
# %gram4_table, %gram5_table, and %gram6_table; 
sub load_gram_tables()
{
    load_gramtable("afp2010_ngrams/gram3.csv"); 
    load_gramtable("afp2010_ngrams/gram4.csv"); 
    load_gramtable("afp2010_ngrams/gram5.csv"); 
    load_gramtable("afp2010_ngrams/ngram6.csv"); 
}



# load some good l3 patterns, as starting point ... 
sub load_seeds()
{
    open SEEDIN, "<l3_best.txt"; 
    while(<SEEDIN>)
    {
        /^(.+)\t\t(\d+)\n/;
        $seed{$1}=$2; 
        #dcode# print STDERR "$1: $seed{$1}\n"; 
    }
    close SEEDIN; 
}



# simple evaluation by counting frequency of its last (up to 6) char grams  
sub eval_pattern
{
    # is the pattern can be matched directly? 
    my $input_len = scalar (@_); 
    if ($input_len < 7)
    {
        return calc_obs_freq(@_); 
    }
    else
    {
        # so, it has more than 6 pos. 
        # eval last 6, 
        # return sum. 
        my @last6 = @_; 
        my @next = @_; 
        shift(@next); 
        while(@last6 > 6)
        {
            shift(@last6); 
        }
        return (calc_obs_freq(@last6) + calc_obs_freq(@next)); 
    }
}

# get one candidate, expand it by adding 1-more length
# return 128 - original_length candidates (an array)
# e.g. "125-43-94" was input 
# => ("125-43-94-0", "125-43-94-1", ... , "125-43-94-127")
# 
# be careful --- this code will fail, if input isn't in perfect form. 
sub expand_one_cand()
{
    my $input = $_[0]; 

    my $cand = $input;
    my %already_in; 
    while(length($cand) > 0)
    {
        $cand =~ /^(\d+)/; 
        my $num = $1; 
        $already_in{$num} = 1; 
        $cand =~ s/^\d+//; 
        $cand =~ s/^-//; 
    }    

    # dcode # print STDERR (join(' ', (keys %already_in))); 
    my @result; 

    # expand now... 
    for(my $i=0; $i < 128; $i++)
    {
        # skip if already in 
        next if (exists $already_in{$i}); 

        # generate one ... 
        my $new_cand = $input . "-" . $i; 
        push @result, $new_cand; 
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
	# dcode # print STDERR $s, "\t"; 
	if (exists $gram_table{$s})
	{
	    $count += log ($gram_table{$s}); 
	    #$count += $gram_table{$s}; 
            # dcode # print STDERR $gram_table{$s}, "\n"; 
	}
    }
    return $count; 
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

# get 125-43-94 and returns (125,43,94) 
sub pattern_string_to_array
{
    my $string = $_[0]; 
    my @result = split /-/, $string; 
}

sub pattern_array_to_string
{
    return join ('-', @_); 
    
}
