/***************************************************************
 * Name:      helpers.h
 * Purpose:   some global functions
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-14
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef HELPERS_H_INCLUDED
#define HELPERS_H_INCLUDED

namespace Helpers
{

// копирует буфер в новый с соотвествующими параметрами
void CropBuffer(Pixel* dst, int dstWidth, int dstHeight, Pixel* src, int srcWidth, int srcHeight);

} // namespace Helpers


#endif

