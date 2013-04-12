use Time::HiRes;
use IPC::Open2;

$version = "TimingMod";
$scrambles = "Benchmark1";
$readFromFile = 0;

$scrambles2 = 
"R2 B L F R B R2 B D' L' R' F U' B2 U2 F2 U2 B' L2 R U2 R2 D2 R\n".
"U F D L' R F' R' F' L' U2 F D U' B L2 B' R' B2 D F' L2 B' L F'\n".
"R2 D U B F' D B' F' R' B' F D2 L' B' F' U R' D' F2 D' B2 R' B' L\n".
"D' U' R' U L' D2 L' F' L B' F' R' D' L2 F' U' F' R' F' L' F' R2 D U2\n".
"U2 F' D U B R U' L R2 D' U2 R D U F2 D2 B2 L2 D2 L2 F' D' R B2 U'\n".
"D2 U' L' D B F' D' F2 U L2 F R' B2 L' D2 L F' L2 F2 U' L2 D U2 L' U2\n".
"B D R' B D' F' L2 D' B2 F2 L2 D' B' F' L' B2 F' D2 F R D U' R' U' B\n".
"D' L' U F' D2 U' L D2 R B2 D F L2 B' D U2 L2 R' U L2 B2 D' U2 B' U D\n".
"L' B L F' L' D2 B L B' F L2 R2 D2 U' L2 R D R' F2 U' B' R2 F' R2 U\n".
"U2 L2 U L U' F' R B D' L2 R' D2 U2 L' F2 U2 R2 B2 F2 U' F' L R F R\n".
"R B' D2 B' D U2 L R D2 U' L' U L2 D' B2 U B2 D R2 D B2 U L2 R2 B'\n".
"F L R U L2 B L B L' R F2 U2 F L' R' B' F D' U2 L2 R' F D U2 F\n".
"R2 D2 U L U2 L B' D2 U' L R' D' F D' B' F L' F' R B' F' D L2 D U R\n".
"R' D' U F U' B2 L' F' R' D' R2 B2 D' B' F R' B2 F L' F2 L B2 F2 D\n".
"U2 B2 D U2 B L2 B F2 D L' B L D2 U B R' B2 D' L' B' F D B' D' U2\n".
"R' B L' R' B F' L R' D' U2 B2 R D2 L' D F2 U F U' B' F' R U2 F'\n".
"B2 R2 F' D' F' U2 B' R2 B F' R' B R' B' L F2 D2 R' U2 B' D2 B L R2 U F'\n".
"U2 L R2 B' F' U F L F L U2 R2 U' F R2 U B2 R' D2 U' F R2 F R' U F R\n".
"B2 U2 B2 L' B F L R' B L R D' U R U' F2 U' R B R' B F2 U' F' U D\n".
"F' D2 L2 R B' F' D F R B2 F L' B' F L2 B R2 U F U L R U L' U R\n".
"D' F' D2 U B D F L2 B2 D2 B2 L F' R2 U R2 F R B F2 U R2 F' D2 F\n".
"U2 F2 L' R' B F2 U2 L B2 F L F2 L R' F' D L F' L2 B2 U2 B2 F2 U'\n".
"F' R2 U B' L' U' L2 U B F U B L' B2 F2 L2 D2 U' L2 R2 F' U' B' D2 R' U'\n".
"D B2 F U2 R2 D2 L2 R' D' F' L2 F2 L D2 B F2 D2 U F D2 L' R B' D\n".
"L D2 U' B2 R' F' D' F2 U2 B2 D2 B' D' L D U' B F U' L' F D2 L2 B' U R' L\n".
"D B2 F D2 U2 L' R2 F' D L B F' R' F' L' R' D L2 U2 F L2 U' R2 B' F\n".
"R' F2 R' B' R' D' U L R F' L U' L' D2 U B2 D U' L2 R B F' D B U'\n".
"D2 U2 B2 F' L2 R B' F U' L2 U' B F2 R B R D2 U' L2 D2 L' R U' B' U R'\n".
"D' L' B2 L U R' U' R2 B2 L' R' B2 L2 R2 B' D L' R2 D' R D2 U' L U F\n".
"L B' L R2 D' L2 U F D2 F' U' R' F R' U' B' U2 R D U' B' F2 D2 F' U'\n".
"B L' R' D B' L R' U2 F2 L' R2 D L F U2 L2 D' U' R2 F D' B F L B\n".
"U2 L' U2 F D2 B' L' D U L' R' B F' L' B' F U2 F L' D2 U L2 R D' L\n".
"R2 B L F R B R2 B D' L' R' F U' B2 U2 F2 U2 B' L2 R U2 R2 D2 R D'\n".
"U F D L' R F' R' F' L' U2 F D U' B L2 B' R' B2 D F' L2 B' L F' R\n".
"R2 D U B F' D B' F' R' B' F D2 L' B' F' U R' D' F2 D' B2 R' B' L R\n".
"D' U' R' U L' D2 L' F' L B' F' R' D' L2 F' U' F' R' F' L' F' R2 D U2 R'\n".
"x\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\n";

