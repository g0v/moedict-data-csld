use utf8;
use 5.14.0;
use Encode;
use JSON::XS 'decode_json', 'encode_json';
use File::Slurp 'read_file';
binmode STDOUT, ':utf8';

my (%variants_id, %variants_ch);
my $csld = decode_json(read_file('dict-csld.json', {binmode => ':mmap'}));

Q1:
my %sound;
for my $file (qw[ 國語一字多音審訂表1999.csv 國語一字多音審訂表2012.csv ]) {
    open my $fh, '<:utf8', $file; <$fh>;
    while (<$fh>) {
        chomp;
        my ($id, $ch, @bpmf) = grep length, split /,/;
        next unless length $ch == 1;
        s/丨/ㄧ/g for @bpmf;
        s/[\s　]//g for @bpmf;
        $sound{$ch}{$_}++ for @bpmf;
    }
}

#1. 字頭收音是否符合體例？
#(1) 哪些字詞的臺灣音讀不同於《國語一字多音審訂表》？

for my $entry (@$csld) {
    my $sounds = $sound{$entry->{title}} or next;
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $bpmf = $hetero->{bopomofo};
        $bpmf =~ s/<br>.*//;
        $bpmf =~ s/陸⃟//g;
        $bpmf =~ s/臺⃟//g;
        $bpmf =~ s/[臺陸]//g;
        $sounds->{$bpmf} or say "$hetero->{id}\t$entry->{title}\t$bpmf" =~ s/ㄧ/丨/gr;
    }
}

#(2) 哪些字詞的大陸音讀不同於《普通話異讀詞審音表》？
Q1_2:

my %pinyin;
# 序號,正體字,簡化字,音一,音二,音三,音四,音五,音六,統讀
open my $fh, '<:mmap', '普通話異讀詞審音表2013.csv';
require Text::CSV_XS;
my $csv = Text::CSV_XS->new ({ binary => 1 });
<$fh>;
while (my $row = $csv->getline($fh)) {
    my (undef, $ch, undef, @sounds) = @$row;
    Encode::_utf8_on($ch);
    pop @sounds;
    for my $py (@sounds) {
        last unless $py;
        Encode::_utf8_on($py);
        $pinyin{$ch}{$py}++;
    }
}

for my $entry (@$csld) {
    my $sounds = $pinyin{$entry->{title}} or next;
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $py = $hetero->{pinyin};
        next unless $py =~ /陸/;
        $py =~ s/陸//;
        $py =~ s/.*<br>//;
        $py =~ s/g/ɡ/g;
        $py = substr($py, 1) while ord substr($py, 0, 1) > 8000;
        $py = substr($py, 0, -1) while ord substr($py, -1) > 8000;
        next unless $py;
        $sounds->{$py} or say "$hetero->{id}\t$entry->{title}\t$py";
    }
}

#2. 哪些詞素取音不符合字頭收音？
Q2:

my %solo;
for my $entry (@$csld) {
    next unless length($entry->{title}) == 1;
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $bpmf = $hetero->{bopomofo};
        $bpmf =~ s/<br>.*//;
        $bpmf =~ s/陸⃟//g;
        $bpmf =~ s/臺⃟//g;
        $bpmf =~ s/[臺陸]//g;
        $bpmf =~ s/ㄧ/｜/g;
        $solo{$entry->{title}}{$bpmf}++;
    }
}

for my $entry (@$csld) {
    next unless length($entry->{title}) > 1;
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $bpmf = $hetero->{bopomofo};
        $bpmf =~ s/<br>.*//;
        $bpmf =~ s/陸⃟//g;
        $bpmf =~ s/臺⃟//g;
        $bpmf =~ s/[臺陸]//g;
        $bpmf =~ s/ㄧ/｜/g;
        my @bpmf = grep /\S/, split /[﹐,，\s]+/, $bpmf;
        my $title = $entry->{title} =~ s/[﹐，,]//gr;
        next if length $title != @bpmf and $title =~ /兒/; # 兒化韻
        next if length $title != @bpmf and !@bpmf;
        #say "$hetero->{id}\t$title\t$hetero->{bopomofo}" unless length $title == @bpmf;
        next unless length $title == @bpmf;
        for my $word (split //, $title) {
            say "$hetero->{id}\t$title\t$word\t$bpmf[0]" unless $solo{$word}{$bpmf[0]} or $bpmf[0] =~ /[•˙˙‧]/ or $word =~ /[一不]/;
            shift @bpmf;
        }
    }
}

