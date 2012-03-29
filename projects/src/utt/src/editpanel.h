/***************************************************************
 * Name:      editpanel.h
 * Purpose:   modified DrawPanel for edit image
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-29
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef EDITPANEL_H_INCLUDED
#define EDITPANEL_H_INCLUDED

// TODO: remove when will be done
#include "drawpanel.h"

class EditPanel :
	public DrawPanel
{

friend class EditPanelImpl;

public:

	EditPanel( wxWindow* parent );
	virtual ~EditPanel(void);

	void SetGridColour(const wxColour& color);
	const wxColour& GetGridColour()
	{
		return mGridColour;
	}

	void SetGridLogic(wxInt32 logic);

	void SetGridEnabled(bool b = true)
	{
		mDrawGrid = b;
	}

	void SetDrawFocus( bool b )
	{
		mDrawFocus = b;
	}

	void SetAllowEdit( bool b /* true */)
	{
		mAllowEdit = b;
	}

	static wxColour		gGlobalLeftColour;
	static wxColour		gGlobalRightColour;

protected:

	virtual bool MouseButton( int btn, bool up );
	virtual bool MouseModifiersButton( int modifier, int btn, bool up );
	virtual bool MouseMoving( int modifier, int btn );

	virtual bool KeyDown( int modifier, int keyCode );
	virtual bool KeyUp( int modifier, int keyCode );
	virtual bool CursorPressed( int directon );

	virtual void Render(wxDC& dc);
	virtual void SetShowParams();

	void DrawGrid( wxDC& dc );
	void PlacePixel( const wxPoint& pos, const wxColour& color );
	bool GetPixel( const wxPoint& pos, wxColour& color );

	bool		mDrawing;
	bool		mDrawCursor;
	wxPoint     mCursor;				// coordinates of current pixel, must be always valid

private:

	void ClearGridPoints();
	bool DoEdit();
	bool BeginDrawing();
	void EndDrawing();

	bool		mDrawGrid;
	bool		mDrawFocus;
	wxColour	mGridColour;
	wxPoint*	mGridPoints;
	wxInt32		mPointsNumber;
	wxPen		mGridPen;
	wxInt32		mGridLogic;

	wxColour	mCurrentColour;
	wxPoint		mPreviousPoint;
	bool		mAllowEdit;

};

#endif
