
//	ZX Spectrum emulator

//	Psion keyboard scanning routines
//	(c) Freeman, September 2000, Prague

/* ------------------------------------------------------------------------- */

#include <plib.h>

#include "zxdev.h"
#include "zxkey.h"

/* ------------------------------------------------------------------------- */

#define		NORMAL_KEYMAP_SIZE		54
#define		SHIFT_KEYMAP_SIZE		12
#define		CURSOR_KEYMAP_SIZE		10
#define		JOY_KEYMAP_SIZE			 5
#define		SYSTEM_KEYMAP_SIZE		 5

#define		FE_PORT_DEFAULT			0xFF
#define		KEMPSTON_PORT			0x1F
#define		FULLER_PORT				0x7F

/* ------------------------------------------------------------------------- */

// Psion port & mask -> ZX Spectrum port & mask

typedef struct

{
	UBYTE	pind;		// Psion port index
	UWORD	pmsk;		// Psion port mask
	UBYTE	zind;		// ZX Spectrum port index
	UBYTE	zmsk;		// ZX Spectrum port mask
}	ScanConvert;

/* ------------------------------------------------------------------------- */

// Psion port & mask -> ZX Spectrum mask

typedef	struct

{
	UBYTE	pind;		// Psion port index
	UWORD	pmsk;		// Psion port mask
	UBYTE	zmsk;		// ZX Spectrum port mask
}	JoyConvert;

/* ------------------------------------------------------------------------- */

// Psion port & mask match

typedef struct

{
	UBYTE	pind;		// Psion port index
	UWORD	pmsk;		// Psion port mask
}	KeyMatch;

/* ------------------------------------------------------------------------- */

// keyboard mapping when Shift is not pressed

static ScanConvert	normalKeyMap[NORMAL_KEYMAP_SIZE] =

{
	{	7, 0x002, 4, 0x01	},		// 1
	{	7, 0x004, 4, 0x02	},		// 2
	{	5, 0x040, 4, 0x04	},		// 3
	{	4, 0x004, 4, 0x08	},		// 4
	{	4, 0x008, 4, 0x10	},		// 5
	{	7, 0x008, 3, 0x10	},		// 6
	{	3, 0x040, 3, 0x08	},		// 7
	{	2, 0x008, 3, 0x04	},		// 8
	{	2, 0x010, 3, 0x02	},		// 9
	{	1, 0x010, 3, 0x01	},		// 0

	{	6, 0x002, 5, 0x01	},		// Q
	{	6, 0x020, 5, 0x02	},		// W
	{	5, 0x020, 5, 0x04	},		// E
	{	4, 0x002, 5, 0x08	},		// R
	{	4, 0x010, 5, 0x10	},		// T
	{	0, 0x008, 2, 0x10	},		// Y
	{	3, 0x020, 2, 0x08	},		// U
	{	2, 0x004, 2, 0x04	},		// I
	{	2, 0x020, 2, 0x02	},		// O
	{	1, 0x020, 2, 0x01	},		// P

	{	6, 0x004, 6, 0x01	},		// A
	{	6, 0x010, 6, 0x02	},		// S
	{	5, 0x010, 6, 0x04	},		// D
	{	5, 0x002, 6, 0x08	},		// F
	{	4, 0x020, 6, 0x10	},		// G
	{	7, 0x040, 1, 0x10	},		// H
	{	3, 0x010, 1, 0x08	},		// J
	{	2, 0x002, 1, 0x04	},		// K
	{	2, 0x040, 1, 0x02	},		// L
	{	0, 0x001, 1, 0x01	},		// ENTER

	{	1, 0x080, 7, 0x01	},		// CAPS SHIFT
	{	6, 0x008, 7, 0x02	},		// Z
	{	6, 0x040, 7, 0x04	},		// X
	{	5, 0x008, 7, 0x08	},		// C
	{	5, 0x004, 7, 0x10	},		// V
	{	4, 0x040, 0, 0x10	},		// B
	{	0, 0x040, 0, 0x08	},		// N
	{	3, 0x008, 0, 0x04	},		// M
	{	3, 0x080, 0, 0x02	},		// SYMB SHIFT
	{	4, 0x001, 0, 0x01	},		// SPACE

	{	2, 0x001, 7, 0x01	},		// DEL -> CAPS SHIFT
	{	2, 0x001, 3, 0x01	},		// DEL -> 0

	{   1, 0x002, 0, 0x02	},		// / -> SYMB SHIFT
	{	1, 0x002, 7, 0x10	},		// / -> V

	{	1, 0x004, 0, 0x02	},		// - -> SYMB SHIFT
	{	1, 0x004, 1, 0x08	},		// - -> J

	{   1, 0x040, 0, 0x02	},		// * -> SYMB SHIFT
	{	1, 0x040, 0, 0x10	},		// * -> B

	{	7, 0x010, 0, 0x02	},		// . -> SYMB SHIFT
	{	7, 0x010, 0, 0x04	},		// . -> M

	{	3, 0x002, 0, 0x02	},		// , -> SYMB SHIFT
	{	3, 0x002, 0, 0x08	},		// , -> N

	{	1, 0x008, 0, 0x02	},		// + -> SYMB SHIFT
	{	1, 0x008, 1, 0x04	}		// + -> K
};