#3. 哪些字詞的注音符號與漢語拼音的音讀不一致？
Q3:
use Bopomofo;
$Bopomofo::Map{ㄉㄚ} = 'da';
$Bopomofo::Map{ㄌㄩ} = 'lu';
$Bopomofo::Map{ㄊㄚ} = 'ta';
$Bopomofo::Map{ㄇㄜ} = 'me';
$Bopomofo::Map{ㄘㄡ} = 'cou';
$Bopomofo::Map{'ㄌㄧ'} = 'li';
$Bopomofo::Map{'ㄒㄧㄢ'} = 'xian';
$Bopomofo::Map{'ㄋㄡ'} = 'nou';
$Bopomofo::Map{'ㄧㄛ'} = 'yo';
$Bopomofo::Map{'ㄧㄞ'} = 'yai';
$Bopomofo::Map{'ㄋㄣ'} = 'nen';
$Bopomofo::Map{'ㄋㄜ'} = 'ne';
$Bopomofo::Map{'ㄎㄟ'} = 'kei';
$Bopomofo::Map{'ㄌㄩㄢ'} = 'lyuan';
$Bopomofo::Map{'ㄛ'} = 'o';
$Bopomofo::Map{'ㄓㄟˋ'} = 'zhei';
my $re = join '|', map quotemeta, sort { length $b <=> length $a } keys %Bopomofo::Map;

for my $entry (@$csld) {
    next unless length $entry->{title} > 1;
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $bpmf = $hetero->{bopomofo};
        next if $bpmf =~ /ㄦ/;
        $bpmf =~ s/<br>.*//;
        $bpmf =~ s/陸⃟//g;
        $bpmf =~ s/臺⃟//g;
        $bpmf =~ s/[臺陸]//g;
        $bpmf =~ s/｜/ㄧ/g;
        my $py = $hetero->{pinyin};
        $py =~ s/<br>.*//;
        $py =~ s/陸⃟//g;
        $py =~ s/臺⃟//g;
        $py =~ s/[臺陸]//g;
        $py =~ s/ɡ/g/g;
        $py =~ s/ɑ/a/g;
        use Unicode::Normalize;
        my $py_nfd = Encode::encode('ascii' => NFD($py));
        $py_nfd =~ s/[-–:',\s\?]//g;
        $bpmf =~ s/($re)/$Bopomofo::Map{$1}/go;
        my $bpmf_nfd = Encode::encode('ascii' => NFD($bpmf));
        $bpmf_nfd =~ s/[-–:',\s\?]//g;
        next if $py_nfd =~ /r$/;
        next unless $py_nfd;
        $bpmf = $hetero->{bopomofo};
        $bpmf =~ s/<br>.*//;
        $bpmf =~ s/陸⃟//g;
        $bpmf =~ s/臺⃟//g;
        $bpmf =~ s/[臺陸]//g;
        $bpmf =~ s/ㄧ/｜/g;
        my $py = $hetero->{pinyin};
        $py =~ s/<br>.*//;
        $py =~ s/陸⃟//g;
        $py =~ s/臺⃟//g;
        $py =~ s/[臺陸]//g;
        $py =~ s/g/ɡ/g;
        say "$hetero->{id}\t$entry->{title}\t$bpmf\t$py" unless $bpmf_nfd eq $py_nfd;
        #TODO: Tonal?
    }
}


Q3_2:
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $bpmf = $hetero->{bopomofo};
        $bpmf =~ s/<br>.*//;
        $bpmf =~ s/陸⃟//g;
        $bpmf =~ s/臺⃟//g;
        $bpmf =~ s/[臺陸]//g;
        my $py = $hetero->{pinyin};
        $py =~ s/<br>.*//;
        $py =~ s/陸⃟//g;
        $py =~ s/臺⃟//g;
        $py =~ s/[臺陸]//g;
        my $py_tones = NFD($py) =~ s/[^ ́ ̌ ̀]+/ /gr;
        $py_tones =~ s/ ́/2/g;
        $py_tones =~ s/ ̌/3/g;
        $py_tones =~ s/ ̀/4/g;
        $py_tones =~ s/ //g;
        my $bpmf_tones = NFD($bpmf) =~ s/[^ˊˇˋ]+/ /gr;
        $bpmf_tones =~ s/ˊ/2/g;
        $bpmf_tones =~ s/ˇ/3/g;
        $bpmf_tones =~ s/ˋ/4/g;
        $bpmf_tones =~ s/ //g;
        next unless $py_tones;
        next unless $bpmf_tones;
        next if $bpmf_tones eq $py_tones;
        $bpmf = $hetero->{bopomofo};
        $bpmf =~ s/<br>.*//;
        $bpmf =~ s/陸⃟//g;
        $bpmf =~ s/臺⃟//g;
        $bpmf =~ s/[臺陸]//g;
        $bpmf =~ s/ㄧ/｜/g;
        my $py = $hetero->{pinyin};
        $py =~ s/<br>.*//;
        $py =~ s/陸⃟//g;
        $py =~ s/臺⃟//g;
        $py =~ s/[臺陸]//g;
        $py =~ s/g/ɡ/g;
        say "$hetero->{id}\t$entry->{title}\t$bpmf\t$py";
    }
}
exit;

