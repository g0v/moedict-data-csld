use utf8;
use Text::CSV_XS;
use JSON::XS;

open my $ch, '<:utf8', '字頭部首筆畫.csv';
<$ch>;
my $csv_ch = Text::CSV_XS->new ({ binary => 1 });
my %CH;
while (my $row = $csv_ch->getline($ch)) {
#cnscode,educode,字頭,部首,部首代碼,部首外筆畫,總筆畫
    my (undef, undef, $ch, $rad, undef, $nrsc, $sc) = @$row;
    $CH{$ch} = { radical => $rad, non_radical_stroke_count => int $nrsc, stroke_count => int $sc };
}

# 字詞流水序      正體字形        簡化字形        音序    臺／陸特有詞    臺／陸特有音 臺灣音讀        臺灣漢拼        大陸音讀        大陸漢拼        釋義１  釋義２  釋義３  釋 義４  釋義５  釋義６  釋義７  釋義８  釋義９  釋義１０        釋義１１        釋義１２ 釋義１３        釋義１４        釋義１５        釋義１６        釋義１７        釋義１８ 釋義１９        釋義２０        釋義２１        釋義２２        釋義２３        釋義２ ４        釋義２５        釋義２６        釋義２７        釋義２８        釋義２９        釋義 ３０

# 稿件階段,稿件狀態,備注,字詞流水序,正體字形,簡化字形,音序,臺／陸特有詞,臺／陸特有音,臺灣音讀,臺灣漢拼,大陸音讀,大陸漢拼,釋義１,釋義２,釋義３,釋義４,釋義５,釋義６,釋義７,釋義８,釋義９,釋義１０,釋義１１,釋義１２,釋義１３,釋義１４,釋義１５,釋義１６,釋義１７,釋義１８,釋義１９,釋義２０,釋義２１,釋義２２,釋義２３,釋義２４,釋義２５,釋義２６,釋義２７,釋義２８,釋義２９,釋義３０
# 稿件版本,稿件階段,稿件狀態,備注,字詞流水序,正體字形,簡化字形,音序,臺／陸特有詞,臺／陸特有音,臺灣音讀,臺灣漢拼,大陸音讀,大陸漢拼,釋義１,釋義２,釋義３,釋義４,釋義５,釋義６,釋義７,釋義８,釋義９,釋義１０,釋義１１,釋義１２,釋義１３,釋義１４,釋義１５,釋義１６,釋義１７,釋義１８,釋義１９,釋義２０,釋義２１,釋義２２,釋義２３,釋義２４,釋義２５,釋義２６,釋義２７,釋義２８,釋義２９,釋義３０


open my $fh, '<:utf8', '兩岸詞典.csv';
binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';

<$fh>;
my %heteronyms;
my %alt;
my %seen;
my $csv = Text::CSV_XS->new ({ binary => 1 });
while (my $row = $csv->getline ($fh)) {
    my ($version, $phase, $state, $id, $title) = @$row;
# 稿件版本,稿件階段,稿件狀態,備注,字詞流水序, 正體字形,簡化字形,音序,臺／陸特有詞,臺／陸特有音,臺灣音讀,臺灣漢拼,大陸音讀,大陸漢拼,釋義１,釋義２,釋義３,釋義４,釋義５,釋義６,釋義７,釋義８,釋義９,釋義１０,釋義１１,釋義１２,釋義１３,釋義１４,釋義１５,釋義１６,釋義１７,釋義１８,釋義１９,釋義２０,釋義２１,釋義２２,釋義２３,釋義２４,釋義２５,釋義２６,釋義２７,釋義２８,釋義２９,釋義３０
    my (undef, undef, undef, undef, undef, $title_cn, $seq_sound, $spec_word, $spec_sound, $bpmf, $pinyin, $bpmf_cn, $pinyin_cn, @defs) = map {
    s/ɡ/g/g;
    s/[〜～]/$title/g;
    s/○○頁//g;
    s/""/"/g;
    s/>\s*</></g;
    s/\r//g;
    s/★/陸\x{20DD}/g;
    s/▲/臺\x{20DD}/g;
    $_; } @$row;
    $bpmf =~ s/丨/ㄧ/g;
    $bpmf_cn =~ s/丨/ㄧ/g;
    $spec_word =~ s/\x{20DD}/\x{20DF}/g if $spec_word;
    # TODO: <<詞條較長時陸音哪裡發音不同，需要視覺化>>
    if ($spec_sound) {
        $spec_sound =~ s/\x{20DD}/\x{20DF}/g;
        $bpmf = "$bpmf$bpmf_cn$spec_sound";
        $pinyin = "$pinyin$pinyin_cn$spec_sound";
    }
    else {
        $bpmf .= "<br>陸\x{20DD}$bpmf_cn" unless !$bpmf_cn or $bpmf eq $bpmf_cn;
        $pinyin .= "<br>陸\x{20DD}$pinyin_cn" unless !$pinyin_cn or $pinyin eq $pinyin_cn;
    }
    $seen{$title}++;
    undef $title_cn if $title_cn eq $title;
    $alt{$title} = $title_cn if $title_cn;

    push @{ $heteronyms{$title} }, {
        id => $id,
                pinyin => $pinyin,
                bopomofo => $bpmf,
                ($title_cn ? (alt => $alt{$title}) : ()),
                ($spec_word ? (specific_to => $spec_word) : ()),
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
    $json = JSON::XS->new->pretty(1)->canonical->encode({
        title => $title,
        heteronyms => $heteronyms{$title},
        %{$CH{$title} || {}},
    });
    $json =~ s/" : /":/g;
    print "$comma $json";
    $comma = ',';
}
print "]";

warn qq["$title"\n] for sort keys %title; 
