/***************************************************************
 * Name:      symbolpanel.h
 * Purpose:   SymbolPanel has to be used to edit font symbol
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-14
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef SYMBOLPANEL_H_INCLUDED
#define SYMBOLPANEL_H_INCLUDED

#include "editpanel.h"
#include "controlline.h"

enum ControlLines
{
	clSymbolWidth,
	clBaseLine,
	clCapLine,
	clLowLine,
	clNum
};

class SymbolPanel :
	public EditPanel
{
public:
	SymbolPanel( wxWindow* parent, wxWindowID id = wxID_ANY );
	~SymbolPanel(void); 
	
	void SetFontInfo( FontInfo* info, int symbolNumber );

protected:
		
	virtual void Render( wxDC& dc );
	virtual void SetShowParams();
	virtual void OnMotion( wxMouseEvent& event );
	virtual void OnBtnDown( wxMouseEvent& event );
	virtual void OnBtnUp( wxMouseEvent& event );

private:

	void UpdateBitmap();
	void UpdateControlLines();
	void DrawAdditionalLine( wxDC& dc, int x );

	FontInfo*		mFontInfo;
	bool			mAllowEdit;
	int				mSymbolNumber;
	int				mActiveLine;
	bool			mDragLine;
	wxPoint			mDragPoint;
	ControlLine*	mLines[ clNum ];


};

#endif
