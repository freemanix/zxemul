
// ZX Spectrum emulation core tester

// (c) Freeman, November 2000, Prague

/* -------------------------------------------------------------------------- */

#include <io.h>
#include <dos.h>
#include <mem.h>
#include <alloc.h>
#include <fcntl.h>
#include <stdio.h>
#include <conio.h>
#include <process.h>
#include <sys\stat.h>

/* -------------------------------------------------------------------------- */

typedef		unsigned char	BYTE;
typedef		unsigned short	WORD;

/* -------------------------------------------------------------------------- */

#define		DRW_COLOR		0		// color mode
#define		DRW_GRAY		1		// gray mode
#define		DRW_BWINK		2		// ink-based black & white mode
#define		DRW_BWFLP		3		// flipped black & white mode
#define		DRW_BWTHR		4		// thresholded black & white mode
#define		DRW_GRTHR		5		// 3-levels gray scale

#define		DRW_NUM			6		// number of color modes

/* -------------------------------------------------------------------------- */

#define		SHR_192			0		// 192 image rows
#define		SHR_168			1		// 168 image rows
#define		SHR_160			2		// 160 image rows
#define		SHR_128			3		// 128 image rows
#define		SHR_96			4		//  96 image rows

#define		SHR_NUM			5		// number of shrink modes

/* -------------------------------------------------------------------------- */

typedef struct

{

	WORD		AF;
	WORD		BC;
	WORD		DE;
	WORD		HL;
	WORD		AF_;
	WORD		BC_;
	WORD		DE_;
	WORD		HL_;
	WORD		IX;
	WORD		IY;
	WORD		SP;
	WORD		PC;
	BYTE		R;
	BYTE		I;
	BYTE		IFF;
	BYTE		IM;

}	Z80Regs;

/* -------------------------------------------------------------------------- */

typedef struct

{

	BYTE		R;
	BYTE		G;
	BYTE		B;

}	RGB;

/* -------------------------------------------------------------------------- */

extern "C" void ZXGetRegs(Z80Regs * regs);
extern "C" void ZXSetRegs(Z80Regs * regs);
extern "C" BYTE ZXGetPort(BYTE port);
extern "C" void ZXSetPort(BYTE port, BYTE val);
extern "C" void ZXSetKeys(BYTE * keys);
extern "C" void ZXReset(WORD seg);
extern "C" void ZXGenINT();
extern "C" void ZXGenNMI();
extern "C" void ZXEmulate(WORD ops);
extern "C" void ZXGInit();
extern "C" void ZXGClose();
extern "C" void ZXGSetPal(RGB * palette, int num);
extern "C" WORD ZXGGetKey();
extern "C" BYTE ZXGGetShift();

/* -------------------------------------------------------------------------- */

Z80Regs		reg;
BYTE far *	mem;
BYTE far *  scr;
BYTE far * 	hlp;
BYTE		drw;
BYTE		shr;
BYTE		skp;
BYTE		lst;

/* -------------------------------------------------------------------------- */

BYTE		key[8]  =   { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };

/* -------------------------------------------------------------------------- */

RGB			pal[32] =	{ { 0x00, 0x00, 0x00 }, { 0x04, 0x04, 0x34 },
						  { 0x34, 0x04, 0x04 }, { 0x34, 0x04, 0x34 },
						  { 0x04, 0x34, 0x04 }, { 0x04, 0x34, 0x34 },
						  { 0x34, 0x34, 0x04 }, { 0x34, 0x34, 0x34 },
						  { 0x00, 0x00, 0x00 }, { 0x08, 0x08, 0x3F },
						  { 0x3F, 0x08, 0x08 }, { 0x3F, 0x08, 0x3F },
						  { 0x08, 0x3F, 0x08 }, { 0x08, 0x3F, 0x3F },
						  { 0x3F, 0x3F, 0x08 }, { 0x3F, 0x3F, 0x3F },

						  { 0x00, 0x00, 0x00 }, { 0x14, 0x14, 0x14 },
						  { 0x1A, 0x1A, 0x1A }, { 0x20, 0x20, 0x20 },
						  { 0x26, 0x26, 0x26 }, { 0x2C, 0x2C, 0x2C },
						  { 0x32, 0x32, 0x32 }, { 0x36, 0x36, 0x36 },
						  { 0x00, 0x00, 0x00 }, { 0x17, 0x17, 0x17 },
						  { 0x1E, 0x1E, 0x1E }, { 0x24, 0x24, 0x24 },
						  { 0x2B, 0x2B, 0x2B }, { 0x32, 0x32, 0x32 },
						  { 0x36, 0x36, 0x36 }, { 0x3F, 0x3F, 0x3F }
						};

