
use strict;
use warnings;
use WordNet::SenseRelate::TargetWord;
use WordNet::SenseRelate::Word;

sub disambiguateTargetWord;
sub readFile;
sub writeToFile;

my $fileName = 'D:/SKOLE/MASTER 2016/testing/100URL-target-context.txt';
# my $writeFile = 'D:/SKOLE/MASTER 2016/testing/All_Words_100_report.txt';
my $returnString ="";

  my %wsd_options = (preprocess => [],
   preprocessconfig => [],
   context => 'WordNet::SenseRelate::Context::NearestWords',
   contextconfig => {(windowsize => 5,
     contextpos => 'n')},
   algorithm => 'WordNet::SenseRelate::Algorithm::Global',
   algorithmconfig => {(measure => 'WordNet::Similarity::res')});

  # Initialize the object
  my ($wsd,$error) = WordNet::SenseRelate::TargetWord->new(\%wsd_options, 0);

readFile();
print"$returnString";
writeToFile($returnString);


############
#DISAMBIGUATION METHOD
#Uses the SenseRelate::TargetWord module.
#Note, this is the test version, runs the test set collected the testing phase
############ 
sub disambiguateTargetWord {

  my ($context, $targetWord) = @_;
  chomp($context);
  chomp($targetWord);
  $context =~ s/[\$#@~!&*()\[\];.,:?^`\\\/]+//g;
  print "$targetWord    $context\n";


    my $hashRef = {};    # Creates a reference to an empty hash.
    # $hashRef->{words}       = [];    # Value is an empty array ref.
    # $hashRef->{wordobjects} = [];    # Value is an empty array ref.
    # $hashRef->{target}      = 0;

    my @splitContArray = split / /, $context;

    foreach my $theword (@splitContArray)
    {
      print "$theword\n";
      my $wordobj = WordNet::SenseRelate::Word->new($theword);
      push(@{$hashRef->{wordobjects}}, $wordobj);
      push(@{$hashRef->{words}}, $theword);
    }
    my ($targetIndex)= grep { $splitContArray[$_] eq $targetWord } 0..$#splitContArray;
    print $targetIndex,"\n";

    $hashRef->{target} = $targetIndex;
    # $hashRef->{id} = "Instance1";

    my ($sense,$error) = $wsd->disambiguate($hashRef);
        # ($sense, $error) = $wsd->disambiguate($hashRef);


        # print "\n-----------------------------\n$sense: ", $wn->querySense($sense,"glos"),"\n-----------------------------\n";
        # print "Synsets: ", join(", ", $wn->querySense($sense,"syns")),"\n-----------------------------\n";
        print "$sense\n";
        $returnString .="Result\n";
        $returnString .="$sense";
        $returnString .="\n";
        # return $sense;
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
        disambiguateTargetWord($context,$target);
        # print "$row\n";
      }
      close $fh;
    }

    sub writeToFile{
      my ($result) = @_;
      print "$result";
      open (my $fr, '>', "TargetWord_100_test_disambiguation.txt");
      print $fr $result;
      close $fr; 
    }