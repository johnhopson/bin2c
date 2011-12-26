#bin2c.rb
- - - - - - - -
bin2c.rb translates the contents of any file to a C array.


### Usage

	Usage: bin2c.rb [options] [filename]
	    -n, --name NAME                  Array name
	    -t, --type TYPE                  Array type
	    -o, --output FILE                Specify output file
	    -p, --[no-]preamble              No file header
	    -v, --verbose                    Run verbosely
	    -h, --help                       Emit help information
	        --version                    Emit version and exit

	Examples:
	    bin2c.rb -o output.cpp  foo.bin
	    bin2c.rb -o header.h  foo.bin
	    bin2c.rb -v  <foo.bin  >output.cpp
	    bin2c.rb --no-preamble  -o output.cpp  <foo.bin
	    bin2c.rb --type "uint8_t"  <foo.bin  >output.cpp


### Output

	//  foo.bin converted to C array.
	//
	//  - using bin2c.rb 0.7
	//  - created 2011-12-24

	unsigned char  foo[22] = 
	{
	    0xc9, 0x78, 0xb3, 0xb0, 0xab, 0x78, 0x2b, 0x09,     //  .x...x+.     0
	    0xfc, 0x52, 0x76, 0xfa, 0x9d, 0xc8, 0xc5, 0x86,     //  .Rv.....     8
	    0x8a, 0x40, 0x3d, 0xf3, 0x9d, 0x1e                  //  .@=...      16
	};


### Testing

bin2c_test.rb is a test suite for bin2c.rb.  Type 'bin2c_test.rb' to run the entire suite.  Type 'bin2c_test.rb -h' to see usage, including how to run individual tests.


### License

Released under the MIT License.  See 'license' file.
