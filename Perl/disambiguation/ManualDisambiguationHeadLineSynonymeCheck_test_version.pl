use strict;
use warnings;
use WordNet::QueryData;
use Lingua::EN::Tagger;
use WordNet::Similarity::lesk;

require "Util/ReturnSenses.pl";
# require "RetDisambiguate.pl";

sub manualDisambiguationV2;
sub FindOneValidForm;
sub SynonymSetCheck;
sub addPointsFromHashToHash;
sub TargetWordAndContextDisambiguation;
sub findTargetWordPos;
sub readFile;
sub writeToFile;

my $wn = WordNet::QueryData->new(
  dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
  verbose => 0,
  noload  => 0
  );

my $measure = WordNet::Similarity::lesk->new($wn);
my $p = new Lingua::EN::Tagger;


my $fileName = 'D:/SKOLE/MASTER 2016/testing/Testing database/100URL-target-headline-context.txt';
my $writeFile = 'Multiplier_HeadLine_Context_Disambiguation_reportTop3.txt';



my @inTextPOSContextArray;
my $inTextPOSContext;
my @inTextArray;

my @HeadLinePOSContextArray;
my $HeadLinePOSContext;
my @HeadLineArray;
my @validPos;

my %valueHash;
my %valueHash1;

my $targetPartOfSpeech;
my $multiplier;


my $WriteString = "";
readFile();
writeToFile($WriteString);

#####Method for adding the points in one hash to another
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


sub readFile {
  open(my $fh, '<:encoding(UTF-8)',$fileName)
  or die "Could not read file $fileName\n";
  while(my $row = <$fh>){
    my ($url,$target,$HeadLine,$context) = split /\|/, $row;

    $context =~ s/[\$#@~\-!&*()\[\];.,:?^`\\\/ ]+/ /g;

    @inTextPOSContextArray = split / /, lc  $p->get_readable($context);
    $inTextPOSContext = lc $p->get_readable($context);
    @inTextArray = split / /, lc $context;

    @HeadLinePOSContextArray = split / /, lc  $p->get_readable($HeadLine);
    $HeadLinePOSContext = lc $p->get_readable($HeadLine);
    @HeadLineArray = split / /, lc $HeadLine;
    @validPos = ();

    %valueHash = ();
    %valueHash1 = ();

    $targetPartOfSpeech = findTargetWordPos($target, $inTextPOSContext);
    $multiplier = 1;

    manualDisambiguationV2($target,$inTextPOSContext,$HeadLinePOSContext);
        #####These commented ones are the acumulated score when running against the HeadLine aswell
    # $multiplier = SynonymSetCheck($target,$HeadLine);
    # %valueHash = TargetWordAndContextDisambiguation($target,$HeadLine);
    
    # %valueHash1 = TargetWordAndContextDisambiguation($target,$context);
    addPointsFromHashToHash(%valueHash1,%valueHash);
    #####End TargetWordAndContextDisambiguation

    my $counter = 0;
    foreach my $y (
      sort { $valueHash{$b} <=> $valueHash{$a} }
      keys %valueHash
      )
    {
      # print $y, " -- ", "value : ", $valueHash{$y}, "\n";
      if ($counter < 3 && scalar (keys %valueHash) >= 3) {
        print "$y\n";
        $WriteString.="$y\n";
      }
      elsif(scalar (keys %valueHash) <=3){
        print "$y\n";
        $WriteString.="$y\n";

      }
      $counter+=1;
      # print "counter = $counter\n";
    }

    chomp $row;
  }
  close $fh;
}

sub writeToFile{
  my ($result) = @_;
  print "@_";
  print join 'hello',@_;
    # my $dir = dir();
    # my $file = $dir->file("Disambiguate_report.txt"); # /tmp/file.txt

    # Get a file_handle (IO::File object) you can write to
    # my $file_handle = $file->openw();
    # $file_handle->print($result);
    open (my $fr, '>', $writeFile) or die "Could not open $writeFile";
    print $fr $result; 
    close $fr;
  }


  sub manualDisambiguationV2{
    my ($targetWord,$posContext,$posHeadline )= @_;

    print "Entering manualDisambiguationV2\n";
    my $multiplier = 1;
    my @targetSenses = ReturnSenses->returnPOSSenses($targetWord,$targetPartOfSpeech);
    if (@targetSenses == 0) {
      @targetSenses = ReturnSenses->returnSenses($targetWord);
    }
    print "@targetSenses\n";
    my %multiplierHash;

    foreach my $x (@targetSenses) {
      $multiplierHash{$x} = 1;
      foreach my $y ($wn->querySense($x,"syns")){
        print "targetSense$x--- targetSense synset$y\n";
        my $noSensey = (split /#/, $y)[0];
        $noSensey =~ tr/_/ /;
        print "TargetSense: $noSensey######\n";
        my $counter = scalar split / /,$y;
        if(scalar (split(/ /,$y)) > 0){
          for(my $i =0; $i < scalar @HeadLineArray; $i++){

            print "$HeadLineArray[$i]----$HeadLineArray[$i+1]\n";
            my $wordPair = $HeadLineArray[$i]." ".$HeadLineArray[$i+1];
          #Below is the multiplication lines: If the word is equal to the sense of the word and not its accompanying synset it gets a 2 times multiplier and 1.5 if it is equal to the synset.
          if($noSensey eq $HeadLineArray[$i]){$multiplierHash{$x} = 1.5;}
          elsif($noSensey eq $wordPair ){$multiplierHash{$x} = 2;}
        }
      }
    }

  }
  print "Disambiguation V2\n";
  foreach my $x (keys %multiplierHash) {
    foreach my $y (@inTextPOSContextArray) {
      my ($contWord,$contWordPOS) = split /\//, $y;
      foreach my $z (ReturnSenses->returnPOSSenses($contWord, lc (substr $contWordPOS,0,1))) {
        $valueHash{$x} += $measure->getRelatedness($x,$z)*$multiplierHash{$x};
        print $multiplierHash{$x},"\n";
      }
    }
  } 
  foreach my $x (keys %multiplierHash) {
    print "$x.-.-.-.-..-$multiplierHash{$x}\n";
  }
}


#Sub for finding and returning the targets Part-Of-Speech tag in context.
sub findTargetWordPos{
  #POS tagged context and targetWord.
  my ($target,$posContext) = @_;
  print "ACCESSING findTargetWordPos\n";
  # print "$posContext\n";
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

sub TargetWordAndContextDisambiguation{
  my ($tWord, $cont) = @_;
  print "Disambiguating...\n";
  my %subValueHash = ();
  my @sList = ReturnSenses->returnPOSSenses($tWord,$targetPartOfSpeech);
  if (@sList == 0) {
    @sList = ReturnSenses->returnSenses($tWord);
  }
  foreach my $x (@sList) {
    $subValueHash{$x} = 0;
    foreach my $y (split / /,$p->get_readable($cont)) {
      my ($contWord,$contWordPOS) = split /\//, $y;
      foreach my $z (ReturnSenses->returnPOSSenses($contWord,(lc substr $contWordPOS,0,1))) {
        if ($z eq 0) {print "skipping\n"; last;}
        # print "$multiplier $x--------$z\n";
        $subValueHash{$x} += (($measure->getRelatedness($x,$z))*$multiplier);
        # print $subValueHash{$x},"\n";
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
                 # print $form,"######__###\n";
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
                  print "Did Not find the TargetWord in the headline \n";
                  print join(" ",@context),"---", $targetWord,"\n";
                }
              }
            }
            return $scoreCode;
          }