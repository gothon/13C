#Include "raster.bi"

Namespace raster
 
Type VIndex
  Declare Constructor (v As Const Vertex Ptr, i As Integer) 
  As Const Vertex Ptr v
  As Integer i
End Type

Constructor VIndex(v As Const Vertex Ptr, i As Integer)
  This.v = v
  This.i = i
End Constructor
  
Sub drawPlanarQuad OverLoad ( _
    ByRef src As Const Image32, _
    ByRef colorMod As Const Vec3F, _
    ByRef v0 As Const Vertex Ptr, _
    ByRef v1 As Const Vertex Ptr, _
    ByRef v2 As Const Vertex Ptr, _
    ByRef v3 As Const Vertex Ptr, _
    dst As Image32 Ptr)
  
  Dim As VIndex sorted(0 To 3) = {VIndex(v0, 0), VIndex(v1, 1), VIndex(v2, 2), VIndex(v3, 3)}
  
  If sorted(0).v->p.y > sorted(2).v->p.y Then Swap sorted(0), sorted(2)
  If sorted(1).v->p.y > sorted(3).v->p.y Then Swap sorted(1), sorted(3)
  If sorted(0).v->p.y > sorted(1).v->p.y Then Swap sorted(0), sorted(1)
  If sorted(2).v->p.y > sorted(3).v->p.y Then Swap sorted(2), sorted(3)
  If sorted(1).v->p.y > sorted(2).v->p.y Then Swap sorted(1), sorted(2)
  
  /'
  Dim As Single dxDy(0 To 1)
  Dim As Single dxDyUpdate(0 To 1)
  Dim As UInteger updateIndex(0 To 1)

  'check side of breaks
  If ((sorted(0).i + 2) Mod 4) = sorted(3).i Then
    'breaks are over both sides
    dxDy(0) = (sorted(1).v->p.x - sorted(0).v->p.x) / (sorted(1).v->p.y - sorted(0).v->p.y)
    dxDy(1) = (sorted(2).v->p.x - sorted(0).v->p.x) / (sorted(2).v->p.y - sorted(0).v->p.y)
    dxDyUpdate(0) = (sorted(3).v->p.x - sorted(1).v->p.x) / (sorted(3).v->p.y - sorted(1).v->p.y)
    dxDyUpdate(1) = (sorted(3).v->p.x - sorted(2).v->p.x) / (sorted(3).v->p.y - sorted(2).v->p.y)
    if dxDy(0) > dxDy(1) Then
      'first break is to the right
      Swap dxDy(0), dxDy(1)
      updateIndex(0) = 1
      updateIndex(1) = 0
    Else
      updateIndex(0) = 0
      updateIndex(1) = 1
    EndIf
  Else
    'breaks are on the same side
    dxDy(0) = (sorted(3).v->p.x - sorted(0).v->p.x) / (sorted(3).v->p.y - sorted(0).v->p.y)
    dxDy(1) = (sorted(1).v->p.x - sorted(0).v->p.x) / (sorted(1).v->p.y - sorted(0).v->p.y)
    dxDyUpdate(0) = (sorted(2).v->p.x - sorted(1).v->p.x) / (sorted(2).v->p.y - sorted(1).v->p.y)
    dxDyUpdate(1) = (sorted(3).v->p.x - sorted(2).v->p.x) / (sorted(3).v->p.y - sorted(2).v->p.y)
    If dxDy(0) < dxDy(1) Then
      'both breaks are on the right
      updateIndex(0) = 1
      updateIndex(1) = 1
    Else
      Swap dxDy(0), dxDy(1)
      updateIndex(0) = 0
      updateIndex(1) = 0      
    EndIf
  EndIf
  
  Dim As Single x(0 To 1) = {sorted(0).v->p.x, sorted(0).v->p.x}
  Dim As Integer drawX(0 To 1) = {Int(x(0)), Int(x(1))}
  
  Dim As Single yDisplace = (Int(sorted(0).v->p.y) + 1.0f) - sorted(0).v->p.y
  x(0) += yDisplace*dxDy(0)
  x(1) += yDisplace*dxDy(1)

  If Int(x(0)) < drawX(0) Then drawX(0) = Int(x(0))
  If Int(x(1)) > drawX(1) Then drawX(1) = Int(x(1))

  Dim As Integer y
  For y = Int(sorted(0).v->p.y) To Int(sorted(1).v->p.y)
    
    
    'stuff on drawX(0) to drawX(1)
    Line (drawX(0)*32, y*32)-(drawX(1)*32 + 31, y*32 + 31), ,BF
    '''
    x(0) += dxDy(0)
    x(1) += dxDy(1)
    drawX(0) = Int(x(0))
    drawX(1) = Int(x(1))
  Next y
  
 
  Dim As UInteger cardinality(0 To 1) = {0, 0}
  cardinality(updateIndex(0)) = 1 - cardinality(updateIndex(0))
  
  x(updateIndex(0)) = sorted(1).v->p.x
  drawX(updateIndex(0)) = Int(sorted(1).v->p.x)
  dxDy(updateIndex(0)) = dxDyUpdate(0)

  yDisplace = (Int(sorted(1).v->p.y) + 1.0f) - sorted(1).v->p.y
  x(updateIndex(0)) += yDisplace*dxDyUpdate(0)
 
  If Int(x(0)) < drawX(0) Then drawX(0) = Int(x(0))
  If Int(x(1)) > drawX(1) Then drawX(1) = Int(x(1))
 
 Print cardinality(0), cardinality(1)
 
  For y = Int(sorted(1).v->p.y) To Int(sorted(2).v->p.y) - 1
    'stuff on drawX(0) to drawX(1)
    Line (drawX(0)*32, y*32)-(drawX(1)*32 + 31, y*32 + 31), ,BF
    '''
    
    If (cardinality(0) = 1) Then
      drawX(0) = Int(x(0))
      x(0) += dxDy(0)
    Else 
      x(0) += dxDy(0)
      drawX(0) = Int(x(0))    
    EndIf

    If (cardinality(1) = 1) Then
      drawX(1) = Int(x(1))
      x(1) += dxDy(1)
    Else 
      x(1) += dxDy(1)
      drawX(1) = Int(x(1))      
    EndIf
  Next y

  cardinality(updateIndex(1)) = 1 - cardinality(updateIndex(1))

  x(updateIndex(1)) = sorted(2).v->p.x
  drawX(updateIndex(1)) = Int(sorted(2).v->p.x)
  dxDy(updateIndex(1)) = dxDyUpdate(1)
  
  yDisplace = (Int(sorted(2).v->p.y) + 1.0f) - sorted(2).v->p.y
  x(updateIndex(1)) += yDisplace*dxDyUpdate(1)

  'If Int(x(0)) < drawX(0) Then drawX(0) = Int(x(0))
  If Int(x(1)) > drawX(1) Then drawX(1) = Int(x(1))
  
  For y = Int(sorted(2).v->p.y) To Int(sorted(3).v->p.y)
    'stuff on drawX(0) to drawX(1)
    Line (drawX(0)*32, y*32)-(drawX(1)*32 + 31, y*32 + 31), ,BF
    '''

    If (cardinality(0) = 0) Then
      drawX(0) = Int(x(0))
      x(0) += dxDy(0)
    Else 
      x(0) += dxDy(0)
      drawX(0) = Int(x(0))    
    EndIf

    If (cardinality(1) = 0) Then
      drawX(1) = Int(x(1))
      x(1) += dxDy(1)
    Else 
      x(1) += dxDy(1)
      drawX(1) = Int(x(1))      
    EndIf
  Next y
  '/
End Sub
  
End Namespace
