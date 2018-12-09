
//	ZX Spectrum emulator

//	Psion screen drawing routines
//	(c) Freeman, September 2000, Prague

/* ------------------------------------------------------------------------- */

#include <plib.h>

#include "zxscreen.h"
#include "zxdev.h"

/* ------------------------------------------------------------------------- */

#define		SHRINKED_ROW_1		0			// which row to shrink out
#define		SHRINKED_ROW_2		23			// which row to shrink out

/* ------------------------------------------------------------------------- */

static ColorMode		colorMode;			// current color mode
static int				drawBorder;			// draw border ?

/* ------------------------------------------------------------------------- */

static UWORD			rowStarts[160];		// screen rows starts

/* ------------------------------------------------------------------------- */

void SetColorMode(ColorMode mode)

{
	// clear gray plane under ZX Spectrum screen area

	if(colorMode == ZX_CLR_GRAY && mode != ZX_CLR_GRAY)
		ZXEraseGray();

	// store new color mode

	colorMode = mode;
}

/* ------------------------------------------------------------------------- */

void SetMappingMode(MappingMode mode, int pan)

{
	int		row;
	UWORD * ptr = rowStarts;

	// calculate image rows starts

	for(row = pan; row < 192+pan; row++)
	{
		// each character row shrinking ?
		
		if(mode != ZX_MAP_PAN && row%8 == SHRINKED_ROW_1)
			continue;

		// additional shrinking ?

		if(mode == ZX_MAP_FIT && row%24 == SHRINKED_ROW_2)
			continue;

		// calculate and store address

		*(ptr++) = 0x4000 + (row/64)*2048 + (row%8)*256 + (row%64/8)*32;

		// finished ?

		if(ptr == rowStarts+160)
			break;
	}
}

/* ------------------------------------------------------------------------- */

void SetDrawBorder(int draw)

{
	// clear existing border

	if(drawBorder && !draw)
		ZXDrawBorder(0);

	// store the flag

	drawBorder = draw;
}

/* ------------------------------------------------------------------------- */

void DrawScreen(int flash)

{
	// redraw screen

	ZXDrawScreen(rowStarts,((UWORD)flash << 15) | 0x7F00 | colorMode);

	// redraw border if needed

	if(drawBorder)
		ZXDrawBorder(colorMode);
}

/* ------------------------------------------------------------------------- */