/* -------------------------------------------------------------------------- */

unsigned long		XXCount[256];
unsigned long       CBCount[256];
unsigned long		DDCount[256];
unsigned long		EDCount[256];
unsigned long		FDCount[256];
unsigned long	  DDCBCount[256];
unsigned long     FDCBCount[256];

/* -------------------------------------------------------------------------- */

typedef struct

{
	BYTE	i;
	BYTE	lbk;
	BYTE 	hbk;
	BYTE 	ebk;
	BYTE 	dbk;
	BYTE 	cbk;
	BYTE 	bbk;
	BYTE 	fbk;
	BYTE 	abk;
	BYTE 	l;
	BYTE 	h;
	BYTE 	e;
	BYTE 	d;
	BYTE 	c;
	BYTE 	b;
	BYTE 	iyl;
	BYTE 	iyh;
	BYTE 	ixl;
	BYTE 	ixh;
	BYTE 	iff2;
	BYTE 	r;
	BYTE 	f;
	BYTE 	a;
	BYTE 	spl;
	BYTE 	sph;
	BYTE 	im;
	BYTE 	border;

}	SNAHeader;

/* -------------------------------------------------------------------------- */

void FatalError(const char * err)

{
	fprintf(stderr,"\nERROR * %s *\n\n",err);
	exit(-1);
}

/* -------------------------------------------------------------------------- */

void ResetCounts()

{
	for(int i = 0; i < 255; i++)
	{
		XXCount[i] = 0;
		CBCount[i] = 0;
		DDCount[i] = 0;
		EDCount[i] = 0;
		FDCount[i] = 0;
		DDCBCount[i] = 0;
		FDCBCount[i] = 0;
	}
}

/* -------------------------------------------------------------------------- */

void UpdateCounts()

{
	BYTE code = mem[reg.PC];

	// decide where to count

	switch(code)
	{
		case 0xCB:

			CBCount[mem[reg.PC+1]]++;
			break;

		case 0xDD:

			if(mem[reg.PC+1] == 0xCB)
				DDCBCount[mem[reg.PC+3]]++;
			else
				DDCount[mem[reg.PC+1]]++;
			break;

		case 0xED:

			EDCount[mem[reg.PC+1]]++;
			break;

		case 0xFD:

			if(mem[reg.PC+1] == 0xCB)
				FDCBCount[mem[reg.PC+3]]++;
			else
				FDCount[mem[reg.PC+1]]++;
			break;

		default:

			XXCount[code]++;
			break;
	}
}

/* -------------------------------------------------------------------------- */

void SNALoad(const char * filename)

{
	SNAHeader	sna;
	int			fd;
	unsigned	sz;

	// read header

	fd = open(filename,O_RDONLY | O_BINARY);

	_dos_read(fd,&sna,sizeof(sna),&sz);

	if(sz != sizeof(sna))
		FatalError("Can't load SNA file");

	_dos_read(fd,mem+0x4000,0xC000,&sz);

	if(sz != 0xC000)
		FatalError("Can't load SNA file");

	close(fd);

	// setup registers

	reg.AF  = (WORD(sna.a)   << 8) | sna.f;
	reg.BC  = (WORD(sna.b)   << 8) | sna.c;
	reg.DE  = (WORD(sna.d)   << 8) | sna.e;
	reg.HL  = (WORD(sna.h)   << 8) | sna.l;
	reg.AF_	= (WORD(sna.abk) << 8) | sna.fbk;
	reg.BC_ = (WORD(sna.bbk) << 8) | sna.cbk;
	reg.DE_ = (WORD(sna.dbk) << 8) | sna.ebk;
	reg.HL_ = (WORD(sna.hbk) << 8) | sna.lbk;
	reg.IX  = (WORD(sna.ixh) << 8) | sna.ixl;
	reg.IY  = (WORD(sna.iyh) << 8) | sna.iyl;

	reg.R   = sna.r;
	reg.I   = sna.i;

	reg.SP  = (WORD(sna.sph) << 8) | sna.spl;
	reg.PC  = mem[reg.SP] | (WORD(mem[reg.SP+1]) << 8);
	reg.SP += 2;

	reg.IFF = sna.iff2 ? 6 : 0;
	reg.IM  = sna.im & 0x03;

	ZXSetRegs(&reg);

	// set port

	ZXSetPort(0xFE,sna.border);
}

