/* -------------------  (c)2011 john hopson  -------------------

 Helps test bin2c program.  Compares the contents of the emitted 
 C array against the binary file from which the array was created.

 - This file is linked with the C output of bin2c.  But before
   compilation, tags in this file must be replaced with info -
       tag           filled with
       ---------     ---------
       <arrtype>     C array type
       <arrname>     C array name
       <arrsize>     C array size
       <filename>    binary file name
       
 - Written and tested with gcc 4.2.1 on OS X.
  
 - Hosted at github.com/johnhopson/bin2c
  
 - 'license' file has release terms
*/

#include  <cstring>
#include  <stdio.h>
#include  <stdlib.h>

typedef unsigned char  byte;

#ifdef  HEADER
#include  "<filename>"
#else
extern "C" <arrtype>  <arrname>[<arrsize>];
#endif

byte  contents[<arrsize>];


int  main( int argc,  char* argv[] )
{    
    //  open original binary file
    
    FILE * infile = fopen( argv[1], "rb" );

    if (infile == NULL)
    {
        fputs( "Error opening input file\n", stderr ); 
        exit(1);
    }

    //  be sure binary file size is 
    //  same as generated C array size.
    
    fseek( infile , 0 , SEEK_END );
    long  insize = ftell( infile );
    rewind ( infile );
    
    if (insize != <arrsize>)
    {
        fputs( "Input file size differs from array size\n", stderr ); 
        fclose( infile );
        exit(2);
    }
   
    //  copy file contents into
    //  buffer for comparison.
    
    int result = fread( contents,
                        1,
                        insize,
                        infile );
    fclose( infile );
                                    
    if (result != insize) 
    {
        fputs( "Error reading file\n", stderr ); 
        exit(3);
    }

    //  compare C array to binary file.
    //
    // - Only check lowest byte.
    //   Impractical to match sign ext-
    //   ension for larger signed types.

    for( int i=0;  i<<arrsize>;  i++ )
    {
        if (contents[i] != (byte)<arrname>[i])
        {
            fputs( "Array and input file differ\n", stderr );     
            exit(4);
        }
    }
    
    printf( "C array is identical to input file\n" );
    return  0;
}
