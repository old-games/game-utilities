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
	utdNone		= 0x00,
	utdExpand	= 0x01,
	utdLeft		= 0x02,
	utdHCenter  = 0x04,
	utdVCenter  = 0x08,
	utdRight	= 0x10,
	utdUp		= 0x20,
	utdDown		= 0x30,
	utdExactFit = 0x40
};

class DrawPanel :
	public wxScrolledWindow
{
public:
	DrawPanel( wxWindow* parent, int id );
	~DrawPanel(void);

	void CreateBitmap(Pixel* buffer, int width, int height);
	void SetBuffer( Pixel* buffer );

protected:
	virtual void OnPaint(wxPaintEvent& event);
	virtual void OnSize(wxSizeEvent& event);
	
private:
	void Render(wxDC& dc);
	void PaintNow();
	void DestroyBitmap();
	void SetShowParams();

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