/* -------------------------------------------------------------------------- */

#define	MEM_BUFFER_SIZE		4096			// buffer size
#define	Z80_VER2_SIZE		  23			// Z80 extended header size (v2.x)
#define	Z80_VER3_SIZE		  54			// Z80 extended header size (v3.x)

typedef unsigned char	UBYTE;
typedef unsigned short	UWORD;

UWORD	gZXMem;
int		fd;

/* -------------------------------------------------------------------------- */

UBYTE * p_alloc(UWORD size)
{
	return (UBYTE *)malloc(size);
}

void p_free(void * mem)
{
	free(mem);
}

/* -------------------------------------------------------------------------- */

void p_sgcopyto(UWORD handle, UWORD from, UBYTE * ptr, UWORD len)
{
	int i;

	// just copy to mem

	for(i = 0; i < len; i++)
		mem[from+i] = ptr[i];
}

/* -------------------------------------------------------------------------- */

void p_sgcopyfr(UWORD handle, UWORD from, UBYTE * ptr, UWORD len)
{
	int i;

	// just copy from mem

	for(i = 0; i < len; i++)
		ptr[i] = mem[from+i];
}

/* -------------------------------------------------------------------------- */

int p_open(void * * file, const char * name, int mask)
{
	if(mask)
		fd = open(name,O_RDONLY | O_BINARY);
	else
		fd = open(name,O_WRONLY | O_CREAT | O_BINARY);

	return !fd;
}

int p_read(void * file, void * ptr, UWORD size)
{
	if(eof(fd))
		return -1;

	return read(fd,ptr,size);
}

int p_write(void * file, void * ptr, UWORD size)
{
	unsigned int sz;

	return _dos_write(fd,ptr,size,&sz);
}

int p_close(void * file)
{
	close(fd);

    return 0;
}

/* -------------------------------------------------------------------------- */

int LoadMemory(void * file, UWORD from, UWORD size)
{
   return 0;
}

/* -------------------------------------------------------------------------- */

#define	FIL_BUF_SIZE		 512			// file buffer size
#define	MEM_BUF_SIZE		4096

#define	E_GEN_NOMEMORY		-10
#define	P_FOPEN				  0
#define P_FSTREAM			  0
#define	P_FREPLACE			  0
#define	P_FUPDATE			  0
#define	E_FILE_EOF			 -1
#define E_FILE_INVALID		 -23

/* -------------------------------------------------------------------------- */

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

static	Z80BaseHeader	z80;					// last used Z80 header
static	Z80ExtHeader	ext;					// extended header

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

				if((err = ReadByte(file,&val)) < 0)
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

						if((err = ReadByte(file,&num)) < 0)
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

						if((err = ReadByte(file,&val)) < 0)
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

	if((err = p_open(&file,filename,1 | P_FOPEN | P_FSTREAM)) != 0)
		return err;

	// load base header

	if((err = p_read(file,&z80,sizeof(z80))) != sizeof(z80))
		return err;

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
			return err;

		// skip possible additional data

		for(len = ext.len; len > sizeof(ext); len--)
			if((err = p_read(file,&tmp,1)) != 1)
				return err;

		// can't load non 48k snapshot

		if(ext.hw >= 3 && (ext.len == Z80_VER2_SIZE || ext.hw >= 4))
			return E_FILE_INVALID;

		// can't use Interface I

		if(ext.irom)
			return E_FILE_INVALID;

		// correct PC

		reg.PC = ext.pc;

		// read compressed pages

		while(fstart != fend || p_read(file,NULL,0) != E_FILE_EOF)
			if((err = LoadZ80Page(file)) != 0)
				return err;
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
				return err;
		}
		else
		{
			// read uncompressed data

			if((err = LoadMemory(file,0x4000,0xC000)) != 0)
				return err;
		}
	}

	// set registers

	ZXSetRegs(&reg);

	// set border

	ZXSetPort(0xFE,(z80.sys >> 1) & 0x7F);

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

		from += len;
		size -= len;
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
		return err;

	// save single compressed block

	if((err = SaveCompressed(file,0x4000,0xC000)) != 0)
		return err;

	// flush cache

	if((err = FlushCache(file)) != 0)
		return err;

	// close file

	if((err = p_close(file)) != 0)
		return err;
	
	// finished

	return 0;
}

/* ------------------------------------------------------------------------- */

void Z80Load(const char * filename)

{


}

