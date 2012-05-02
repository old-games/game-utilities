/***************************************************************
 * Name:      drawpanel.cpp
 * Purpose:   DrawPanel class code
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-02
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "drawpanel.h"

#define SCALE_STEP	0.25f

DrawPanel::DrawPanel(  wxWindow* parent ):
	wxScrolledWindow( parent, Helpers::wxCustomPanelId++ ),
	SelectionRectangle( this ),
	mXAspectRatio( 0.0f ),
	mYAspectRatio( 0.0f ),
	mShowWidth( 0 ),
	mShowHeight( 0 ),
	mPosX( 0 ),
	mPosY( 0 ),
	mScale( 1.0f ),
	mScaleMin( SCALE_STEP ),
	mScaleMax( 50.0f ),
	mScaledWidth( 0 ),
	mScaledHeight( 0 ),
	mBitmapRect(),
	mMousePoint( -1, -1 ),
	mBitmap( NULL ),
	mWidth( 0 ),
	mHeight( 0 ),
	mAlign( utdNone ),
	mAllowScaling( true ),
	mPreviousSize( 0, 0 )
{
	this->SetBackgroundStyle( wxBG_STYLE_PAINT );
	this->SetDoubleBuffered( true );

	this->Bind( wxEVT_MOUSEWHEEL, &DrawPanel::OnMouseWheel, this );
	this->Bind( wxEVT_MOTION, &DrawPanel::OnMotion, this );
	this->Bind( wxEVT_LEFT_DOWN, &DrawPanel::OnBtnDown, this );
	this->Bind( wxEVT_LEFT_UP, &DrawPanel::OnBtnUp, this );
	this->Bind( wxEVT_RIGHT_DOWN, &DrawPanel::OnBtnDown, this );
	this->Bind( wxEVT_RIGHT_UP, &DrawPanel::OnBtnUp, this );
	this->Bind( wxEVT_KEY_DOWN, &DrawPanel::OnKeyDown, this );
	this->Bind( wxEVT_KEY_UP, &DrawPanel::OnKeyUp, this );


	this->Bind( wxEVT_PAINT, &DrawPanel::OnPaint, this );
	this->Bind( wxEVT_SIZE, &DrawPanel::OnSize, this);

	this->Bind( wxEVT_ENTER_WINDOW, &DrawPanel::OnEnterWindow, this );

}

DrawPanel::~DrawPanel(void)
{

	this->Unbind( wxEVT_MOUSEWHEEL, &DrawPanel::OnMouseWheel, this );
	this->Unbind( wxEVT_MOTION, &DrawPanel::OnMotion, this );
	this->Unbind( wxEVT_LEFT_DOWN, &DrawPanel::OnBtnDown, this );
	this->Unbind( wxEVT_LEFT_UP, &DrawPanel::OnBtnUp, this );
	this->Unbind( wxEVT_RIGHT_DOWN, &DrawPanel::OnBtnDown, this );
	this->Unbind( wxEVT_RIGHT_UP, &DrawPanel::OnBtnUp, this );
	this->Unbind( wxEVT_KEY_DOWN, &DrawPanel::OnKeyDown, this );
	this->Unbind( wxEVT_KEY_UP, &DrawPanel::OnKeyUp, this );

	this->Unbind( wxEVT_PAINT, &DrawPanel::OnPaint, this );
	this->Unbind( wxEVT_SIZE, &DrawPanel::OnSize, this );

	this->Unbind( wxEVT_ENTER_WINDOW, &DrawPanel::OnEnterWindow, this );



	DestroyBitmap();
}

void DrawPanel::SetAlign( int align )
{
	mAlign = align;
}

void DrawPanel::SetAllowScaling( bool b /* true */)
{
	mAllowScaling = b;
}

void DrawPanel::CreateBitmap( Pixel* buffer, int width, int height )
{
	DestroyBitmap();
	wxImage image( width, height, (wxByte*) buffer, true );
	mBitmap = new wxBitmap( image );
	ApplyBitmap();
}

void DrawPanel::SetBitmap( wxBitmap* bitmap )
{
	if ( !bitmap->IsOk() )
	{
		wxLogError("DrawPanel::SetBitmap: bad bitmap!");
		return;
	}
	DestroyBitmap();
	mBitmap = bitmap;
	ApplyBitmap();
}

void DrawPanel::ApplyBitmap()
{
	if ( !mBitmap || !mBitmap->IsOk() )
	{
		wxLogError("DrawPanel::ApplyBitmap: bad bitmap!");
		return;
	}
	mWidth = mBitmap->GetWidth();
	mHeight = mBitmap->GetHeight();
	mBitmapRect = wxRect( 0, 0, mWidth, mHeight );
	SetBitmapScale( mScale );
}

