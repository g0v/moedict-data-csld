use utf8;
use 5.14.0;
use Encode;
use JSON::XS 'decode_json', 'encode_json';
use File::Slurp 'read_file';
use Set::SortedArray;
binmode STDOUT, ':utf8';

my $csld_titles = Set::SortedArray->new(
    map { s/[\[\],"]//gr } split(/\n/, read_file('index.json', {binmode => ':utf8'}))
);

#1. 本詞典與「兩岸生活用語差異詞表」（約2000筆）比對：
{
    last;
    my @titles;
    open my $fh, '<:mmap', '兩岸三地生活差異詞語彙編-同名異實.csv';
    require Text::CSV_XS;
    my $csv = Text::CSV_XS->new ({ binary => 1 });
    <$fh>;
    while (my $row = $csv->getline($fh)) {
        push @titles, Encode::decode_utf8($row->[0]);
    }
    #本詞典未收那些字詞？
    my $diff_titles = Set::SortedArray->new(@titles);
    my $x = $csld_titles->asymmetric_difference($diff_titles);
    say join $/, @{ $x->[1] };
}
{
    my @titles;
    open my $fh, '<:mmap', '兩岸三地生活差異詞語彙編-同實異名.csv';
    require Text::CSV_XS;
    my $csv = Text::CSV_XS->new ({ binary => 1 });
    <$fh>;
    while (my $row = $csv->getline($fh)) {
        for my $idx (4..6) {
            my $title = $row->[$idx] or last;
            $title =~ s/-$//g;
            push @titles, Encode::decode_utf8($title);
        }
    }
    #本詞典未收那些字詞？
    my $diff_titles = Set::SortedArray->new(@titles);
    my $x = $csld_titles->asymmetric_difference($diff_titles);
    say join $/, @{ $x->[1] };
}