$scrambles1 =
"B'L U' F R' U' B' U' D' F U' B' U\n".
"B'L U' F R' U' B' U' D' F U' B' U L\n".
"B'L U' F R' U' B' U' D' F U' B' U L F\n".
"B'L U' F R' U' B' U' D' F U' B' U L F L'\n".
"B'L U' F R' U' B' U' D' F U' B' U L F L' D'\n".
"B'L U' F R' U' B' U' D' F U' B' U L F L' D' R'\n".
"B'L U' F R' U' B' U' D' F U' B' U L F L' D' R' F\n".
"B'L U' F R' U' B' U' D' F U' B' U L F L' D' R' F R\n".
"B'L U' F R' U' B' U' D' F U' B' U L F L' D' R' F R B\n".
"B'L U' F R' U' B' U' D' F U' B' U L F L' D' R' F R B U\n".
"L F' R2 B U B F2 L F R' D B'\n".
"L F' R2 B U B F2 L F R' D B' D\n".
"L F' R2 B U B F2 L F R' D B' D R\n".
"L F' R2 B U B F2 L F R' D B' D R U\n".
"L F' R2 B U B F2 L F R' D B' D R U R2\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F U\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F U L\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F U L F2\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F U L F2 U\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F U L F2 U R\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F U L F2 U R F'\n".
"L F' R2 B U B F2 L F R' D B' D R U R2 F U L F2 U R F' U2\n".
"x\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\n";

$problems = "B2 D L2 D' B' L' R' U' L2 D2 F' L2 R2 D2 B' L R2 D2 L R D U F' R2\n"."U2 L R2 B' F' U F L F L U2 R2 U' F R2 U B2 R' D2 U' F R2 F R'\n"."x\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\n";

$scrambles2a =

