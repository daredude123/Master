use strict;
use warnings;

use WordNet::QueryData;
use WordNet::SenseRelate::AllWords;
use WordNet::Tools;


sub disambiguateAll;
sub getWordFromContext;
sub readFile;
sub writeToFile;


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
    measure => 'WordNet::Similarity::lesk'
    );
my $obj = WordNet::SenseRelate::AllWords->new(%optionsa);


my $fileName = 'D:/SKOLE/MASTER 2016/testing/100URL-target-context.txt';
my $returnString ="";
readFile();
writeToFile($returnString);
print "-------------------------------------------------------\n";


sub disambiguateAll {

    my ($x,$target) = @_;
    my @context = split / /, $x;
    my @res          = $obj->disambiguate(
        window  => 3,
        context => [@context]
        );

    my ($targetIndex) = getWordFromContext(\@res,$target);
    print $targetIndex,"\n";
    $returnString.="Results:  $targetIndex\n";

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

    sub readFile {

        open(my $fh, '<:encoding(UTF-8)',$fileName)
        or die "Could not read file $fileName\n";
        while(my $row = <$fh>){
          chomp $row;
          my ($url,$target,$context) = split /\|/, $row;
        # $returnString+= $row;
        # print $row,"\n";
        print "URL= $url\nTarget: $target\nContext: $context\n";
        disambiguateAll($context,$target);
        # print "$row\n";
    }
    close $fh;
}

sub writeToFile{
  my ($result) = @_;
  print "$result";
  open (my $fr, '>', "AllWords_Disambiguation_100_test_Results.txt");
  print $fr $result;
  close $fr; 
}