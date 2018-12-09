
//	ZX Spectrum emulator

//	Psion screen drawing routines
//	(c) Freeman, September 2000, Prague

#ifndef	__ZXSCREEN_H
#define	__ZXSCREEN_H

/* ------------------------------------------------------------------------- */

// color modes

typedef enum 

{
	ZX_CLR_INK,				// ink only
	ZX_CLR_BW,				// black & white
	ZX_CLR_GRAY				// 3 levels of gray

}	ColorMode;

/* ------------------------------------------------------------------------- */

// screen mapping modes

typedef enum

{
	ZX_MAP_PAN,				//  no shrinking - 4 characters row panning
	ZX_MAP_SHRINK,			// 7:8 shrinking - 1 characters row panning
	ZX_MAP_FIT				// 5:6 shrinking - screen fits

}	MappingMode;

/* ------------------------------------------------------------------------- */

// set new color mode

void SetColorMode(ColorMode mode);

/* ------------------------------------------------------------------------- */

// set new mapping mode and panning (in screen (not character) rows)

void SetMappingMode(MappingMode mode, int pan);

/* ------------------------------------------------------------------------- */

// enable/disable border drawing

void SetDrawBorder(int draw);

/* ------------------------------------------------------------------------- */

// redraw the screen (and border) with flashing on or off

void DrawScreen(int flash);

/* ------------------------------------------------------------------------- */

#endif
