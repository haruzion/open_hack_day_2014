#!user/local/bin/perl
#形態素解析をして、名詞を抜き出すスクリプト

use MeCab;
#use Data::Dumper;

sub main{
    $file_path = $ARGV[0];
    my @result_ary = ();
    open (my $fh, "<", "$file_path");

    #読み込んだ文章をmecabで形態素解析する
    while (my $line = <$fh>){
        chomp $line;
        my @tmp_ary = &parse_text($line);
        foreach my $noun (@tmp_ary){
            push (@result_ary, $noun);
        }
    }
    #output
    print join(",",@result_ary)."\n";

    close($fh);
}

#parse
sub parse_text(){
    my $line = shift;
    my @result_ary = ();
    my $m = new MeCab::Tagger("-Ochasen"); #インスタンスの作成
    my $node = $m->parseToNode("$line"); #テキストを解析

    while ($node = $node->{next}){
        my $surface = $node->{surface};
        my $feature = $node->{feature};
        #表層形,品詞,品詞細分類1,品詞細分類2,品詞細分類3,活用形,活用型,原形,読み,発音
        my @feature_meta = split (/,/,$feature);
        #my $char_type = $node->{char_type};

        #名詞のみを抽出
        if ($feature_meta[0] eq "名詞") {
            push (@result_ary, $surface);
        }
    }
    return @result_ary;
}

main();

