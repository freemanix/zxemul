
//	ZX Spectrum emulator

//	Memory snapshots loading and saving
//	(c) Freeman, September 2000, Prague

/* ------------------------------------------------------------------------- */

#include <plib.h>

#include "zxdev.h"
#include "zxkey.h"
#include "zxsnap.h"

/* ------------------------------------------------------------------------- */

#define	MEM_BUF_SIZE		4096			// memory access buffer size
#define	FIL_BUF_SIZE		 512			// file buffer size
#define	Z80_VER2_SIZE		  23			// Z80 extended header size (v2.x)
#define	Z80_VER3_SIZE		  54			// Z80 extended header size (v3.x)	

/* ------------------------------------------------------------------------- */

// SNA file header

typedef struct 

{
	UBYTE		i;
	UWORD		hl_;
	UWORD		de_;
	UWORD		bc_;
	UWORD		af_;
	UWORD		hl;
	UWORD		de;
	UWORD		bc;
	UWORD		iy;
	UWORD		ix;
	UBYTE		iff;
	UBYTE		r;
	UWORD		af;
	UWORD		sp;
	UBYTE		im;
	UBYTE		border;
}	SNAHeader;

/* ------------------------------------------------------------------------- */

// Z80 ver1.0 file header

typedef struct

{
	UBYTE		a;
	UBYTE		f;
	UWORD		bc;
	UWORD		hl;
	UWORD		pc;
	UWORD		sp;
	UBYTE		i;
	UBYTE		r;
	UBYTE		sys;
	UWORD		de;
	UWORD		bc_;
	UWORD		de_;
	UWORD		hl_;
	UBYTE		a_;
	UBYTE		f_;
	UWORD		iy;
	UWORD		ix;
	UBYTE		iff1;
	UBYTE		iff2;
	UBYTE		cfg;

}	Z80BaseHeader;

/* ------------------------------------------------------------------------- */

// Z80 ver2.0 and above file header

typedef struct

{
	UWORD		len;
	UWORD		pc;
	UBYTE		hw;
	UBYTE		sam;
	UBYTE		irom;
	UBYTE		emul;
	UBYTE		sndsel;
	UBYTE		sndreg[16];

}	Z80ExtHeader;

/* ------------------------------------------------------------------------- */

// Z80 memory block header

typedef struct

{	
	UWORD		len;
	UBYTE		page;

}	Z80MemHeader;

/* ------------------------------------------------------------------------- */

static	SNAHeader		sna;					// last used SNA header
static	Z80BaseHeader	z80;					// last used Z80 header
static	Z80ExtHeader	ext;					// extended header
static	Z80Regs			reg;					// emulator registers

/* ------------------------------------------------------------------------- */

static	UBYTE			fbf[FIL_BUF_SIZE];		// input/output file buffer
static	UBYTE *			fstart;					// start in file buffer
static	UBYTE *			fend;					// end in file buffer

/* ------------------------------------------------------------------------- */

void ResetCache()

{
	// reset pointers

	fstart = fend = fbf;
}

/* ------------------------------------------------------------------------- */

int FlushCache(void * file)

{
	int err;

	// write the contents to the file

	err = p_write(file,fbf,fend-fbf);
	fend = fbf;

	return err;
}

/* ------------------------------------------------------------------------- */

int ReadByte(void * file, UBYTE * val)

{
	int err;

	// if the buffer is empty, fetch it

	if(fstart == fend)
	{
		if((err = p_read(file,fbf,FIL_BUF_SIZE)) < 0)
			return err;

		fstart = fbf;
		fend   = fbf+err;
	}

	// get value

	*val = *(fstart++);

	// finished 

	return 0;
}

/* ------------------------------------------------------------------------- */

int WriteByte(void * file, UBYTE val)

