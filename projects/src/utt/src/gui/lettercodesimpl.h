/***************************************************************
 * Name:      lettercodesimpl.h
 * Purpose:   LetterCodesGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-23
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#ifndef LETTERCODESIMPL_H_INCLUDED
#define LETTERCODESIMPL_H_INCLUDED

#include "uttgui.h"

class LetterCodesImpl :
	public LetterCodesGui
{
public:
	LetterCodesImpl( wxWindow* parent, FontInfo* finfo );
	~LetterCodesImpl(void);
	void GenerateCodes();
	void UpdateTable();

protected:

	virtual void OnBtnClick( wxCommandEvent& event );
	virtual void OnCodePageChange( wxCommandEvent& event );
	virtual void OnCellChange( wxGridEvent& event );	
private:

		void SetCurrentEncoding();
		void CellValueChanged(wxInt32 row, wxInt32 col);
		void UpdateRow(wxUint32 n);

		FontInfo*	mFontInfo;
		Symbols		mSymbolsCopy;

		int			mCurrentEncoding;
		wxString	mEncodingName;
		
		int			mHexAlign;


		wxEncodingConverter mFromSystem;
		wxEncodingConverter mToSystem;
		bool mCanFromSystem;
		bool mCanToSystem;
		
		wxGridCellAttr*	mConvertedAttr;
		wxGridCellAttr*	mValuesAttr;
		wxGridCellAttr*	mSymbolAttr;
};

#endif
