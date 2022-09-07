# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'
use Benchmark ':all';
#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 125;
BEGIN { use_ok('Algorithm::LCS::XS') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use Algorithm::Diff;
use POSIX 'dup2';
dup2 fileno(STDERR), fileno(STDOUT);

my @a = (qw/a b d c e f/) x 10;
my @b = (qw/a c d b e f/) x 10;

$|++;


my $alg = Algorithm::LCS::XS->new;
my @lcs = $alg->LCS(\@a, \@b);

ok @lcs == 40;
ok $a[$lcs[$_][0]] eq $b[$lcs[$_][1]] for 0..39;

my $cb = $alg->callback(@b);

my @lcs2 = $cb->(\@a);
ok @lcs2 == 40;
ok $a[$lcs2[$_][0]] eq $b[$lcs2[$_][1]] for 0..39;

my $non_xs = sub { Algorithm::Diff::LCSidx(\@a, \@b) };
my $my_xs_lcs = sub { $alg->LCS(\@a, \@b) };
my $my_xs_cb = sub { $cb->(\@a) };

my ($l, $r) = $non_xs->();
ok @$l == @$r;
ok @$l == 40;
ok $a[$l[$_]] eq $b[$r[$_]] for 0..39;

use LCS::BV;
my $obj = LCS::BV->new;
my $positions = $obj->prepare(\@a);

my $bv_llcs = sub { $obj->LLCS_prepared($positions, \@b) };


use LCS::XS;

my $alg2 = LCS::XS->new;
my $lcs_xs = sub { $alg2->LCS(\@a, \@b) };

cmpthese 100_000 => { non_xs => $non_xs, my_xs_lcs => $my_xs_lcs, my_xs_cb => $my_xs_cb, bv_llcs => $bv_llcs, lcs_xs => $lcs_xs };
