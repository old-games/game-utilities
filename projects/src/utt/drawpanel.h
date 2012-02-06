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
	
	wxBitmap*	mBitmap;
	wxCoord		mWidth;
	wxCoord		mHeight;
};

#endif
