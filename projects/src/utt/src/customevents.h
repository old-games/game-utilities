/***************************************************************
 * Name:      custumevents.h
 * Purpose:   custom events for internal use
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-12
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef CUSTOMEVENTS_H_INCLUDED
#define CUSTOMEVENTS_H_INCLUDED

class ColourPickEvent;

wxDECLARE_EVENT( wxEVT_COLOURPICK, ColourPickEvent );

class ColourPickEvent : public wxEvent
{
public:

    ColourPickEvent( )
        : wxEvent(0, wxEVT_COLOURPICK),
			mColour( *wxBLACK ),
			mButton( 0 )
	{ }
	
    ColourPickEvent( const wxColour& colour, int button )
        : wxEvent(0, wxEVT_COLOURPICK),
			mColour( colour ),
			mButton( button )
	{ }
	
    ColourPickEvent(const ColourPickEvent& event)
        : wxEvent(event),
   			mColour( event.mColour ),
			mButton( event.mButton )
    { }

    virtual wxEvent *Clone() const { return new ColourPickEvent(*this); }
    
    int GetButton()
    {
		return mButton;
    }
    
    const wxColour& GetColour()
    {
		return mColour;
    }

protected:
	
private:

	wxColour	mColour;
	int			mButton;
    DECLARE_DYNAMIC_CLASS_NO_ASSIGN(ColourPickEvent)
};

typedef void (wxEvtHandler::*ColourPickEventFunction)(ColourPickEvent&);



#define ColourPickEventHandler(func) \
    wxEVENT_HANDLER_CAST(ColourPickEventFunction, func)

#define EVT_COLOURPICK(func) wx__DECLARE_EVT0(wxEVT_COLOURPICK, ColourPickEventHandler(func))

#endif
