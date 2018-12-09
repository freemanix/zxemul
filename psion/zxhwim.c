
//	ZX Spectrum emulator

//	HWIM GUI application
//	(c) Freeman, September 2000, Prague

/* ------------------------------------------------------------------------- */

#include <plib.h>
#include <hwim.h>
#include <files.g>
#include <zxemul.g>
#include <zxemul.rsg>

#include "zxdev.h"
#include "zxkey.h"
#include "zxscreen.h"
#include "zxsnap.h"

/* ------------------------------------------------------------------------- */

extern char			*	DatProcessNamePtr;
extern char			*   DatUsedPathNamePtr;
extern char			*	DatCommandPtr;
extern WSERV_SPEC	*	wserv_channel;
extern PR_WSERV		*	w_ws;
extern PR_HWIMMAN	*	w_am;

/* ------------------------------------------------------------------------- */

static const char	*	extStat[2] = { ".Z80", ".SNA" };
static const char	*	clrStat[3] = { "Ink", "B&W", "Gray" };
static const char	*	mapStat[3] = { "Pan", "Shrink", "Fit" };
static const char	*	joyStat[6] = { "None", "Kempston", "Sinclair 1", 
                                       "Sinclair 2", "Cursor", "Fuller" };

static const int		mapPan[3]  = { 4, 1, 0 };

/* ------------------------------------------------------------------------- */

static const int		keySft[4]  = { 2, 27, 42, 2 };
static const UBYTE		grpBit[16] = 

{
	0xF0, 0x00, 0x0F, 0x00, 0xFF, 0x00, 0x00, 0xF0, 
	0xF0, 0xF0, 0x0F, 0xF0, 0xFF, 0xF0, 0x00, 0x00
};

/* ------------------------------------------------------------------------- */

static PR_ZXENG		*	zxeng;					// emulation engine
static PR_ZXSTAT	*	zxstat;					// zx status window

static int				running;				// is emulation running ?
static int				paused;					// is emulation paused  ?
static int				restore;				// last emulation state 

static P_EXTENT			statExt;				// status window extent
static W_WINDATA		mainWin;				// main window data

static int				filefmt;				// current file format 
static char				filename[P_FNAMESIZE];	// current file name

/* ------------------------------------------------------------------------- */

static ColorMode	clrMode = ZX_CLR_GRAY;		// current color mode
static MappingMode	mapMode = ZX_MAP_FIT;		// current mapping mode
static int			drwBord = TRUE;				// border drawing enabled
static int			panning = 0;				// current mapping panning

static JoyType		joyType = ZX_JOY_KEMPSTON;	// joystick type
static int			keyClicks  = FALSE;			// key clicks
static UWORD		opsPerInt  = 6000;			// Z80 instructions per INT
static UWORD		scrRefresh = 4;				// screen refresh
static int			romPatch   = TRUE;			// patch ROM ?

static int			flashCycle;					// flash cycle

/* ------------------------------------------------------------------------- */

void MapChanged()

{
	// set new mode into the emulator and redraw status window

	SetMappingMode(mapMode,panning);
	p_send2(zxstat,O_WN_DODRAW);

	// force redraw if paused

	if(paused)
		p_send2(zxeng,O_AO_QUEUE);
}

/* ------------------------------------------------------------------------- */

void ClrChanged()

{
	// set new mode into the emulator and redraw status window

	SetColorMode(clrMode);
	SetDrawBorder(drwBord);
	wsSelectList(clrMode);

	// force redraw if paused

	if(paused)
		p_send2(zxeng,O_AO_QUEUE);
}

/* ------------------------------------------------------------------------- */

void PrefsChanged()

{
	UWORD addr;

	// enable/disable key clicks

	wDisableKeyClick(!keyClicks);

	// re-initialize keys processing

	InitKeys();

	// apply/undo ROM patch

	if(romPatch)
	{
		// modify to point to ROM

		addr = 0x386E;
		p_sgcopyto(gZXMem,0x33FC,&addr,2);
	}
	else
	{
		// modify to point to original location 0

		addr = 0x0000;
		p_sgcopyto(gZXMem,0x33FC,&addr,2);
	}
}

