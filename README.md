# vt_boxes.pl
Draw boxes around data in a vt100/linux terminal

libraries have their place, but sometimes you just want to code and go.

This file is a set of functions to draw boxes around data (and color them) in a linux/vt100 type terminal session without calling external libraries.
This is probably crappy code. This was part of a project for me to get back into PERL after a long hiatus. I wanted to show the HDD status of my Dell server (see file output.jpg)

## usage:

>$0 <width><height><ROWSxCOLS>
>(i.e.: $0 20 10 3x5)
>
>       OR
>
>   $0 auto
>
>  $0 <no input argument> -> will output a single max size box to the terminal


 Script is currently built to use test array (@testarr) for data

 as this script is pre-set with test data, "$0 auto" sets the $AUTO size feature
 which auto sizes the boxes according to the longest line and most lines per the 
 data array

List of Subs:

```
setflag()
-input: string (flag severity)
	CRITICAL, MAJOR, OK, INFO, OTHER
-output: returns corresponding terminal color code set in GLOBALs


box()
    -input:  (NOTE: 2, 3, & 4 are IGNORED if $AUTO is set)
        1) data array reference 
        2) box width (# of characters)
        3) box height (# of lines)
        4) string representing rows and columns of output;
            in the form of ROWSxCOLS:
            i.e.  "4x2" -> 4 columns, 3 rows
            "3x5" -> 3 columns, 5 rows ```

	$MARGIN is the spacing (# of chars) between boxes. 
	Terminal output is about 2x width to 1x height, so 
	$VMARGIN (vertical margin) is set to 1/2 $MARGIN
	
    -output: prints display (boxes with data) to terminal	
```
```
getsettings ()
-input: NONE
-output: array of (rows,cols) of current terminal display from "stty -a"
```
```
print_H_ruler()  (enabled with GLOBAL $PRINT_RULERS)
-input: NONE
-output: prints a (horizontal) ruler to the terminal, numbering the columns
```
```
print_V_ruler()
-input: NONE
-output: returns a string using 4 characters, a (vertical) ruler with the output, numbering row lines
uses $V_ruler_counter between calls to track current line
```