/* ------------------------------------------------------------------------- */

// keyboard mapping when Shift is pressed

static ScanConvert	shiftKeyMap[SHIFT_KEYMAP_SIZE] =

{
	{   1, 0x002, 0, 0x02	},		// ; -> SYMB SHIFT
	{	1, 0x002, 2, 0x02	},		// ; -> O

	{	1, 0x004, 0, 0x02	},		// _ -> SYMB SHIFT
	{	1, 0x004, 3, 0x01	},		// _ -> 0

	{   1, 0x040, 0, 0x02	},		// : -> SYMB SHIFT
	{	1, 0x040, 7, 0x02	},		// : -> Z

	{	7, 0x010, 0, 0x02	},		// > -> SYMB SHIFT
	{	7, 0x010, 5, 0x10	},		// > -> T

	{	3, 0x002, 0, 0x02	},		// < -> SYMB SHIFT
	{	3, 0x002, 5, 0x08	},		// < -> R

	{	1, 0x008, 0, 0x02	},		// = -> SYMB SHIFT
	{	1, 0x008, 1, 0x02	}		// = -> L
};

/* ------------------------------------------------------------------------- */

// cursor keys mapping

static ScanConvert	cursorKeyMap[CURSOR_KEYMAP_SIZE] = 

{
	{	0, 0x010, 7, 0x01	},		// LEFT -> CAPS SHIFT
	{	0, 0x010, 4, 0x10	},		// LEFT -> 5

	{	0, 0x002, 7, 0x01	},		// RIGHT -> CAPS SHIFT
	{	0, 0x002, 3, 0x04	},		// RIGHT -> 8

	{	7, 0x020, 7, 0x01	},		// UP -> CAPS SHIFT
	{	7, 0x020, 3, 0x08	},		// UP -> 7

	{	0, 0x020, 7, 0x01	},		// DOWN -> CAPS SHIFT
	{	0, 0x020, 3, 0x10	},		// DOWN -> 6

	{	0, 0x004, 7, 0x01	},		// FIRE	-> CAPS SHIFT
	{	0, 0x004, 3, 0x01	}		// FIRE -> 0
};

/* ------------------------------------------------------------------------- */

// joystick ports key mappings

static JoyConvert	kempstonJoyMap[JOY_KEYMAP_SIZE] =

{
	{  0, 0x010, 0x02	},			// LEFT 
	{  0, 0x002, 0x01	},			// RIGHT
	{  7, 0x020, 0x08	},			// UP   
	{  0, 0x020, 0x04	},			// DOWN	 
	{  0, 0x004, 0x10	}			// FIRE 
};

static JoyConvert	fullerJoyMap[JOY_KEYMAP_SIZE] = 

{
	{  0, 0x010, 0x04	},			// LEFT 
	{  0, 0x002, 0x08	},			// RIGHT
	{  7, 0x020, 0x01	},			// UP   
	{  0, 0x020, 0x02	},			// DOWN	 
	{  0, 0x004, 0x80	}			// FIRE 
};

static JoyConvert	sinclair1JoyMap[JOY_KEYMAP_SIZE] =

{
	{  0, 0x010, 0x10	},			// LEFT 
	{  0, 0x002, 0x08	},			// RIGHT
	{  7, 0x020, 0x02	},			// UP   
	{  0, 0x020, 0x04	},			// DOWN	 
	{  0, 0x004, 0x01	}			// FIRE 
};

static JoyConvert	sinclair2JoyMap[JOY_KEYMAP_SIZE] =

{
	{  0, 0x010, 0x01	},			// LEFT 
	{  0, 0x002, 0x02	},			// RIGHT
	{  7, 0x020, 0x08	},			// UP   
	{  0, 0x020, 0x04	},			// DOWN	 
	{  0, 0x004, 0x10	}			// FIRE 
};

/* ------------------------------------------------------------------------- */

static KeyMatch		sysKey[SYSTEM_KEYMAP_SIZE] =