/* ------------------------------------------------------------------------- */

void RunEngine()

{
	// activate only if not running yet

	if(running++ == 0)
		p_send2(zxeng,O_AO_QUEUE);
}

/* ------------------------------------------------------------------------- */

void StopEngine()

{
	// deactivate if needed

	if(--running == 0)
		p_send2(zxeng,O_AO_CANCEL);
}

/* ------------------------------------------------------------------------- */

int CheckExtension(char * path)

{
	char		buf[P_FNAMESIZE];
	P_FPARSE	crk;

	// parse file name
	
	f_fparse(path,NULL,buf,&crk);

	// return index of extension

	return (p_scmp(buf+crk.system+crk.device+crk.path+crk.name,
		           extStat[0]) != 0);
}

/* ------------------------------------------------------------------------- */

void SaveSettings()

{
	int		data[10];
	int *	ptr = data;

	// fill data buffer with values

	*(ptr++) = 0x0100;
	*(ptr++) = clrMode;
	*(ptr++) = mapMode;
	*(ptr++) = drwBord;
	*(ptr++) = panning;
	*(ptr++) = joyType;
	*(ptr++) = keyClicks;
	*(ptr++) = opsPerInt;
	*(ptr++) = scrRefresh;
	*(ptr++) = romPatch;

	// store data as environment variable

	p_setenviron("ZXEMUL",6,data,20);
}

/* ------------------------------------------------------------------------- */

void LoadSettings()

{
	int		data[10];
	int *	ptr = data;
	int     sz;

	// get data from environment variable

	sz = p_getenviron("ZXEMUL",6,data);

	// use only 1.0 version info

	if(sz == 20 && *(ptr++) <= 0x0100)
	{
		clrMode    = *(ptr++);
		mapMode    = *(ptr++);
		drwBord    = *(ptr++);
		panning    = *(ptr++);
		joyType    = *(ptr++);
		keyClicks  = *(ptr++);
		opsPerInt  = *(ptr++);
		scrRefresh = *(ptr++);
		romPatch   = *(ptr++);
	}
}

/* ------------------------------------------------------------------------- */

void main(void)

{
	IN_HWIMMAN	app;
	IN_WSERV	ws;

	// link to ROM libraries

	p_linklib(0);

	// setup parameters

	app.flags		= FLG_APPMAN_RSCFILE | FLG_APPMAN_SRSCFILE | 
					  FLG_APPMAN_CLEAN   | FLG_APPMAN_FULLSCREEN;
	app.wserv_cat	= p_getlibh(CAT_ZXEMUL_ZXEMUL);
	app.wserv_class = C_ZXWS;
	ws.com_cat		= p_getlibh(CAT_ZXEMUL_ZXEMUL);
	ws.com_class    = C_ZXCOM;

	// create application manager and initialize it

	p_send4(p_new(CAT_ZXEMUL_HWIM,C_HWIMMAN),O_AM_INIT,&app,&ws);
}

/* ========================================================================= */

#pragma METHOD_CALL

/* ========================================================================= */

METHOD void zxws_ws_dyn_init(PR_ZXWS * self)

