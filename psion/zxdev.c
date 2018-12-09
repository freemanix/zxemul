
//	ZX Spectrum emulator

//	ZXEMUL device driver interface
//	(c) Freeman, September 2000, Prague

/* ------------------------------------------------------------------------- */

#include <plib.h>

#include "zxdev.h"

/* ------------------------------------------------------------------------- */

#define		ZX_DRV_NAME		"ZXS"
#define		ZX_SEG_NAME		"ZXEMUL.MEM"

/* ------------------------------------------------------------------------- */

void	*	gZXS;			// ZXS device driver process control block
HANDLE		gZXMem;			// handle to 64KB segment of ZX memory 

/* ------------------------------------------------------------------------- */

int OpenDriver(const char * filename)

{
	int		err;

	// allocate memory

	gZXMem = p_sgcreate(ZX_SEG_NAME,0x1000,E_SEGMENT_HIGH);

	// check for error

	if(gZXMem < 0)
		return gZXMem;

	// load device

	err = p_loadldd(filename);

	// check for problem (ignore if the driver is already loaded)

	if(err && err != E_FILE_EXIST)
		return err;

	// try to open the driver

	return p_open(&gZXS,ZX_DRV_NAME ":",-1);
}

/* ------------------------------------------------------------------------- */

void CloseDriver(void)

{
	// try to free memory

	p_sgclose(gZXMem);

	// uload device driver

	p_devdel(ZX_DRV_NAME,E_LDD);
}

/* ------------------------------------------------------------------------- */

