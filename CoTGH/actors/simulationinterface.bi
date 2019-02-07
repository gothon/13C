#Ifndef ACTOR_SIMULATIONINTERFACE_BI
#Define ACTOR_SIMULATIONINTERFACE_BI

#Include "../actor.bi"
#Include "../physics.bi"
#Include "../aabb.bi"
#Include "../primitive.bi"
#Include "../darray.bi"

DECLARE_DARRAY(AnyPtr)

Namespace act
	
Type SimulationInterface Extends DynamicActor
 Public:
 	ACTOR_REQUIRED_DECL(SimulationInterface)
 
	Declare Constructor(parent As ActorBankFwd Ptr, simulation As Simulation Ptr)
	
	Declare Sub setForce(ByRef f As Const Vec2F)
	Declare Const Function getIntersects(ByRef box As Const AABB) As DArray_AnyPtr
	Declare Const Function getIntersectsBlockGrid(ByRef box As Const AABB) As BlockType
	
	Declare Function update(dt As Double) As Boolean Override
 	Declare Sub notify() Override
	
	Declare Sub doSlowdown()
	Declare Sub endSlowdown()
	
 	Declare Function clone(parent As ActorBankFwd Ptr) As Actor Ptr Override
 Private:
 	As Simulation Ptr sim_ = Any
 	As Single timeSlowMul_ = Any
 	As Boolean slowdownMode_ = Any
End Type

End Namespace

#EndIf