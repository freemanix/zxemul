
//	ZX Spectrum emulator

//	Psion keyboard scanning routines
//	(c) Freeman, September 2000, Prague

#ifndef	__ZXKEY_H
#define	__ZXKEY_H

/* ------------------------------------------------------------------------- */

// joystick types

typedef enum

{
	ZX_JOY_NONE,				// no joystick simulation
	ZX_JOY_KEMPSTON,			// kempston joystick
	ZX_JOY_SINCLAIR1,			// sinclair 1 joystick
	ZX_JOY_SINCLAIR2,			// sinclair 2 joystick
	ZX_JOY_CURSOR,				// cursor joystick
	ZX_JOY_FULLER				// fuller joystick

}	JoyType;

/* ------------------------------------------------------------------------- */

// call to initialize keyboard scanning 

void InitKeys(void);

/* ------------------------------------------------------------------------- */

// scan currently pressed keys and set appropriate ZX ports
// return TRUE if system key is pressed

int ScanKeys(JoyType joy);

/* ------------------------------------------------------------------------- */

#endif
