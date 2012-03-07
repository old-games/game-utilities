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
	public wxScrolledWindow
{
public:

	DrawPanel( wxWindow* parent,  wxWindowID id = wxID_ANY );
	virtual ~DrawPanel(void);

	void SetBitmap( wxBitmap* bitmap );
	void CreateBitmap(Pixel* buffer, wxInt32 width, wxInt32 height);
	void SetBuffer( Pixel* buffer );
	void SetScale( wxFloat32 scale );
	void SetAlign( wxInt32 align );

protected:

	virtual void OnMouseWheel( wxMouseEvent &event );
	virtual void OnBtnDown( wxMouseEvent& event );
	virtual void OnMotion( wxMouseEvent& event );
	virtual void OnBtnUp( wxMouseEvent& event );
	
	virtual void OnFocus(wxFocusEvent& event);
	virtual void OnPaint(wxPaintEvent& event);
	virtual void OnSize(wxSizeEvent& event);
	virtual void Render(wxDC& dc);
	
	void PaintNow();
	void DestroyBitmap();
	void ApplyBitmap();
	virtual void SetShowParams();
	void CalculateScrollBars();

	wxInt32		mAlign;
	wxFloat32	mXAspectRatio;
	wxFloat32	mYAspectRatio;
	wxCoord		mShowWidth;				// ширина картинки для отображения
	wxCoord		mShowHeight;			
	wxCoord		mPosX;					// стартовая позиция для отображения
	wxCoord		mPosY;
	wxFloat32	mScale;
	wxCoord		mScaledWidth;
	wxCoord		mScaledHeight;
	
	wxBitmap*	mBitmap;
	wxCoord		mWidth;
	wxCoord		mHeight;
};

#endif
