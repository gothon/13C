#Include "util.bi"

Namespace util
  
Function genUId() As ULongInt
  Return CLngInt(Rnd*CDbl(CUInt(&hffffffff))) Or (CLngInt(Rnd*CDbl(CUInt(&hffffffff))) Shl 32)
End Function
  
End Namespace
