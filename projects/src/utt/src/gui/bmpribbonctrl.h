/***************************************************************
 * Name:      bmpribbonctrl.h
 * Purpose:   Bitmap ribbon control
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-05-12
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef BITMAPRIBBONCTRL_H_INCLUDED
#define BITMAPRIBBONCTRL_H_INCLUDED

#include "simplegui.h"

class DrawPanelArray;


class BitmapRibbonCtrl : public BitmapRibbonGui
{
public:
	BitmapRibbonCtrl( wxWindow* parent );
	~BitmapRibbonCtrl(void);

	void Reserve( size_t n );
	void SetBitmap( size_t n, wxBitmap* bmp );
	void RefillHolder();
	void DoIncrement( int step );

protected:

	virtual void OnButtonClick( wxCommandEvent& event );


private:

	void Clear();

	DrawPanelArray*		mThumbnails;
	size_t				mCurrent;
	size_t				mToShow;
};

#endif
