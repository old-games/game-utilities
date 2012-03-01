/***************************************************************
 * Name:      gridhexeditor.h
 * Purpose:   the editor for hex numeric (long) data
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-01
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

class GridHexEditor : public wxGridCellTextEditor
{
public:
    // allows to specify the range - if min == max == -1, no range checking is
    // done
    explicit GridHexEditor( wxInt32 min, wxInt32 max );

    virtual void Create(wxWindow* parent,
                        wxWindowID id,
                        wxEvtHandler* evtHandler);

    virtual bool IsAcceptedKey(wxKeyEvent& event);
    virtual void BeginEdit(wxInt32 row, wxInt32 col, wxGrid* grid);
    virtual bool EndEdit(wxInt32 row, wxInt32 col, const wxGrid* grid,
                         const wxString& oldval, wxString *newval);
    virtual void ApplyEdit(wxInt32 row, wxInt32 col, wxGrid* grid);

    virtual void Reset();
    virtual void StartingKey(wxKeyEvent& event);

    // parameters string format is "min,max"
    virtual void SetParameters(const wxString& params);

    virtual wxGridCellEditor *Clone() const
        { return new GridHexEditor(m_min, m_max); }

    // added GetValue so we can get the value which is in the control
    virtual wxString GetValue() const;

	bool HexToLong(long& dest, const wxString& src);

	wxInt32 GetAlign()
	{
		return mAlign;
	}

	static wxString LongToHex( long value, wxInt32 align )
	{
		return wxString::Format("%0.*X", align, (wxInt32) value);
	}


protected:

    // string representation of our value
    wxString GetString() const
        { return LongToHex( m_value, mAlign ); }

private:

	bool IsKeyCodeValid( wxInt32 keycode );
    wxInt32 m_min,
        m_max;

    long m_value;

    wxInt32 mAlign;	// for formatting string by max value

    wxDECLARE_NO_COPY_CLASS(GridHexEditor);
};
