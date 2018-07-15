use strict;
use warnings;
use WordNet::SenseRelate::WordToSet;
use WordNet::QueryData;

#define the subroutines
sub disambiguate;
sub readFile;
sub writeToFile;



#Setting up 
use Time::HiRes qw( time );

my $qd = WordNet::QueryData->new(
    dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
    verbose => 0,
    noload  => 0
    );

my %options = (
	measure=>'WordNet::Similarity::lesk',
	wordnet=> $qd);

my $mod = WordNet::SenseRelate::WordToSet->new(%options);

disambiguate("","The dog faught with teeth, fangs, and claws","dog");
#disambiguation method
#Ikke nødvendig å splitte listen her, den skal komme igjennom allerede splittet
sub disambiguate{
	my ($nothing, $sentence,$word) = @_;
    my $start = time();
    # print "welcome to the wordtoset module";
    if (length($sentence)<=0) {
      my $firstWordSense = $word."#n#1";
      print "sense :", join( ", ", $qd->querySense( $firstWordSense, "glos"));
  }
  else{

      my @sentenceArray = split / /, $sentence;

      my $res = $mod->disambiguate(
         target => "$word",
         context => [@sentenceArray]);

      my $best;
      my @resList1 = ();
      my $best_score = -100;
      foreach my $key ( keys %$res ) {
       next unless defined $res->{$key};
       if ( $res->{$key} > $best_score ) {
           $best_score = $res->{$key};
           print $key, " : ",$best_score,"\n";
           $best       = $key;
       }
   }
   print "$best : ", join( ", ", $qd->querySense( $best, "glos")),"\n";
}
my $end = time();
printf("Time in algorithm: %.2f\n", $end - $start);
}
