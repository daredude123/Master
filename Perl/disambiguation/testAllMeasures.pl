use strict;
use warnings;
use WordNet::QueryData;
use WordNet::SenseRelate::WordToSet;
use WordNet::Similarity;
use diagnostics;


sub wupMeasure;
sub vectorMeasure;
sub vector_pairsMeasure;
sub resMeasure;
sub randomMeasure;
sub pathMeasure;
sub linMeasure;
sub leskMeasure;
sub lchMeasure;
sub jcnMeasure;
sub hsoMeasure;


my $word ="";
my @sentence=[];

#En hash som har ordet som skal disambigueres som nøkkel og konteksten som en verdi
my %disHash = (
  "break"=> "The glass broke in a thousand pieces i hate it when things break",
  "light"=> "he shead som light on the situation at hand, it was hard to understand",
  "charge"=> "The bank charged him for not paying his bills on time, he lacked the funds to do so",
  "face" => "Look for the dice and tell me what face it shows",
  "cat"=> "It was used on slave trade ships to punish the prisoners by whipping them with the cat",
  "dog"=> "That person sure has an ugly face, a real dog",
  "stab"=> "He took bullet and stab wounds to the head, face, side, and arm, returning fire the whole time.",
  "tank"=> "WW1 tactics and theoreticians soon announced that at least three tank types would be necessary to make a difference in no-man’s land (which was still the only imagined battleground for most staffs)."
  );

my $start = time;

#initialiserer wordnet querydata. 
my $qd = WordNet::QueryData->new();


#Lager en fil som jeg kan lagre disambigueringen i.
my $filename = "report.txt";
open(my $fh, '>',$filename) or die "Could not open file '$filename' $!";


foreach my $disword (sort keys %disHash){  
  my $value = $disHash{$disword};
  print $fh "---------------------------\n";
  print $fh "$disword --- $value \n";
  print $fh "---------------------------\n";

  #regex for å fjerne karakterer som algoritmen ikke trenger
  $value =~ s/[\$#@~!&*()\[\];.,:?^`\\\/]+//g;

  my @sentence = split / /, $value;

  $word = $disword;

#Kjør alle similarity målingene tilgjengelig i perl modulen
  wupMeasure;
  vectorMeasure;
  vector_pairsMeasure;
  resMeasure;
  randomMeasure;
  pathMeasure;
  linMeasure;
  leskMeasure;
  lchMeasure;
  jcnMeasure;
  hsoMeasure;
  print $fh "---------------------------\n";
}
close $fh;
my $duration = time - $start;
print "Executiuon time: $duration \n";


# my $qd = WordNet::QueryData->new();
# print "write a sentence:\n";
# my @sentence = split / /, <>;


# foreach my $x (@sentence) {
#   $x =~ s/[\$#@~!&*()\[\];.,:?^`\\\/]+//g;
#   }
# print (@sentence);

# print $fh "Context: ", join(" ", @sentence), "\n";

# print "write word to disambiguate\n";
# my $word = <>;
# chomp($word);

# print $fh "Tagged Word: ", $word; 



# wupMeasure;
# vectorMeasure;
# vector_pairsMeasure;
# resMeasure;
# randomMeasure;
# pathMeasure;
# linMeasure;
# leskMeasure;
# lchMeasure;
# jcnMeasure;
# hsoMeasure;
# close $fh;




sub wupMeasure {

  print $fh "wupMeasure\n";

  my %options = (measure =>'WordNet::Similarity::wup',
                 wordnet => $qd);

  my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
	my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
	my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }

  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";

}

sub vector_pairsMeasure {
 
  print $fh "vector_pairsMeasure\n";
  my %options = (measure =>'WordNet::Similarity::vector_pairs',
                 wordnet => $qd);

  my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }
  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";
}

sub vectorMeasure {
	
  print $fh "vectorMeasure\n";
  my %options = (measure =>'WordNet::Similarity::vector',
					wordnet=>$qd);
	
  my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);

	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }
  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";

}

sub resMeasure {
	
  print $fh "resMeasure\n";
  my %options = (measure =>'WordNet::Similarity::res',
					wordnet=>$qd);

  my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }

  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";
}

sub randomMeasure {
	
  print $fh "randomMeasure\n";
  my %options = (measure =>'WordNet::Similarity::random',
					wordnet=> $qd);

  my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }

  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";

}

sub pathMeasure {

  print $fh "pathMeasure\n";
	my %options = (measure =>'WordNet::Similarity::path',
					wordnet=> $qd);
	my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }
  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";

}

sub linMeasure {

  print $fh "linMeasure\n";
	my %options = (measure =>'WordNet::Similarity::lin',
					wordnet=> $qd);
	my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }
  if (($best eq "") == 1) {
    $best = $newWord."#n#1";
  }
  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";
}
sub leskMeasure {

  print $fh "leskMeasure\n";
	my %options = (measure =>'WordNet::Similarity::lesk',
					wordnet=> $qd);
 my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }

  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";
}
sub lchMeasure {

  print $fh "lchMeasure\n";
	my %options = (measure =>'WordNet::Similarity::lch',
					wordnet=>$qd);
 my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }

  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";
}

sub jcnMeasure {

  print $fh "jcnMeasure\n";
	my %options = (measure =>'WordNet::Similarity::jcn',
					wordnet=> $qd);
	 my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }

  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";
}

sub hsoMeasure {

  print $fh "hsoMeasure\n";
	my %options = (measure =>'WordNet::Similarity::hso',
					wordnet=>$qd);
	 my $newWord = $word;
  my @newSentence = @sentence;
  my $wordToSet = WordNet::SenseRelate::WordToSet->new(%options);
  my $res = $wordToSet->disambiguate(target => $newWord,
                                     context => [@newSentence]);
	my $best_score = -100;
  my $best = "";
  foreach my $key (keys %$res) {
    next unless defined $res->{$key};
    if ($res->{$key} > $best_score) {
        $best_score = $res->{$key};
        $best = $key;
    }
  }
    if (($best eq "") == 1) {
    $best = $newWord."#n#1";
  }

  # let's call WordNet::QueryData to get the gloss of the most
  # related sense of the target to the set 

  print $fh "$best : ", join(", ", $qd->querySense($best, "glos")), "\n";
}



