use strict;
use warnings;
use WordNet::QueryData;
use WordNet::Similarity::lesk;
use Lingua::EN::Tagger;
use List::Util qw(max);
use List::Util qw(first);
use Try::Tiny;
use Term::ProgressBar;

#This script has the ability to run similarity measures between verbs and Nouns.
sub retrieveSenses;
sub ManualDisambiguation;
sub prepareContext;



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

##########################################
#Enter the context for disambiguation#####
print "Write context : \n";
my $cont = lc <>;
chomp($cont);
$cont =~ s/[\$#@~!&*()\[\];.,:?^`\\\/]+//g;

#Tag Part of speech the context###########
my $posContext = lc $p->get_readable($cont);
##########################################

##########################################
#write the what you want to disambiguate##
print "write target Word: ";
my $targetWord = lc <>;
chomp($targetWord);
##########################################
my $newposTemp; 

if ($targetWord) {

    # my $posString = $p->add_tags($cont);

    # print $posString,"\n";

    # my %hashContext = prepareContext($cont);

    my @context = split / /, $cont;

    my @SenseList = ();

    #Find the targets Sense and put them into the senseList
    my ($posTemp) = ( $posContext =~ /($targetWord)\/([a-z])([a-z]*)/ )[1];

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
            }
            catch {
                warn "caught error: $_";
            };

            if ( scalar @SenseList > 0 ) {
                ManualDisambiguation;
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
                }
                @SenseList = retrieveSenses( $targetWord, $posTemp );
                ManualDisambiguation;
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
                ManualDisambiguation;
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
        if ( scalar @targetSenseList == 0 ) {

            # print "\n###\nNo senses for $subWord\n###\n";
        }
        else {
        # print "\nSenses for $subWord: ", join(", ", @targetSenseList), "\n";
        }
        return @targetSenseList;
    }

# The manual disambiguation method, has an algorithm that retrieves a hash of the target words senses and accompanying measures based on the context.
    sub ManualDisambiguation {
        my $newpostemp= "";
        if ( scalar @SenseList == 1 ) {
            print "Successful disambiguation! Correct sense: ",
                $SenseList[0], " : ",
                $wn->querySense( $SenseList[0], "glos" ), "\n";
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
                            @contSenses
                                = retrieveSenses( $word, $newpostemp );
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
                        my $target_Cont_measure
                            = $measure->getRelatedness( $targetSense,
                            $contSense );

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
                            @contSenses = retrieveSenses($vForm),;
                        }

                    }
                    if ( scalar @contSenses > 0 ) {

                        #the loop over the contextword' senses
                        foreach my $contSense (@contSenses) {
                            if ( $contSense eq $targetSense ) {
                                next;
                            }
                            my $target_Cont_measure
                                = $measure->getRelatedness( $targetSense,
                                $contSense );

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

        foreach my $y (
            sort { $valueHash{$a} <=> $valueHash{$b} }
            keys %valueHash
            )
        {
            print $y, " -- ", "value : ", $valueHash{$y}, "\n";
            print "########DEF########\n";
            print $wn->querySense( $y, "glos" ), "\n";
            print "###################\n";
        }
    }

}
