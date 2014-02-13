#!user/local/bin/perl
#形態素解析をして、名詞を抜き出すスクリプト

use MeCab;
#use utf-8;
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
    open (my $fh_out, ">","$file_path.out");
    print $fh_out join("\n",@result_ary);
    close ($fh_out);

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
        #my $char_type = $node->{char_type};
        ##表層形,品詞,品詞細分類1,品詞細分類2,品詞細分類3,活用形,活用型,原形,読み,発音##
        my @feature_meta = split (/,/,$feature);

        #名詞のみを抽出
        if ($feature_meta[0] eq "名詞" && $feature_meta[1] ne "サ変接続" && $feature_meta[2] ne "数" && $feature_meta[1] ne "非自立" && $feature_meta[1] ne "代名詞") {
            if ( $surface =~ /^[a-zA-Z0-9]/){
                print "filtering $surface\n";
            }else{
                if (length ($surface) <= 3){
                    print "filtering 2 $surface\n";
                }else{
                    push (@result_ary, "$surface\t$feature");
                }
            }
        }
    }
    return @result_ary;
}

main();

