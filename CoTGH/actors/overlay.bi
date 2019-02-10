#Ifndef ACTOR_OVERLAY_BI
#Define ACTOR_OVERLAY_BI

#Include "../actor.bi"
#Include "../image32.bi"
#Include "fbgfx.bi"

Namespace act

Type Overlay Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(Overlay)

	Declare Constructor(parent As ActorBankFwd Ptr, target As Image32 Ptr)
	Declare Destructor()
	
 	Declare Sub drawOverlay()
 	Declare Sub setPhoto(photo As Image32 Ptr)
 	Declare Sub setHasCamera(hasCamera As Boolean)
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
 	
 	Declare Sub showText(ByRef text As Const String)
 	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	Declare Sub drawText(x As Integer, y As Integer, ByRef t As Const String)
 	Declare Sub drawTextBox()
 
 	As String text_
 	As Image32 Ptr target_ = Any
 	As Image32 Ptr photo_ = Any
 	As Boolean hasCamera_ = Any
 	As fb.IMAGE Ptr font_ = Any
End Type

End Namespace

#EndIf
