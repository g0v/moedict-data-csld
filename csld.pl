use utf8;
use JSON::XS;
# 字詞流水序	正體字形	簡化字形	臺／陸特有詞	臺／陸特有音	臺灣音讀	臺灣漢拼	大陸音讀	大陸漢拼	音序	釋義１	釋義２	釋義３	釋義４	釋義５	釋義６	釋義７	釋義８	釋義９	釋義１０	釋義１１	釋義１２	釋義１３	釋義１４	釋義１５	釋義１６	釋義１７	釋義１８	釋義１９	釋義２０	釋義２１	釋義２２	釋義２３	釋義２４	釋義２５	釋義２６	釋義２７	釋義２８	釋義２９	釋義３０
# 字詞流水序      正體字形        簡化字形        音序    臺／陸特有詞    臺／陸特有音 臺灣音讀        臺灣漢拼        大陸音讀        大陸漢拼        釋義１  釋義２  釋義３  釋 義４  釋義５  釋義６  釋義７  釋義８  釋義９  釋義１０        釋義１１        釋義１２ 釋義１３        釋義１４        釋義１５        釋義１６        釋義１７        釋義１８ 釋義１９        釋義２０        釋義２１        釋義２２        釋義２３        釋義２ ４        釋義２５        釋義２６        釋義２７        釋義２８        釋義２９        釋義 ３０
open my $fh, '<:utf8', '兩岸常用詞典.tsv';
binmode STDERR, ':utf8';
binmode STDOUT, ':raw';
<$fh>;
my %heteronyms;
my %alt;
while (<$fh>) {
    my ($id, $title) = split /\t/, $_;
    s/[〜～]/$title/g;
    s/○○頁//g;
    s/""/"/g;
    s/>\s*</></g;
    s/\r//g;
    s/★/陸\x{20DD}/g;
    s/▲/臺\x{20DD}/g;
    my (undef, undef, $title_cn, $seq_sound, $spec_word, $spec_sound, $bpmf, $pinyin, $bpmf_cn, $pinyin_cn, @defs) = split /\t/, $_;
    $bpmf =~ s/丨/ㄧ/g;
    $bpmf_cn =~ s/丨/ㄧ/g;
    $bpmf .= "<br>陸\x{20DD}$bpmf_cn" unless !$bpmf_cn or $bpmf eq $bpmf_cn;
    $pinyin .= "<br>陸\x{20DD}$pinyin_cn" unless !$pinyin_cn or $pinyin eq $pinyin_cn;
    undef $title_cn if $title_cn eq $title;
    $alt{$title} = $title_cn if $title_cn;
    push @{ $heteronyms{$title} }, {
                pinyin => $pinyin,
                bopomofo => $bpmf,
                definitions => [ map {
                        my %entry;
                        s/^\d+\.\s*//;
                        s/^\s*"+\s*//g;
                        s/\s*"+\s*$//g;
                        if (s/[［\[]例[］\]]([^。]+)。?//) {
                            $entry{example} = [ "例\x{20DD}" . join('、', map "「$_」", split /[｜︱│\∣]/, $1) . "。" ];
                        }
                        s/[\[［]([^\x00-\xff])[］\]]/$1\x{20DD}/g;
                        $entry{def} = $_;
                        \%entry
                    } grep {/\S/} @defs
                ]
    };
}
my $comma = '[';
for my $title (sort keys %heteronyms) {
    $json = JSON::XS::encode_json({ title => $title, heteronyms => $heteronyms{$title},
                ($alt{$title} ? (alt => $alt{$title}) : ()),
        });
    print "$comma$json\n";
    $comma = ',';
}
print "]";

