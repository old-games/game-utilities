/***************************************************************
 * Name:      lettercodesimpl.cpp
 * Purpose:   Code for LetterCodesImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-23
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "lettercodesimpl.h"
#include "gridhexeditor.h"

namespace ColumnsInfo
{
	enum
	{
		ciValue,
		ciSymbol,
		ciConvertedSymbol,
		ciNum
	};
	
	const wxString Name[ciNum] =
	{
		"Code",
		"Symbol",
		"Selected codepage"
	};
}

LetterCodesImpl::LetterCodesImpl(  wxWindow* parent, FontInfo* finfo ):
		LetterCodesGui( parent ),
		mFontInfo( finfo ),
		mSymbolsCopy( mFontInfo->GetSymbols() ),
		mCurrentEncoding( 0 ),
 		mConvertedAttr( new wxGridCellAttr( NULL ) ),
 		mValuesAttr( new wxGridCellAttr( NULL ) ),
 		mSymbolAttr( new wxGridCellAttr( NULL ) )
{
	GridHexEditor* editor = new GridHexEditor( 0, 0xFFFF );
	wxGridCellTextEditor* symbolEditor = new wxGridCellTextEditor();

	mHexAlign = editor->GetAlign();
	mValuesAttr->SetEditor( editor );

	symbolEditor->SetParameters("1");
	mSymbolAttr->SetEditor( symbolEditor );
	
	mConvertedAttr->SetReadOnly();

	mCodesGrid->SetColAttr(ColumnsInfo::ciValue, mValuesAttr);
	mCodesGrid->SetColAttr(ColumnsInfo::ciSymbol, mSymbolAttr);
	mCodesGrid->SetColAttr(ColumnsInfo::ciConvertedSymbol, mConvertedAttr);
	SetCurrentEncoding();
}

LetterCodesImpl::~LetterCodesImpl(void)
{
}

void LetterCodesImpl::GenerateCodes()
{
	if (!mFontInfo)
	{
		return;
	}
	int val = mInitialSpinCtrl->GetValue();
	for (size_t i = 0; i < mSymbolsCopy.size(); ++i)
	{
		mSymbolsCopy[ i ].mCode = val++;		
	}
	UpdateTable();
}

void LetterCodesImpl::UpdateTable()
{
	if (!mFontInfo)
	{
		return;
	}
	
	if (mCodesGrid->GetNumberCols() != ColumnsInfo::ciNum)
	{
		if ( mCodesGrid->GetNumberCols() != 0 )
		{
			mCodesGrid->DeleteCols( 0, mCodesGrid->GetNumberCols() );
		}
		mCodesGrid->AppendCols( ColumnsInfo::ciNum );
		for (int i = 0; i < ColumnsInfo::ciNum; ++i)
		{
			mCodesGrid->SetColLabelValue( i, ColumnsInfo::Name[i] );
		}
	}
	
	size_t num = mSymbolsCopy.size();
	
	wxASSERT( num != 0 );
	
	int diff = (int) num - mCodesGrid->GetNumberRows();
	if ( diff != 0 )
	{
		if ( diff < 0 )
		{
			mCodesGrid->DeleteRows( 0, abs(diff), false );
		}
		else
		{
			mCodesGrid->AppendRows( diff, false );
		}	
	}
	wxEncodingConverter encoder;
	bool canConvert = encoder.Init( (wxFontEncoding) mCurrentEncoding, wxFONTENCODING_UNICODE);
	for (size_t i = 0; i < num; ++i)
	{
		SymbolInfo& symbol = mSymbolsCopy[ i ];
		
		mCodesGrid->SetCellValue( i, ColumnsInfo::ciValue, GridHexEditor::LongToHex( symbol.mCode, mHexAlign ) );// wxString::Format("%d", symbol.mCode ) );
		wxString toConvert = wxString::Format("%c", symbol.mCode );
		mCodesGrid->SetCellValue( i, ColumnsInfo::ciSymbol, toConvert );
		wxString convert = "N/A";
		if ( canConvert )
		{
			convert = encoder.Convert( toConvert );
		}
		//else
		//{
		//	switch (mCurrentEncoding)
		//	{
		//		case wxFONTENCODING_UTF8:
		//			convert = wxString::FromUTF8( (char*) &symbol.mCode, 4 );
		//		break;
		//	}
		//}
		mCodesGrid->SetCellValue( i, ColumnsInfo::ciConvertedSymbol, convert );
	}
}

void LetterCodesImpl::SetCurrentEncoding()
{
	mEncodingName = wxFontMapper::Get()->GetEncodingName( (wxFontEncoding) mCurrentEncoding );
	mCodeTxt->SetValue( mEncodingName );
	UpdateTable();
}

void LetterCodesImpl::OnBtnClick( wxCommandEvent& event ) 
{ 
	switch (event.GetId())
	{
		case wxID_GENERATE_CODES_BTN:
			GenerateCodes();
		break;
		
		case wxID_OK:
			mFontInfo->SetSymbols( mSymbolsCopy );
		break;
 
		case wxID_GET_ENCODING_BTN:
			wxFontMapper dlg;
			dlg.SetDialogParent( this );
			mCurrentEncoding = dlg.CharsetToEncoding("unknown", true);
			SetCurrentEncoding();
		break;
	}
	event.Skip(); 
}

void LetterCodesImpl::OnCodePageChange( wxCommandEvent& event )
{
	UpdateTable();
	event.Skip();
}

