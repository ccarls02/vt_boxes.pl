#!/usr/bin/perl
#
## usage:
##
##  $0 <width><height><#rowsx#cols>
##  (i.e.: $0 20 10 3x5)
##
##       OR
##
##   $0 auto
##
##  $0 <no input argument> -> will output a single max size box to the terminal
##
##
##  will use test array (@testarr) for data
##
## as this script is pre-set with test data, "$0 auto" sets the $AUTO size feature
## which auto sizes the boxes according to the longest line and most lines per the 
## data array
#

use strict;
use feature 'unicode_strings';

#
# setting colors with terminal codes
#
our $FLAG_CRITICAL = "\033[91m";  #foreground RED
our $FLAG_MAJOR = "\033[93m";     #foreground ORANGE
our $FLAG_OK = "\033[92m";        #foreground GREEN
our $FLAG_INFO = "\033[94m";      #foreground BLUE
our $FLAG_NONE = "\033[97m";      #  fg_lt_gray
our $FLAG_OTHER = "\e[38;5;7m";  # light gray
our $FLAG_UNKNOWN = "\033[95m";   #MAGENTA
our $FLAG_CLEAR = "\033[39m\033[49m\e[0m";          #clear all formatting
#
## global var to use box auto colors
#   according to 'color flag' in @inputarray[x][y][0]
our $USE_FLAG_COLORS=1;


## global var for autosize switch
our $AUTO=0;


## global var for print test ruler on output
our $PRINT_RULERS = 0;

## global var to track vertical test ruler
# dont modify this:
our $V_ruler_counter=0;

our ($TERMWIDTH,$TERMHEIGHT)=&getsettings();

## test array for output
##  3D array @array[ROW][COLUMN][DATA]
#      where @array[ROW][COLUMN][0] is a specific severity string 
#      to auto color the boxes, see: sub setflag()
#
my @testarr;

$testarr[0][0][0] = 'MAJOR';
$testarr[0][0][1] = 'array 0 0 ';

$testarr[1][0][0] = 'INFO';
$testarr[1][0][1] = '0 0 second line';

$testarr[2][1][0] = 'invalid flag';
$testarr[2][1][1] = 'array 0 1';
$testarr[2][1][2] = '0 1 second line';
$testarr[2][1][3] = '0 1 THIRD line';
$testarr[2][1][4] = '0 1 44444 line';
$testarr[2][1][5] = '0 1 five line';
$testarr[2][1][6] = '0 1 six line';
$testarr[2][1][7] = '0 1 seven seven seven really long  line';
$testarr[3][0][0] = 'CRITICAL';
$testarr[3][0][1] = 'array 1 0';
$testarr[3][0][2] = '1 0 second line';
$testarr[3][1][0] = 'OK';
$testarr[3][1][1] = 'array 1 1';
$testarr[3][1][2] = '1 1 second line';
$testarr[4][2][0] = 'OTHER';
$testarr[4][2][2] = 'test of random';



if ($ARGV[0] eq  "auto") { $AUTO=1; }
&box(\@testarr,@ARGV);


exit;

##################################
#
#setflag()
#-input: string (flag severity)
#       CRITICAL, MAJOR, OK, INFO, OTHER
#-output: returns corresponding terminal color code set in GLOBALs
#
#
sub setflag {
if ($USE_FLAG_COLORS) {
my $instring = shift (@_);
if ($instring eq "CRITICAL") {
        return $FLAG_CRITICAL;
}
elsif ($instring eq "MAJOR") {
         return $FLAG_MAJOR;
}
elsif ($instring eq "OK") {
        return $FLAG_OK;
}
elsif ($instring eq "INFO") {
        return $FLAG_INFO;
}
elsif ($instring eq "OTHER") {
        return $FLAG_OTHER;
}
elsif ($instring eq "") {  #NONE
        return $FLAG_NONE;
}
else { return $FLAG_UNKNOWN; }
  } 
}

