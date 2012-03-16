/***************************************************************
 * Name:      drawpanel.h
 * Purpose:   DrawPanel class declaration
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-02
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef DRAWPANEL_H_INCLUDED
#define DRAWPANEL_H_INCLUDED

#include "selectrect.h"

enum UTTDrawParams
{
	utdNone		= 0x0000,
	utdReserve	= 0x0001,
	utdLeft		= 0x0002,
	utdHCenter  = 0x0004,
	utdVCenter  = 0x0008,
	utdRight	= 0x0010,
	utdUp		= 0x0020,
	utdDown		= 0x0040,
	utdExpand	= 0x0080,
	utdExactFit = 0x0100,
	utdStretch	= 0x0200
};

class DrawPanel :
	public wxScrolledWindow, public SelectionRectangle
{
public:

	DrawPanel( wxWindow* parent );
	virtual ~DrawPanel(void);

	void SetBitmap( wxBitmap* bitmap );
	void CreateBitmap(Pixel* buffer, int width, int height);
	void SetBuffer( Pixel* buffer );
	void SetScale( wxFloat32 scale );
	void SetScaleRange( wxFloat32 min, wxFloat32 max );
	void SetAlign( int align );
	void SetAllowScaling( bool b = true );

protected:

	virtual void OnMouseWheel( wxMouseEvent &event );
	virtual void OnBtnDown( wxMouseEvent& event );
	virtual void OnMotion( wxMouseEvent& event );
	virtual void OnBtnUp( wxMouseEvent& event );
	virtual void OnKeyDown( wxKeyEvent& event );
	virtual void OnKeyUp( wxKeyEvent& event );
	
	virtual void OnFocus(wxFocusEvent& event);
	virtual void OnChildFocus(wxChildFocusEvent& event);
	virtual void OnPaint(wxPaintEvent& event);
	virtual void OnSize(wxSizeEvent& event);
	virtual void Render(wxDC& dc);
	
	virtual bool MouseButton( int btn, bool up );
	virtual bool MouseModifiersButton( int modifier, int btn, bool up );
	virtual bool MouseMoving( int modifier, int btn );
	virtual bool MouseWheel( int modifier, int delta );
	
	virtual bool KeyDown( int modifier, int keyCode );	
	virtual bool KeyUp( int modifier, int keyCode );	
	virtual bool PlusMinusPressed( bool plus );

	void PaintNow();
	void DestroyBitmap();
	void ApplyBitmap();
	virtual void SetShowParams();
	void CalculateScrollBars();

	wxFloat32	mXAspectRatio;
	wxFloat32	mYAspectRatio;
	wxCoord		mShowWidth;				// ширина картинки для отображения
	wxCoord		mShowHeight;			
	wxCoord		mPosX;					// стартовая позиция для отображения
	wxCoord		mPosY;
	wxFloat32	mScale;
	wxFloat32	mScaleMin;
	wxFloat32	mScaleMax;
	wxCoord		mScaledWidth;
	wxCoord		mScaledHeight;
	wxRect		mBitmapRect;
	wxPoint		mMousePoint;			// pixel coordinats where mouse cursor points
		
	wxBitmap*	mBitmap;
	wxCoord		mWidth;
	wxCoord		mHeight;
	
private:
	int			mAlign;
	bool		mAllowScaling;			// allows scaling by mouse wheel
};

#endif
