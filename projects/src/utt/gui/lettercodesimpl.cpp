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
	mFontInfo( finfo )
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
	for (size_t i = 0; i < mFontInfo->mNum; ++i)
	{
		mFontInfo->mCodes[i] = val++;		
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
		mCodesGrid->DeleteCols( 0, mCodesGrid->GetNumberCols() );
		mCodesGrid->AppendCols( ColumnsInfo::ciNum );
		for (int i = 0; i < ColumnsInfo::ciNum; ++i)
		{
			mCodesGrid->SetColLabelValue( i, ColumnsInfo::Name[i] );
		}
	}
	if (mFontInfo->mNum == 0)
	{
		return;
	}
	
	int diff = (int) mFontInfo->mNum - mCodesGrid->GetNumberRows();
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
	
	for (size_t i = 0; i < mFontInfo->mNum; ++i)
	{
		mCodesGrid->SetCellValue( i, ColumnsInfo::ciValue, wxString::Format("%d", mFontInfo->mCodes[i]) );
		mCodesGrid->SetCellValue( i, ColumnsInfo::ciSymbol, wxString::Format("%c", mFontInfo->mCodes[i]) );
	}
}

void LetterCodesImpl::OnBtnClick( wxCommandEvent& event ) 
{ 
	switch (event.GetId())
	{
		case wxID_GENERATE_CODES_BTN:
			GenerateCodes();
		break;
	}
	event.Skip(); 
}