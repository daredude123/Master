package ReturnSenses;
use strict;
use warnings;
use WordNet::QueryData;

#######################################
####Return every Synset from a word####
#######################################

sub returnSenses;
sub returnPOSSenses;

my $wn = WordNet::QueryData->new(
  dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
  verbose => 0,
  noload  => 0
  );
sub returnSenses{
  my ($subInput) = $_[1];
  my @newSenseList = ();
  if (scalar (split //, $subInput) < 2) {
    return @newSenseList;
  }
  else{
    foreach my $x ($wn->querySense($subInput)) {
      push (@newSenseList,$wn->querySense($x));
    }
    return @newSenseList;
  }
}

sub returnPOSSenses{
  my ($shaaait,$subInput,$pos) = @_;
  print "$shaaait-----------|$subInput|---------$pos\n";
  if ($pos) {

    #v==verb
    #a(j)==adjective
    #r==adverb
    #n==noun
    if (   "$pos" eq "v"
      || "$pos" eq "j"
      || "$pos" eq "r"
      || "$pos" eq "n" ){
      if ( "$pos" eq 'j' ) {

        #Because in this wordnet module, the POS tag jj is equivalent to an adjective which is tagged as #a here.
        $pos = 'a';
      }
    }
    else{
      return returnSenses($subInput);
    }
  }
  print "ACCESSING returnPOSSenses\n";
  print $pos,"\n";
  my $querySenseSearch = "$subInput#$pos";
  print "$querySenseSearch";
  my @posSenseList = ();
  print join(", ", $wn->querySense($querySenseSearch)),"\n";
  foreach my $x ($wn->querySense($querySenseSearch)) {
   print "$x\n";
   push (@posSenseList,$x);
 } 
 if(scalar @posSenseList == 0){
  print "Trying with validForms\n";
  my @validFormsList = $wn->validForms($subInput);
  foreach my $x (@validFormsList) {
    my ($validWord,$ifPos) = split /#/,$x;
    if ($ifPos eq $pos) {
      foreach my $x ($wn->querySense($x)) {
       print "$x\n";
       push (@posSenseList,$x);
     } 
   }
 }
}
print "RETURNING FROM returnPOSSenses\n";
return @posSenseList;
}
1;