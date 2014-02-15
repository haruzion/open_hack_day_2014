#!user/local/bin/perl
#形態素解析をして、名詞を抜き出すスクリプト

use MeCab;
#use utf8;
#use Data::Dumper;

sub main{
    $file_path = $ARGV[0];
    $recom_type = $ARGV[1];
    my %cnt_hash = ();
    my $values_num = 0;
    open (my $fh, "<", "$file_path");

    #読み込んだ文章をmecabで形態素解析する
    while (my $line = <$fh>){
        chomp $line;
        my @filter_ary = &filtering_text($line);

        &cnt_text(\@filter_ary,\%cnt_hash, \$values_num);
        
        #&output_text();
=pod
        foreach my $noun (@filter_ary){
            $values_num += 1;
            if (exists ($cnt_hash{$noun})){
                $cnt_hash{$noun} += 1;
            }else{
                $cnt_hash{$noun} = 1;
            }
        }
=cut
    }
    
    #output
    open (my $fh_out, ">","$file_path.out") or die ("can't open $file_path : $!");
    #print $fh_out join ("$_\t$cnt_hash{$_}\n",sort {$cnt_hash{$b} <=> $cnt_hash{$a}} keys (%cnt_hash));
    foreach my $key (sort {$cnt_hash{$b} <=> $cnt_hash{$a}} (keys (%cnt_hash))){
        if ($recom_type eq "rerank"){
            if ($cnt_hash{$key} <= 50){ #filtering noun 10 over.
            print $fh_out "$key\t".$cnt_hash{$key}/$values_num."\n";
            }
        }else{
            print $fh_out "$key\t".$cnt_hash{$key}/$values_num."\n";
        }
    }
    
    close ($fh_out);
    close($fh);
}

#
sub filtering_text(){
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
        if ($feature_meta[0] eq "名詞" || $feature_meta[0] eq "形容詞"  && $feature_meta[1] ne "サ変接続" && $feature_meta[2] ne "数" && $feature_meta[1] ne "非自立" && $feature_meta[1] ne "代名詞") {
            if ( $surface =~ /^[a-zA-Z0-9]/){
                #print "filtering $surface\n";
            }else{
                if (length ($surface) <= 6){
                    #print "filtering 2 $surface\n";
                }else{
                    push (@result_ary, "$surface");
                }
            }
        }
    }
    return @result_ary
}

sub cnt_text(){
    my $filter_ary = shift;
    my $cnt_hash = shift;
    my $values_num = shift;
    my @return_ary = ();

    foreach my $noun (@{$filter_ary}){
        $$values_num += 1;
        if (exists ($cnt_hash->{$noun})){
            $cnt_hash->{$noun} += 1;
        }else{
            $cnt_hash->{$noun} = 1;
        }
    }
    #push (@return_ary, $cnt_hash);
    #push (@return_ary, $values);
    #return @return_ary;
    return $values_num;
}


&main();

