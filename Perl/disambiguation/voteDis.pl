use strict;
no warnings;
# # require "Util/AskForContext.pl";
# require 'AllWords_Disambiguation.pl';
# require 'Disambiguate.pl';
require 'TargetWord_Disambiguation.pl';
# require 'perlDisambiguate.pl';

# sub voting;
sub readFile;

# my ($context, $targetWord) = AskForContext->AskForContext;
my $fileName = 'D:/SKOLE/MASTER 2016/testing/100URL-target-context.txt';
my $writeFile = 'D:/SKOLE/MASTER 2016/testing/All_Words_100_report.txt';
readFile($fileName);
# voting;
# sub voting {
#     my $input;

#     while () {
#         TargetWord_Disambiguation->disambiguateTargetWord($context,$targetWord);
#         AllWords_Disambiguation->disambiguateAll($context,$targetWord);
#         Disambiguate->runDis($context,$targetWord);
#         perlDisambiguate->disambiguate($context,$targetWord);
#         print "What do you want to do?\n";
#         print "\"Y\" for try again\n";
#         print "\"N\" for Ending the program\n";
#         $input = <>;
#         chomp($input);
#         if($input eq 'N'){
#             last;
#         }
#         else{
#             ($context, $targetWord) = AskForContext->AskForContext;
#         }
#     }
# }
sub readFile {

    open(my $fh, '<:encoding(UTF-8)',$fileName)
    or die "Could not read file $fileName\n";
    my $returnString;
    while(my $row = <$fh>){
        my ($url,$target,$context) = split /\|/, $row;
        $returnString+= $row;
        print $row,"\n";
        print "URL= $url\nTarget: $target\nContext: $context\n";
        writeToFile(TargetWord_Disambiguation->disambiguateTargetWord($context,$target));
        chomp $row;
        # print "$row\n";
    }
}

sub writeToFile{
    my $result = @_;
    open (my $fh, '>', $writeFile);
    print $fh $result,"\n"; 
}