/* -------------------------------------------------------------------------- */

void DrawBorder(BYTE col)

{
	BYTE far *  dst = scr;
	BYTE		upp, bod;
	int		    r, c;

	// do not draw if not needed

	if(lst == col)
		return;

	lst = col;

	// compare modes

	switch(drw)
	{
		case DRW_GRAY:

			col += 0x10;

			break;

		case DRW_BWINK:

			col = 0x07;

			break;

		case DRW_BWFLP:
		case DRW_BWTHR:

			if(col > 0x03)
				col = 0x07;
			else
				col = 0x00;

			break;

		case DRW_GRTHR:

			if(col < 0x02)
				col = 0x10;
			else if(col < 0x05)
				col = 0x13;
			else
				col = 0x17;

			break;

	}

	// compare shrink modes

	switch(shr)
	{
		case SHR_192:

			upp = 4;
			bod = 192;

			break;


		case SHR_168:

			upp = 16;
			bod = 168;

			break;

		case SHR_160:

			upp = 20;
			bod = 160;

			break;
	}

	// upper bar

	for(r = 0; r < upp; r++)
		for(c = 0; c < 320; c++)
			*(dst++) = col;

	// main body

	for(r = 0; r < bod; r++)
	{
		for(c = 0; c < 32; c++)
			*(dst++) = col;

		dst += 256;

		for(c = 0; c < 32; c++)
			*(dst++) = col;
	}

	// lower bar

	for(r = 0; r < upp; r++)
		for(c = 0; c < 320; c++)
			*(dst++) = col;
}

/* -------------------------------------------------------------------------- */

void DrawScreen(BYTE far * ptr)

{
	static BYTE cnt = 0;

	BYTE far * dst = scr + 4*320 + 32;

	// skip more if shrinked

	if(shr == SHR_168)
		dst += 12*320;

	if(shr == SHR_160)
		dst += 16*320;

	if(shr == SHR_128)
		dst += 24*320;

	if(shr == SHR_96)
    	dst += 48*320;

	for(int r = 0; r < 192; r++)
	{
		// check if drawing needed

		if((shr == SHR_160 || shr == SHR_168) && r%8 == 0)
			continue;

		if(shr == SHR_160 && r%24 == skp)
			continue;

		if(shr == SHR_128 && r%4 == 0)
			continue;

		if(shr == SHR_96 && r%2 == 1)
			continue;

		BYTE far * src = ptr +
						 (r/64)*32*64 +
						 (r%8)*8*32   +
						 (r%64/8)*32;

		BYTE far * atr = ptr + 192*32 + (r/8)*32;

		for(int c = 0; c < 32; c++)
		{
			// get colours

			BYTE brg =  (*atr & 0x40) >> 3;
			BYTE ink = ((*atr & 0x07) >> 0) | brg;
			BYTE pap = ((*atr & 0x38) >> 3) | brg;

			// flash colour ?

			if((*atr & 0x80) && cnt >= 50)
			{
				brg = ink;
				ink = pap;
				pap = brg;
			}

			// compare drawing modes

			switch(drw)
			{
				case DRW_GRAY:

					ink += 0x10;
					pap += 0x10;

					break;

				case DRW_BWINK:

					ink = 0x00;
					pap = 0x07;

					break;

				case DRW_BWFLP:

					if(ink > pap)
					{
						ink = 0x07;
						pap = 0x00;
					}
					else if(ink < pap)
					{
						ink = 0x00;
						pap = 0x07;
					}
					else
					{
						if(ink > 0x03)
							ink = pap = 0x07;
						else
							ink = pap = 0x00;
					}

					break;


				case DRW_BWTHR:

					ink &= 0x07;
					pap &= 0x07;

					if(ink > 0x03)
						ink = 0x07;
					else
						ink = 0x00;

					if(pap > 0x03)
						pap = 0x07;
					else
						pap = 0x00;

					break;

				case DRW_GRTHR:

					ink &= 0x07;
					pap &= 0x07;

					if(ink < 0x02)
						ink = 0x10;
					else if(ink < 0x05)
						ink = 0x13;
					else
						ink = 0x17;

					if(pap < 0x02)
						pap = 0x00;
					else if(pap < 0x05)
						pap = 0x13;
					else
						pap = 0x17;


					break;
			}

			// draw byte

			for(BYTE b = 128; b > 0; b >>= 1)
				if(*src & b)
					*(dst++) = ink;
				else
					*(dst++) = pap;

			// next in ZX memory

			src++;
			atr++;
		}

		// skip rest of screen

		dst += 64;
	}

	// update frame count

	if(++cnt == 100)
		cnt = 0;
}

