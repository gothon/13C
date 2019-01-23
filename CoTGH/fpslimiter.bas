#Include "fpslimiter.bi"

#Include "debuglog.bi"
#Include "util.bi"

Const As Double DEFAULT_REFRESH_RATE = 60.0

Constructor FpsLimiter()
	framesElapsed_ = 0
	fps_ = 0
	lastEpoch_ = 0
	elapsedFrameTime_ = 0
	Dim As Integer refreshRate = Any
	ScreenInfo ,,,,, refreshRate
	DEBUG_ASSERT_WITH_MESSAGE(refreshRate <> 0, "Unknown refresh rate.")
	DEBUG_ASSERT_WITH_MESSAGE((refreshRate Mod 30) = 0, "FpsLimiter requires a refresh rate that's a multiple of 30.")
	actualFrameTime_ = 1.0 / CDbl(refreshRate)
	updateFunStuff()
End Constructor
 	
Const Function FpsLimiter.getFps() As UInteger
	Return fps_
End Function

Sub FpsLimiter.sync()
	elapsedFrameTime_ = Timer - elapsedFrameTime_
	If elapsedFrameTime_ < actualFrameTime_ Then 
		Dim As Double spinTime = Timer 'const
		Dim As Double waitTime = (actualFrameTime_ - elapsedFrameTime_) + actualFrameTime_*0.5 'const
		While (Timer - spinTime) < waitTime
			If largeValue_ Mod trialDivide_ = 0 Then
				updateFunStuff()
			Else
				trialDivide_ += 1
				If trialDivide_ >= largeSquare_ Then 
					DEBUG_LOG("Found a prime: " + Str(largeValue_))
					updateFunStuff()
				EndIf
			EndIf
		Wend
	EndIf
	ScreenSync
	elapsedFrameTime_ = Timer	
	
	framesElapsed_ += 1
	If (Timer - lastEpoch_) > 1 Then
		fps_ = framesElapsed_
		framesElapsed_ = 0
		lastEpoch_ = Timer
	EndIf
End Sub

Sub FpsLimiter.updateFunStuff()
	largeValue_ = util.genUId()
	trialDivide_ = 2
	largeSquare_ = Sqr(largeValue_)
End Sub
