
//	ZX Spectrum emulator

//	Memory snapshots loading and saving
//	(c) Freeman, September 2000, Prague

#ifndef	__ZXSNAP_H
#define	__ZXSNAP_H

/* ------------------------------------------------------------------------- */

// load memory range from given file

int LoadMemory(void * file, UWORD from, UWORD size);

/* ------------------------------------------------------------------------- */

// save memory range into given file

int SaveMemory(void * file, UWORD from, UWORD size);

/* ------------------------------------------------------------------------- */

// save memory range as raw data into the file

int SaveRawFile(const char * filename, UWORD from, UWORD size);

/* ------------------------------------------------------------------------- */

// load memory range as raw data into the file

int LoadRawFile(const char * filename, UWORD from, UWORD size);

/* ------------------------------------------------------------------------- */

// save memory and registers into SNA file 

int SaveSNAFile(const char * filename);

/* ------------------------------------------------------------------------- */

// load SNA file into memory and set registers

int LoadSNAFile(const char * filename);

/* ------------------------------------------------------------------------- */

// save memory and registers into Z80 file

int SaveZ80File(const char * filename);

/* ------------------------------------------------------------------------- */

// load Z80 file into memory and set registers

int LoadZ80File(const char * filename);

/* ------------------------------------------------------------------------- */

#endif
