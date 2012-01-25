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
	mSymbolsCopy( mFontInfo->GetSymbols() )
{
	UpdateTable();
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
	
	for (size_t i = 0; i < num; ++i)
	{
		SymbolInfo& symbol = mSymbolsCopy[ i ];
		mCodesGrid->SetCellValue( i, ColumnsInfo::ciValue, wxString::Format("%d", symbol.mCode ) );
		mCodesGrid->SetCellValue( i, ColumnsInfo::ciSymbol, wxString::Format("%c", symbol.mCode ) );
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
			mFontInfo->SetSymbols( mSymbolsCopy );
		break;
	}
	event.Skip(); 
}

void LetterCodesImpl::OnSize( wxSizeEvent& event ) 
{ 
	event.Skip();
	return;
	wxSize size = this->GetSize();
	size.y -= mAutoSizer->GetSize().GetHeight();
	size.y -= mPalSizer->GetSize().GetHeight();
	size.y = 100;
	mCodesGrid->SetSize(size);
	mCodesGrid->SetMaxSize(size);
}