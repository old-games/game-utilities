/***************************************************************
 * Name:      gridhexeditor.cpp
 * Purpose:   code of the editor for hex numeric (long) data
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-01
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "gridhexeditor.h"

GridHexEditor::GridHexEditor(int min, int max)
{
    m_min = min;
    m_max = max;
	mAlign = wxString::Format("%X", max).length();
}

void GridHexEditor::Create(wxWindow* parent,
                                    wxWindowID id,
                                    wxEvtHandler* evtHandler)
{
	// just a text control
	wxGridCellTextEditor::Create(parent, id, evtHandler);
}

bool GridHexEditor::HexToLong(long& dest, const wxString& src)
{
	wxString str = "0x" + src;
	return str.ToLong(&dest, 16);
}

void GridHexEditor::BeginEdit(int row, int col, wxGrid* grid)
{
    // first get the value
    wxGridTableBase *table = grid->GetTable();
    wxString txt = table->GetValue( row, col );

    if ( !HexToLong( m_value, txt) )
	{
        m_value = 0;
        if ( !txt.empty() )
        {
            wxFAIL_MSG( wxT("this cell doesn't have hex numeric value") );
            return;
        }
    }
    DoBeginEdit(GetString());
}

bool GridHexEditor::EndEdit(int WXUNUSED(row),
                                     int WXUNUSED(col),
                                     const wxGrid* WXUNUSED(grid),
                                     const wxString& oldval, wxString *newval)
{
    long value = 0;
    wxString text;

    text = Text()->GetValue();
    if ( text.empty() )
    {
        if ( oldval.empty() )
            return false;
    }
    else // non-empty text now (maybe 0)
    {
        if ( !HexToLong(value, text) )
            return false;

        // if value == m_value == 0 but old text was "" and new one is
        // "0" something still did change
        if ( value == m_value && (value || !oldval.empty()) )
            return false;
    }
    m_value = value;
    if ( newval )
        *newval = text;
    return true;
}

void GridHexEditor::ApplyEdit(int row, int col, wxGrid* grid)
{
    wxGridTableBase * const table = grid->GetTable();
	table->SetValue(row, col, GetString() );
}

void GridHexEditor::Reset()
{
	DoReset(GetString());
}

inline bool GridHexEditor::IsKeyCodeValid( int keycode )
{
	if ( (keycode < 128) &&
		(	wxIsdigit(keycode) || keycode == '+' || keycode == '-') ||
			keycode >= 'A' || keycode <= 'F' || keycode >= 'a' || keycode <= 'f' )
	{
		return true;
	}
	return false;
}

bool GridHexEditor::IsAcceptedKey(wxKeyEvent& event)
{
    if ( wxGridCellEditor::IsAcceptedKey(event) )
    {
		return IsKeyCodeValid( event.GetKeyCode() );
    }
    return false;
}

void GridHexEditor::StartingKey(wxKeyEvent& event)
{
    if ( IsKeyCodeValid(event.GetKeyCode()) )
    {
        wxGridCellTextEditor::StartingKey(event);
        return;
    }
    event.Skip();
}

void GridHexEditor::SetParameters(const wxString& params)
{
    if ( !params )
    {
        // reset to default
        m_min =
        m_max = -1;
    }
    else
    {
        long tmp;
        if ( params.BeforeFirst(wxT(',')).ToLong(&tmp) )
        {
            m_min = (int)tmp;

            if ( params.AfterFirst(wxT(',')).ToLong(&tmp) )
            {
                m_max = (int)tmp;

                // skip the error message below
                return;
            }
        }

        wxLogDebug(wxT("Invalid GridHexEditor parameter string '%s' ignored"), params.c_str());
    }
}

wxString GridHexEditor::GetValue() const
{
	return Text()->GetValue();
}
