/***************************************************************
 * Name:      controlline.h
 * Purpose:   ControlLine used to visualize some font parameters
				like width, capital line e.t.c.
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-15
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef CONTROLLINE_H_INCLUDED
#define CONTROLLINE_H_INCLUDED

class ControlLine
{
public:
	ControlLine( wxScrolledWindow* parent );
	~ControlLine(void); 
		
	void SetParameters( int orientation, const wxColour& colour,  int width, int style, const wxString& txt );
	void SetValue( int mValue );
	void SetValue( const wxPoint& pos );
	bool CheckMouse();

	void SetOffsetXY( wxCoord sx, wxCoord sy, wxCoord zwidth, wxCoord zheight, wxFloat32 scale );

	void DrawControlLine( wxDC& dc );

	const wxString& GetToolTip()
	{
		return mToolTip;
	}

	const wxCursor& GetCursor()
	{
		return mCursor;
	}
	
protected:
	
	
private:

	void CalcPoints( wxPoint& first, wxPoint& second );

	wxScrolledWindow*	mParent;
	bool				mInitiated;
	int					mOrientation;
	wxColour			mColour;	
	int					mWidth;
	int					mStyle;
	int					mValue;				// если линия горизонтальная, то это Y, если вертикальная то X

	wxCoord				mPosX;
	wxCoord				mPosY;
	wxCoord				mZoneWidth;
	wxCoord				mZoneHeight;
	wxFloat32			mScale;
	wxCursor			mCursor;
	wxString			mToolTip;
};

#endif