void DrawPanel::DestroyBitmap()
{
	delete mBitmap;
	mBitmap = NULL;
}

void DrawPanel::SetBuffer( Pixel* buffer )
{
	if ( !mBitmap || !mBitmap->IsOk() )
	{
		return;
	}
	DestroyBitmap();
	wxImage image( mWidth, mHeight, (wxByte*) buffer, true );
	mBitmap = new wxBitmap( image );
	PaintNow();
}

void DrawPanel::SetBitmapScale( wxDouble scale )
{
	mScale = scale;
	mScaledWidth = (wxDouble) mWidth * mScale;
	mScaledHeight = (wxDouble) mHeight * mScale;
	SetShowParams();
}

void DrawPanel::SetScaleRange( wxDouble min, wxDouble max )
{
	mScaleMin = min;
	mScaleMax = max;
	if ( mScale < mScaleMin )
	{
		SetBitmapScale( mScaleMin );
	}
	if ( mScale > mScaleMax )
	{
		SetBitmapScale( mScaleMax );
	}
}

/* virtual */ void DrawPanel::OnEnterWindow( wxMouseEvent& event )
{
	this->SetFocus();
	event.Skip();
}

/* virtual */ void DrawPanel::Render(wxDC& dc)
{
	if (!mBitmap || !mBitmap->IsOk())
	{
		return;
	}
	wxMemoryDC mdc;
	mdc.SelectObjectAsSource( *mBitmap );
	dc.Clear();
	if (!dc.StretchBlit(0, 0, mShowWidth, mShowHeight, &mdc, 0, 0, mWidth, mHeight))
    {
        wxLogError("DrawPanel::Render error: stretchblit failed!");
    }
	RenderSelection( dc );
}

/* virtual */ void DrawPanel::OnPaint( wxPaintEvent& event )
{
	wxAutoBufferedPaintDC dc(this);
	if (!mBitmap || !mBitmap->IsOk())
	{
		dc.Clear();
		event.Skip();
		return;
	}
	int x, y;
	this->GetViewStart(&x, &y);
	dc.SetDeviceOrigin( mPosX - x, mPosY - y);
	Render( dc );
	event.Skip();

}

void DrawPanel::PaintNow()
{
    this->Refresh();
}

inline void DrawPanel::CalculateScrollBars()
{
	int x,y;
	this->GetViewStart( &x, &y );
	SetScrollbars(1, 1, mShowWidth, mShowHeight, x, y, true);

}

/* virtual */ inline void DrawPanel::SetShowParams()
{
	mShowWidth = mScaledWidth;
	mShowHeight = mScaledHeight;

	wxSize bounds = this->GetClientSize();
	int clw = bounds.GetWidth();
	int clh = bounds.GetHeight();
//	wxLogMessage(wxString::Format("clw: %d, clh: %d", clw, clh));
	mPosX = 0;
	mPosY = 0;
	if ( mAlign != utdNone )
	{
		int halfHeight = clh / 2;
		int halfWidth = clw / 2;

		mXAspectRatio = (wxDouble) clw / (wxDouble) mScaledWidth;
		mYAspectRatio = (wxDouble) clh / (wxDouble) mScaledHeight;

		if ( (mAlign & utdExactFit) != 0)
		{
			wxDouble modifier = 1.000f;
			if ( clw < mWidth && clh < mScaledHeight )
			{
				modifier = clw > clh ? mYAspectRatio : mXAspectRatio;
			}
			else
			{
				if ( clw < mScaledWidth )
				{
					modifier = mXAspectRatio;
				}
				if ( clh < mScaledHeight )
				{
					modifier = mYAspectRatio;
				}
			}
			mShowWidth *= modifier;
			mShowHeight *= modifier;
		}

		if ( (mAlign & utdExpand) != 0 )
		{
			if (clw > mScaledWidth && clh > mScaledHeight)
			{
				wxDouble modifier = mYAspectRatio > mXAspectRatio ? mXAspectRatio : mYAspectRatio;
				mShowWidth *= modifier;
				mShowHeight *= modifier;
			}
		}

		if ( (mAlign & utdStretch) != 0 )
		{
			mShowHeight = clh;
			mShowWidth = clw;
		}

		if ( (mAlign & utdHCenter) != 0 && clw > mShowWidth )
		{
			mPosX = halfWidth - mShowWidth / 2;
		}
		if ( (mAlign & utdVCenter) != 0 && clh > mShowHeight )
		{
			mPosY = halfHeight - mShowHeight / 2;
		}
		if ( (mAlign & utdLeft) != 0 )
		{
			mPosX = 0;
		}
		if ( (mAlign & utdRight) != 0 )
		{
			mPosX = clw - mShowWidth;
		}
		if ( (mAlign & utdUp) != 0 )
		{
			mPosY = 0;
		}
		if ( (mAlign & utdDown) != 0 )
		{
			mPosY = clh - mShowHeight;
		}
	}
	CalculateScrollBars();
	SetWorkZone( wxRect(mPosX, mPosY, mShowWidth, mShowHeight), mScale );
}

