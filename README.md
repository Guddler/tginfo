# tginfo
Simple TGA image file dumper.

Right now all this does is dump the header info in a human readable format.

It is written in Swift.

It is probably a bit crap.

Build it. Use it. Or don't.

It was written just so that I could understand some Z80 palette loading code for the ZX Next. I've done that now. Oh, and it's more or les the first time I've used 
Swift in any meaningful way. Which is a good reason why it's probably crap.

If I can be bothered then I might implement the full file dump to a C header file as the usage note suggests but in all likelihood there must be hundreds of those 
out there already, and the Z80 assembler I was planning on using can read it directly into the memory map anyway so there's probably not a massive amount of point 
in taking this any further.

