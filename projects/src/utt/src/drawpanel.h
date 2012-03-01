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
	DrawPanel( wxWindow* parent, wxInt32 id = wxID_ANY );
	~DrawPanel(void);

	void CreateBitmap(Pixel* buffer, wxInt32 width, wxInt32 height);
	void SetBuffer( Pixel* buffer );

protected:
	virtual void OnPaint(wxPaintEvent& event);
	virtual void OnSize(wxSizeEvent& event);
	
private:
	void Render(wxDC& dc);
	void PaintNow();
	void DestroyBitmap();
	void SetShowParams();
	void CalculateScrollBars();

	int			mAlign;
	float		mXAspectRatio;
	float		mYAspectRatio;
	wxCoord		mShowWidth;				// ширина картинки для отображения
	wxCoord		mShowHeight;			
	wxCoord		mPosX;					// стартовая позиция для отображения
	wxCoord		mPosY;
	
	wxBitmap*	mBitmap;
	wxCoord		mWidth;
	wxCoord		mHeight;
};

#endif