/* -------------------------------------------------------------------------- */

int ProcessKeys()

{
	for(int i = 0; i < 8; i++)
		key[i] = 0xFF;

	BYTE sft = ZXGGetShift();

	// process SHIFT

	if(sft & 0x03)
		key[7] &= ~0x01;

	// process ALT

	if(sft & 0x08)
		key[0] &= ~0x02;

	// process normal keys

	WORD kb = ZXGGetKey();

	// anything pressed ?

	if(!kb)
		return 0;

	// process code

	BYTE code = kb/256;

	switch(code)
	{
		case 0x2C:	// Z

			key[7] &= ~0x02;
			break;

		case 0x2D:	// X

			key[7] &= ~0x04;
			break;

		case 0x2E:	// C

			key[7] &= ~0x08;
			break;

		case 0x2F:	// V

			key[7] &= ~0x10;
			break;

		case 0x1E:	// A

			key[6] &= ~0x01;
			break;

		case 0x1F:	// S

			key[6] &= ~0x02;
			break;

		case 0x20:	// D

			key[6] &= ~0x04;
			break;

		case 0x21:	// F

			key[6] &= ~0x08;
			break;

		case 0x22:	// G

			key[6] &= ~0x10;
			break;

		case 0x10:	// Q

			key[5] &= ~0x01;
			break;

		case 0x11:	// W

			key[5] &= ~0x02;
			break;

		case 0x12:	// E

			key[5] &= ~0x04;
			break;

		case 0x13:	// R

			key[5] &= ~0x08;
			break;

		case 0x14:	// T

			key[5] &= ~0x10;
			break;

		case 0x02:	// 1
		case 0x78:

			key[4] &= ~0x01;
			break;

		case 0x03:	// 2
		case 0x79:

			key[4] &= ~0x02;
			break;

		case 0x04:	// 3
		case 0x7A:

			key[4] &= ~0x04;
			break;

		case 0x05:	// 4
		case 0x7B:

			key[4] &= ~0x08;
			break;

		case 0x06:	// 5
		case 0x7C:

			key[4] &= ~0x10;
			break;

		case 0x0B:	// 0
		case 0x81:

			key[3] &= ~0x01;
			break;

		case 0x0A:	// 9
				case 0x80:

			key[3] &= ~0x02;
			break;

		case 0x09:	// 8
		case 0x7F:

			key[3] &= ~0x04;
			break;

		case 0x08:	// 7
		case 0x7E:

			key[3] &= ~0x08;
			break;

		case 0x07:	// 6
		case 0x7D:

			key[3] &= ~0x10;
			break;

		case 0x19:	// P

			key[2] &= ~0x01;
			break;

		case 0x18:	// O

			key[2] &= ~0x02;
			break;

		case 0x17:	// I

			key[2] &= ~0x04;
			break;

		case 0x16:	// U

			key[2] &= ~0x08;
			break;

		case 0x15:	// Y

			key[2] &= ~0x10;
			break;

		case 0x1C:	// Enter

			key[1] &= ~0x01;
			break;

		case 0x26:	// L

			key[1] &= ~0x02;
			break;

		case 0x25:	// K

			key[1] &= ~0x04;
			break;

		case 0x24:	// J

			key[1] &= ~0x08;
			break;

		case 0x23:	// H

			key[1] &= ~0x10;
			break;

		case 0x39:	// Space

			key[0] &= ~0x01;
			break;

		case 0x32:	// M

			key[0] &= ~0x04;
			break;

		case 0x31:	// N

			key[0] &= ~0x08;
			break;

		case 0x30:	// B

			key[0] &= ~0x10;
			break;

		case 0x0E:	// Backspace

			key[3] &= ~0x01;
			key[7] &= ~0x01;
			break;

	}

	// eat the code

	if(!getch())
		getch();

	// return code

	return code;
}

/* -------------------------------------------------------------------------- */

void SaveProfile(FILE * file, const char * prefix, unsigned long * table)

{
	for(int i = 0; i < 256; i++)
		if(table[i] > 0)
			fprintf(file,"%4s%02X : %8ld\n",prefix,i,table[i]);
}

/* -------------------------------------------------------------------------- */

unsigned short checksum()

{
	int   i;
	unsigned short sum = 0;


	for(i = 0; i < 13384; i++)
		sum += mem[i];


	return sum;
}

