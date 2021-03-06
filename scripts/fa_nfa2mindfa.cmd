@perl -Sx %0 %*
@goto :eof
#!perl


sub usage {

print <<EOM;

Usage: fa_nfa2mindfa [--alg=br|hg] [OPTIONS] < Nfa.txt > Dfa.txt

This utility builds minimal deterministic Rabin-Scott automaton from the Nfa.

  --alg=br - Brzozowski's minimization algorithm (used by default),
    program runs the following pipe:

    fa_nfa2revnfa OPTIONS | fa_nfa2dfa OPTIONS | \
    fa_nfa2revnfa OPTIONS | fa_nfa2dfa OPTIONS 

  --alg=hg - determinization plus Hopcroft-Gries minimization algorithm,
    program runs the following pipe:

    fa_nfa2dfa OPTIONS | fa_dfa2mindfa OPTIONS
EOM

}

$alg = "--alg=br";

while (0 < 1 + $#ARGV) {

    if("--help" eq $ARGV [0]) {

        usage ();
        exit (0);

    } elsif ($ARGV [0] =~ /^--alg=./ ) {

        $alg = $ARGV [0];

    } else {

        last;
    }

    shift @ARGV;
}

$options = join ' ', @ARGV;

if ("--alg=br" eq $alg) {

    $command = "| fa_nfa2revnfa $options | fa_nfa2dfa $options | fa_nfa2revnfa $options | fa_nfa2dfa $options " ;

} else {

    $command = "| fa_nfa2dfa $options | fa_fsm_renum --fsm-type=rs-dfa | fa_dfa2mindfa $options" ;
}

open OUTPUT, $command ;
local $SIG{PIPE} = sub { die "ERROR: Broken pipe at fa_nfa2mindfa" };

if (OUTPUT) {

    while(<STDIN>) {
        print OUTPUT $_ ;
    }
    close OUTPUT;

} else {

    print STDERR "ERROR: fatal in fa_nfa2mindfa";
    exit (1);
}