#4. 哪些字詞的漢語拼音有誤？
Q4:
for my $entry (@$csld) {
    for my $hetero (@{ $entry->{heteronyms} }) {
        my $py = $hetero->{pinyin};
        $py =~ s/<br>.*//;
        $py =~ s/陸⃟//g;
        $py =~ s/臺⃟//g;
        $py =~ s/[臺陸]//g;
        my $shown = $py;
        $py =~ s/ɡ/g/g;
        $py =~ s/ɑ/a/g;
        $py =~ s/[-–－a-z:’',，\sāǎáàēěéèóōòǒūúùìíǐīǔǘǚǜü]//g;
        $shown =~ s/g/ɡ/g;
        say "$hetero->{id}\t$entry->{title}\t$shown\t$py" if $py;
    }
}

#5. 音序是否正確？
Q5:
open my $fh, '<:mmap', '兩岸常用詞典2013.csv';
require Text::CSV_XS;
my $csv = Text::CSV_XS->new ({ binary => 1 });
<$fh>;
#(1) 哪些多音字詞的音序有重號或跳號？
my $cur = 1;
my $prev_title = '';
my (%dup, %seq, %exp);
while (my $row = $csv->getline ($fh)) {
    my (undef, undef, undef, $id, $title, undef, $seq_sound) = @$row;
    $seq_sound =~ s/\.$//;
    if ($seq_sound) {
        $cur = 1 unless $title eq $prev_title;
        unless ($seq_sound == $cur) {
            $dup{$title} .= Encode::decode_utf8("$id\t$title\t$seq_sound\t$cur");
            push @{ $seq{$title} }, $seq_sound;
            push @{ $exp{$title} }, $cur;
        }
        $cur++;
    }
    else {
        $cur = 1;
    }
    $prev_title = $title;
}

for my $title (sort keys %dup) {
    next if "@{[ sort @{ $seq{$title} } ]}" eq "@{[ sort @{ $exp{$title} } ]}";
    say $dup{$title};
}

Q5_2:
#(2) 哪些單音字詞誤填了音序？
open $fh, '<:mmap', '兩岸常用詞典2013.csv';
require Text::CSV_XS;
my $csv = Text::CSV_XS->new ({ binary => 1 });
<$fh>;
my (%seen, %count);
while (my $row = $csv->getline ($fh)) {
    my (undef, undef, undef, $id, $title, undef, $seq_sound) = @$row;
    if ($seq_sound) {
        $seen{$title} .= Encode::decode_utf8("$id\t$title\t$seq_sound");
        $count{$title}++;
    }
}

for my $title (sort keys %seen) {
    say $seen{$title} if $count{$title} == 1 and $seen{$title} =~ /1$/;
}