{
	PR_ZXSPLASH * splash;

	// check screen size

	if(p_getlcd() != E_LCD_480_160)
		p_leave(E_GEN_NSUP);

	// check window server version

	if((wserv_channel->conn.info.version_id & WS_VERSION_MASK) < WS_VERSION_4)
		p_leave(E_GEN_NSUP);

	// prevent switch to the other application during init

	wSystemModal(0);

	// check speed of processor

	if((p_romversion() >> 8) < 6)	
	{
		// this is not 3mx - update defaults

		opsPerInt  = 2000;
		scrRefresh = 6;
	}

	// load settings

	LoadSettings();

	// get status window extent

	wInquireStatusWindow(W_STATUS_WINDOW_BIG,&statExt);

	// create client window

	self->wserv.cli = f_newsend(CAT_ZXEMUL_ZXEMUL,C_ZXWIN,O_WN_INIT);

	// show standard status window

	wStatusWindow(W_STATUS_WINDOW_BIG);
	wsSetList(3,clrStat,clrMode);

	// create and show left status window

	zxstat = f_newsend(CAT_ZXEMUL_ZXEMUL,C_ZXSTAT,O_WN_INIT);
	p_send2(zxstat,O_WN_DODRAW);

	// create and show splash window

	splash = f_newsend(CAT_ZXEMUL_ZXEMUL,C_ZXSPLASH,O_WN_INIT);
	p_send2(splash,O_WN_DODRAW);

	// setup help

	w_ws->wserv.help_index_id = ZXEMUL_HELP;

	// open emulation driver

	f_fparse("\\APP\\ZXEMUL\\ZXEMUL.LDD",DatCommandPtr,filename,NULL);
	f_leave(OpenDriver(filename));

	// load ZX Spectrum ROM

	f_fparse("\\APP\\ZXEMUL\\ZXEMUL.ROM",DatCommandPtr,filename,NULL);
	f_leave(LoadRawFile(filename,0x0000,0x4000));

	// process preferences

	PrefsChanged();
	ClrChanged();
	MapChanged();

	// now destroy the splash

	p_send2(splash,O_DESTROY);

	// run the emulation

	zxeng = f_new(CAT_ZXEMUL_ZXEMUL,C_ZXENG);
	p_send2(zxeng,O_AO_INIT);

	// process the command line

	p_send4(w_ws->wserv.com,O_COM_FILE_CHANGE,
		    w_am->hwimman.command,DatUsedPathNamePtr);

	// stop system modality

	wCancelSystemModal(0);
}

/* ------------------------------------------------------------------------- */

METHOD void zxws_ws_foreground(PR_ZXWS * self, UINT flags)

{
	// enable engine if it was running

	if(restore)
		RunEngine();
}

/* ------------------------------------------------------------------------- */

METHOD void zxws_ws_background(PR_ZXWS * self, UINT flags)

{
	// store status and disable engine

	restore = TRUE;
	StopEngine();
}

/* ------------------------------------------------------------------------- */

METHOD void zxws_ws_do_dial(PR_ZXWS * self, HANDLE cat, 
							int class, DL_DATA * pdata)

{
	// disable engine during dialogs

	StopEngine();
	p_supersend5(self,O_WS_DO_DIAL,cat,class,pdata);
	RunEngine();
}

/* ========================================================================= */

METHOD void zxwin_wn_init(PR_ZXWIN * self)

{
	mainWin.extent.tl.x   = statExt.width;
	mainWin.extent.tl.y	  = statExt.tl.y;
	mainWin.extent.width  = wserv_channel->conn.info.pixels.x-2*statExt.width;
	mainWin.extent.height = wserv_channel->conn.info.pixels.y;
	mainWin.background	  = W_WIN_BACK_CLR;

	// connect and show itself

	p_send5(self,O_WN_CONNECT,NULL,W_WIN_EXTENT | W_WIN_BACKGROUND,&mainWin);
	hInitVis(self);
}

/* ------------------------------------------------------------------------- */

METHOD void zxwin_wn_draw(PR_ZXWIN * self)

{
	// the border should be re-drawn

	ZXForceRedraw();

	// force single redraw if paused

	if(paused)
		p_send2(zxeng,O_AO_QUEUE);
}

/* ------------------------------------------------------------------------- */

METHOD int zxwin_wn_key(PR_ZXWIN * self, int keycode, int modifiers)

{
	keycode &= ~W_SPECIAL_KEY;

	// pan up ?

	if(keycode == W_KEY_PAGE_UP)
	{
		if(panning > 0)
		{
			panning -= 8;
			MapChanged();
		}

		return WN_KEY_CHANGED;
	}

	// pan down ?

	if(keycode == W_KEY_PAGE_DOWN)
	{
		if(panning < mapPan[mapMode]*8)
		{
			panning += 8;
			MapChanged();
		}

		return WN_KEY_CHANGED;
	}

	// terminate pause mode ?

	if(paused)
	{
		paused = FALSE;
		wCancelBusyMsg();
		RunEngine();

		return WN_KEY_CHANGED;
	}

	// enter pause mode ?

	if(keycode == W_KEY_ESCAPE)
	{
		hBusyPrint(0,STR_PAUSED);

		// stop engine

		StopEngine();
		paused = TRUE;

		// force single redraw

		p_send2(zxeng,O_AO_RUN);
		
		return WN_KEY_CHANGED;
	}

	// not processed

	return WN_KEY_NO_CHANGE;
}

