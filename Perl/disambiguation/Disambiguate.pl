package Disambiguate;
use strict;
use warnings;
use WordNet::QueryData;
use WordNet::Similarity::lesk;
use Lingua::EN::Tagger;
use List::Util qw(max);
use List::Util qw(first);
use Try::Tiny;
use Term::ProgressBar;
# use Path::Class;
# require "Util/AskForContext.pl";

#This script has the ability to run similarity measures between verbs and Nouns.
sub readFile;
sub writeToFile;
sub runDis;
sub retrieveSenses;
sub ManualDisambiguation;
sub prepareContext;

my $fileName = 'D:/SKOLE/MASTER 2016/testing/Testing database/100URL-target-context.txt';
my $writeFile = 'Perl_Manual_DisambiguateV2_100_ReportTop3.txt';

my $wn = WordNet::QueryData->new(
    dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
    verbose => 0,
    noload  => 0
    );

my $measure = WordNet::Similarity::lesk->new($wn);

my $p = new Lingua::EN::Tagger;

my %tagHash = (
    "n" => "NOUN(s)",
    "v" => "VERB(s)",
    "a" => "ADJECTIVE(s)",
    "r" => "ADVERB(s)"
    );
my @sortedHashkey;
my $newposTemp; 
my @SenseList;
my $posContext;
my $WriteString = "";