/* virtual */ void DrawPanel::OnSize(wxSizeEvent& event)
{
    if ( event.GetSize() != mPreviousSize )
    {
        SetShowParams();
        mPreviousSize = event.GetSize();
    }
	event.Skip();
}

/* virtual */ void DrawPanel::OnMouseWheel( wxMouseEvent &event )
{
	if (!MouseWheel( event.GetModifiers(), event.GetWheelRotation() ))
	{
		event.Skip();
	}
}

/* virtual */ void DrawPanel::OnKeyDown( wxKeyEvent& event )
{
	if ( !KeyDown( event.GetModifiers(), event.GetKeyCode() ) )
	{
		event.Skip();
	}
}

/* virtual */ void DrawPanel::OnKeyUp( wxKeyEvent& event )
{
	if ( !KeyUp( event.GetModifiers(), event.GetKeyCode() ) )
	{
		event.Skip();
	}
}

/* virtual */ bool DrawPanel::KeyDown( int WXUNUSED( modifier ), int keyCode )
{
	bool res = false;
	switch ( keyCode )
	{
		case WXK_NUMPAD_ADD:
		case WXK_NUMPAD_SUBTRACT:
			res = this->PlusMinusPressed( keyCode == WXK_NUMPAD_ADD );
		break;
	}
	return res;
}

/* virtual */ bool DrawPanel::KeyUp( int WXUNUSED( modifier ), int WXUNUSED( keyCode ) )
{
	return false;
}


/* virtual */ bool DrawPanel::PlusMinusPressed( bool plus )
{
	if ( !mAllowScaling )
	{
		return false;
	}
	wxDouble inc = plus ? SCALE_STEP : -SCALE_STEP;
	if (mScale + inc < mScaleMin || mScale + inc > mScaleMax)
	{
		return false;
	}
	SetBitmapScale( mScale + inc );
	PaintNow();
	return true;
}


/* virtual */ void DrawPanel::OnBtnDown( wxMouseEvent& event )
{
	if ( event.GetButton() != wxMOUSE_BTN_NONE )
	{
		if ( event.HasModifiers() )
		{
			MouseModifiersButton( event.GetModifiers(), event.GetButton(), false );
		}
		else
		{
			MouseButton( event.GetButton(), false );
		}
	}
	event.Skip();
}

/* virtual */ void DrawPanel::OnMotion( wxMouseEvent& event )
{
	mMousePoint = MousePosition2PointCoords( event.GetPosition() );
	MouseMoving( event.GetModifiers(), 0 );
	event.Skip();
}

/* virtual */ void DrawPanel::OnBtnUp( wxMouseEvent& event )
{
	if ( event.GetButton() != wxMOUSE_BTN_NONE )
	{
		if ( event.HasModifiers() )
		{
			MouseModifiersButton( event.GetModifiers(), event.GetButton(), true );
		}
		else
		{
			MouseButton( event.GetButton(), true );
		}
	}
	event.Skip();
}

/* virtual */ bool DrawPanel::MouseButton( int btn, bool up  )
{
	if ( up && !PointInZone( mMousePoint ) && btn != wxMOUSE_BTN_NONE )
	{
		ResetZone();
		return true;
	}
	return false;
}

/* virtual */ bool DrawPanel::MouseModifiersButton( int modifier, int btn, bool up  )
{
	if ( SelectionDragging() )
	{
		if ( btn == wxMOUSE_BTN_LEFT && up )
		{
			SelectionEnd();
			return true;
		}
	}
	if ( modifier == wxMOD_CONTROL )
	{
		if (btn == wxMOUSE_BTN_LEFT && !up)
		{
			SelectionBegin();
			if ( SelectionDragging() )
			{
				return true;
			}
		}
	}
	return false;
}

/* virtual */ bool DrawPanel::MouseMoving( int WXUNUSED( modifier ), int WXUNUSED( btn ) )
{
	if ( SelectionDragging() )
	{
		OnSelectionMotion();
		return true;
	}
	return false;
}

/* virtual */ bool DrawPanel::MouseWheel( int modifier, int delta )
{
	if ( modifier == wxMOD_CONTROL )
	{
		PlusMinusPressed( delta > 0 );
		return true;
	}
	return false;
}