/* ========================================================================= */

METHOD void zxstat_wn_init(PR_ZXSTAT * self)

{
	W_WINDATA	wd;

	wd.extent.tl.x   = 0;
	wd.extent.tl.y   = 0;
	wd.extent.width  = statExt.width-1;
	wd.extent.height = statExt.height;
	wd.background    = W_WIN_BACK_CLR;

	// connect and show itself

	p_send5(self,O_WN_CONNECT,NULL,W_WIN_EXTENT | W_WIN_BACKGROUND,&wd);
	hInitVis(self);
}

/* ------------------------------------------------------------------------- */

METHOD void zxstat_wn_draw(PR_ZXSTAT * self)

{
	int			i;
	P_RECT		rect;
	W_WINDATA	wd;

	// draw border

	p_supersend2(self,O_WN_DRAW);

	// set font

	hSetGFont(WS_FONT_BASE+9);
	wInquireWindow(self->win.id,&wd);

	// draw panning diagram

	rect.tl.x = 8;
	rect.br.x = wd.extent.width-8;
	rect.br.y = wd.extent.height-20;
	rect.tl.y = rect.br.y-3*24-4;

	gBorderRect(&rect,W_BORD_CORNER_2);

	p_insrec(&rect,2,2);
	rect.tl.y += 3*panning/8;
	rect.br.y  = rect.tl.y + 3*(24-mapPan[mapMode]);
	
	gFillPattern(&rect,WS_BITMAP_GREY,G_TRMODE_REPL);
	gDrawBox(&rect);

	// print title
	
	rect.tl.x = 2;
	rect.tl.y = 1;
	rect.br.x = wd.extent.width - 2;
	rect.br.y = 1 + 12;

	gPrintBoxText(&rect,10,G_TEXT_ALIGN_CENTRE,0,
		          DatProcessNamePtr,p_slen(DatProcessNamePtr));
	gDrawLine(0,rect.br.y+1,wd.extent.width,rect.br.y+1);

	// print list of modes

	rect.tl.y += 3;
	rect.br.y += 3;

	for(i = 0; i < 3; i++)
	{
		rect.tl.y += 12;
		rect.br.y += 12;

		// print list text

		gPrintBoxText(&rect,10,G_TEXT_ALIGN_LEFT,9,
			          mapStat[i],p_slen(mapStat[i]));

		// active ?

		if(mapMode == i)
			gPrintText(rect.tl.x,rect.tl.y+10,"\004",1);
	}

	gDrawLine(0,rect.br.y+1,wd.extent.width,rect.br.y+1);

	// print current joystick

	rect.br.y = wd.extent.height - 1;
	rect.tl.y = rect.br.y - 12;

	gPrintBoxText(&rect,10,G_TEXT_ALIGN_CENTRE,0,
		          joyStat[joyType],p_slen(joyStat[joyType]));
}

/* ========================================================================= */

METHOD void zxhelp_wn_init(PR_ZXHELP * self)

{
	W_WINDATA		wd;
	W_OPEN_BIT_SEG	bs;

	wd.extent.tl.x   = 0;
	wd.extent.tl.y	 = 0;
	wd.extent.width	 = wserv_channel->conn.info.pixels.x;
	wd.extent.height = wserv_channel->conn.info.pixels.y;
	wd.background	 = W_WIN_BACK_CLR | W_WIN_BACK_GREY_CLR;

	// disable possible flashing PAUSED

	wCancelBusyMsg();

	// load keymap from resources

	hLoadResource(ZXEMUL_KEYMAP,&self->zxhelp.keyMap);

	// prepare 8x8 bitmap for semigraphics

	bs.size.x = 8;
	bs.size.y = 8;

	self->zxhelp.bmpId  = gCreateBit(WS_BIT_SEG_ACCESS,&bs);
	self->zxhelp.bmpSeg = p_sgopen(bs.seg_name);

	// use itself as filter

	w_ws->wserv.filter = (PR_WIN *)self;

	// connect and show itself

	p_send5(self,O_WN_CONNECT,NULL,W_WIN_EXTENT | W_WIN_BACKGROUND,&wd);
	hInitVis(self);
}

