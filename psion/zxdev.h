
//	ZX Spectrum emulator

//	ZXEMUL device driver interface
//	(c) Freeman, September 2000, Prague

#ifndef	__ZXDEV_H
#define	__ZXDEV_H

/* ------------------------------------------------------------------------- */

// device driver function numbers

enum

{
	ZX_RESET,
	ZX_SETREGS,
	ZX_GETREGS,
	ZX_GENINT,
	ZX_GENNMI,
	ZX_EMULATE,
	ZX_SETPORT,
	ZX_GETPORT,
	ZX_SETKEYS,
	ZX_DRAWSCREEN,
	ZX_DRAWBORDER,
	ZX_ERASEGRAY,
	ZX_FORCEREDRAW
};

/* ------------------------------------------------------------------------- */

// all accessible Z80 registers

typedef struct

{
	UWORD		AF;
	UWORD		BC;
	UWORD		DE;
	UWORD		HL;
	UWORD		AF_;
	UWORD		BC_;
	UWORD		DE_;
	UWORD		HL_;
	UWORD		IX;
	UWORD		IY;
	UWORD		SP;
	UWORD		PC;
	UBYTE		R;
	UBYTE		I;
	UBYTE		IFF;		
	UBYTE		IM;		

}	Z80Regs;

/* ------------------------------------------------------------------------- */

extern void * gZXS;			// ZXS device driver process control block
extern HANDLE gZXMem;		// handle to 64KB segment of ZX memory 

/* ------------------------------------------------------------------------- */

// load, open and initialize ZXEMUL logical device driver, allocate memory

int OpenDriver(const char * filename);

/* ------------------------------------------------------------------------- */

// shutdown and unload ZXEMUL logical device driver, free memory

void CloseDriver(void);

/* ------------------------------------------------------------------------- */

// reset emulated processor, specify segment of 64kB ZX Spectrum memory

static void inline ZXReset(HANDLE mem)

{
	p_iow3(gZXS,ZX_RESET,(void *)mem);
}

/* ------------------------------------------------------------------------- */

// set new values into the Z80 registers

static void inline ZXSetRegs(Z80Regs * regs)

{
	p_iow3(gZXS,ZX_SETREGS,(void *)regs);
}

/* ------------------------------------------------------------------------- */

// get current values of Z80 registers

static void inline ZXGetRegs(Z80Regs * regs)

{
	p_iow3(gZXS,ZX_GETREGS,(void *)regs);
}

/* ------------------------------------------------------------------------- */

// generate INT signal

static void inline ZXGenINT(void)

{
	p_iow2(gZXS,ZX_GENINT);
}

/* ------------------------------------------------------------------------- */

// generate NMI signal

static void inline ZXGenNMI(void)

{
	p_iow2(gZXS,ZX_GENNMI);
}

/* ------------------------------------------------------------------------- */

// emulate next ops instructions 

static void inline ZXEmulate(UWORD ops)

{
	p_iow3(gZXS,ZX_EMULATE,(void *)ops);
}

/* ------------------------------------------------------------------------- */

// output new value into the given port

static void inline ZXSetPort(UBYTE port, UBYTE val)

{
	p_iow4(gZXS,ZX_SETPORT,(void *)port,(void *)val);
}

/* ------------------------------------------------------------------------- */

// input a value from the given port

static UBYTE inline ZXGetPort(UBYTE port)

{
	return p_iow3(gZXS,ZX_GETPORT,(void *)port);
}

/* ------------------------------------------------------------------------- */

// process 8 bytes of 0x7F, 0xBF, ... keyboard ports

static void inline ZXSetKeys(UBYTE * keys)

{
	p_iow3(gZXS,ZX_SETKEYS,(void *)keys);
}

/* ------------------------------------------------------------------------- */

// redraw screen in given rows mapping and color mode
// higher byte of mode is either 0x7F or 0xFF (flashing)

static void inline ZXDrawScreen(UWORD * rows, UWORD mode)

{
	p_iow4(gZXS,ZX_DRAWSCREEN,rows,(void *)mode);
}

/* ------------------------------------------------------------------------- */

// draw border in given color mode

static void inline ZXDrawBorder(UWORD mode)

{
	p_iow3(gZXS,ZX_DRAWBORDER,(void *)mode);
}

/* ------------------------------------------------------------------------- */

// erase both border and screen are in the gray plane
// used for switching modes from gray to other ones

static void inline ZXEraseGray(void)

{
 	p_iow2(gZXS,ZX_ERASEGRAY);
}

/* ------------------------------------------------------------------------- */

// force redrawing of border on next drawing

static void inline ZXForceRedraw(void)

{
	p_iow2(gZXS,ZX_FORCEREDRAW);
}

/* ------------------------------------------------------------------------- */

#endif
