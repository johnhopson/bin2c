#!/usr/bin/env ruby 
# ------------------  (c)2011 john hopson  -------------------
#
#  Translates the contents of any file to a C array.
#
#  - See readme.md for usage and examples.
#
#  - Written and tested with ruby 1.8.7 on OS X.
#
#  - Hosted at github.com/johnhopson/bin2c
#
#  - 'license' file has release terms
#

require  'time'
require  'optparse'
require  'benchmark'


#  bin2c version
@VERSION = '0.7'

#  various constants

@appname   = File.basename(__FILE__)
@verstring = "#{@appname} #{@VERSION}"

@date = Time.now.strftime('%Y-%m-%d')

#  Parse command line options 
#  and verify their settings.

def parseopts
  
  @options = { :arrayname => "",
               :arraytype => "unsigned char",
               :outfile   => "STDOUT",
               :preamble  => true,
               :verbose   => false,
               :help      => false,
               :version   => false }
               
  opts = OptionParser.new 
  opts.banner = "Usage: #{@appname} [options] [filename]"

  opts.on( '-n', '--name NAME',     "Array name"           )  { |n| @options[:arrayname] = n }
  opts.on( '-t', '--type TYPE',     "Array type"           )  { |t| @options[:arraytype] = t }
  opts.on( '-o', '--output FILE',   "Specify output file"  )  { |f| @options[:outfile]   = f }      
  opts.on( '-p', '--[no-]preamble', "No file header"       )  { |n| @options[:preamble]  = n }        
  opts.on( '-v', '--verbose',       "Run verbosely"        )  { @options[:verbose]    = true }        
  opts.on( '-h', '--help',          "Emit help information")  { @options[:help]       = true }  
  opts.on(       '--version',       "Emit version and exit")  { @options[:version]    = true }
  
  opts.separator                                                             "\n" + 
                 "Examples:"                                                 "\n" +    
                 "    #{@appname} -o output.cpp  foo.bin"                    "\n" +
                 "    #{@appname} -o header.h  foo.bin"                      "\n" +
                 "    #{@appname} -v  <foo.bin  >output.cpp"                 "\n" +
                 "    #{@appname} --no-preamble  -o output.cpp  <foo.bin"    "\n" +
                 "    #{@appname} --type \"uint8_t\"  <foo.bin  >output.cpp" "\n" +
                 ""
  begin
    opts.parse!(ARGV)
    
  rescue Exception => e
    puts e, opts
    exit
  end

  if @options[:version] == true
    puts @verstring
    exit 0

  elsif @options[:help] == true
    puts opts
    exit 0
  end


  #  if output file specified, 
  #  redirect stdout to the file

  if @options[:outfile] != "STDOUT"
     $stdout.reopen( @options[:outfile], "w")
  end


  #   if no arrayname specified, use 
  #   infile name.  If infile is
  #   stdin, use default.

  if @options[:arrayname] == ""
    fname = ARGF.filename

    if fname == "-"  # stdin
      fname = "binary_data"
    end

    @options[:arrayname] = fname.chomp(File.extname(fname))
  end


  #  print option list, if verbose

  if @options[:verbose] == true  
    warn @verstring
    warn ""
    warn "options:"    

    @options.each  do  |name, val|
      warn "    %-9s = #{val}" % name
    end
    warn ""
    warn  "infile " + ARGF.filename
    warn ""          
  end
end



#  Emit output file contents.
#
#  - Typical output -
#     //  test.bin converted to C array.
#     //
#     //  - using bin2c.rb 0.2
#     //  - created 2011-12-21
#
#     const unsigned char  test[160] = 
#     {
#         0xee, 0x93, 0x70, 0x32, 0xf5, 0x90, 0xac, 0x44,     //  ..p2...D     0
#         0xd0, 0x5c, 0x70, 0xe2, 0xfc, 0x19, 0xda, 0xb5,     //  .\p.....     8
#         ...

def emitfile

  content = []
  ARGF.bytes.each do |b|
    content << b    
  end

  if content.length == 0
    warn "empty input file - exiting"
    exit!(1)
  end

  #  emit file header
  if @options[:preamble] == true

    if ARGF.filename != "-" # stdin
      puts  "//  %s converted to C array.\n" % ARGF.filename
      puts  "//\n"
    end

    puts  "//  - using #{@verstring}\n"
    puts  "//  - created #{@date}\n\n"
  end

  #  emit array contents

  puts "#{@options[:arraytype]}  #{@options[:arrayname]}[%d] = \n\{" % content.length

  #  read input as binary and emit 
  #  each byte into C array of hex values.

  ascii    = ""
  elements = ""
  line     = 1
  index    = 0
      
  #   emit content lines

  content.each_with_index  do |b, x|
    
    ascii    <<  (/[[:print:]]/ === b.chr  ? b.chr : '.')        
    elements << "0x%02x, " % b.to_s

    #  add gaps every 8 lines, for readability

    if elements.length >= "0x00, ".length * 8
  
      if line > 1  &&  (line-1) % 4 == 0
        puts ""
      end
      
      if x == content.length-1
        break
      end
      
      puts  "    %-50s  //  %-9s  %3d" % [elements, ascii, index]
          
      index    =  x+1
      elements =  ""
      ascii    =  ""        
      line     += 1
    end
  end

  if elements.length > 0
      puts  "    %-50s  //  %-9s  %3d" % [elements[0...-2], ascii, index]
  end

  puts "};\n\n"

end


#  start processing

time = Benchmark.realtime do
  parseopts
  emitfile 
end

puts "Time elapsed %.2f ms\n\n"  %  (time*1000)  if @options[:verbose]