#Include "light.bi"

#Include "util.bi"
#Include "debuglog.bi"
#Include "vecmath.bi"
 
DEFINE_PRIMITIVE_PTR(Light)
 	
Constructor Light(ByRef p As Const Vec3F, ByRef c As Const Vec3F, r As Double, mode As LightMode)
	This.p_ = p
	This.c_ = c
	'Since colors are reversed in the vertices
	Swap This.c_.x, This.c_.z
	This.r_ = r
	This.mode_ = mode
	This.enabled_ = TRUE
  This.bindings_ = 0
  updateExtent()
End Constructor

Constructor Light(ByRef other As Const Light)
	This = other
End Constructor

Operator Light.Let(ByRef other As Const Light)
	This.p_ = other.p_
	This.c_ = other.c_
	This.r_ = other.r_
	This.mode_ = other.mode_
	This.enabled_ = other.enabled_
  This.bindings_ = 0
  updateExtent()
End Operator

Destructor Light()
	DEBUG_ASSERT(bindings_ = 0)
End Destructor

Sub Light.bind()
  bindings_ += 1
End Sub

Sub Light.unbind()
  DEBUG_ASSERT(bindings_ > 0)
  bindings_ -= 1
End Sub  

Const Sub Light.add(ByRef p As Const Vec3F, ByRef n As Const Vec3F, v As Vertex Ptr)
	If Not inRange(p) Then Return 
	
	Dim As Vec3F lightNorm = p_ - p
	Dim As Double m = lightNorm.m() 'const
	lightNorm /= m
	
	Dim As Double s = (r_ - m)/r_
	If s < 0 Then s = 0
	s *= s

	Dim As Double l = Sqr(vecmath.dot(lightNorm, n))
	If l < 0 Then l = 0
	
	v->c += c_*l*s
End Sub

Const Sub Light.distanceAdd(ByRef p As Const Vec3F, v As Vertex Ptr)
	If Not inRange(p) Then Return 
	
	Dim As Vec3F lightNorm = p_ - p 'const
	Dim As Double m = lightNorm.m() 'const

	Dim As Double s = (r_ - m)/r_
	If s < 0 Then s = 0
	s *= s

	v->c += c_*s
End Sub
 	
 	
Const Function Light.inRange(ByRef p As Const Vec3F) As Boolean
	If enabled_ = FALSE Then Return FALSE
	If (p.x < minExtent_.x) OrElse (p.x > maxExtent_.x) OrElse _
			(p.y < minExtent_.y) OrElse (p.y > maxExtent_.y) OrElse _
			(p.z < minExtent_.z) OrElse (p.z > maxExtent_.z) Then Return FALSE
	Return TRUE
End Function 

Sub Light.updateExtent()
	minExtent_ = p_ - Vec3F(r_, r_, r_)
	maxExtent_ = p_ + Vec3F(r_, r_, r_)
End Sub
 	
Const As Double FLICKER_TOGGLE_CHANCE = 0.3
 	
Sub Light.update(t As Double)
	If This.mode_ = LightMode.FLICKER Then enabled_ = IIf(Rnd <= FLICKER_TOGGLE_CHANCE, Not enabled_, enabled_)
End Sub
 	
Sub Light.translate(ByRef v As Const Vec3F)
	p_ += v
	updateExtent()
End Sub
 	
Sub Light.on()
	enabled_ = TRUE
End Sub

Sub Light.off()
	enabled_ = FALSE
End Sub