/* ------------------------------------------------------------------------- */

METHOD void zxhelp_wn_draw(PR_ZXHELP * self)

{
	int		i, r, c;
	int		len, x, y;
	P_RECT	rect, br;
	P_POINT	pos;
	G_GC	gc;
	char  * keymap = self->zxhelp.keyMap;
	const UBYTE * msk = grpBit;
	UWORD	gr[8];

	// prepare bitmap rectangle

	br.tl.x = br.tl.y = 0;
	br.br.x = br.br.y = 8;

	// draw buttons

	for(y = 6, r = 0; r < 4; r++, y += 40)
	{
		rect.tl.y = y;
		rect.br.y = y + 25;

		for(x = keySft[r], c = 0; c < 10; c++, x += 44)
		{
			rect.tl.x = x;
			rect.br.x = x + 40;

			// CAPS SHIFT or SPACE ?

			if(r == 3 && (c == 0 || c == 9))
			{
				rect.br.x += 20;
				x += 20;
			}

			// draw button frame

			gDrawBox(&rect);

			gc.flags = G_GC_FLAG_GREY_PLANE;
			gSetGC(0,G_GC_MASK_GREY,&gc);
			gClrRect(&rect,G_TRMODE_SET);

			// print letter

			gc.flags = 0;
			gc.font  = WS_FONT_BASE+9;
			gSetGC(0,G_GC_MASK_FONT | G_GC_MASK_GREY,&gc);

			len = p_slen(keymap);
			gPrintText(x+4,y+13,keymap++,len);
			keymap += len;

			// print symbol

			gc.font  = WS_FONT_BASE+12;
			gSetGC(0,G_GC_MASK_FONT,&gc);

			// print semigraphics ?

			len = p_slen(keymap);

			if(*keymap == '#')
			{
				for(i = 0; i < 4; i++)
					gr[i] = *msk | 0x81;

				++msk;

				for(i = 4; i < 8; i++)
					gr[i] = *msk | 0x81;

				++msk;

				// add upper and lower border

				gr[0] |= 0xFF;
				gr[7] |= 0xFF;

				// set bitmap
			
				p_sgcopyto(self->zxhelp.bmpSeg,0,gr,16);
				
				// setup position

				pos.x = x+20;
				pos.y = y+4;

				// draw bitmap

				gCopyBit(&pos,self->zxhelp.bmpId,&br,G_TRMODE_REPL);
				wFlush();
				
				// skip #

				++keymap;
			}
			else
				gPrintText(x+15,y+11,keymap++,len);

			keymap += len;

			// print keyword

			len = p_slen(keymap);
			gPrintText(x+2,y+22,keymap++,len);
			keymap += len;

			// print upper keyword

			len = p_slen(keymap);
			gPrintText(x+0,y-1,keymap++,len);
			keymap += len;

			// print lower keyword

			len = p_slen(keymap);
			gPrintText(x+0,y+31,keymap++,len);
			keymap += len;
		}
	}

	// print irregular texts

	gPrintText(377,136,"SYMBOL",6);
	gPrintText(379,146,"SHIFT",5);
	gPrintText(443,101,"ENTER",5);
	gPrintText(434,135,"BREAK",5);

	gc.font  = WS_FONT_BASE+9;
	gSetGC(0,G_GC_MASK_FONT,&gc);

	gPrintText(430,147,"SPACE",5);

	gc.style = G_STY_BOLD;
	gc.font  = WS_FONT_BASE+8;
	gSetGC(0,G_GC_MASK_STYLE | G_GC_MASK_FONT,&gc);

	gPrintText(20,137,"CAPS",4);
	gPrintText(18,147,"SHIFT",5);
}

/* ------------------------------------------------------------------------- */

METHOD int zxhelp_wn_key(PR_ZXHELP * self)

