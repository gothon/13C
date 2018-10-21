#Ifndef VERTEX_BI
#Define VERTEX_BI

#Include "vec3f.bi"
#Include "vec2f.bi"

'A simple vertex for model rendering.
Type Vertex  
  Declare Constructor( _
      ByRef p As Const Vec3F = Type(0.0f, 0.0f, 0.0f), _
      ByRef t As Const Vec2F = Type(0.0f, 0.0f), _
      ByRef c As Const Vec3F = Type(1.0f, 1.0f, 1.0f))
 
  'Position
  As Vec3F p
  
  'Texture coordinates
  As Vec2F t
  
  'Color modulator
  As Vec3F c
End Type

#EndIf
