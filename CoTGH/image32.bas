#Include "image32.bi"

#Include "debuglog.bi"
#Include "null.bi"
#Include "fbimage.bi"

Constructor Image32()
  This.imageData_ = NULL
  This.refs_ = 0
  This.source_ = NULL
  This.offset_ = 0
End Constructor

Constructor Image32(w_ As Integer, h_ As Integer)
  DEBUG_ASSERT((w_ > 0) AndAlso (h_ > 0))
  This.w_ = w_
  This.h_ = h_
  This.imageData_ = ImageCreate(w_, h_, 0, 32)
  DEBUG_ASSERT(This.imageData_ <> NULL)
  ImageInfo This.imageData_,,,,, This.pixels_
  This.refs_ = 0
  This.source_ = NULL
	This.offset_ = 0
End Constructor

Constructor Image32(path As String)
  This.imageData_ = LoadRGBAFile(path)
  DEBUG_ASSERT(This.imageData_ <> NULL)
  ImageInfo This.imageData_, This.w_, This.h_,,, This.pixels_
  This.refs_ = 0
  This.source_ = NULL
	This.offset_ = 0
End Constructor

Destructor Image32()
	DEBUG_ASSERT(refs_ = 0)
	If (imageData_ <> NULL) AndAlso (source_ = NULL) Then ImageDestroy(imageData_)
	If source_ <> NULL Then source_->unref()
End Destructor

Sub Image32.bindIn(source As Image32 Ptr)
	DEBUG_ASSERT((source_ <> NULL) OrElse (imageData_ = NULL))
	If source_ <> NULL Then source_->unref()
	source_ = source
	w_ = source_->w_
	h_ = source_->h_
	imageData_ = source_->imageData_
	pixels_ = source_->pixels_
	source_->ref()
End Sub

Sub Image32.ref()
	refs_ += 1
End Sub

Sub Image32.unref()  
	DEBUG_ASSERT(refs_ > 0)
	refs_ -= 1	
End Sub

Sub Image32.setOffset(x As UInteger, y As UInteger)
	offset_ = y*This.w_ + x
End Sub

Function Image32.pixels() As Pixel32 Ptr
  DEBUG_ASSERT(imageData_ <> NULL)
  Return pixels_ + offset_
End Function

Const Function Image32.constPixels() As Const Pixel32 Ptr
  DEBUG_ASSERT(imageData_ <> NULL)
  Return pixels_ + offset_
End Function

Function Image32.fbImg() As Any Ptr
  DEBUG_ASSERT(imageData_ <> NULL)
  Return imageData_
End Function

Const Function Image32.constFbImg() As Const Any Ptr
  DEBUG_ASSERT(imageData_ <> NULL)
  Return imageData_
End Function

Const Function Image32.w() As Integer
  DEBUG_ASSERT(imageData_ <> NULL)
  Return w_
End Function

Const Function Image32.h() As Integer
  DEBUG_ASSERT(imageData_ <> NULL)
  Return h_
End Function