##########################################
#Enter the context for disambiguation#####
# my ($cont,$targetWord) = AskForContext->AskForContext;
# $posContext = lc $p->get_readable($cont);
# ##########################################
# runDis($cont,$targetWord);
# writeToFile("hello\n");
readFile();
print "$WriteString";
writeToFile($WriteString);
sub readFile {
    open(my $fh, '<:encoding(UTF-8)',$fileName)
    or die "Could not read file $fileName\n";
    while(my $row = <$fh>){
        my ($url,$target,$context) = split /\|/, $row;
        print "URL= $url\nTarget: $target\nContext: $context\n";
        # writeToFile($target);
        # $WriteString .= "$url\n";
        runDis($context,$target);
        # $returnString +="\n";
        # print $row,"\n";
        # print $returnString,"\n","#######\n";
        # writeToFile($returnString);
        chomp $row;

        # print "$row\n";
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

sub runDis {
    my ($cont, $targetWord) = @_;

    $cont =~ s/[\$#@~\-!&*()\[\];.,:?^`\\\/ ]+/ /g;
    my $posContext = lc $p->get_readable($cont);

    print "posContext: $posContext\n";

    if ($targetWord) {

        my @context = split / /, $cont;
        my %hashPosContext;
        my ($target,$posTemp,$rest) = ( $posContext =~ /($targetWord)\/([a-z])([a-z]*)/ );
        print "$posTemp\n";
        @SenseList = ();
        if ($posTemp) {}
        else{
            %hashPosContext = prepareContext($cont);
            foreach my $x (keys %hashPosContext) {
                if ($targetWord eq $x) {
                    $posTemp = %hashPosContext{$x};
                    print "$x", %hashPosContext{$x},"\n";
                }
            }
            
        }


        if ($posTemp) {

        #v==verb
        #a(j)==adjective
        #r==adverb
        #n==noun
        if (   "$posTemp" eq "v"
            || "$posTemp" eq "j"
            || "$posTemp" eq "r"
            || "$posTemp" eq "n" )
        {
            if ( $posTemp eq 'j' ) {

#Because in this wordnet module, the POS tag jj is equivalent to an adjective which is tagged as #a here.
$posTemp = 'a';
}

try {
    @SenseList = retrieveSenses( $targetWord, $posTemp );
    if (scalar @SenseList > 0) {}
    else{@SenseList = retrieveSenses($targetWord);}

}
catch {
    warn "caught error: $_";
};

if ( scalar @SenseList > 0 ) {
    ManualDisambiguation($posContext,\@SenseList);
}
else {
#Retrieving the valid form of the word so the algorithm can succesfully find it in the querysense method(sub).
my @validForms = $wn->validForms($targetWord);
foreach my $valid (@validForms) {
    my ( $x, $y ) = split /#/, $valid;
    if ( $y eq $posTemp ) {
        $targetWord = $x;
        last;
    }
    else{$targetWord = $x;}
}
@SenseList = retrieveSenses( $targetWord, $posTemp );
ManualDisambiguation($posContext,\@SenseList);
}

}
else {
    @SenseList = retrieveSenses($targetWord);
    if ( scalar @SenseList == 1 ) {
        print "Successful disambiguation! Correct sense: ",
        $SenseList[0], " : ",
        $wn->querySense( $SenseList[0], "glos" ), "\n";
    }
    else {
        ManualDisambiguation($posContext,\@SenseList);
    }
}
}
}
}

#returns a hash list where the key is the valid form of the context word, and the value is the pos tag (v,a,r, or n)
sub prepareContext {
    my ($prepCont) = @_;
    my $posContext = $p->get_readable($prepCont);

        # print "$posContext\n";
        my %hashCont = ();
        foreach my $x ( split / /, $posContext ) {

            # print "$x\n";
            my ( $w, $t ) = split /\//, $x;
            my ($newposTemp) = lc substr $t, 0, 1;

            # print "*** new pos Temp $newposTemp \n";
            my @contWordForms = $wn->validForms($w);
            foreach my $contWord (@contWordForms) {
                my ( $vForm, $vTag ) = split /#/, $contWord;
                if ($vTag eq "a") {
                    $vTag = 'j';
                }
                if ( $vTag eq $newposTemp ) {
                    $hashCont{$vForm} = $vTag;
                }
            }
        }
        return %hashCont;
    }

#Method for getting all of the available senses for a word and if passed, a POS tag.
sub retrieveSenses {
    my ( $subWord, $senseTag ) = @_;
    my @posList = ();
    if ($senseTag) {
        @posList = ($senseTag);
    }
    else {
        @posList = keys %tagHash;
    }
    my @targetSenseList = ();
    foreach my $tag (@posList) {
        my @tempList = $wn->querySense( $subWord . "#" . $tag );
        if ( scalar @tempList > 0 ) {
            push( @targetSenseList, @tempList );
        }
    }
    if (scalar @targetSenseList == 0) {
        my @WordForms = $wn->validForms($subWord);
        foreach my $x (@WordForms) {
            my ($w,$t) = split /#/, $x;
            if ($t eq $senseTag) {
                my @tempList = $wn->querySense($x);
                push(@targetSenseList,@tempList);
            }
        }
    }
    return @targetSenseList;
}




# The manual disambiguation method, has an algorithm that retrieves a hash of the target words senses and accompanying measures based on the context.
sub ManualDisambiguation {
    my ($posContext,$SenseL) = @_;

    my @SenseList = @{$SenseL};
    my $newpostemp = "";
    my $topValue = "";
    if ( scalar @SenseList == 1 ) {
        print "Successful disambiguation! Correct sense: ",
        $SenseList[0], " : ",
        $wn->querySense( $SenseList[0], "glos" ), "\n";
        $WriteString.=$SenseList[0]."\n";
        return;
    }
    my %valueHash = ();

    #Iterating through each of the senses of the targetWord
    my $progress_bar     = Term::ProgressBar->new( scalar @SenseList );
    my $progress_counter = 0;
    foreach my $targetSense (@SenseList) {

        $valueHash{$targetSense} = 0;

            #Pass through context by words
            foreach my $contextKey ( split / /, $posContext ) {

                my %contSenseHash = ();

                #The word and the POS tag
                my ( $word, $wTag ) = split /\//, $contextKey;
                $newposTemp = lc substr $wTag, 0, 1;

                my @contSenses = ();
                if ($newpostemp) {
                    foreach my $validTag ( keys %tagHash ) {
                        if ( $validTag eq $newpostemp ) {
                            @contSenses = retrieveSenses($word,$newpostemp);
                            last;
                        }
                    }
                }
                if ( scalar @contSenses == 0 ) {
                    @contSenses = retrieveSenses($word);
                }

                #If there are available senses, they will be measured against the target sense.
                if ( scalar @contSenses > 0 ) {

                    #the loop over the contextword' senses
                    foreach my $contSense (@contSenses) {
                        if ( $contSense eq $targetSense ) {
                            next;
                        }
                        my $target_Cont_measure = $measure->getRelatedness( $targetSense, $contSense );
                        $contSenseHash{$contSense} = $target_Cont_measure;
                        $valueHash{$targetSense} += $target_Cont_measure;
                    }
                }

                #Try again with valid forms
                else {
                    my @contWordForms = $wn->validForms($word);

                    foreach my $contWord (@contWordForms) {
                        my ($newposTemp) = lc substr $wTag, 0, 1;
                        my ( $vForm, $vTag ) = split /#/, $contWord;
                        if ( $vTag eq $newposTemp ) {
                            @contSenses = retrieveSenses( $vForm, $vTag );
                            last;
                        }
                        else {
                            @contSenses = retrieveSenses($vForm);
                        }
                    }
                    if ( scalar @contSenses > 0 ) {

                        #the loop over the contextword' senses
                        foreach my $contSense (@contSenses) {
                            if ( $contSense eq $targetSense ) {
                                next;
                            }
                            my $target_Cont_measure = $measure->getRelatedness( $targetSense,$contSense );
                            $contSenseHash{$contSense} = $target_Cont_measure;
                            $valueHash{$targetSense} += $target_Cont_measure;
                        }
                    }
                }
            }
            $progress_counter++;
            $progress_bar->update($progress_counter);
        }
        print "\n";

        
        print "Results\n\n";
        print "\n\n";
        my $counter = 0;
        foreach my $y (
            sort { $valueHash{$b} <=> $valueHash{$a} }
            keys %valueHash
            )
        {
            print $y, " -- ", "value : ", $valueHash{$y}, "\n";
            # print "########DEF########\n";
            # print $wn->querySense( $y, "glos" ), "\n---\n";
            # print "Synset: ", join(", ", $wn->querySense($y, "syns")), "\n";
            # print "###################\n";
            if ($counter < 3 && scalar (keys %valueHash) >=3) {
                print "$y\n";
                $WriteString.="$y\n";
            }
            elsif(scalar (keys %valueHash) <=3){
                print "$y\n";
                $WriteString.="$y\n";
                
            }
            $counter+=1;
            print "counter = $counter\n";
        }
        # print "Results\n###\nDisambiguation: ";
       # my %sortedHash =  (sort { $valueHash{$a} <=> $valueHash{$b} } %valueHash);
        # $topValue = (keys %sortedHash)[-1];
        # $WriteString .= "$topValue\n";
       #  print $topValue,"\n";
        # print $topValue,'\n';
        # print $wn->querySense($topValue);
    }
    