{
	{	0, 0x080	},				// Psion   key
	{	5, 0x080	},				// Menu    key
	{	4, 0x080	},				// Diamond key
	{	3, 0x004	},				// Help	   key
	{	7, 0x100	}				// Esc	   key
};

/* ------------------------------------------------------------------------- */

static UBYTE		zxKeyPort[2][8];	// two port maps

static UBYTE *		newKeyPort;			// pointer to new key port
static UBYTE * 		oldKeyPort;			// pointer to old key port

static UWORD		psionKeys[10];		// currently pressed Psion keys

/* ------------------------------------------------------------------------- */

// convert currently pressed Psion keys with given table into ZX keys
// return TRUE if at least one mapping was found

int PsionToKey(ScanConvert * table, int size, UBYTE * dest)

{
	int	i;
	int	fnd = FALSE;

	// search table

	for(i = 0; i < size; i++, table++)
		if(psionKeys[table->pind] & table->pmsk)
		{
			dest[table->zind] &= ~table->zmsk;
			fnd = TRUE;
		}

	// return TRUE if at least one key found

	return fnd;
}

/* ------------------------------------------------------------------------- */

// convert currently pressed Psion keys with given table into ZX joy mask
// return TRUE if at least one mapping was found

UBYTE PsionToJoy(JoyConvert * table, int size)

{
	int i;
	UBYTE msk = 0;

	// search table

	for(i = 0; i < size; i++, table++)
		if(psionKeys[table->pind] & table->pmsk)
			msk |= table->zmsk;

	// return final mask

	return msk;
}

/* ------------------------------------------------------------------------- */

// return TRUE if at least one of Psion keys in given table was pressed

int CheckKeys(KeyMatch * table, int size)

{
	int i;

	// search table

	for(i = 0; i < size; i++, table++)
		if(psionKeys[table->pind] & table->pmsk)
			return TRUE;

	// not found

	return FALSE;
}

/* ------------------------------------------------------------------------- */

void InitKeys(void)

{
	int i;

	// reset joysticks

	ZXSetPort(KEMPSTON_PORT,0x00);
	ZXSetPort(FULLER_PORT,0xFF);

	// initialize pointers

	oldKeyPort = zxKeyPort[0];
	newKeyPort = zxKeyPort[1];

	// change old keys to force initial set

	for(i = 0; i < 8; i++)
		oldKeyPort[i] = ~FE_PORT_DEFAULT;
}

/* ------------------------------------------------------------------------- */

int ScanKeys(JoyType joy)

{
	int	i;
	UBYTE * tmp;

	// get Psion keyboard layout

	p_getscancodes(psionKeys);

	// if system key is pressed, quit immediately

	if(CheckKeys(sysKey,SYSTEM_KEYMAP_SIZE))
		return TRUE;

	// initialize 

	for(i = 0; i < 8; i++)
		newKeyPort[i] = FE_PORT_DEFAULT;

	// process both normal and shifted combinations

	if(!((psionKeys[1] & 0x080) || (psionKeys[3] & 0x080)) ||
	   !PsionToKey(shiftKeyMap,SHIFT_KEYMAP_SIZE,newKeyPort))
		PsionToKey(normalKeyMap,NORMAL_KEYMAP_SIZE,newKeyPort);

	// process joysticks

	switch(joy)
	{
	case ZX_JOY_KEMPSTON:

		ZXSetPort(KEMPSTON_PORT,PsionToJoy(kempstonJoyMap,JOY_KEYMAP_SIZE));
		break;

	case ZX_JOY_SINCLAIR1:

		newKeyPort[3] &= ~PsionToJoy(sinclair1JoyMap,JOY_KEYMAP_SIZE);
		break;

	case ZX_JOY_SINCLAIR2:

		newKeyPort[4] &= ~PsionToJoy(sinclair2JoyMap,JOY_KEYMAP_SIZE);
		break;

	case ZX_JOY_CURSOR:

		PsionToKey(cursorKeyMap,CURSOR_KEYMAP_SIZE,newKeyPort);
		break;

	case ZX_JOY_FULLER:

		ZXSetPort(FULLER_PORT,~PsionToJoy(fullerJoyMap,JOY_KEYMAP_SIZE));
		break;
	}

	// if the key status has changed since last test, update ports

	for(i = 0; i < 8; i++)
	{
		if(oldKeyPort[i] != newKeyPort[i])
		{
			ZXSetKeys(newKeyPort);
			break;
		}
	}

	// store old status

	tmp = oldKeyPort;
	oldKeyPort = newKeyPort;
	newKeyPort = tmp;

	// normal keys

	return FALSE;
}

/* ------------------------------------------------------------------------- */
