#Include "image32.bi"

#Include "debuglog.bi"

Constructor Image32(w_ As Integer, h_ As Integer)
  DEBUG_ASSERT((w_ > 0) AndAlso (h_ > 0))
  This.w_ = w_
  This.h_ = h_
  This.pixels_ = New Pixel32[w*h]
  Clear *This.pixels_, 0, w_*h_*SizeOf(Pixel32) 
End Constructor

Destructor Image32()
  Delete This.pixels
End Destructor

Function Image32.pixels() As Pixel32 Ptr
  Return pixels_
End Function

Function Image32.w() As Integer
  Return w_
End Function

Function Image32.h() As Integer
  Return h_
End Function
