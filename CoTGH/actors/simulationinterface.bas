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

Function SimulationInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
