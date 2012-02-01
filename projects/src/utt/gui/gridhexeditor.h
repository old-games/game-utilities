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
    explicit GridHexEditor( int min, int max );

    virtual void Create(wxWindow* parent,
                        wxWindowID id,
                        wxEvtHandler* evtHandler);

    virtual bool IsAcceptedKey(wxKeyEvent& event);
    virtual void BeginEdit(int row, int col, wxGrid* grid);
    virtual bool EndEdit(int row, int col, const wxGrid* grid,
                         const wxString& oldval, wxString *newval);
    virtual void ApplyEdit(int row, int col, wxGrid* grid);

    virtual void Reset();
    virtual void StartingKey(wxKeyEvent& event);

    // parameters string format is "min,max"
    virtual void SetParameters(const wxString& params);

    virtual wxGridCellEditor *Clone() const
        { return new GridHexEditor(m_min, m_max); }

    // added GetValue so we can get the value which is in the control
    virtual wxString GetValue() const;

	bool HexToLong(long& dest, const wxString& src);
	
	int GetAlign()
	{
		return mAlign;
	}

	static wxString LongToHex( long value, int align )
	{
		return wxString::Format(wxT("%0.*X"), align, value);
	}
	
	
protected:

    // string representation of our value
    wxString GetString() const
        { return LongToHex( m_value, mAlign ); }

private:

	bool IsKeyCodeValid( int keycode );
    int m_min,
        m_max;

    long m_value;
    
    int mAlign;	// for formatting string by max value

    wxDECLARE_NO_COPY_CLASS(GridHexEditor);
};
