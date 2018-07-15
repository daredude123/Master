use strict;
use warnings;
use WordNet::SenseRelate::WordToSet;
use WordNet::QueryData;

#define the subroutines
sub disambiguate;
sub readFile;
sub writeToFile;


#Setting up 
my $qd = WordNet::QueryData->new(
  dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
  verbose => 0,
  noload  => 0
  );

my %options = (
	measure=>'WordNet::Similarity::lesk',
	wordnet=> $qd);

my $mod = WordNet::SenseRelate::WordToSet->new(%options);

#Kjører disambiguering av ord basert på konteksten
# disambiguate($splitArgument[0],$splitArgument[1]);
# disambiguate("Organizing information can help aid retrieval.  You can organize information in sequences (such as alphabetically, by size or by time).","aid");
my $writeString = "";
readFile();
writeToFile($writeString);
#disambiguation method
#Ikke nødvendig å splitte listen her, den skal komme igjennom allerede splittet
sub disambiguate{
	my ($sentence,$targetWord) = @_;
    # print "welcome to the wordtoset module";


    my @sentenceArray = split / /, $sentence;

    my $res = $mod->disambiguate(
     target => $targetWord,
     context => [@sentenceArray]);

    my $best;
    my @resList1 = ();
    my $best_score = -100;
    foreach my $key ( keys %$res ) {
     next unless defined $res->{$key};
     if ( $res->{$key} > $best_score ) {
       $best_score = $res->{$key};
       $best       = $key;
     }
   }
   $writeString .="$best\n";
   print "$writeString\n";
 }
 sub readFile {
  my $fileName = "D:/SKOLE/MASTER 2016/testing/100URL-target-context.txt";
  open(my $fh, '<:encoding(UTF-8)',$fileName)
  or die "Could not read file $fileName\n";
  my $returnString;
  while(my $row = <$fh>){
    chomp $row;
    my ($url,$target,$context) = split /\|/, $row;
        # $returnString+= $row;
        # print $row,"\n";
        # print "URL= $url\nTarget: $target\nContext: $context\n";
        disambiguate($context,$target);
        # print "$row\n";
      }
      close $fh;
    }

    sub writeToFile{
      my $result = @_;
      print "$result\n";
      open (my $fr, '>', "WordToSet_100_test_disambiguation_test_results.txt");
      print $fr $result;
      close $fr; 
    }
