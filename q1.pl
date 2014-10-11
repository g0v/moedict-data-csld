use utf8;
use 5.20.0;
use experimental qw[ autoderef ];
use JSON::XS 'decode_json';
use File::Slurp 'read_file';
binmode STDOUT, ':utf8';
my $STAGE = shift @ARGV or die "Usage: perl $0 <stage>\n";
my $index = decode_json(read_file('index.json'));
my $csld = decode_json(read_file('dict-csld.json'));

#1. 哪些詞目用字未收入字頭？
my %char = map { $_ => 1 } (10, split //, '，－0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz「」。（）"#$%\'()+-./:;<=>[]{}¥°±²³·×àáãèéìíñòóö÷ùúüĀāăēěīōūƧǎǐǒǔǚɑɡˇˊˋˍ˙αβγδζηπφКавдеклморстцьḥṃṇṣ–—―‖‘’•…‧′⃝℃℉ⅠⅡ→∕√∞∣∥∶≌≠≤≥⊙─┌┐║╳○✓　、〇〈〉《》『』【】〔〕あいうえおかがくけこさしじすせたっつてでとどなにのばぶぷべみもゃょらりれわんアカサタビワㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦㄧㄨㄩ︱︵﹏﹒﹙﹚﹝﹞﹪！％＊＋．／５６７：；＜＝＞？ＣＤＧＪＫＰＱＴＵＶＸＹ＿ａｂｅｆｉｍｎｏｐｒｕｗ｛｜｝｣ﾟ𠃍 ︳!?・㈠'.$/);

my %index = %char;
for my $title (@$index) {
    $char{$title} = 1 if length($title) == 1;
    $index{$title} = 1;
}
my %title_to_id;
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        $title_to_id{ $entry->{title} } = $hetero->{id};
    }
}
goto Q2 unless $STAGE == 1;
for my $title (@$index) {
    for (split //, $title) {
        next if exists $char{$_};
        print "$title_to_id{$title}\t$_\tU+@{[ sprintf '%04X', ord $_ ]}\t$title\n";
    }
}
exit;

Q2: #2. 哪些行文用字未收入字頭？
goto Q3 unless $STAGE == 2;

my %seen;
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        for my $def (@{ $hetero->{definitions} }) {
            for my $check ($def->{def}, @{ $def->{example} // [] }) {
                for (split //, $check) {
                    next if exists $char{$_};
                    next unless /\p{scx=Han}/;
                    my $ord = sprintf('%X', ord $_);
                    my $copy = $check;
                    $copy =~ s/陸\x{20DD}/★/g;
                    $copy =~ s/臺\x{20DD}/▲/g;
                    $copy =~ s/例\x{20DD}/[例]/g;
                    $copy =~ s/\n//g;
                    $copy =~ s/<[^>]*>//g;
                    $copy =~ s/$_/<$_>/g;
                    print "$hetero->{id}\t$_\tU+$ord\t$entry->{title}\t$copy\n";
                }
            }
        }
    }
}
exit;

Q3: #3. 成組詞目是否收錄？
my $KIND = ($STAGE == 3.1) ? '見' :
           ($STAGE == 3.2) ? '即' :
           ($STAGE == 3.3) ? '作' :
           ($STAGE == 3.4) ? '作' : die "Usage: perl $0 3.1\n";

my %also;
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        for my $def (@{ $hetero->{definitions} }) {
            while ($def->{def} =~ s/([^\p{IsPunct}]*)(作|見|即)([【「][^」】]+[】」](?:、[【「][^」】]+[】」])*)//) {
                my ($prec, $kind, $words) = ($1, $2, $3);
                next unless $kind eq $KIND;
                my $orig = "$prec$kind$words";
                next if $orig =~ /讀作/ or $orig =~ /寫作/;
                $orig =~ s/陸\x{20DD}/★/g;
                $orig =~ s/臺\x{20DD}/▲/g;
                $orig =~ s/例\x{20DD}/[例]/g;
                $orig =~ s/[∥║]//g;
                $orig =~ s/\n//g;
                $words =~ s/（[^）]*）//g;
                $words =~ s/[【「】」]//g;
                for my $word (split /、/, $words) {
                    if ($STAGE == 3.4) {
                        $also{$entry->{title}}{$word}++;
                        next;
                    }
                    next if exists $index{$word};
                    next unless $word =~ /\p{scx=Han}/;
                    my $copy = $orig;
                    $copy =~ s/$word/<$word>/g;
                    print "$hetero->{id}\t$word\t$entry->{title}\t$copy\n";
                }
            }
        }
    }
}
if ($STAGE == 3.4) {
    for my $k (sort keys %also) {
        for my $kk (sort keys $also{$k}) {
            print "$title_to_id{$k}\t$k\t$kk\n" unless $also{$kk}{$k} or $kk !~ /\p{scx=Han}/;
        }
    }
}