"D2 U' L' D B F' D' F2 U L2 F R' B2 L' D2 L F' L2 F2 U' L2 D U2 L'\n".
"B D R' B D' F' L2 D' B2 F2 L2 D' B' F' L' B2 F' D2 F R D U' R' U2\n".
"U2 F' D U B R U' L R2 D' U2 R D U F2 D2 B2 L2 D2 L2 F' D' R B2\n".
"D' L' U F' D2 U' L D2 R B2 D F L2 B' D U2 L2 R' U L2 B2 D' U2 B'\n".
"L' B L F' L' D2 B L B' F L2 R2 D2 U' L2 R D R' F2 U' B' R2 F' R2\n".
"U2 L2 U L U' F' R B D' L2 R' D2 U2 L' F2 U2 R2 B2 F2 U' F' L R F\n".
"R B' D2 B' D U2 L R D2 U' L' U L2 D' B2 U B2 D R2 D B2 U L2 R2\n".
"B2 D L2 D' B' L' R' U' L2 D2 F' L2 R2 D2 B' L R2 D2 L R D U F' R2\n".
"F L R U L2 B L B L' R F2 U2 F L' R' B' F D' U2 L2 R' F D U2\n".
"F' R2 U B' L' U' L2 U B F U B L' B2 F2 L2 D2 U' L2 R2 F' U' B' D2\n".
"R' D' U F U' B2 L' F' R' D' R2 B2 D' B' F R' B2 F L' F2 L B2 F2 D\n".
"R2 D2 U L U2 L B' D2 U' L R' D' F D' B' F L' F' R B' F' D L2 D\n".
"U2 B2 D U2 B L2 B F2 D L' B L D2 U B R' B2 D' L' B' F D B' D'\n".
"R' B L' R' B F' L R' D' U2 B2 R D2 L' D F2 U F U' B' F' R U2 F'\n".
"R U' B D R F' D' U2 L2 R' B' U2 B F L2 B' F2 D U2 R2 D U2 F R2\n".
"B2 R2 F' D' F' U2 B' R2 B F' R' B R' B' L F2 D2 R' U2 B' D2 B L R2\n".
"B2 U2 B2 L' B F L R' B L R D' U R U' F2 U' R B R' B F2 U' F'\n".
"D B2 F D2 U2 L' R2 F' D L B F' R' F' L' R' D L2 U2 F L2 U' R2 B'\n".
"F' D2 L2 R B' F' D F R B2 F L' B' F L2 B R2 U F U L R U L'\n".
"D' F' D2 U B D F L2 B2 D2 B2 L F' R2 U R2 F R B F2 U R2 F' D2\n".
"U2 F2 L' R' B F2 U2 L B2 F L F2 L R' F' D L F' L2 B2 U2 B2 F2 U'\n".
"R' F2 R' B' R' D' U L R F' L U' L' D2 U B2 D U' L2 R B F' D B\n".
"D B2 F U2 R2 D2 L2 R' D' F' L2 F2 L D2 B F2 D2 U F D2 L' R B' D\n".
"D2 U2 B2 F' L2 R B' F U' L2 U' B F2 R B R D2 U' L2 D2 L' R U' B'\n".
"D' L' B2 L U R' U' R2 B2 L' R' B2 L2 R2 B' D L' R2 D' R D2 U' L U\n".
"B L' R' D B' L R' U2 F2 L' R2 D L F U2 L2 D' U' R2 F D' B F L\n".
"R2 D U B F' D B' F' R' B' F D2 L' B' F' U R' D' F2 D' B2 R' B' L\n".
"U2 L' U2 F D2 B' L' D U L' R' B F' L' B' F U2 F L' D2 U L2 R D'\n".
"L B' L R2 D' L2 U F D2 F' U' R' F R' U' B' U2 R D U' B' F2 D2 F'\n".
"R2 B L F R B R2 B D' L' R' F U' B2 U2 F2 U2 B' L2 R U2 R2 D2 R\n".
"U F D L' R F' R' F' L' U2 F D U' B L2 B' R' B2 D F' L2 B' L F'\n".
"D' U' R' U L' D2 L' F' L B' F' R' D' L2 F' U' F' R' F' L' F' R2 D U\n".
"x\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\nx\n";

if(@ARGV == 2){
        $version = $ARGV[0];
        $scrambles = $ARGV[1];
}

if($scrambles == "Benchmark2"){
        $scrambles = $scrambles2;
} else {
        $scrambles = $scrambles1;
}
$cmd = $version."/optiqtm +";
my $pid = open2(*Reader, *Writer, $cmd);
$start = time();
print Writer $scrambles;

my @got = <Reader>;
$end = time();
close Reader;
close Writer;
close $pid;

print "Took ".($end-$start)." seconds to execute\n";
                                        
