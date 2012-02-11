#bin2c
- - - - - - - -
Bin2c translates the contents of any file to a C array.


### Usage

	Usage: bin2c [options] [filename]
	    -n, --name NAME                  Array name
	    -t, --type TYPE                  Array type
	    -o, --output FILE                Specify output file
	    -p, --[no-]preamble              No file header
	    -v, --verbose                    Run verbosely
	    -h, --help                       Emit help information
	        --version                    Emit version and exit

	Examples:
	    bin2c -o output.cpp  foo.bin
	    bin2c -o header.h  foo.bin
	    bin2c -v  <foo.bin  >output.cpp
	    bin2c --no-preamble  -o output.cpp  <foo.bin
	    bin2c --type "uint8_t"  <foo.bin  >output.cpp


### Output

	//  foo.bin converted to C array.
	//
	//  - using bin2c 0.7
	//  - created 2011-12-23

	unsigned char  foo[22] =
	{
	    0xc9, 0x78, 0xb3, 0xb0, 0xab, 0x78, 0x2b, 0x09,     //  .x...x+.     0
	    0xfc, 0x52, 0x76, 0xfa, 0x9d, 0xc8, 0xc5, 0x86,     //  .Rv.....     8
	    0x8a, 0x40, 0x3d, 0xf3, 0x9d, 0x1e                  //  .@=...      16
	};



## Test
'test/bin2c\_test.rb' is a test suite for Bin2c.  Use the '-h' option to see
usage, including how to run individual tests.

## Other
Written and tested with Ruby 1.8.7 on OS X 10.7.

[![CC](http://i.creativecommons.org/l/by-sa/3.0/88x31.png)](http://creativecommons.org/licenses/by-sa/3.0/)   &nbsp;Licensed under [Creative Commons](http://creativecommons.org/licenses/by-sa/3.0/)
