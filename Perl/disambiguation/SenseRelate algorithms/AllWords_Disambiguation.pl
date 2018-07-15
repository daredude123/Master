package AllWords_Disambiguation;

use strict;
use warnings;

use WordNet::QueryData;
use WordNet::SenseRelate::AllWords;
use WordNet::Tools;


sub disambiguateAll;
sub getWordFromContext;


# print "---------ALL WORDS-------------------------------------\n";
my $wn = WordNet::QueryData->new(
    dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
    verbose => 0,
    noload  => 0
    );
my $wntools  = WordNet::Tools->new($wn);
my %optionsa = (
    wordnet => $wn,
    wntools => $wntools,
    measure => 'WordNet::Similarity::jcn'
    );
my $obj = WordNet::SenseRelate::AllWords->new(%optionsa);
##################################
print "context:\n";
my $contextsplit = <>;
chomp($contextsplit);
print "word:\n";
my $target = <>;
chomp($target);
##################################
disambiguateAll("",$contextsplit,$target);
print "-------------------------------------------------------\n";


sub disambiguateAll {

    my ($shiiiiiiet,$x,$target) = @_;
    my @context = split / /, $x;
    my @res          = $obj->disambiguate(
        window  => 3,
        scheme  => 'normal',
        tagged  => 0,
        context => [@context]
        );

    my ($targetIndex) = getWordFromContext(\@res,$target);
    print "\nResults\n####\nDisambiguation: $targetIndex\n";
    print "####\nSynsets: ",join(" ",  $wn->querySense($targetIndex,"syns")),"\n###";

}

sub getWordFromContext {

    my ($arg1,$arg2) = @_;
    my @disArray = @{$arg1};
    my $target1 = $arg2;
    chomp($target1);
    my @validform = $wn->validForms($target1);
    my $index = 0;
    foreach my $x (@disArray) {
        my $temp = (split /#/, $x)[0];
        if ($temp eq $target1) {
            return $disArray[$index];
        }
        else{
            foreach my $y (@validform) {
                if ((split /#/,$y)[0] eq $temp) {
                    return $disArray[$index];
                }
            }                   
        }
        $index++;}   
    }
1;