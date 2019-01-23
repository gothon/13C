#Ifndef FPSLIMITIER_BI
#Define FPSLIMITIER_BI

Type FpsLimiter
 Public:
 	Declare Constructor()
 	
 	Declare Const Function getFps() As UInteger
 	Declare Sub sync()
 	
 Private:
 	Declare Sub updateFunStuff()
 
 	As Double actualFrameTime_ = Any
 	As UInteger framesElapsed_ = Any
 	As UInteger fps_ = Any
 	As Double lastEpoch_ = Any
 	As Double elapsedFrameTime_ = Any
 	
 	As ULongInt largeValue_ = Any
 	As ULongInt trialDivide_ = Any
 	As ULongInt largeSquare_ = Any
End Type

#EndIf
