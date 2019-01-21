#Include "drawbufferinterface.bi"

#Include "../debuglog.bi"
#Include "../quaddrawbuffer.bi"

Namespace act
ACTOR_REQUIRED_DEF(DrawBufferInterface, ActorTypes.DRAWBUFFERINTERFACE)
	
Constructor DrawBufferInterface(parent As ActorBankFwd Ptr, drawBuffer As QuadDrawBuffer Ptr)
	Base.Constructor(parent)
	setType()

	setKey("DRAWBUFFER INTERFACE")
	
	This.drawBuffer_ = drawBuffer	
End Constructor

Sub DrawBufferInterface.setGlobalLightDirection(ByRef d As Const Vec3F)
	drawBuffer_->setGlobalLightDirection(d)
End Sub

Sub DrawBufferInterface.setGlobalLightMinMax(min As Double, max As Double)
	drawBuffer_->setGlobalLightMinMax(min, max)
End Sub

Function DrawBufferInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