#######################################
#
#  main display output sub
#
#  box()
#  -input:   (NOTE: 2, 3, and 4 are ignored if $AUTO is set)
#       1) data array reference 
#       2) box width (# of characters)                      
#       3) box height (# of lines)                          
#       4) string representing rows and columns of output;
#          in the form of ROWSxCOLS:
#               i.e.  "4x2" -> 4 columns, 3 rows
#                     "3x5" -> 3 columns, 5 rows
#
#        $MARGIN is the spacing (# of chars) between boxes
#        terminal output is about 2x width to 1x height, so 
#        $VMARGIN (vertical margin) is set to 1/2 $MARGIN
#
#
sub box {

# input data array
my @matrix;
my $inarrayref;



##
##make MARGIN an EVEN number so Vspacing can be even 1/2
# $MARGIN is horizontal spacing
my $MARGIN = 2;
my $VMARGIN = $MARGIN/2;


## get ARGV parms
my ($inarrayref, $boxwidth,$boxheight,$boxnum) = @_;
@matrix = @$inarrayref;
my ($boxcols,$boxrows) = split /x/, $boxnum;
##
##  if inputs are invalid, show one big box
#
if ($boxwidth == 0 || $boxheight == 0 || $boxrows < 1 || $boxcols < 1) {
        $boxwidth = $TERMWIDTH - $MARGIN - 5;
        $boxheight = $TERMHEIGHT - 10;
        $boxrows = 1;
        $boxcols = 1;
        }

## subtract top and bottom lines
$boxheight = $boxheight-2;




########################  getting auto size info ###############################
my $maxpassedlength=0;
my $maxpassedheight=0;
my $maxbarow;
my $maxbacol;
my %FLAG;
my $xcounter=0;
my $xcountermax=0;
my $ycounter=0;
my $ycountermax=0;

## loop thru data array to get size info
# $#matrix = ROWS
# $#matrix[x] = COLS
# $#matrix[x][x] = maxlen DATA
#
if  ($#matrix > $maxbarow) { $maxbarow = $#matrix; }

for my $ref (@matrix) {
        if  ($#{$ref} > $maxbacol) { $maxbacol = $#{$ref}; }

    for my $inner (@$ref) {

        if ($#{$inner} > $maxpassedheight) { $maxpassedheight = $#{$inner}; }

        for my $ltext (@$inner) {

             if ((length($ltext)) > $maxpassedlength) { $maxpassedlength = length($ltext); } 
             }                     
        $ycounter++;
        }
        if ($ycounter > $ycountermax) { $ycountermax = $ycounter; }
        $ycounter=0;
  $xcounter++;
  }
$xcountermax = $xcounter;

#print "found array<$xcountermax><$ycountermax><x>\n";


if ($AUTO) {
########################  auto sizing boxes ###############################

  # array 0 base to  1 base:
$maxpassedheight +=1;  
$maxbarow += 1;
$maxbacol += 1;

## set box parameters
$boxrows = $maxbarow;
$boxcols = $maxbacol;
$boxwidth = $maxpassedlength + 3;  # initial space + 2x line character
$boxheight = $maxpassedheight;
###########################################################################

}


#############################
#  LEN of this char = 3
#     see $fudgefactor below
#
my $boxchar = "█";


# variable for line of box body
my $box_H_string;
# max text length (minus 1st/last box character)
my $boxbodylen =  $boxwidth-2;


##  this works great, but cannot use color codes with sprintf.
#   Variable for the actual text in the box
#    set box data line to blank (spaces), we will SUBSTR replace later
my $boxbody = sprintf("%-${boxbodylen}s", " ");

#set left margin
my $leftmargin = ( ' ' x $MARGIN);

# build top and bottom line of box
for (my $i=$boxwidth; $i > 0; $i--) { $box_H_string .= $boxchar; }

##############################################
##   calculate width requirements
##
my $fudgefactor = length($box_H_string) / 3;
## non ascii character is not 1 byte;


#calculate total width of output and test against terminal width
my $fudgelen = length("$leftmargin") + $fudgefactor;
$fudgelen *= $boxcols;

if ($fudgelen > $TERMWIDTH) { 
        $PRINT_RULERS=0;
        print "\n  ERROR: output ($fudgelen chars) cannot fit terminal width ($TERMWIDTH chars)\n\n"; 
        exit; 
        }



#########################
#
#  begin output section
#

if ($PRINT_RULERS) { &print_H_ruler(); }

# box rows
my $bros = 0;
# string for box TOP and BOTTOM line
my $btopstring;
#string for body lines of box
my $bbodyline;

#string for box BOTTOM line
#my $bbotline;

## ROW LOOP                     ROWSxCOLS
#                               row = $bros
#                               col = $bbols
#                               $kline = line
#
# string for report prints row of boxes
my $reportopstring;
# variable that holds box line after replacing spaces with data
my $writebody;
# variable for length(box data)
my $st;
# loop counter for vertical spacing
my $vspacing;
# variable to hold colorcode
my $boxflag; 
while ($bros < $boxrows) {


        ## print box TOP
        my $tbols=0; 
        while ($tbols < $boxcols) {
                        # set color flag from [0] element of data array
                        $boxflag = &setflag($matrix[$bros][$tbols][0]);

                        $btopstring .= "$leftmargin$boxflag$box_H_string$FLAG_CLEAR";
                        undef $boxflag;
                        $tbols++;
                        }
                        $reportopstring .=  &print_V_ruler ."$btopstring\n";

        ## print box BODY
        #starting loop at 1 because 0 contains the flag and we dont want to print it
        for (my $kline=1; $kline < $boxheight; $kline++) {
                my $bbols=0;
                while ($bbols < $boxcols) {
                        # set color flag from [0] element of data array
                        $boxflag = &setflag($matrix[$bros][$bbols][0]);
                        $writebody = $boxbody;
                        $st = length($matrix[$bros][$bbols][$kline]);


                        substr($writebody,1,$st,"$matrix[$bros][$bbols][$kline]");
                        if ($st >= $boxbodylen) { $writebody = substr($writebody,1,$boxbodylen); }
                        $bbodyline .= "$leftmargin$boxflag$boxchar$FLAG_CLEAR$writebody$boxflag$boxchar$FLAG_CLEAR";
                        $bbols++;
                }
                $reportopstring .=  &print_V_ruler . "$bbodyline\n";
                undef $bbodyline;
                undef $boxflag;
        }


        # TOP is the same as BOTTOM
        $reportopstring .=  &print_V_ruler ."$btopstring \n";
        undef $btopstring;

        ## box V spacing
        for ($vspacing = $VMARGIN;$vspacing > 0; $vspacing--) { $reportopstring .= &print_V_ruler . "\n"; }

$bros++;
}
print $reportopstring;

## box characters to try later
#$bbh = "ᐳ ";
#$bbv = "ᐱ";
# "ᐯ"
# "ᐸ"
#
#$bbh = "▇";
#$bbv = "█";
#
#$barh = "△ ";
#$barc = "◍ ";
#
#$barh = "▚";
#$barv = "▚";
#
#$barh = "▟";
#$barv = "▟";
#
#############################
# bullets
# "▶"
# "▲"
# "◀"
# "▼"
#
# ""
#
#

}


##############################
#
# getsettings ()
# -input: NONE
# -output: array of (rows,cols) of current terminal display from "stty -a"
#
#
sub getsettings {
my @sets = `stty -a`;
my @dats = split /;/, $sets[0];

my $line;
my $rows;
my $cols;
foreach $line (@dats) {
        if ($line =~ /rows/) { ($rows) = (split / /, $line)[2]; }
        elsif ($line =~ /columns/) { ($cols) = (split / /, $line)[2]; }
        }
#print "rows-> $rows | cols -> $cols\n";
return ($cols,$rows);
}

#############################################
#
# print_H_ruler()  (enabled with GLOBAL $PRINT_RULERS)
#
# -input: NONE
# -output: prints a (horizontal) ruler to the terminal, numbering the columns
#
#
sub print_H_ruler {

#
# termwidth -= 3 because of left side ruler
$TERMWIDTH -=3;

print "\nTERMINAL MEASUREMENTS: $TERMWIDTH x $TERMHEIGHT\n\n";

my $pcenter = $TERMWIDTH / 2;

my $header1 = "╔╦╗╔═╗╦═╗╔╦╗  ╦═╗╦ ╦╦  ╔═╗╦═╗\n";
my $header2 = " ║ ║╣ ╠╦╝║║║  ╠╦╝║ ║║  ║╣ ╠╦╝\n";
my $header3 = " ╩ ╚═╝╩╚═╩ ╩  ╩╚═╚═╝╩═╝╚═╝╩╚═\n";

$pcenter = $TERMWIDTH / 2;

# length/4 because header is extended ascii
#  otherwise it would be length/2
my $halfwid = length($header1) / 4;

#spaces to center header
my $suffix =  ( ' ' x ($pcenter-$halfwid));
## horizontal line to demarcate ruler
my $linebreak = ( '_ ' x ($TERMWIDTH/2));

print $suffix . $header1;
print $suffix . $header2;
print $suffix . $header3;

my $ones;
my $tens;
my $hundreds;
my $i; 
my $j; 
my @colno;

## format column line numbers to print vertically
for ($i=-3;$i<$TERMWIDTH;$i++) {
        $j = reverse $i;
        @colno = split //, $j;
        if ($colno[1] eq "") { $colno[1] = " "; }
        if ($colno[2] eq "") { $colno[2] = " "; }
        if ($i <= 0) { $colno[0] = "."; $colno[1] = "."; $colno[2] = "."; }
        $ones .= "$colno[0]";
        $tens .= "$colno[1]";
        $hundreds .= "$colno[2]";
        }

print "$hundreds\n";
print "$tens\n";
print "$ones\n";
print "$linebreak\n";
}

#########################################
#
#
# print_V_ruler()
# -input: NONE
# -output: returns a 4 character string, 
#          a (vertical) ruler with the output, numbering row lines
#
#  uses GLOBAL $V_ruler_counter between calls to track current line
#
#
sub print_V_ruler {

#this is global to track number between calls
$V_ruler_counter++;

my $retval = sprintf("%4s", "$V_ruler_counter|");

if ($PRINT_RULERS) { return $retval; }
else { return ""; }

}


