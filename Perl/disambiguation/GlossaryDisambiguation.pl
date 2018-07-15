use strict;
use warnings;
use WordNet::QueryData;
use Lingua::EN::Tagger;
use WordNet::Similarity::lesk;

require "Util/AskForContext.pl";
require "Util/ReturnSenses.pl";
require "RetDisambiguate.pl";

sub GlossaryDisambiguation;
sub FindOneValidForm;
sub SynonymSetCheck;
sub addPointsFromHashToHash;
sub findTargetWordPos;

my $wn = WordNet::QueryData->new(
  dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
  verbose => 0,
  noload  => 0
  );


print "Write the in-text context:\n";
my $context = <>;
chomp($context);
$context =~ s/[\$#@~!&*()\[\];.,:?^`\\\/ ]+/ /g;
my $p = new Lingua::EN::Tagger;

my ($HeadLine,$targetWord) = AskForContext->AskForContext;

my @inTextPOSContextArray = split / /, lc  $p->get_readable($context);
my $inTextPOSContext = lc $p->get_readable($context);
my @inTextArray = split / /, lc $context;

my @HeadLinePOSContextArray = split / /, lc  $p->get_readable($HeadLine);
my $HeadLinePOSContext = lc $p->get_readable($HeadLine);
my @HeadLineArray = split / /, lc $HeadLine;
my @validPos = ();
#The Target word senselist values. 
#The disambiguator adds point during the disambiguation. But the idea is to give more points to the target words senses if the word is included in the title/headline. 

my %valueHash = ();
my %valueHash1 = ();
my $measure = WordNet::Similarity::lesk->new($wn);

my $targetPartOfSpeech = findTargetWordPos($targetWord, $inTextPOSContext);
my $multiplier = 1;#SynonymSetCheck($targetWord,@HeadLineArray);


#####Start glossarydisambiguation- This method uses the glossary disambiguation method, running through context and the Headline
%valueHash = GlossaryDisambiguation($targetWord,@HeadLinePOSContextArray);
$multiplier = SynonymSetCheck($targetWord,@HeadLineArray);
%valueHash1 = GlossaryDisambiguation($targetWord,@inTextPOSContextArray);
#####End GlossaryDisambiguation-

#Method for adding the points in one hash to another
# addPointsFromHashToHash(%valueHash1, %valueHash);


foreach my $y (
  sort { $valueHash{$a} <=> $valueHash{$b} }
  keys %valueHash
  )
{
  print $y, " -- ", "value : ", $valueHash{$y}, "\n";
  print "########DEF########\n";
  print $wn->querySense( $y, "glos" ), "\n---\n";
  print "Synset: ", join(", ", $wn->querySense($y, "syns")), "\n";
  print "###################\n";
}



#Sub for finding and returning the targets Part-Of-Speech tag in context.
sub findTargetWordPos{
  #POS tagged context and targetWord.
  my ($target,$posContext) = @_;
  print "ACCESSING findTargetWordPos\n";
  print "$posContext\n";
  my ($posTemp) = ( $posContext =~ /($target)\/([a-z])([a-z]*)/ )[1];
  if (defined $posTemp) {
    if ( $posTemp eq 'j' ) {
    #Because in this wordnet module, the POS tag jj is equivalent to an adjective which is tagged as #a here.
    $posTemp = 'a';
  }
}
else{
  foreach my $x (@inTextPOSContextArray) {
    my ($w,$t) = split /\//, $x;
    if (FindOneValidForm($w)) {
      return (substr $t,0,1);
    }
  }
}
return $posTemp;
}




#Glossary disambiguation. Each of the target senses glossary is disambiguated against the context. I.E. Each of the words in the glossary has a N number of senses,
#these senses are measured against each of the context words N number of senses. The resulting product is a Hash array of the target words senses and each of the 
#mentioned measurments.
sub GlossaryDisambiguation{
  my ($target,@cont) = @_;
  my %subValueHash =  ();
  #Loop: 0, Runs through each of the target words available senses
  foreach my $x (ReturnSenses->returnPOSSenses($target,$targetPartOfSpeech)) {
    print "$x\n";
    $subValueHash{$x} = 0;
    my @glossPOSArray = split / /,(lc $p->get_readable(($wn->querySense($x,"glos"))));
    print @glossPOSArray;
    #Loop: 1, Runs through the current target senses pos tagged definition 
    foreach my $y (@glossPOSArray) {
      print "$y\n";
      my ($glossW,$glossWPOS) = split /\//, $y;
      #Loop 2: Runs through each of the senses for each of the words in the definition
      foreach my $z (ReturnSenses->returnPOSSenses($glossW,(lc substr $glossWPOS,0,1))) {
        print "$z\n";
        #Loop 3: Runs through each of the context words
        foreach my $xy (@cont) {
          my ($contextW, $contextWPOS) = split /\//, $xy;
          #Loop 4: Runs through each of the context words senses
          foreach my $xyz (ReturnSenses->returnSenses($contextW)) {
            print "$z----------------$xyz\n";
            #measuring target words definition word against context word senses. 
            $subValueHash{$x} += $measure->getRelatedness($xyz,$z)*$multiplier;
            print $measure->getRelatedness($xyz,$z),"\n";
          }
        }
      }
    }
  }
  return %subValueHash;
}

sub FindOneValidForm {
  my $x = @_;
  my @posList = qw(r n v a);
  # my @validPos =();
  my @temp = $wn->validForms($x);
  my $valid = $temp[0];
  my ($tempVal,$tag) = split /#/, $valid;
  return $tempVal;
}

sub addPointsFromHashToHash{
  my (%fromHash,%toHash) = @_;
  foreach my $x (keys %fromHash) {
    $toHash{$x} += $fromHash{$x};
  }
}

sub SynonymSetCheck{
  my ($targetWord, @context) = @_;

  print "ACCESSING SynonymSetCheck\n";
  my $found = 0;
  my $scoreCode = 1;

  print $targetWord,"\n";
    #Is the word included in the title?
    if ( grep {$_ eq $targetWord}   @context) {
      print "Found the target word in the HeadLine\n";
      $found = 1;
      return $scoreCode = 2;
      
    }
    #Try with validForms
    else{
      $found = 0;
      print "Trying with validForms...\n";
      my $valid = FindOneValidForm($targetWord);
      foreach my $y (@context) {
        if ($valid eq $y) {
          print "Found it with validForms!!    ---$valid---   \n";
          $found = 1;
          return $scoreCode =1.5;
        }
      }
      if($found == 0){
        print "Did not find it with validForms. Checking with synonym sets!\n";
        my @synsets = ReturnSenses->returnSenses($targetWord);
        print "@synsets\n";
        foreach my $x (@synsets) {
                # print join("--", $wn->querySense($x,"syns")),"\n";
                foreach my $y ($wn->querySense($x,"syns")) {
                 my $form =  (split /#/,$y)[0];
                 print $form,"######__###\n";
                 $form=~ tr/_/ /;
                 foreach my $z (@context) {
                       # print "$form    $z\n";
                       if ($form eq $z) {
                         print "Found it with Synonym Sets:D:D:D:D:D:D:D:D       $form    $z\n";
                         $found = 1;
                         return $scoreCode = 1.25;
                       }
                     }    
                   }
                 }
                 if($found == 0){
                  $scoreCode = 1;
                  print "Did Not find the TargetWord in the Context \n";
                  print join(" ",@context),"---", $targetWord,"\n";
                }
              }
            }
            return $scoreCode;
          }