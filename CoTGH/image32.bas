#Include "image32.bi"

#Include "debuglog.bi"
#Include "null.bi"
#Include "fbimage.bi"

Constructor Image32()
  This.imageData = NULL
End Constructor

Constructor Image32(w_ As Integer, h_ As Integer)
  DEBUG_ASSERT((w_ > 0) AndAlso (h_ > 0))
  This.w_ = w_
  This.h_ = h_
  This.imageData = ImageCreate(w_, h_, 0, 32)
  DEBUG_ASSERT(This.imageData <> NULL)
  ImageInfo This.imageData,,,,, This.pixels_
End Constructor

Constructor Image32(path As String)
  This.imageData = LoadRGBAFile(path)
  DEBUG_ASSERT(This.imageData <> NULL)
  ImageInfo This.imageData, This.w_, This.h_,,, This.pixels_
End Constructor

Destructor Image32()
	If imageData <> NULL Then ImageDestroy(imageData)
End Destructor

Function Image32.pixels() As Pixel32 Ptr
  DEBUG_ASSERT(imageData <> NULL)
  Return pixels_
End Function

Const Function Image32.constPixels() As Const Pixel32 Ptr
  DEBUG_ASSERT(imageData <> NULL)
  Return pixels_
End Function

Function Image32.fbImg() As Any Ptr
  DEBUG_ASSERT(imageData <> NULL)
  Return imageData
End Function

Const Function Image32.w() As Integer
  DEBUG_ASSERT(imageData <> NULL)
  Return w_
End Function

Const Function Image32.h() As Integer
  DEBUG_ASSERT(imageData <> NULL)
  Return h_
End Function
