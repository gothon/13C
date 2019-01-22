#Ifndef IMAGE32_BI
#Define IMAGE32_BI

#Include "pixel32.bi"

'32 bit image
Type Image32
 Public:
  Declare Constructor()
 
  'Create a blank image of the given size
  Declare Constructor(w As Integer, h As Integer)

  'Load an image from a file
  Declare Constructor(path As String)
  
  Declare Destructor()
  
  'Bind another image to this s.t. this image sources its pixel from the other image.
  Declare Sub bindIn(source As Image32 Ptr)
    
  'Sets an offset s.t. calls to *pixels() return a pointer to the upper-left image pixel
  'offset by any amount set here.
  Declare Sub setOffset(x As UInteger, y As UInteger)
    
  'Returns a pointer to the raw pixel data of this image.
  Declare Function pixels() As Pixel32 Ptr
  Declare Const Function constPixels() As Const Pixel32 Ptr
  
  'Returns a pointer to the start of the image descriptor generated by GfxLib.
  Declare Function fbImg() As Any Ptr
  
  Declare Const Function w() As Integer
  Declare Const Function h() As Integer
  
  Declare Sub ref()
  Declare Sub unref()  
  
 Private:
  As Integer w_ = Any 'Const
  As Integer h_ = Any 'Const
  
  As Image32 Ptr source_ = Any 'Const
  As UInteger refs_ = Any
  
  As Any Ptr imageData_ = Any 'Const Ptr
  As Pixel32 Ptr pixels_ = Any 'Const Ptr
  
  As UInteger offset_ = Any
End Type

#EndIf
