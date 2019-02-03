#Include "simulationinterface.bi"

#Include "../debuglog.bi"

Namespace act
ACTOR_REQUIRED_DEF(SimulationInterface, ActorTypes.SIMULATIONINTERFACE)
	
Constructor SimulationInterface(parent As ActorBankFwd Ptr, simulation As Simulation Ptr)
	Base.Constructor(parent)
	setType()

	setKey("SIMULATION INTERFACE")
	
	This.sim_ = simulation
End Constructor

Sub SimulationInterface.setForce(ByRef f As Const Vec2F)
	sim_->setForce(f)
End Sub

Const Function SimulationInterface.getIntersects(ByRef box As Const AABB) As DArray_AnyPtr
	Return sim_->getIntersects(box)
End Function

Const Function SimulationInterface.getIntersectsBlockGrid(ByRef box As Const AABB) As BlockType
	Return sim_->getIntersectsBlockGrid(box)
End Function

Function SimulationInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
