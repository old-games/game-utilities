/***************************************************************
 * Name:      bmpribbonctrl.cpp
 * Purpose:   
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-05-12
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "drawpanel.h"
#include "bmpribbonctrl.h"



BitmapRibbonCtrl::BitmapRibbonCtrl(  wxWindow* parent ):
	BitmapRibbonGui( parent ),
	mThumbnails( new DrawPanelArray( 0 ) ),
	mCurrent( 0 ),
	mToShow( 3 )
{
}

BitmapRibbonCtrl::~BitmapRibbonCtrl(void)
{
	Clear();
}

void BitmapRibbonCtrl::Clear()
{
	WX_CLEAR_ARRAY( *mThumbnails );
	mThumbnails->Clear();
}

void BitmapRibbonCtrl::Reserve( size_t n )
{
	Clear();
	//mThumbnails->SetCount( n, NULL );
}

void BitmapRibbonCtrl::RefillHolder()
{
	size_t _max = mThumbnails->GetCount() - mToShow;
	if ( mCurrent > _max )
	{
		mCurrent = _max;
	}
	size_t from = mCurrent;
	size_t to = mCurrent + mToShow;
	mBitmapsHolder->Clear();
	for ( size_t i = from; i < to; ++i )
	{
		mBitmapsHolder->Add( mThumbnails->Item(i), 1, wxEXPAND|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5  );
	}
	mBitmapsHolder->Layout();
	this->Refresh();
}

void BitmapRibbonCtrl::SetBitmap( size_t n, wxBitmap* bmp )
{
	DrawPanel* dp = new DrawPanel( this );
	dp->SetAlign( utdHCenter | utdVCenter | utdExactFit );
	dp->SetDrawFocus( true );
	dp->SetBitmap( bmp );

	mThumbnails->Insert( dp, n );
}

void BitmapRibbonCtrl::DoIncrement( int step )
{
	if (mCurrent + step < mThumbnails->GetCount() )
	{
		mCurrent += step;
		RefillHolder();
	}
}

/* virtual */ void BitmapRibbonCtrl::OnButtonClick( wxCommandEvent& event )
{ 
	int inc = 1;
	switch ( event.GetId() )
	{
		case wxID_SCROLLLEFT_BTN:
			inc = -1;
		case wxID_SCROLLRIGHT_BTN:
			DoIncrement( inc );
		break;

		default:
			wxLogMessage( wxString::Format("BitmapRibbonCtrl::OnButtonClick: Unknown button id: %d", event.GetId()) );
		break;
	}
	event.Skip(); 
}
