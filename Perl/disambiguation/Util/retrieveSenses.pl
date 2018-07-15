package retrieveSenses;
use strict;
use warnings;
use WordNet::QueryData;

#######################################
####Print every sense from a word######
#######################################

sub findSenses;

#Wordnet setup
my $wn = WordNet::QueryData->new(
    dir     => "D:/Perl/wn3.1.dict.tar/wn3.1.dict/dict",
    verbose => 0,
    noload  => 0
    );
my %tagHash = (
    "n"=>"NOUN(s)",
    "v"=>"VERB(s)",
    "a"=>"ADJECTIVE(s)",
    "r"=>"ADVERB(s)");
my @senseList = ();

while(){

    print "Write what word that you want Senses for:\n";
    my $input = <>;
    chomp($input);
    findSenses($input);
    print "\nContinue? y/n\n";
    my $choice = <>;
    chomp($choice);
    if($choice eq "n"){
        last;
    }
    elsif($choice eq "y"){}
}

# my @validForms = $wn->validForms($input);

sub findSenses{
    my $subInput = $_[0];
    print "################################";
    foreach my $x ($wn->querySense($subInput)) {
        my ($word,$tag) = split(/#/,$x);
        print "\n####$tagHash{$tag}####\n";
        push(@senseList, $wn->querySense($word));
        foreach my $y ($wn->querySense($x)) {
            print "$y : ", join("\n", $wn->querySense("$y","glos")), "\n";    
            print "--Synsets--\n";
            print join ", ", $wn->querySense($y,"syns"),"\n";
            print "---\n";
        }
    }
    if (scalar @senseList < 1) {
        # print "@validForms";

        my @val= $wn->validForms($subInput);
        my ($valid,$tag) = split(/#/,$val[0]);
        print @val,"\n";
        foreach my $x ($wn->querySense($valid)) {
            my ($word,$tag) = split(/#/,$x);
            print "\n-----$tagHash{$tag}-----\n";
            foreach my $y ($wn->querySense($x)) {
                print "$y : ", join("\n", $wn->querySense("$y","glos")), "\n";
                print "--Synsets--\n";
                print join ", ", $wn->querySense($y,"syns"),"\n";
                print "---\n";   
            }
        }
        print "################################\n";
    }
}

