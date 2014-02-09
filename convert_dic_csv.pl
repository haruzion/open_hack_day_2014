#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use encoding "utf-8";

my $FILE_PATH = $ARGV[0]; #file path
my $ORG_FILE = "jawiki-latest-all-titles-in-ns0";
my $WIKI_FILE = "wikipedia.test.csv";

open (my $in, "<", "$FILE_PATH/$ORG_FILE"); #input wikipedia file
open (my $out, ">", "$WIKI_FILE"); #output convert csv wikipedia file
binmode $out, ":utf8"; #output defined utf8


=pod
while (my $line = <$in>){
    my $max_return;
    chomp $line;
    print "$line\n";
    #必要無い単語は飛ばす
    next if $line =~ /^\./;
    next if $line =~ /(曖昧さの回避)/;
    next if $line =~ /^[0-9]{1,100}$/;
    next if $line =~ /[0-9]{4}./;
    
    if (length($line) > 3 ){
        $max_return = max(-36000,-400 * (length($line)));
        print $out "$line,0,0,$max_return,名詞,固有名詞,*,*,*,*,$line,*,*,wikipedia_word,\n";
    }
}
=cut

for(<$in>) {
  chomp($_);
  print $_."\n";

  ## いらない単語をとばす
  next if $_ =~ /^\./;
  next if $_ =~ /(曖昧さの回避)/;
  next if $_ =~ /^[0-9]{1,100}$/;
  next if $_ =~ /[0-9]{4}./;
  
  
  if (length($_) > 3) {
    print $out "$_,0,0,".max(-36000,-400 * (length^1.5)).",名詞,固有名詞,*,*,*,*,$_,*,*,wikipedia_word,\n";
  }
}

close($out);
close($in);


sub max{
    my ($comp, $val) = @_;
    my $max = $comp;
    if ($comp <= $val) {
        $max = $val;
    }
    return int($max);
}


