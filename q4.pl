use utf8;
use 5.12.0;
use Encode;
use JSON::XS 'decode_json', 'encode_json';
use File::Slurp 'read_file';
binmode STDOUT, ':utf8';

my (%variants_id, %variants_ch);
my $csld = decode_json(read_file('dict-csld.json', {binmode => ':mmap'}));

for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        next unless $hetero->{id} =~ /^4/;
        for my $def (@{ $hetero->{definitions} }) {
            next unless $def->{def} =~ /「(.+)」的異體字/;
            $variants_ch{$entry->{title}} = $1;
            $variants_id{$entry->{title}} = $hetero->{id};
        }
    }
}
my $re_var = '(' . join('|', keys %variants_ch) . ')';

#1. 哪些字詞的釋義行文用字誤用「異體字」（流水序4開頭）？
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        next if $hetero->{id} =~ /^4/;
        for my $def (@{ $hetero->{definitions} }) {
            my $text = $def->{def};
            next unless $text =~ s/$re_var/<$1|$variants_ch{$1}>/go;
            say "$hetero->{id}\t$entry->{title}\t$variants_id{$1}\t$text";
        }
    }
}

Q2:
#2. 義項序是否正確？

open my $fh, '<:mmap', '兩岸常用詞典2013.csv';
require Text::CSV_XS;
my $csv = Text::CSV_XS->new ({ binary => 1 });
<$fh>;
my @solos;
while (my $row = $csv->getline ($fh)) {
    my (undef, undef, undef, $id, $title, undef, undef, undef, undef, undef, undef, undef, undef, @defs) = @$row;
    @defs = grep { length } @defs;
#(1) 哪些字詞的義項序有重號或跳號？
    if (@defs > 1) {
        my $ord = 1;
        for my $def (@defs) {
            next unless $def =~ /([1-9]\d*)\.(?![56])/;
            say "$id\t$title\t$ord\t$1" unless $def =~ /$ord\.(?![56])/;
            $ord++;
        }
    }
    else {
#(2) 哪些字詞僅有一個義項卻誤填了義項序？
        push @solos, "$id\t$title\t@defs" if $defs[0] =~ /^\d+\./;
    }
}
say $_ for @solos;


Q3:
use Regexp::Common qw /balanced/;
#3. 成組符號是否有缺漏？
#　　EX. 「」、『』、[]、〈〉、《》？
my @opener = qw(（ 「 『 [ 〈 《);
my @closer = qw(） 」 』 ] 〉 》);

my $re = $RE{balanced}
    {-begin => join '|', @opener}
    {-end   => join '|', @closer};
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        for my $def (@{ $hetero->{definitions} }) {
            my $text = $def->{def};
            for my $idx (0..$#opener) {
                my $opener = $opener[$idx];
                my $closer = $closer[$idx];
                if ("$opener$text$closer" !~ /^$re$/o) {
                    say "$hetero->{id}\t$entry->{title}\t$opener$closer\t$text";
                }
            }
        }
    }
}
