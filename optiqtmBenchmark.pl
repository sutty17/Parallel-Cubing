use Time::HiRes;
use IPC::Open2;

$version = "TimingMod";
$scrambles = "Benchmark1";
$readFromFile = 0;

if(@ARGV == 2){
	$version = $ARGV[0];
	$scrambles = $ARGV[1];
}

if(@ARGV == 3){
	$version = $ARGV[0];
	$scrambles = $ARGV[1];
	$readFromFile = 1;
}

$cmd = $version."/optiqtm +";
my $pid = open2(*Reader, *Writer, $cmd);
open FILE, "Scrambles/".$scrambles.".txt" or die$!;
my @lines = <FILE>;
$start = time();
foreach(@lines){
	print Writer $_."\n";
}

print Writer "x\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\n";
my @got = <Reader>;
$end = time();
close Reader;
close Writer;
close $pid;

if($readFromFile){
	open(TEXTWRITTEN, $version."AllOut.txt") or die("Unable to find output, did you mean to provide 3 parameters?");
	@got = <TEXTWRITTEN>;
	close(TEXTWRITTEN);
}

$runTime = $end-$start;
print "\nTook $runTime seconds to execute\n";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
open(OUTPUT, '>>'."Results/".$version.'Results-'.$scrambles.'-'.$year.$mon.$mday.$hour.$min.$sec.".txt");
print OUTPUT @got;
print OUTPUT "\nTook $runTime seconds to execute\n";

#open(SOLUTIONS, '>>'."Solutions/".$version.'Solutions-'.$scrambles.'-'.$year.$mon.$mday.$hour.$min.$sec.".txt");

$out = "";

open(OUT, '>>'."TerminalOutput/".$version.$year.$mon.$mday.$hour.$min.$sec.".txt");

print OUT @got;

close(OUT);

foreach(@got){
	$out = $out.$_;
	
}

open(TIMES, '>>'."Times/".$version.'Times-'.$scrambles.'-'.$year.$mon.$mday.$hour.$min.$sec.".txt");

@solves = split("END-OF-SOLVE\n",$out);
$scrambleNum = 0;
$success = 1;
foreach (@solves){
	@parts = split('Time elapsed for ');
	@time = split(': ',@parts[1]);
	print TIMES $scrambleNum.':'.@time[1];
	$strpre = 'Solutions-'.$scrambles.'-'.$scrambleNum;
	$strpost = '-'.$year.$mon.$mday.$hour.$min.$sec;
	open(SOLUTIONS, '>>'."Solutions/".$version.$strpre.$strpost.".txt");
	$scrambleNum++;
	@bits = split('\n',@parts[0]);
	foreach(@bits){
		$_ = $_."\n";
		@temp = split('SOLUTION:');
		print SOLUTIONS @temp[1];
	}

	close(SOLUTIONS);

	if(verify($strpre,$version.$strpre.$strpost)){
		print"Good so far\n";
	} else {
		$success = 0;
		print "Uh-Oh!\n";
	}

	#$v = open2(*Reader, *Writer, "perl verify.pl ".$strpre.' '.$strpre.$strpost);
	#my @out = <Reader>;
	#if(!(@out[0] eq "Successfully verified LocalSolutions/".$strpre.".txt against Solutions/".$strpre.$strpost.".txt")){
	#	print"Error\n";
	#	$success = 0;
	#} else {
#		print"Verified ".$strpre." against ".$strpre.$strpost."\n";
#	}
#	print @out[0]."\n";
#	print "Successfully verified LocalSolutions/".$strpre.".txt against Solutions/".$strpre.$strpost.".txt\n";
}

if($success){
	print $version." verified\n";
} else {
	print "I don't think it worked!\n";
}

close(OUTPUT);
close(SOLUTIONS);

sub verify{
	$real = $_[0];
	$test = $_[1];
	open REAL, "LocalSolutions/".$real.".txt" or die$!."LocalSolutions/".$real.".txt";
	open TEST, "Solutions/".$test.".txt" or die$!."Solutions/".$test.".txt";
	my @rSolutions = <REAL>;
	my @tSolutions = <TEST>;


	foreach(@rSolutions){
		$res = contains($_,\@tSolutions);
		if($res){
		} else {
			return 0;
		}
	}

	foreach(@tSolutions){
		if(contains($_,\@rSolutions)){
		} else {
			return 0;
		}
	}


	return 1;
	}

sub contains{
	$arrayRef = $_[1];
	$element = $_[0];

	foreach(@$arrayRef){
		if($_ eq $element){
			return 1;
		}
	}
	return 0;
}
