package AskForContext;

use strict;
use warnings;

#########################
#script for retrieving context and Target word
#Returns two two variables
##########################


sub AskForContext;


sub AskForContext{
    print "Write Context\n";
    my $context = lc <>;
    chomp($context);
    $context =~ s/[\$#@~!&*()\[\];.,:?^`\\\/ ]+/ /g;

    print "Write Target Word\n";
    my $targetWord = lc <>;
    chomp($targetWord);

    if (($context || $targetWord) ne defined) {
          ##################
          print "Context: $context\nTarget Word: $targetWord\n";
    ##################
    return($context,$targetWord);
}
else{
    AskForContext;
}

}
1;