#Include "snapshotinterface.bi"

#Include "../debuglog.bi"
#Include "../pixel32.bi"

Namespace act
ACTOR_REQUIRED_DEF(SnapshotInterface, ActorTypes.SNAPSHOTINTERFACE)
	
Constructor SnapshotInterface(parent As ActorBankFwd Ptr, target As Const Image32 Ptr)
	Base.Constructor(parent)
	setType()
	setKey("SNAPSHOT INTERFACE")

	DEBUG_ASSERT(((target->w() = 640) AndAlso (target->h() = 480)) _
			OrElse ((target->w() = 320) AndAlso (target->h() = 240)))
	This.target_ = target
End Constructor

Sub blockDownscale(dst As Image32 Ptr, src As Const Image32 Ptr, blockL As UInteger)
	Dim As Pixel32 Ptr dstPxls = dst->pixels()
	Dim As Const Pixel32 Ptr srcPxls = src->constPixels()
	Dim As UInteger pixelsPerBlock = blockL*blockL 'const
	Dim As Double maxLum = 0.0
	Dim As Double minLum = 1.0
	For dstY As UInteger = 0 To 47
		For dstX As UInteger = 0 To 63
			Dim As UInteger outR = 0
			Dim As UInteger outG = 0
			Dim As UInteger outB = 0
			For srcY As UInteger = dstY*blockL To (dstY + 1)*blockL - 1
				For srcX As UInteger = dstX*blockL To (dstX + 1)*blockL - 1
					Dim As Const Pixel32 outPx = srcPxls[srcY*src->w() + srcX] 'const
					outR += outPx.r
					outG += outPx.g
					outB += outPx.b
				Next srcX		
			Next srcY
			outR /= pixelsPerBlock
			outG /= pixelsPerBlock
			outB /= pixelsPerBlock
			
			Dim As Double thisLum = (outR / 255.0)*0.2126 + (outG / 255.0)*0.7152 + (outB / 255.0)*0.0722
			If thisLum < minLum Then minLum = thisLum
			If thisLum > maxLum Then maxLum = thisLum
			
			dstPxls[dstY*dst->w() + dstX] = Pixel32(outR, outG, outB)
		Next dstX
	Next dstY

	Dim As Double lumScale = 1.0 / ((maxLum - minLum)*255.0)
	Dim As Double lumOffset = 255.0*minLum
	For dstY As UInteger = 0 To 47
		For dstX As UInteger = 0 To 63
			Dim As Pixel32 outPx = dstPxls[dstY*dst->w() + dstX] 'const
			Dim As UInteger outR = ((outPx.r - lumOffset)*lumScale)^0.8*255.0
			If outR > 255.0 Then outR = 255
			Dim As UInteger outG = ((outPx.g - lumOffset)*lumScale)^0.8*255.0
			If outG > 255.0 Then outG = 255
			Dim As UInteger outB = ((outPx.b - lumOffset)*lumScale)^0.8*255.0
			If outB > 255.0 Then outB = 255
			dstPxls[dstY*dst->w() + dstX] = Pixel32(outR, outG, outB)	
		Next dstX
	Next dstY
End Sub

Const Function SnapshotInterface.createSnapshot() As Image32 Ptr
	Dim As Image32 Ptr retImage = New Image32(64, 48)
	blockDownscale(retImage, target_, IIf(target_->w() = 640, 10, 5))
	Return retImage
End Function

Function SnapshotInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