{
	int err;

	// if there is no space, flush cache

	if(fend >= fbf+FIL_BUF_SIZE)
		if((err = FlushCache(file)) != 0)
			return err;

	// store value

	*(fend++) = val;

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

UBYTE ZXPeek(UWORD addr)

{
	UBYTE	tmp;

	// copy single byte from the segment

	p_sgcopyfr(gZXMem,addr,&tmp,1);
	return tmp;
}

/* ------------------------------------------------------------------------- */

void ZXPoke(UWORD addr, UBYTE val)

{
	// store single byte into the segment (check for ROM)

	if(addr >= 0x4000)
		p_sgcopyto(gZXMem,addr,&val,1);
}

/* ------------------------------------------------------------------------- */

int LoadMemory(void * file, UWORD from, UWORD size)

{
	int	   err;
	UWORD  len;
	void * buf;
	
	// allocate buffer
	
	if(!(buf = p_alloc(MEM_BUF_SIZE)))
		return E_GEN_NOMEMORY;

	// process all memory
	
    while(size != 0)
    {
		len = (size < MEM_BUF_SIZE) ? size : MEM_BUF_SIZE;

    	// read a chunk of file
    	
		if((err = p_read(file,buf,len)) < 0)
		{
			p_free(buf);
			return err;
		}
		
		// copy data to memory segment
		
		p_sgcopyto(gZXMem,from,buf,len);
		
		// advance
		
		from += len;
		size -= len;
	}
	
	// free buffer
	
	p_free(buf);

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int SaveMemory(void * file, UWORD from, UWORD size)

{
	int	   err;
	UWORD  len;
	void * buf;
	
	// allocate buffer
	
	if(!(buf = p_alloc(MEM_BUF_SIZE)))
		return E_GEN_NOMEMORY;

	// process all memory
	
    while(size != 0)
    {
		len = (size < MEM_BUF_SIZE) ? size : MEM_BUF_SIZE;

		// copy data from memory segment

		p_sgcopyfr(gZXMem,from,buf,len);

    	// write it to file
    	
		if((err = p_write(file,buf,len)) < 0)
		{
			p_free(buf);
			return err;
		}
		
		// advance
		
		from += len;
		size -= len;
	}
	
	// free buffer
	
	p_free(buf);

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int SaveRawFile(const char * filename, UWORD from, UWORD size)

{
	int	   err;
	void * file;

	// open file for rewriting

	if((err = p_open(&file,filename,P_FREPLACE | P_FSTREAM | P_FUPDATE)) != 0)
		return err;

	// save data

	if((err = SaveMemory(file,from,size)) != 0)
	{
		p_close(file);
		return err;
	}

	// close file

	if((err = p_close(file)) != 0)
		return err;

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int LoadRawFile(const char * filename, UWORD from, UWORD size)

{
	int		err;
	void *	file;

	// open file for reading

	if((err = p_open(&file,filename,P_FOPEN | P_FSTREAM)) != 0)
		return err;

	// load data

	if((err = LoadMemory(file,from,size)) != 0)
	{
		p_close(file);
		return err;
	}

	// close file

	if((err = p_close(file)) != 0)
		return err;

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int SaveSNAFile(const char * filename)

{
	int		err;
	void *	file;

	// store border

	sna.border = ZXGetPort(0xFE);

	// get registers

	ZXGetRegs(&reg);

	// setup header

	sna.af	= reg.AF;
	sna.bc	= reg.BC;
	sna.de	= reg.DE;
	sna.hl	= reg.HL;
	sna.af_	= reg.AF_;
	sna.bc_	= reg.BC_;
	sna.de_	= reg.DE_;
	sna.hl_	= reg.HL_;
	sna.ix	= reg.IX;
	sna.iy	= reg.IY;

	// simulate NMI

	sna.sp	= reg.SP-2;

	ZXPoke(sna.sp  ,reg.PC%256);
	ZXPoke(sna.sp+1,reg.PC/256);

	// set system registers

	sna.r	= reg.R;
	sna.i	= reg.I;
	sna.iff	= reg.IFF & 0x04;
	sna.im	= reg.IM;

	// open file for rewriting

	if((err = p_open(&file,filename,P_FREPLACE | P_FSTREAM | P_FUPDATE)) != 0)
		return err;

	// save header

	if((err = p_write(file,&sna,sizeof(sna))) != 0)
	{
		p_close(file);
		return err;
	}

	// save memory

	if((err = SaveMemory(file,0x4000,0xC000)) != 0)
	{
		p_close(file);
		return err;
	}

	// close file

	if((err = p_close(file)) != 0)
		return err;

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int LoadSNAFile(const char * filename)

{
	int		err;
	void *	file;

	// open file for reading

	if((err = p_open(&file,filename,P_FOPEN | P_FSTREAM)) != 0)
		return err;

	// load header

	if((err = p_read(file,&sna,sizeof(sna))) != sizeof(sna))
	{
		p_close(file);
		return err;
	}

	// load memory

	if((err = LoadMemory(file,0x4000,0xC000)) != 0)
	{
		p_close(file);
		return err;
	}

	// close file

	if((err = p_close(file)) != 0)
		return err;

	// setup registers

	reg.AF	= sna.af;
	reg.BC	= sna.bc;
	reg.DE	= sna.de;
	reg.HL	= sna.hl;
	reg.AF_	= sna.af_;
	reg.BC_	= sna.bc_;
	reg.DE_	= sna.de_;
	reg.HL_	= sna.hl_;
	reg.IX	= sna.ix;
	reg.IY	= sna.iy;

	// simulate RETN

	reg.SP	= sna.sp + 2;
	reg.PC	= ZXPeek(sna.sp) | (ZXPeek(sna.sp+1) << 8);

	// set system registers

	reg.R	= sna.r;
	reg.I	= sna.i;
	reg.IFF	= sna.iff ? 6 : 0;
	reg.IM	= sna.im & 0x03;

	// reset emulator (to unblock HALT state)

	ZXReset(gZXMem);

	// set registers

	ZXSetRegs(&reg);

	// set port value

	ZXSetPort(0xFE,sna.border);

	// finished 

	return 0;
}

/* ------------------------------------------------------------------------- */

int SaveComprItem(void * file, UWORD num, int val)

{
	int   err;

	// repeated symbol found ?

	if(num > 1)
	{
		// too short sequence ?

		if(num < 5 && val != 0xED)
		{
			// copy it directly

			while(num--)
			{
				if((err = WriteByte(file,val)) != 0)
					return err;
			}
		}
		else
		{
			// compress

			if((err = WriteByte(file,0xED)) != 0)
				return err;

			if((err = WriteByte(file,0xED)) != 0)
				return err;

			if((err = WriteByte(file,num)) != 0)
				return err;

			if((err = WriteByte(file,val)) != 0)
				return err;
		}
	}
	else
	{
		// store normally

		if(val != -1)
			if((err = WriteByte(file,val)) != 0)
				return err;
	}

	// finished ok

	return 0;
}

/* ------------------------------------------------------------------------- */

int SaveCompressed(void * file, UWORD from, UWORD size)

{
	int		err;
	UWORD	len, num = 1;
	UBYTE * buf, * ptr;
	int		last = -1;

	// allocate buffer

	if(!(buf = p_alloc(MEM_BUF_SIZE)))
		return E_GEN_NOMEMORY;

	// process all memory

	while(size > 0)
	{
		// get memory block

		len = (size < MEM_BUF_SIZE) ? size : MEM_BUF_SIZE;

		// copy data from memory segment

		p_sgcopyfr(gZXMem,from,buf,len);

		// advance

		size -= len;
		from += len;
		ptr   = buf;

		// compress data

		while(len > 0)
		{
			// search lookahead for the same symbol

			while(len > 0 && num < 255 && last == *ptr)
			{
				// advance

				ptr++;
				num++;
				len--;
			}

			// end of sequence found ?

			if(len)
			{
				// last was 0xED and the new one is not ?

				if(last == 0xED && num == 1)
				{
					// save 0xED

					if((err = SaveComprItem(file,1,0xED)) != 0)
					{
						p_free(buf);
						return err;
					}

					// save single found item

					if((err = SaveComprItem(file,1,*ptr)) != 0)
					{
						p_free(buf);
						return err;
					}

					// flush last to prevent nesting

					last = -1;
					len--;
					ptr++;
				}
				else
				{
					// save last value repeated num times

					if((err = SaveComprItem(file,num,last)) != 0)
					{
						p_free(buf);
						return err;
					}

					// reset num

					num = 1;

					// keep last item

					len--;
					last = *(ptr++);
				}
			}
		}
	}

	// store last found item

	if((err = SaveComprItem(file,num,last)) != 0)
	{
		p_free(buf);
		return err;
	}

	// write end-marker

	if((err = WriteByte(file,0x00)) != 0)
	{
		p_free(buf);
		return err;
	}

	if((err = WriteByte(file,0xED)) != 0)
	{
		p_free(buf);
		return err;
	}

	if((err = WriteByte(file,0xED)) != 0)
	{
		p_free(buf);
		return err;
	}
	
	if((err = WriteByte(file,0x00)) != 0)
	{
		p_free(buf);
		return err;
	}

	// free buffer

	p_free(buf);

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int SaveZ80File(const char * filename)

{
	void * file;
	int	   err;

	// get registers

	ZXGetRegs(&reg);

	// setup header

	z80.a    = reg.AF/256;
	z80.f    = reg.AF%256;
	z80.bc   = reg.BC;
	z80.de   = reg.DE;
	z80.hl   = reg.HL;
	z80.a_   = reg.AF_/256;
	z80.f_   = reg.AF_%256;
	z80.bc_  = reg.BC_;
	z80.de_  = reg.DE_;
	z80.hl_  = reg.HL_;
	z80.ix   = reg.IX;
	z80.iy   = reg.IY;
	z80.sp   = reg.SP;
	z80.pc   = reg.PC;

	z80.r    = reg.R;
	z80.i    = reg.I;
	z80.iff1 = (reg.IFF & 0x02) >> 1; 
	z80.iff2 = (reg.IFF & 0x04) >> 2;
	z80.cfg  = reg.IM;
	z80.sys  = 0x20 | ((reg.R & 0x80) >> 7) | ((ZXGetPort(0xFE) & 0x07) << 1);

	// prepare file cache

	ResetCache();

	// open file for rewriting

	if((err = p_open(&file,filename,P_FREPLACE | P_FSTREAM | P_FUPDATE)) != 0)
		return err;

	// save header

	if((err = p_write(file,&z80,sizeof(z80))) != 0)
	{
		p_close(file);
		return err;
	}

	// save single compressed block

	if((err = SaveCompressed(file,0x4000,0xC000)) != 0)
	{
		p_close(file);
		return err;
	}

	// flush cache

	if((err = FlushCache(file)) != 0)
	{
		p_close(file);
		return err;
	}

	// close file

	if((err = p_close(file)) != 0)
		return err;
	
	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int LoadCompressed(void * file, UWORD from, UWORD size)

{
	int	    err;
	UWORD	len;
	UBYTE * buf, * ptr;
	UBYTE   lst, num, val;
	
	// allocate buffer
	
	if(!(buf = p_alloc(MEM_BUF_SIZE)))
		return E_GEN_NOMEMORY;

	// process all memory

	lst = val = num = 0;
	
    while(size > 0)
    {
		// buffer not yet filled

		ptr = buf;
		len = 0;

		while(size > 0 && len < MEM_BUF_SIZE)
		{
			// inside compressed sequence ?

			if(num)
			{
				*(ptr++) = val;
				--num;
				++len;
			}
			else
			{
				// read next byte

				if((err = ReadByte(file,&val)) != 0)
				{
					p_free(buf);
					return err;
				}

				--size;

				// was last byte flag ?

				if(lst == 0xED)
				{	
					// compressed sequence ?

					if(val == 0xED)
					{
						// check if not corrupted

						if(size < 2)
							return E_FILE_INVALID;

						// read repeat counter

						if((err = ReadByte(file,&num)) != 0)
						{
							p_free(buf);
							return err;
						}

						// check end of file marker

						if(num == 0)
						{
							len = size = 0;
							break;
						}

						// read repeated value

						if((err = ReadByte(file,&val)) != 0)
						{
							p_free(buf);
							return err;
						}

						size -= 2;
					}
					else
					{
						// store last 0xED

						*(ptr++) = lst;
						++len;

						// force storage of val

						num = 1;
					}

					// no last sequence

					lst = 0;
				}
				else
				{
					// keep last value

					lst = val;

					// do not store 0xED

					if(val != 0xED)
					{
						*(ptr++) = val;
						++len;
					}
				}
			}
		}

		// copy data to memory segment
		
		p_sgcopyto(gZXMem,from,buf,len);
		
		// advance
		
		from += len;
	}
	
	// free buffer
	
	p_free(buf);

	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

int LoadZ80Page(void * file)

{
	int			 i, err;
	UWORD		 size;
	UWORD		 from;
	Z80MemHeader mem;	

	// load header

	for(i = 0; i < sizeof(mem); i++)
		if((err = ReadByte(file,((UBYTE *)(&mem))+i)) < 0)
			return err;

	// get values

	switch(mem.page)
	{
	case 4:

		from = 0x8000;
		break;

	case 5:

		from = 0xC000;
		break;

	case 8:

		from = 0x4000;
		break;

	default:

		return E_FILE_INVALID;

	}

	size = mem.len;

	// read the page

	return LoadCompressed(file,from,size);
}

/* ------------------------------------------------------------------------- */

int LoadZ80File(const char * filename)

{
	int		err;
	void *	file;
	UBYTE	tmp;
	int		len;

	// reset cache

	ResetCache();

	// open file for reading

	if((err = p_open(&file,filename,P_FOPEN | P_FSTREAM)) != 0)
		return err;

	// load base header

	if((err = p_read(file,&z80,sizeof(z80))) != sizeof(z80))
	{
		p_close(file);
		return err;
	}

	// setup registers

	reg.AF	= (z80.a  << 8) | z80.f;
	reg.BC	= z80.bc;
	reg.DE	= z80.de;
	reg.HL	= z80.hl;
	reg.AF_	= (z80.a_ << 8) | z80.f_;
	reg.BC_	= z80.bc_;
	reg.DE_	= z80.de_;
	reg.HL_	= z80.hl_;
	reg.IX	= z80.ix;
	reg.IY	= z80.iy;
	reg.SP	= z80.sp;
	reg.PC	= z80.pc;

	reg.R	= (z80.r & 0x7F) | ((z80.sys & 0x01) << 7);
	reg.I	= z80.i;
	reg.IFF	= (z80.iff1 ? 0x02 : 0) | (z80.iff2 ? 0x04 : 0);
	reg.IM	= z80.cfg & 0x03;
	
	// extended header ?

	if(reg.PC == 0)
	{
		// load extended header

		if((err = p_read(file,&ext,sizeof(ext))) != sizeof(ext))
		{
			p_close(file);
			return err;
		}

		// skip possible additional data

		for(len = ext.len; len > sizeof(ext); len--)
			if((err = p_read(file,&tmp,1)) != 1)
			{
				p_close(file);
				return err;
			}

		// can't load non 48k snapshot

		if(ext.hw >= 3 && (ext.len == Z80_VER2_SIZE || ext.hw >= 4))
		{
			p_close(file);
			return E_FILE_INVALID;
		}

		// can't use Interface I

		if(ext.irom)
		{
			p_close(file);
			return E_FILE_INVALID;
		}

		// correct PC

		reg.PC = ext.pc;

		// read compressed pages

		while(fstart != fend || p_read(file,NULL,0) != E_FILE_EOF)
			if((err = LoadZ80Page(file)) != 0)
			{
				p_close(file);
				return err;
			}
	}
	else
	{
		// compatibility check

		if(z80.sys == 0xFF)
			z80.sys = 1;

		// check type

		if(z80.sys & 0x20)
		{
			// read compressed data

			if((err = LoadCompressed(file,0x4000,0xFFFF)) != 0)
			{
				p_close(file);
				return err;
			}
		}
		else
		{
			// read uncompressed data

			if((err = LoadMemory(file,0x4000,0xC000)) != 0)
			{
				p_close(file);
				return err;
			}
		}
	}

	// reset emulator (to unblock HALT state)

	ZXReset(gZXMem);

	// set registers

	ZXSetRegs(&reg);

	// set border

	ZXSetPort(0xFE,(z80.sys >> 1) & 0x07);

	// close file

	if((err = p_close(file)) != 0)
		return err;

	// finished 

	return 0;
}

/* ------------------------------------------------------------------------- */
