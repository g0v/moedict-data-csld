use utf8;
use 5.12.0;
use JSON::XS 'decode_json';
use File::Slurp 'read_file';
binmode STDOUT, ':utf8';

my $index = decode_json(read_file('index.json'));
#1. 哪些詞目用字未收入字頭？
my %char = map { $_ => 1 } (10, split //, '，－0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz「」。（）"#$%\'()+-./:;<=>[]{}¥°±²³·×àáãèéìíñòóö÷ùúüĀāăēěīōūƧǎǐǒǔǚɑɡˇˊˋˍ˙αβγδζηπφКавдеклморстцьḥṃṇṣ–—―‖‘’•…‧′⃝℃℉ⅠⅡ→∕√∞∣∥∶≌≠≤≥⊙─┌┐║╳○✓　、〇〈〉《》『』【】〔〕あいうえおかがくけこさしじすせたっつてでとどなにのばぶぷべみもゃょらりれわんアカサタビワㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦㄧㄨㄩ︱︵﹏﹒﹙﹚﹝﹞﹪！％＊＋．／５６７：；＜＝＞？ＣＤＧＪＫＰＱＴＵＶＸＹ＿ａｂｅｆｉｍｎｏｐｒｕｗ｛｜｝｣ﾟ𠃍 ︳!?・㈠'.$/);
my %index = %char;
for my $title (@$index) {
    $char{$title} = 1 if length($title) == 1;
    $index{$title} = 1;
}
goto Q2;
for my $title (@$index) {
    for (split //, $title) {
        next if exists $char{$_};
        print "$title\t$_\n";
    }
}

Q2: #2. 哪些行文用字未收入字頭？
my %seen;
my $csld = decode_json(read_file('dict-csld.json'));

goto Q3;
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        for my $def (@{ $hetero->{definitions} }) {
            for my $check ($def->{def}, @{ $def->{example} // [] }) {
                for (split //, $check) {
                    next if exists $char{$_};
                    my $ord = sprintf('%X', ord $_);
                    my $copy = $check;
                    $copy =~ s/陸\x{20DD}/★/g;
                    $copy =~ s/臺\x{20DD}/▲/g;
                    $copy =~ s/例\x{20DD}/[例]/g;
                    $copy =~ s/\n//g;
                    $copy =~ s/$_/<$_>/g;
                    print "$hetero->{id}\t$entry->{title}\t$_\tU+$ord\t$copy\n";
                }
            }
        }
    }
}

Q3: #3. 成組詞目是否收錄？
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        for my $def (@{ $hetero->{definitions} }) {
            while ($def->{def} =~ s/([^\p{IsPunct}]*)(作|見|即)([【「][^」】]+[】」](?:、[【「][^」】]+[】」])*)//) {
                my ($prec, $kind, $words) = ($1, $2, $3);
                next unless $kind eq '見';
                my $orig = "$prec$kind$words";
                next if $orig =~ /讀作/;
                $orig =~ s/陸\x{20DD}/★/g;
                $orig =~ s/臺\x{20DD}/▲/g;
                $orig =~ s/例\x{20DD}/[例]/g;
                $orig =~ s/[∥║]//g;
                $orig =~ s/\n//g;
                $words =~ s/（[^）]*）//g;
                $words =~ s/[【「】」]//g;
                for my $word (split /、/, $words) {
                    next if exists $index{$word};
                    my $copy = $orig;
                    $copy =~ s/$word/<$word>/g;
                    print "$hetero->{id}\t$word\t$entry->{title}\t$copy\n";
                }
            }
        }
    }
}
