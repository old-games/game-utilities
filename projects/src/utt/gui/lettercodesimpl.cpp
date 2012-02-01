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
		mCurrentEncoding( mFontInfo->GetEncoding() ),
		mCanFromSystem( false ),
		mCanToSystem( false ),
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

	this->Bind( wxEVT_GRID_CELL_CHANGED, &LetterCodesImpl::OnCellChange, this);
}

LetterCodesImpl::~LetterCodesImpl(void)
{
	this->Unbind( wxEVT_GRID_CELL_CHANGED, &LetterCodesImpl::OnCellChange, this);
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
	mCodesGrid->AutoSizeColumn( ColumnsInfo::ciConvertedSymbol );
	
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
	for (size_t i = 0; i < num; ++i)
	{
		UpdateRow( i );
	}
}

void LetterCodesImpl::SetCurrentEncoding()
{
	mEncodingName = wxFontMapper::Get()->GetEncodingName( (wxFontEncoding) mCurrentEncoding );
	mCodeTxt->SetValue( mEncodingName );
	mCanFromSystem = mFromSystem.Init( wxFONTENCODING_UNICODE, (wxFontEncoding) mCurrentEncoding );
	mCanToSystem = mToSystem.Init( (wxFontEncoding) mCurrentEncoding, wxFONTENCODING_UNICODE );

	UpdateTable();
}

inline void LetterCodesImpl::UpdateRow(unsigned int n)
{
	SymbolInfo& symbol = mSymbolsCopy[ n ];

	mCodesGrid->SetCellValue( n, ColumnsInfo::ciValue, GridHexEditor::LongToHex( symbol.mCode, mHexAlign ) );
	wxString toConvert = wxString::Format("%c", symbol.mCode );
	mCodesGrid->SetCellValue( n, ColumnsInfo::ciSymbol, toConvert );
	wxString convert = "N/A";
	if ( mCanToSystem )
	{
		convert = mToSystem.Convert( toConvert );
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
	mCodesGrid->SetCellValue( n, ColumnsInfo::ciConvertedSymbol, convert );
}

void LetterCodesImpl::CellValueChanged(int row, int col)
{
	bool update = true;
	wxString val = mCodesGrid->GetCellValue( row, col );
	long intVal = mSymbolsCopy[ row ].mCode;
	switch ( col )
	{
		case ColumnsInfo::ciValue:
			{
				GridHexEditor* hexEditor = (GridHexEditor*) mCodesGrid->GetCellEditor( row, col );
				hexEditor->HexToLong( intVal, val );
			}
			break;

		case ColumnsInfo::ciSymbol:
			if ( mCanFromSystem )
			{
				val = mFromSystem.Convert( val );
			}
			intVal = val.GetChar(0);
			break;

		default:
			update = false;
	}
	wxASSERT( update );
	if (update)
	{
		mSymbolsCopy[ row ].mCode = intVal;
		this->UpdateRow( row );
	}
}


void LetterCodesImpl::OnBtnClick( wxCommandEvent& event ) 
{ 
	switch (event.GetId())
	{
		case wxID_GENERATE_CODES_BTN:
			GenerateCodes();
		break;
		
		case wxID_OK:
			mFontInfo->SetEncoding( mCurrentEncoding );
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

void LetterCodesImpl::OnCellChange( wxGridEvent& event )
{
	this->CellValueChanged( event.GetRow(), event.GetCol() );
	event.Skip();
}
