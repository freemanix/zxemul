
//	ZX Spectrum emulator

//	Screenshots saving
//	(c) Freeman, September 2000, Prague

/* ------------------------------------------------------------------------- */

#include <plib.h>
#include "zxpic.h"

/* ------------------------------------------------------------------------- */

typedef	struct

{
	ULONG		magic;
	UBYTE		version;
	UBYTE		runtime;
	UWORD		number;

}	PICheader;

/* ------------------------------------------------------------------------- */

typedef	struct

{
	UWORD		crc;
	UWORD		width;
	UWORD		height;
	UWORD		size;
	ULONG		offset;

}	BMPheader;

/* ------------------------------------------------------------------------- */

void SaveScreenshot(const char * filename, int style)

{
	


}

/* ------------------------------------------------------------------------- */
