use utf8;
use JSON::XS;
# 字詞流水序	正體字形	簡化字形	臺／陸特有詞	臺／陸特有音	臺灣音讀	臺灣漢拼	大陸音讀	大陸漢拼	音序	釋義１	釋義２	釋義３	釋義４	釋義５	釋義６	釋義７	釋義８	釋義９	釋義１０	釋義１１	釋義１２	釋義１３	釋義１４	釋義１５	釋義１６	釋義１７	釋義１８	釋義１９	釋義２０	釋義２１	釋義２２	釋義２３	釋義２４	釋義２５	釋義２６	釋義２７	釋義２８	釋義２９	釋義３０
open my $fh, '<:utf8', '兩岸常用詞典.tsv';
binmode STDERR, ':utf8';
binmode STDOUT, ':raw';
<$fh>;
my @dict;
while (<$fh>) {
    my ($id, $title, undef, $spec_word, $spec_sound, $bpmf, $pinyin, undef, undef, $seq, @defs) = split /\t/, $_;
    warn qq["$title"$/];
    push @dict, {
        title => $title,
        heteronyms => [ {
                pinyin => $pinyin,
                bopomofo => $bpmf,
                definitions => [
                    map { s/^\d+\.\s*//; +{ def => $_ } } grep {/\S/} @defs
                ]
            }]
    }
}
print JSON::XS::encode_json(\@dict);