/* -------------------------------------------------------------------------- */

int	main(int argc, char * * argv)

{
	int			    i, fd;
	unsigned int    sz;
	unsigned short  check;

	// get 64k memory for ZX Spectrum

	mem = (BYTE far *)farmalloc(0x10010ul);

	if(!mem)
		FatalError("Can't allocate ZX Spectrum memory");

	// align it to segment boundary

	mem = (BYTE far *)MK_FP(FP_SEG(mem)+1,0);

	// get screen

	scr = (BYTE far *)MK_FP(0xA000,0x0000);

	// get help memory

	hlp = (BYTE far *)farmalloc(6912);

	if(!hlp)
		FatalError("Can't allocate help screen memory");

	// load ROM into the memory

	fd = open("ZXEMUL.ROM",O_RDONLY | O_BINARY);
	_dos_read(fd,mem,16384,&sz);
	close(fd);

	if(sz != 16384)
		FatalError("Can't load ZXEMUL.ROM");

	// load help layout

	fd = open("ZXEMUL.HLP",O_RDONLY | O_BINARY);
	_dos_read(fd,hlp,6912,&sz);
	close(fd);

	if(sz != 6912)
		FatalError("Can't load ZXEMUL.HLP");

	// hide copyright :)

	for(i = 6912-64; i < 6912; i++)
		hlp[i] = 0x00;

	// reset spectrum

	ZXReset(FP_SEG(mem));

	// load snapshot ?

	if(argc == 2)
		LoadZ80File(argv[1]);

	// switch to graphics

	ZXGInit();

	// prepare palette

	ZXGSetPal(pal,32);

	// start with normal mode

	drw = DRW_COLOR;
	shr = SHR_192;
	skp = 12;

	// patch ROM

	mem[0x33FC] = 0x6E;
	mem[0x33FD] = 0x38;

	// store ROM checksum

	check = checksum();

	// reset counts

	ResetCounts();

	// emulation loop

	while(1)
	{
		// process keyboard

		fd = ProcessKeys();

		// quit emulation ?

		if(fd == 0x01)
			break;

		// help screen ?

		if(fd == 0x3B)
		{
			DrawScreen(hlp);
			DrawBorder(0);

			if(!getch())
				getch();

			DrawScreen(mem+16384);
		}

		// switch mode ?

		if(fd == 0x44)
		{
			drw = (drw+1)%DRW_NUM;
			lst = -1;
		}

		// switch shrink

		if(fd == 0x43)
		{
			shr = (shr+1)%SHR_NUM;
			lst = -1;
		}

		// switch skip

		if(fd == 0x42)
		{
			if(skp == 7 || skp == 15 || skp == 23)
				skp++;

			skp = (skp+1)%24;
		}

		// start profiling

		if(fd == 0x41)
		{
			ResetCounts();
		}

		// scan keyboard ports

		ZXSetKeys(key);

		// generate interrupts

		ZXGenINT();

		// 2 updates for single interrupt

		for(fd = 0; fd < 2; fd++)
		{
			for(i = 0; i < 3500; i++)
			{
				if(mem[0] != 0xF3)
					sz = 0;

				if(reg.PC == 0x33C8)
					sz++;

				// beep ?

				if(reg.PC == 0x03B5)
					sound(1000+reg.DE);

				if(reg.PC == 0x03F6)
					nosound();

				// fetch registers

				ZXGetRegs(&reg);

				// update counts

				UpdateCounts();

				// single step emulation

				ZXEmulate(1);
			}

			if(check != checksum())
				return -1;

			// redraw screen

			DrawScreen(mem+16384);

			// redraw border

			DrawBorder(ZXGetPort(0xFE) & 0x07);
		}
	}

	// switch off graphics

	ZXGClose();

	// save profiling statistics

	FILE * out = fopen("profile.txt","wt");

	SaveProfile(out,"",XXCount);
	SaveProfile(out,"CB",CBCount);
	SaveProfile(out,"DD",DDCount);
	SaveProfile(out,"ED",EDCount);
	SaveProfile(out,"FD",FDCount);
	SaveProfile(out,"DDCB",DDCBCount);
	SaveProfile(out,"FDCB",FDCBCount);

	fclose(out);

	// save new ROM

	fd = open("ZXEMUL.NEW",O_CREAT | O_BINARY);
	_dos_write(fd,mem,16384,&sz);
	close(fd);

	// finished

	return 0;
}

/* -------------------------------------------------------------------------- */