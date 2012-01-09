#!/usr/bin/env ruby
# ------------------  (c)2011 john hopson  -------------------
#
#  Test suite for bin2c program.
#
#  - Get usage with 'bin2c_test.rb -h'
#
#  - Binary file lengths have no significance, unless
#    specified.  A variety of lengths are used to test
#    arbitrary sizes.
#
#  - Requires GCC, but only basic features.
#
#  - Written and tested with ruby 1.8.7 on OS X.
#
#  - Hosted at github.com/johnhopson/bin2c
#
#  - 'license' file has release terms
#


require "test/unit"
require 'stringio'


class TestBin2C < Test::Unit::TestCase

  def setup
    @rootdir = File.join(File.dirname(__FILE__), '..')
    @bin2c   = File.join( @rootdir, 'bin2c' )
  end


  def  test_tiny_file
    size_test( 1 )
  end

  def  test_large_file
    size_test( 105267 )
  end

  def  test_huge_file
    size_test( 1845236 )
  end


  def  test_over_span_of_10_by_1
    (100..110).each do |i|
      size_test( i )
    end
  end

  def  test_over_span_of_100_by_10
    200.step(330, 10) do |i|
      size_test( i )
    end
  end

  def  test_over_span_of_1000_by_99
    3.step(1100, 99) do |i|
      size_test( i )
    end
  end


  def  test_c_header_output
    common_test  "--type \"const unsigned char\" -o foo.h  foo.bin",
                 "foo.h"
  end

  def  test_cpp_usage
    common_test  "-o foo.cpp  foo.bin",
                 "foo.cpp"
  end

  def  test_char_type
    common_test  "-t \"char\"  <foo.bin  >foo.cpp",
                 "foo.cpp"
  end

  def  test_int_type
    common_test  "-t \"int\"   <bar.bin  >foo.c",
                 "foo.c",
                 "bar.bin"
  end

  def  test_unsigned_int_type
    common_test  "-t \"unsigned int\"   <bar.bin  >bar.c",
                 "bar.c",
                 "bar.bin"
  end


  def  test_name_option_short
    common_test  "-n darwin  -o foo.cpp  foo.bin",
                  "foo.cpp"
  end

  def  test_name_option_long
    common_test  "--name abe  -o foo.c  foo.bin"
  end

  def  test_very_long_name
    name = "this_is_an_incredibly_unbelievably_stupendously_fabulously_long_name"
    common_test  "-n #{name}  --output foo.c  foo.bin"
  end


  def  test_version_option
    assert_equal  "bin2c 0.7\n", `#{@bin2c}  --version`
  end


  def  test_output_with_no_header

    gen_random_file  "foo.bin", 99
    `#{@bin2c}  -o foo.c  foo.bin`
    size_with_preamble = File.stat("foo.c").size
    File.delete "foo.c"

    `#{@bin2c}  --preamble  -o foo.c  foo.bin`
    assert_equal  size_with_preamble, File.stat("foo.c").size

    `#{@bin2c}  --no-preamble  -o foo.c  foo.bin`
    size_wo_preamble = File.stat("foo.c").size
    assert  size_with_preamble > size_wo_preamble

    compiler_test  "foo.c", "foo.bin"
  end


  def  test_help
    expected  = <<-notes.gsub(/^ {8}/, '')
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
            bin2c --type \"uint8_t\"  <foo.bin  >output.cpp

       notes

    assert_equal expected, `#{@bin2c}  --help`
  end


  def  test_zero_file_size_error

    gen_random_file  "test.bin", 0
    assert_equal  "empty input file - exiting\n",
                  `#{@bin2c}  -o "test.c"  test.bin 2>&1`
    assert_equal  $?.exitstatus, 1

  ensure
    File.delete "test.c"    if File.exists? "test.c"
    File.delete "test.bin"  if File.exists? "test.bin"
  end


  def  test_that_c_compile_can_fail

    gen_random_file  "abe.bin", 1280
    `#{@bin2c}  -o abe.c  abe.bin`

    #  corrupt C so compile will fail
    text = File.read( "abe.c" )
    text.gsub! /\}/, ""
    File.open( "abe.c", "w" ) { |f| f.puts text }

    assert_raise Test::Unit::AssertionFailedError do
      compiler_test  "abe.c", "abe.bin"
    end
  end


  def  test_that_c_to_binary_comparison_can_fail

    gen_random_file  "abe.bin", 780
    `#{@bin2c}  -o abe.c  abe.bin`

    # shorten binary so comparison will fail
    bin = File.open( "abe.bin", "rb" ).read(1280)
    File.open( "abe.bin", "wb" ) { |f| f.write bin[0..-2] }

    assert_raise Test::Unit::AssertionFailedError do
      compiler_test  "abe.c", "abe.bin"
    end
  end



  # --  support methods  -------------------------------------

  protected


  #  Test bin2c's ability to generate
  #  a file of a specified size.

  def  size_test  size
    common_test  "-o foo.c  foo.bin",
                 "foo.c",
                 "foo.bin",
                 size
  end


  #  Generate binary data file
  #  of specified size.  Data
  #  is random.

  def  gen_random_file  name, size

    data = Array.new(size) { rand(256) }.pack('c*')
    File.open( name, "w" ) { |f| f.write( data ) }
  end


  #  Most common test scenario - generate
  #  binary file, run bin2c, check output.

  def  common_test  cmdline,
                    cfile    ="foo.c",
                    binfile  ="foo.bin",
                    filesize =nil

    if filesize == nil
      filesize = 1 + rand(8000)
    end

    gen_random_file  binfile, filesize

    `#{@bin2c}  #{cmdline}`
    assert_equal 0, $?.exitstatus

    compiler_test  cfile,
                   binfile
  end


  #  Compile file produced by bin2c
  #  and run it in C app that verifies
  #  its contents.

  def  compiler_test  cfile, binfile

    assert  File.exist? cfile
    assert  File.exist? binfile

    #  extract array type, name &
    #  size from cfile.

    repl = {}
    text = File.read( cfile )

    text.scan( /^(.*) ([A-Za-z_][A-Za-z_0-9]*)\[(\d+)\] =/ )  do
      |type, name, size|

      #  remove 'const' modifier from
      #  type.  test array must be writeable.

      if type[0,5] == "const"
        type = type[6..-1]
      end

      repl = {/<arrtype>/  => type.strip,
              /<arrname>/  => name,
              /<arrsize>/  => size,
              /<filename>/ => cfile }
    end

    #  adjust labels in test app
    #  to link it with cfile.

    text = File.read( "bin2c_test.c" )

    repl.each do |search, replace|
      text.gsub! search, replace
    end

    File.open( "tmp_test.c", "w" ) { |f| f.puts text }

    #  compile with cfile and run
    #  app to test.  g++ allows c
    #  or c++.

    if cfile.end_with?(".h")
      out = `g++  -o tmp_test.exe  tmp_test.c  -D HEADER  2>&1`
    else
      out = `g++  -o tmp_test.exe  tmp_test.c  #{cfile}  2>&1`
    end
    assert_equal 0, $?.exitstatus

    out += `./tmp_test.exe  #{binfile}  2>&1`
    assert_equal 0, $?.exitstatus

    out

  ensure
    [cfile, binfile, "tmp_test.c", "tmp_test.exe"].each do |f|
      File.delete f   if File.exists? f
    end
  end

end
