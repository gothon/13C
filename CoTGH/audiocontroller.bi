#Ifndef AUDIOCONTROLLER_H
#Define AUDIOCONTROLLER_H

#Include "primitive.bi"
#Include "darray.bi"
#Include "hashmap.bi"
#Include "vec2f.bi"

DECLARE_DARRAY(Integer_)
dsm_HashMap_define(ZString, Integer_)

Type AudioController
 Public:
 	Declare Static Sub fadeOut()
 	Declare Static Sub fadeIn()
 	
 	Declare Static Sub switchMusic(audioFile As ZString Ptr, playbackPosition As LongInt = -1)
 	Declare Static Sub setMusicVol(v As Single)
 	Declare Static Function getPlaybackPosition() As LongInt
 	
 	Declare Static Sub playSample(audioFile As ZString Ptr, ByRef offset As Vec2F = Vec2F(0, 0))
 	
 	Declare Static Sub update(dt As Double)
 	
 	Declare Static Sub cacheMusic(audioFile As ZString Ptr)
 	Declare Static Sub cacheSample(audioFile As ZString Ptr)
 	
 	Declare Static Sub resetFrequencyMul()
 	Declare Static Sub setFrequencyMul(m As Double)
 	
 	Static As DArray_Integer_ samples_
 	Static As DArray_Integer_ musics_
 Private:
 	Declare Constructor()
 	
 	Declare Static Function getSample(audioFile As ZString Ptr) As Integer
 	Declare Static Function getMusic(audioFile As ZString Ptr) As Integer
 	
 	Static As Single musicVol_
 	
 	Static As dsm.HashMap(ZString, Integer_) sampleCache_
 	Static As dsm.HashMap(ZString, Integer_) musicCache_
 	
 	Static As Single musicVolume_
 	Static As Boolean fadeIn_
 	Static As Integer currentMusicHandle_
 	Static As Integer currentMusicChannel_
 	Static As Double freqMul_
 	
 	Static As Double sampleRate_ 'const
 	
 	As Integer _ignored_
End Type

#EndIf
