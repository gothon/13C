#Ifndef VERTEX_BI
#Define VERTEX_BI

#Include "vec3f.bi"
#Include "vec2f.bi"

'A simple vertex for model rendering.
Type Vertex  
  Declare Constructor(ByRef p As Const Vec3F, ByRef t As Const Vec2F, c As Single)
  
  'Sets the texture coordinates to 0,0 and modulator to 1.
  Declare Constructor(ByRef p As Const Vec3F = Type(0.0f, 0.0f, 0.0f))
  
  'Position
  As Vec3F p
  
  'Texture coordinates
  As Vec2F t
  
  'Color modulator
  As Single c
End Type

#EndIf
