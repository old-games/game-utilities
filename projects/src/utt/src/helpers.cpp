/***************************************************************
 * Name:      helpers.cpp
 * Purpose:   Code for helpers 
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-14
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "helpers.h"

void Helpers::CropBuffer(Pixel* dst, int dstWidth, int dstHeight, Pixel* src, int srcWidth, int srcHeight)
{
	//if (dstHeight < srcHeight)
	//{
	//	srcHeight = dstHeight;
	//}
	//if (dstWidth < srcWidth)
	//{
	//	srcWidth = dstWidth;
	//}
	memset( dst, 0, dstWidth * dstHeight * sizeof( Pixel) );
	size_t copyLength = sizeof( Pixel ) * dstWidth;
	size_t correction = sizeof( Pixel ) * srcWidth - copyLength;
	for (int  y = 0; y < srcHeight; ++y)
	{
		memcpy(dst, src, copyLength);
		src += correction;
	}
}