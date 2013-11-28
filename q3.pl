use utf8;
use 5.12.0;
use Encode;
use JSON::XS 'decode_json', 'encode_json';
use File::Slurp 'read_file';
binmode STDOUT, ':utf8';

my (%variants_id, %variants_ch);
my $csld = decode_json(read_file('dict-csld.json', {binmode => ':mmap'}));

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
        $sounds->{$bpmf} or say "$hetero->{id}\t$entry->{title}\t$bpmf";
    }
}

#(2) 哪些字詞的大陸音讀不同於《普通話異讀詞審音表》？

#2. 哪些詞素取音不符合字頭收音？

#3. 哪些字詞的注音符號與漢語拼音的音讀不一致？

#4. 哪些字詞的漢語拼音有誤？

#5. 音序是否正確？
#(1) 哪些多音字詞的音序有重號或跳號？
#(2) 哪些單音字詞誤填了音序？