{
	// free resource

	p_free(self->zxhelp.keyMap);

	// remove bitmap

	p_sgclose(self->zxhelp.bmpSeg);
	wFree(self->zxhelp.bmpId);

	// remove key filter

	w_ws->wserv.filter = NULL;

	// close itself

	p_send2(self,O_DESTROY);

	// restore paused notice

	if(paused)
		hBusyPrint(0,STR_PAUSED);

	// run engine

	RunEngine();

	// do not process key press to be immeditelly used

	return WN_KEY_CHANGED;
}

/* ========================================================================= */

METHOD void zxsplash_wn_init(PR_ZXSPLASH * self)

{
	W_WINDATA	wd;

	// fit into main client window

	wd.extent.tl.x   = 0;
	wd.extent.tl.y   = 0;
	wd.extent.width  = mainWin.extent.width;
	wd.extent.height = mainWin.extent.height;
	wd.background    = W_WIN_BACK_CLR | W_WIN_BACK_GREY_CLR;

	// connect and show itself

	p_send5(self,O_WN_CONNECT,w_ws->wserv.cli,
		    W_WIN_EXTENT|W_WIN_BACKGROUND,&wd);
	hInitVis(self);
}

/* ------------------------------------------------------------------------- */

METHOD void zxsplash_wn_draw(PR_ZXSPLASH * self)

{
	W_OPEN_BIT_SEG	bmp;
	P_POINT			dst;
	P_RECT			src;
	int				id;
	G_GC			gc;
	LONG			pos = 0x0034;
	UINT			offset;
	void		*	file;
	
	// open application file for reading

	f_open(&file,DatCommandPtr,P_FOPEN | P_FSTREAM | P_FRANDOM | P_FSHARE);
	f_seek(file,P_FABS,&pos);
	f_read(file,&offset,2);
	p_close(file);

	gSetOpenAddress(G_OPEN_MODE_OFFSET,offset);

	// open first bitmap

	id = gOpenBit(DatCommandPtr,0,0,&bmp);

	// setup destination

	dst.x = (mainWin.extent.width -bmp.size.x)/2;
	dst.y = (mainWin.extent.height-bmp.size.y)/2;

	// source is the complete bitmap

	src.tl.x = 0;
	src.tl.y = 0;
	src.br.x = bmp.size.x;
	src.br.y = bmp.size.y;

	// write to black plane

	gCopyBit(&dst,id,&src,G_TRMODE_SET);
	wFlush();
	wFree(id);

	// write to grey plane

	gSetOpenAddress(G_OPEN_MODE_OFFSET,offset);

	id = gOpenBit(DatCommandPtr,1,0,&bmp);
	gc.flags = G_GC_FLAG_GREY_PLANE;
	gSetGC(0,G_GC_MASK_GREY,&gc);
	gCopyBit(&dst,id,&src,G_TRMODE_SET);
	wFlush();
	wFree(id);
}

/* ========================================================================= */

METHOD void zxcom_com_mode_change(PR_ZXCOM * self, int shifted)

