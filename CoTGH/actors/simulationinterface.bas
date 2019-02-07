#Include "simulationinterface.bi"

#Include "../debuglog.bi"
#Include "../actorbank.bi"
#Include "../actordefs.bi"
#Include "../audiocontroller.bi"

Namespace act
ACTOR_REQUIRED_DEF(SimulationInterface, ActorTypes.SIMULATIONINTERFACE)
	
Constructor SimulationInterface(parent As ActorBankFwd Ptr, simulation As Simulation Ptr)
	Base.Constructor(parent)
	setType()

	setKey("SIMULATION INTERFACE")
	
	This.sim_ = simulation
	This.timeSlowMul_ = 1.0
	This.slowdownMode_ = FALSE
End Constructor

Sub SimulationInterface.setForce(ByRef f As Const Vec2F)
	sim_->setForce(f)
End Sub

Sub SimulationInterface.doSlowdown()
	slowdownMode_ = TRUE
End Sub

Sub SimulationInterface.endSlowdown()
	slowdownMode_ = FALSE
End Sub

Const Function SimulationInterface.getIntersects(ByRef box As Const AABB) As DArray_AnyPtr
	Return sim_->getIntersects(box)
End Function

Const Function SimulationInterface.getIntersectsBlockGrid(ByRef box As Const AABB) As BlockType
	Return sim_->getIntersectsBlockGrid(box)
End Function

Function SimulationInterface.update(dt As Double) As Boolean
	If (Not slowdownMode_) OrElse GET_GLOBAL("TRANSITION NOTIFIER", TransitionNotifier).happened() Then
		timeSlowMul_ = 1.0
		slowdownMode_ = FALSE
	ElseIf slowdownMode_ Then
		timeSlowMul_ *= 0.9
	EndIf
	
	AudioController.setFrequencyMul(timeSlowMul_^0.15)
	sim_->setTimeMultiplier(timeSlowMul_)
	
	Return FALSE
End Function

Sub SimulationInterface.notify()
	
End Sub

Function SimulationInterface.clone(parent As ActorBankFwd Ptr) As Actor Ptr
	DEBUG_ASSERT(FALSE)
End Function

End Namespace
