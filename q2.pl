use utf8;
use 5.12.0;
use Encode;
use JSON::XS 'decode_json', 'encode_json';
use File::Slurp 'read_file';
binmode STDOUT, ':utf8';

my (%variants_id, %variants_ch);
my $csld = decode_json(read_file('dict-csld.json', {binmode => ':mmap'}));

goto Q2;
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

#1. 哪些詞目用字誤用「異體字」（流水序4開頭）？
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        next if $hetero->{id} =~ /^4/;
        my $title = $entry->{title};
        next unless $title =~ s/$re_var/<$variants_ch{$1}>/go;
        next unless $entry->{title} =~ s/$re_var/<$1>/go;
        say "$hetero->{id}\t$entry->{title}\t$variants_id{$1}\t$title";
    }
}

#2. 哪些應簡化而未簡化?

Q2:
open my $fh, '<:mmap', '通用漢字規範表2013.csv';
require Text::CSV_XS;
my $csv = Text::CSV_XS->new ({ binary => 1 });
<$fh>;
#序號,字表別,大陸規範字,臺灣標準字一,臺灣標準字二,臺灣標準字三,臺灣標準字四
my (%t2n, %t2n_partial, %t2n_eq);
while (my $row = $csv->getline ($fh)) {
    my (undef, undef, $cn, @tw) = @$row;
    for (@tw) {
        next unless $_;
        tr/ //d;
        if ($_ eq $cn) {
            $t2n_eq{Encode::decode_utf8($_)}++;
        }
        elsif (s/[()]//g) {
            $t2n_partial{Encode::decode_utf8($_)} = Encode::decode_utf8($cn);
        }
        else {
            $t2n{Encode::decode_utf8($_)} = Encode::decode_utf8($cn);
        }
    }
}

delete $t2n{'三'};
my $re_t2n = '(' . join('|', keys %t2n) . ')';
my $re_t2n_partial = '(' . join('|', keys %t2n_partial) . ')';
my $re_t2n_eq = '(?:' . join('|', keys %t2n_eq) . ')';

goto Q3;
for my $entry (@$csld) {
    my $tw = $entry->{title};
    for my $hetero (@{ $entry->{heteronyms} }) {
        next if $hetero->{alt};
        my $cn = $tw;
        $cn =~ s/$re_t2n/$t2n{$1}/g;
        last if $tw eq $cn;
        # Look more closely...
        my $tw2 = $tw;
        my $cn2 = $tw;
        $tw2 =~ s/$re_t2n_eq/X/g;
        $cn2 =~ s/$re_t2n_eq/X/g;
        $cn2 =~ s/$re_t2n/$t2n{$1}/g;
        say "$hetero->{id}\t$tw\t$cn\t$hetero->{definitions}[0]{def}"  if $tw2 ne $cn2;
        # my $cn = $entry->{alt};
    }
}
#3. 哪些不必簡化而簡化?
Q3:
for my $entry (@$csld) {
    my $tw = $entry->{title};
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $alt = $hetero->{alt} or next;
        my $cn = $tw;
        $cn =~ s/$re_t2n/$t2n{$1}/g;
        next if $cn ne $tw;
        next if $alt eq $cn;
        $cn =~ s/$re_t2n_partial/$t2n{$1}/g;
        next if $cn ne $tw;
        next if $alt eq $cn;
        next if $alt =~ /[(（+]/;
        say "$hetero->{id}\t$tw\t$alt\t$hetero->{definitions}[0]{def}";
    }
}