{
	if(shifted)
	{
		// update mapping mode

		mapMode = (mapMode+1)%3;
		panning = 0;

		// redraw left status

		MapChanged();
	}
	else
	{
		// update color mode

		clrMode = (clrMode+1)%3;

		// redraw right status

		ClrChanged();
	}
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_file_change(PR_ZXCOM * self, int command, char * pname)

{
	p_scpy(filename,pname);

	// create or open file ?

	switch(command)
	{
	case H_COMMAND_CREATE_FILE:

		// just reset the Spectrum

		ZXReset(gZXMem);
		break;

	case H_COMMAND_OPEN_FILE:

		hBusyPrint(0,STR_LOADING);

		// load file
	
		if(CheckExtension(filename))
			f_leave(LoadSNAFile(filename));
		else
			f_leave(LoadZ80File(filename));

		wCancelBusyMsg();
		break;
	}

	// store new file name

	p_send3(w_am,O_AM_NEW_FILENAME,filename);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_exit(PR_ZXCOM * self)

{
	// destroy engine to unload device driver

	p_send2(zxeng,O_DESTROY);

	// shutdown emulator

	CloseDriver();

	// save settings

	SaveSettings();

	// finished

	p_supersend2(self,O_COM_EXIT);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_new(PR_ZXCOM * self)

{
	char buf[P_FNAMESIZE];

	// change filename to ZXEMUL.Z80

	f_fparse("ZXEMUL.Z80",filename,buf,NULL);

	// reset engine

	p_send4(self,O_COM_FILE_CHANGE,H_COMMAND_CREATE_FILE,buf);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_open(PR_ZXCOM * self)

{
	DL_DATA	dlg;

	// present user a dialog to choose file

	dlg.id   = OPEN_FILE_DIALOG;
	dlg.rbuf = NULL;
	dlg.pdlg = NULL;

	// notify application about file change

	if(hLaunchDial(CAT_ZXEMUL_ZXEMUL,C_FILEDLG,&dlg))
		p_send4(self,O_COM_FILE_CHANGE,H_COMMAND_OPEN_FILE,filename);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_save_as(PR_ZXCOM * self)

{
	DL_DATA	dlg;

	// present user a dialog to choose file

	dlg.id   = SAVE_FILE_DIALOG;
	dlg.rbuf = NULL;
	dlg.pdlg = NULL;

	if(!hLaunchDial(CAT_ZXEMUL_ZXEMUL,C_FILEDLG,&dlg))
		return;

	// save file

	p_send2(self,O_COM_SAVE);

	// notify application about file change

	p_send3(w_am,O_AM_NEW_FILENAME,filename);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_save(PR_ZXCOM * self)

{
	// save under current file name

	hBusyPrint(0,STR_SAVING);

	// prepare directories if needed

	hEnsurePath(filename);

	// save in the appropriate format

	if(CheckExtension(filename))
		f_leave(SaveSNAFile(filename));
	else
		f_leave(SaveZ80File(filename));

	wCancelBusyMsg();
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_set_mode(PR_ZXCOM * self)

{
	DL_DATA	dlg;

	dlg.id   = VIEWMODE_DIALOG;
	dlg.rbuf = NULL;
	dlg.pdlg = NULL;

	// show dialog

	hLaunchDial(CAT_ZXEMUL_ZXEMUL,C_MODEDLG,&dlg);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_show_keys(PR_ZXCOM * self)

{
	// stop engine

	StopEngine();

	// create and show help window

	f_newsend(CAT_ZXEMUL_ZXEMUL,C_ZXHELP,O_WN_INIT);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_prefs(PR_ZXCOM * self)

{
	DL_DATA dlg;

	dlg.id   = PREFS_DIALOG;
	dlg.rbuf = NULL;
	dlg.pdlg = NULL;

	// show dialog

	hLaunchDial(CAT_ZXEMUL_ZXEMUL,C_PREFDLG,&dlg);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_reset(PR_ZXCOM * self)

{
	// just reset emulator

	ZXReset(gZXMem);
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_nmi(PR_ZXCOM * self)

{
	// generate NMI

	ZXGenNMI();
}

/* ------------------------------------------------------------------------- */

METHOD void zxcom_com_about(PR_ZXCOM * self)

{
	DL_DATA	dlg;

	dlg.id   = ABOUT_DIALOG;
	dlg.rbuf = NULL;
	dlg.pdlg = NULL;

	// show dialog

	hLaunchDial(CAT_ZXEMUL_HWIM,C_DLGBOX,&dlg);
}

/* ========================================================================= */

METHOD void zxeng_ao_init(PR_ZXENG * self)

{
	// set priority just below WSERV messages

	self->active.priority = PRIORITY_ACTIVE_COMMAND;

	// reset emulator

	ZXReset(gZXMem);
	ZXForceRedraw();

	// add itself into the queue

	p_send3(w_am,O_AM_ADD_TASK,self);

	// start itself

	RunEngine();
}

/* ------------------------------------------------------------------------- */

METHOD int zxeng_ao_run(PR_ZXENG * self)

{
	int i;

	// do not work if there is menu or help active

	if(!w_ws->wserv.bar && !w_ws->wserv.help && !w_ws->wserv.dial)
	{
		// redraw screen

		DrawScreen(flashCycle >= 25);		

		// paused ?

		if(!paused)
		{
			// emulate a given number of INTs

			for(i = 0; i < scrRefresh; i++)
			{
				// scan keyboard 

				ScanKeys(joyType);

				// generate interrupt

				ZXGenINT();

				// emulate a given amount of instructions

				ZXEmulate(opsPerInt);

				// advance flash cycle

				++flashCycle;
			}

			// normalize flash counter

			flashCycle %= 50;
		}
	}

	// add itself again into queue

	if(!paused)
		p_send2(self,O_AO_QUEUE);

	// finished

	return RUN_ACTIVE_USED;
}

/* ========================================================================= */

METHOD void filedlg_dl_dyn_init(PR_FILEDLG * self)

{
	// fill file name

	hDlgSet(1,filename);

	// update controls

	p_send3(self,O_DL_CHANGED,1);
}

/* ------------------------------------------------------------------------- */

METHOD void	filedlg_dl_changed(PR_FILEDLG * self, int index)

{
	char buf[P_FNAMESIZE];
	PR_FNSELWN * fil;
	
	// get file selection control
	
	fil = (PR_FNSELWN *)p_send3(self,O_DL_INDEX_TO_HANDLE,1);

	// get current file name

	p_send3(fil,O_WN_SENSE,buf);

	// select good extension

	if(index == 1)
		hDlgSetChlist(3,CheckExtension(buf));

	// set new file name and update the extension

	f_fparse(extStat[hDlgSenseChlist(3)],buf,buf,NULL);

	// force on dropped flags (ugly)

	fil->fnselwn.flags |= IN_FNSELWN_SET_DEFEXT | IN_FNSELWN_RESTRICT_LIST;
	p_send3(fil,O_WN_SET,buf);
}

/* ------------------------------------------------------------------------- */

METHOD int	filedlg_dl_key(PR_FILEDLG * self, int index,
				   	      int keycode, int actbut)

{
	// check file extension

	p_send3(self,O_DL_CHANGED,3);

	// fetch file name

	hDlgSense(1,filename);

	// finished

	return WN_KEY_CHANGED;
}

/* ========================================================================= */

METHOD void modedlg_dl_dyn_init(PR_MODEDLG * self)

{
	// fill dialog with the current values

	hDlgSetChlist(1,clrMode);
	hDlgSetChlist(2,mapMode);
	hDlgSetChlist(3,drwBord);
}

/* ------------------------------------------------------------------------- */

METHOD int  modedlg_dl_key(PR_MODEDLG * self, int index, 
						   int keycode, int actbut)

{
	// ignore changes if escape was pressed

	if(keycode == W_KEY_RETURN)
	{
		clrMode = hDlgSenseChlist(1);
		mapMode = hDlgSenseChlist(2);
		drwBord = hDlgSenseChlist(3);

		// modes may have changed

		MapChanged();
		ClrChanged();

		// border drawing may have changed

		SetDrawBorder(drwBord);
	}

	return WN_KEY_CHANGED;
}

/* ========================================================================= */

METHOD void prefdlg_dl_dyn_init(PR_PREFDLG * self)

{
	// fill dialog with the current values

	hDlgSetChlist(1,joyType);
	hDlgSetChlist(2,keyClicks);
	hDlgSetNcedit(3,scrRefresh);
	hDlgSetNcedit(4,opsPerInt);
	hDlgSetChlist(5,romPatch);
}

/* ------------------------------------------------------------------------- */

METHOD int  prefdlg_dl_key(PR_PREFDLG * self, int index, 
						   int keycode, int actbut)

{
	// ignore changes if escape was pressed

	if(keycode == W_KEY_RETURN)
	{
		joyType    = hDlgSenseChlist(1);
		keyClicks  = hDlgSenseChlist(2);
		scrRefresh = hDlgSenseNcedit(3);
		opsPerInt  = hDlgSenseNcedit(4);
		romPatch   = hDlgSenseChlist(5);

		// process key clicks

		wDisableKeyClick(!keyClicks);

		// re-initialize keys

		InitKeys();

		// redraw left status window

		p_send2(zxstat,O_WN_DODRAW);
	}

	return WN_KEY_CHANGED;
}

/* ========================================================================= */
