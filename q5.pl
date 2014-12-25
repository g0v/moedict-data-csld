use utf8;
use 5.20.0;
use Encode;
use JSON::XS 'decode_json', 'encode_json';
use File::Slurp 'read_file';
use Set::SortedArray;
binmode STDOUT, ':utf8';
my $STAGE = shift @ARGV or die "Usage: perl $0 <stage>\n";

my $csld_titles = Set::SortedArray->new(
    map { s/[\[\],"\s]//gr } split(/\n/, read_file('index.json', {binmode => ':utf8'}))
);

#1. 本詞典與教育部《重編國語辭典修訂本》比對：
my $revised_titles = Set::SortedArray->new(
    map { s/[\[\],"]//gr } split(/\n/, read_file('../moedict-webkit/a/index.json', {binmode => ':utf8'}))
);

#本詞典多收那些字詞？
my $x = $csld_titles->asymmetric_difference($revised_titles);
goto Q2 unless $STAGE == 1;
say join $/, @{ $x->[0] };
exit;

Q2:
#本詞典未收那些字詞？
say join $/, grep { length == 1 } @{ $x->[1] };
say join $/, grep { length == 2 } @{ $x->[1] };
say join $/, grep { length > 2 } @{ $x->[1] };
