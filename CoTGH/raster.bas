#Include "raster.bi"

#Include "debuglog.bi"
#Include "vec2f.bi"
#Include "vecmath.bi"

'TODO(DotStarMoney): Rewrite scanline inner-loops to be pure ASM so we can reuse things like zeroed xmm2 register.

Namespace raster

'Opaque max-pink
#Define TRANSPARENT_COLOR_INT &hFFFF00FF

Type VIndex
  Declare Constructor (v As Const Vertex Ptr, i As Integer) 
  As Const Vertex Ptr v
  As Integer i
End Type

Constructor VIndex(v As Const Vertex Ptr, i As Integer)
  This.v = v
  This.i = i
End Constructor

#Macro DEFINE_LINEARINTERPOLATOR(_TYPENAME_)
Type LinearInterpolator##_TYPENAME_
 Public:
  Declare Constructor()
  Declare Constructor (ByRef base_ As Const _TYPENAME_, ByRef delta As Const _TYPENAME_)
  Declare Const Function value(x As Single) As _TYPENAME_
 Private:
  base_ As _TYPENAME_ 'Const
  delta As _TYPENAME_ 'Const
End Type

Constructor LinearInterpolator##_TYPENAME_()
  'Nop
End Constructor

Constructor LinearInterpolator##_TYPENAME_(ByRef base_ As Const _TYPENAME_, ByRef delta As Const _TYPENAME_)
  This.base_ = base_
  This.delta = delta
End Constructor

Const Function LinearInterpolator##_TYPENAME_.value(x As Single) As _TYPENAME_
  Return base_ + x*delta
End Function
#EndMacro

DEFINE_LINEARINTERPOLATOR(Vec3F)
DEFINE_LINEARINTERPOLATOR(Vec2F)
DEFINE_LINEARINTERPOLATOR(Single)

Type EdgeIterator
 Public:
  Declare Constructor()
  Declare Constructor( _
      startV As Const Vertex Ptr, _
      endV As Const Vertex Ptr, _
      ByRef deltaNorm As Const Vec2F, _
      dxDy As Single, _
      leftMost As Boolean)
    
  Declare Sub stepEdge()
  
  Declare Const Function x() As Integer
  Declare Const Function uv() As Vec2F
  Declare Const Function z() As Single
  Declare Const Function c() As Vec3F
 Private:
  Declare Sub updateEdgeDistance()
  Declare Sub stepInternal(amount As Single)
  Declare Sub boundX()
 
  As Integer iX
  As Vec2F p
  As Single capturedY
  As Single edgeD
  
  As LinearInterpolatorVec2F uvInterp
  As LinearInterpolatorSingle zInterp
  As LinearInterpolatorVec3F cModInterp

  As Single m 'Const
  As Vec2F dNorm 'Const
  As Vec2F startP 'Const
  As Vec2F endP 'Const
  As Single y1Floor 'Const
  As Single dxDy 'Const
  As Integer getBeforeStep 'Const
End Type
  
Constructor EdgeIterator()
  'Nop
End Constructor
  
Constructor EdgeIterator( _
    startV As Const Vertex Ptr, _
    endV As Const Vertex Ptr, _
    ByRef deltaNorm As Const Vec2F, _
    dxDy As Single, _
    leftMost As Boolean)
  
  This.startP = Vec2F(startV->p.x, startV->p.y)
  This.endP = Vec2F(endV->p.x, endV->p.y)
  This.y1Floor = Int(This.endP.y)
  
  This.m = deltaNorm.m()
  DEBUG_ASSERT(This.m > 0.0f)
  
  Dim As Single mInverse = 1.0f / This.m
  This.dNorm = deltaNorm * mInverse
  
  uvInterp = LinearInterpolatorVec2F(startV->t, (endV->t - startV->t)*mInverse)
  zInterp = LinearInterpolatorSingle(startV->p.z, (endV->p.z - startV->p.z)*mInverse)
  cModInterp = LinearInterpolatorVec3F(startV->c, (endV->c - startV->c)*mInverse)

  This.dxDy = dxDy
  This.getBeforeStep = IIf(This.dxDy > 0, leftMost, Not leftMost)
  
  Dim As Single yDisplace = (Int(This.startP.y) + 1.0f) - This.startP.y
  
  This.p.x = This.startP.x
  This.capturedY = This.startP.y
  stepInternal(yDisplace*This.dxDy)
End Constructor

Sub EdgeIterator.stepInternal(amount As Single)
  p.y = capturedY
  capturedY = Int(capturedY) + 1.5f
  If Int(capturedY) >= y1Floor Then capturedY = endP.y
  If getBeforeStep Then
    iX = Int(p.x)
    p.x += amount
    boundX()
  Else 
    p.x += amount
    boundX()
    iX = Int(p.x)
  EndIf
  updateEdgeDistance()
End Sub

Sub EdgeIterator.boundX()
  If dxDy >= 0 Then
    p.x = IIf(p.x > endP.x, endP.x, p.x)
  Else
    p.x = IIf(p.x < endP.x, endP.x, p.x)
  EndIf
End Sub

Sub EdgeIterator.stepEdge()
  stepInternal(dxDy)
End Sub

Sub EdgeIterator.updateEdgeDistance()
  edgeD = vecmath.dot(dNorm, Vec2F(iX + 0.5f, p.y) - startP)
  If edgeD < 0.0f Then
    edgeD = 0.0f
  ElseIf edgeD > m Then
    edgeD = m
  EndIf
End Sub

Const Function EdgeIterator.x() As Integer
  Return iX
End Function

Const Function EdgeIterator.z() As Single
  Return zInterp.value(edgeD)
End Function

Const Function EdgeIterator.uv() As Vec2F
  Return uvInterp.value(edgeD)
End Function

Const Function EdgeIterator.c() As Vec3F
  Return cModInterp.value(edgeD)
End Function

Sub drawScanLine_Textured( _
    ByRef src As Const Image32, _
    y As Integer, _
    ByRef edge0 As Const EdgeIterator, _
    ByRef edge1 As Const EdgeIterator, _
    trimRightEdge As Boolean = FALSE, _
    dst As Image32 Ptr) 
  Dim As Single steps = edge1.x() - edge0.x()
  If steps = 0.0f Then steps = 1.0f

  Dim As Single lB = IIf(edge0.x() < 0.0f, 0.0f, edge0.x()) 'Const
  Dim As Single rB = _
      IIf(edge1.x() >= dst->w(), dst->w() - 1, edge1.x()) - IIf(trimRightEdge, 1, 0) 'Const
  Dim As Single leftEdgeOverlap = lB - edge0.x() 'Const
  
  Dim As Single curSz = edge0.z()
  Dim As Single sZStep = (edge1.z() - edge0.z()) / steps 'Const
  curSz += leftEdgeOverlap * sZStep
  
  Dim As Vec2F curUv = edge0.uv()
  Dim As Vec2F uvStep = (edge1.uv() - edge0.uv()) / steps 'Const
  curUv += leftEdgeOverlap * uvStep

  Dim As Pixel32 Ptr dstPixels = @dst->pixels()[y*dst->w() + lB] 
  For x As Integer = lB To rB
    Dim As Integer u = Int(curUv.x / curSz) 'Const
    Dim As Integer v = Int(curUv.y / curSz) 'Const
    
    Dim As Const Pixel32 Ptr srcP = src.constPixels() 'Const
    Dim As Integer srcW = src.w() 'Const
    
    Asm
      'Get pixel offset, v*src.w() + u in EAX
      mov eax, v
      mul srcW
      add eax, u  
      'Get pixel value in EBX using the pixel offset
      mov ebx, srcP
      mov ebx, [ebx+eax*4]
      mov eax, TRANSPARENT_COLOR_INT
      'Here we get both the pointer value of, and, the value at, dstPixels
      mov ecx, dstPixels
      mov edx, [ecx]
      'Plot src else dst if src == transparent color
      cmpxchg ebx, edx
      mov [ecx], ebx
    End Asm
    
    dstPixels += 1
    curSz += sZStep
    curUv += uvStep
  Next x
End Sub

Sub drawScanLine_TexturedModulated(_
    ByRef src As Const Image32, _
    y As Integer, _
    ByRef edge0 As Const EdgeIterator, _
    ByRef edge1 As Const EdgeIterator, _
    trimRightEdge As Boolean = FALSE, _
    dst As Image32 Ptr) 
  Dim As Single steps = edge1.x() - edge0.x()
  If steps = 0.0f Then steps = 1.0f

  Dim As Single lB = IIf(edge0.x() < 0.0f, 0.0f, edge0.x()) 'Const
  Dim As Single rB = _
      IIf(edge1.x() >= dst->w(), dst->w() - 1, edge1.x()) - IIf(trimRightEdge, 1, 0) 'Const
  Dim As Single leftEdgeOverlap = lB - edge0.x() 'Const
  
  Dim As Single curSz = edge0.z()
  Dim As Single sZStep = (edge1.z() - edge0.z()) / steps 'Const
  curSz += leftEdgeOverlap * sZStep
  
  Dim As Vec2F curUv = edge0.uv()
  Dim As Vec2F uvStep = (edge1.uv() - edge0.uv()) / steps 'Const
  curUv += leftEdgeOverlap * uvStep
  
  Dim As Single curMod(0 To 3) = {edge0.c().x*256.0f, edge0.c().y*256.0f, edge0.c().z*256.0f, 0.0f}
  Dim As Single modStep(0 To 3) = { _
      (edge1.c().x - edge0.c().x)/steps*256.0f, _
      (edge1.c().y - edge0.c().y)/steps*256.0f, _
      (edge1.c().z - edge0.c().z)/steps*256.0f, _
      0.0f} 'Const
      
  curMod(0) += leftEdgeOverlap * modStep(0)
  curMod(1) += leftEdgeOverlap * modStep(1)
  curMod(2) += leftEdgeOverlap * modStep(2)

  Dim As Pixel32 Ptr dstPixels = @dst->pixels()[y*dst->w() + lB] 
  For x As Integer = lB To rB
    Dim As Integer u = Int(curUv.x / curSz) 'Const
    Dim As Integer v = Int(curUv.y / curSz) 'Const
    
    Dim As Const Pixel32 Ptr srcP = src.constPixels() 'Const
    Dim As Integer srcW = src.w() 'Const
    
    Dim As Single Ptr modPtr = @curMod(0) 'Const
    
    Asm
      'Get the color mod in xmm1 as 4x 32-bit ints between 0 and 256. We'll shift the 256 out later
      'during multiplication.
      mov esi, modPtr
      movaps xmm0, [esi]
      cvttps2dq xmm1, xmm0
      'Get 4 16-bit ints of the mod in the bottom 64-btis of xmm1
      packssdw xmm1, xmm1
      
      'Get pixel offset, v*src.w() + u in EAX
      mov eax, v
      mul srcW
      add eax, u  
      'Get pixel value in xmm0 and ebx using the pixel offset
      mov ebx, srcP
      mov ebx, [ebx+eax*4]
      movd xmm0, ebx

      'Clear xmm2
      pxor xmm2, xmm2
      'Get the byte values as 4 shorts into xmm0
      punpcklbw xmm0, xmm2
      'Multiply the mod and the src, shifting down by 8 afterward
      pmullw xmm0, xmm1
      psrlw xmm0, 8
      
      'Pack the byte-ranged integers back into actual bytes in xmm0
      packuswb xmm0, xmm2
      'Move back into normal register world
      movd esi, xmm0
      
      mov eax, TRANSPARENT_COLOR_INT
      'Here we get both the pointer value of, and, the value at, dstPixels
      mov ecx, dstPixels
      mov edx, [ecx]
      'Save a copy of the actual source pixel (ebx)
      mov edi, ebx
      'Move src else dst if src == transparent color into ebx
      cmpxchg ebx, edx
      
      'Do one more compare and exchange to either keep the dst color or update the
      'src color with the blended one.
      mov eax, edi
      cmpxchg ebx, esi
      
      mov [ecx], ebx
    End Asm

    dstPixels += 1
    
    curSz += sZStep
    curUv += uvStep
    
    curMod(0) += modStep(0)
    curMod(1) += modStep(1)
    curMod(2) += modStep(2)
  Next x  
End Sub

Sub drawScanLine_Flat(_
    ByRef src As Const Image32, _
    y As Integer, _
    ByRef edge0 As Const EdgeIterator, _
    ByRef edge1 As Const EdgeIterator, _
    trimRightEdge As Boolean = FALSE, _
    dst As Image32 Ptr) 
  Dim As Single steps = edge1.x() - edge0.x()
  If steps = 0.0f Then steps = 1.0f

  Dim As Single lB = IIf(edge0.x() < 0.0f, 0.0f, edge0.x()) 'Const
  Dim As Single rB = _
      IIf(edge1.x() >= dst->w(), dst->w() - 1, edge1.x()) - IIf(trimRightEdge, 1, 0) 'Const
  Dim As Single leftEdgeOverlap = lB - edge0.x() 'Const
  
  Dim As Single curMod(0 To 3) = {edge0.c().x*255.0f, edge0.c().y*255.0f, edge0.c().z*255.0f, 0.0f}
  Dim As Single modStep(0 To 3) = { _
      (edge1.c().x - edge0.c().x)/steps*255.0f, _
      (edge1.c().y - edge0.c().y)/steps*255.0f, _
      (edge1.c().z - edge0.c().z)/steps*255.0f, _
      0.0f} 'Const
      
  curMod(0) += leftEdgeOverlap * modStep(0)
  curMod(1) += leftEdgeOverlap * modStep(1)
  curMod(2) += leftEdgeOverlap * modStep(2)

  Dim As Pixel32 Ptr dstPixels = @dst->pixels()[y*dst->w() + lB] 
  For x As Integer = lB To rB
    Dim As Const Pixel32 Ptr srcP = src.constPixels() 'Const
    Dim As Integer srcW = src.w() 'Const
    
    Dim As Single Ptr modPtr = @curMod(0) 'Const
    
    Asm
      'Get the color mod in xmm1 as 4x 32-bit ints between 0 and 255.
      mov esi, modPtr
      movaps xmm0, [esi]
      cvttps2dq xmm1, xmm0
      'Get 4 16-bit ints of the mod in the bottom 64-btis of xmm1
      packssdw xmm1, xmm1
      'Clear xmm2
      pxor xmm2, xmm2
      'Pack the byte-ranged integers back into actual bytes in xmm0
      packuswb xmm1, xmm2
      'Move back into normal register world
      movd esi, xmm1
      'Plot!
      mov ecx, dstPixels
      mov [ecx], esi
    End Asm

    dstPixels += 1

    curMod(0) += modStep(0)
    curMod(1) += modStep(1)
    curMod(2) += modStep(2)
  Next x  
End Sub

Sub drawScanLine_TexturedConstant(_
    ByRef src As Const Image32, _
    y As Integer, _
    ByRef edge0 As Const EdgeIterator, _
    ByRef edge1 As Const EdgeIterator, _
    trimRightEdge As Boolean = FALSE, _
    dst As Image32 Ptr) 
  Dim As Single steps = edge1.x() - edge0.x()
  If steps = 0.0f Then steps = 1.0f

  Dim As Single lB = IIf(edge0.x() < 0.0f, 0.0f, edge0.x()) 'Const
  Dim As Single rB = _
      IIf(edge1.x() >= dst->w(), dst->w() - 1, edge1.x()) - IIf(trimRightEdge, 1, 0) 'Const
  Dim As Single leftEdgeOverlap = lB - edge0.x() 'Const
  
  Dim As Single curSz = edge0.z()
  Dim As Single sZStep = (edge1.z() - edge0.z()) / steps 'Const
  curSz += leftEdgeOverlap * sZStep
  
  Dim As Vec2F curUv = edge0.uv()
  Dim As Vec2F uvStep = (edge1.uv() - edge0.uv()) / steps 'Const
  curUv += leftEdgeOverlap * uvStep
  
  Dim As Single modConst(0 To 3) = {edge0.c().x*256.0f, edge0.c().y*256.0f, edge0.c().z*256.0f, 0.0f} 'Const
  Dim As Single Ptr modPtr = @modConst(0) 'Const
    
  Dim As Pixel32 Ptr dstPixels = @dst->pixels()[y*dst->w() + lB] 
  For x As Integer = lB To rB
    Dim As Integer u = Int(curUv.x / curSz) 'Const
    Dim As Integer v = Int(curUv.y / curSz) 'Const
    
    Dim As Const Pixel32 Ptr srcP = src.constPixels() 'Const
    Dim As Integer srcW = src.w() 'Const
    
    Asm
      'Get the color mod in xmm1 as 4x 32-bit ints between 0 and 256. We'll shift the 256 out later
      'during multiplication.
      mov esi, modPtr
      movaps xmm0, [esi]
      cvttps2dq xmm1, xmm0
      'Get 4 16-bit ints of the mod in the bottom 64-btis of xmm1
      packssdw xmm1, xmm1
      
      'Get pixel offset, v*src.w() + u in EAX
      mov eax, v
      mul srcW
      add eax, u  
      'Get pixel value in xmm0 and ebx using the pixel offset
      mov ebx, srcP
      mov ebx, [ebx+eax*4]
      movd xmm0, ebx

      'Clear xmm2
      pxor xmm2, xmm2
      'Get the byte values as 4 shorts into xmm0
      punpcklbw xmm0, xmm2
      'Multiply the mod and the src, shifting down by 8 afterward
      pmullw xmm0, xmm1
      psrlw xmm0, 8
      
      'Pack the byte-ranged integers back into actual bytes in xmm0
      packuswb xmm0, xmm2
      'Move back into normal register world
      movd esi, xmm0
      
      mov eax, TRANSPARENT_COLOR_INT
      'Here we get both the pointer value of, and, the value at, dstPixels
      mov ecx, dstPixels
      mov edx, [ecx]
      'Save a copy of the actual source pixel (ebx)
      mov edi, ebx
      'Move src else dst if src == transparent color into ebx
      cmpxchg ebx, edx
      
      'Do one more compare and exchange to either keep the dst color or update the
      'src color with the blended one.
      mov eax, edi
      cmpxchg ebx, esi
      
      mov [ecx], ebx
    End Asm

    dstPixels += 1
    
    curSz += sZStep
    curUv += uvStep
  Next x  
End Sub
 
#Macro DEFINE_DRAWPLANARQUAD(_METHOD_)
Sub drawPlanarQuad_##_METHOD_( _
    ByRef src As Const Image32, _
    ByRef v0 As Const Vertex Ptr, _
    ByRef v1 As Const Vertex Ptr, _
    ByRef v2 As Const Vertex Ptr, _
    ByRef v3 As Const Vertex Ptr, _
    trimRightEdge As Boolean = FALSE, _
    trimLowerEdge As Boolean = FALSE, _
    dst As Image32 Ptr)
  
  Dim As VIndex sorted(0 To 3) = {VIndex(v0, 0), VIndex(v1, 1), VIndex(v2, 2), VIndex(v3, 3)}
  
  'Sort the vertices
  If sorted(0).v->p.y > sorted(2).v->p.y Then Swap sorted(0), sorted(2)
  If sorted(1).v->p.y > sorted(3).v->p.y Then Swap sorted(1), sorted(3)
  If sorted(0).v->p.y > sorted(1).v->p.y Then Swap sorted(0), sorted(1)
  If sorted(2).v->p.y > sorted(3).v->p.y Then Swap sorted(2), sorted(3)
  If sorted(1).v->p.y > sorted(2).v->p.y Then Swap sorted(1), sorted(2)

  If Int(sorted(0).v->p.y) >= dst->h() Then Return
  If Int(sorted(3).v->p.y) < 0.0f Then Return
  
  'Get just the screen coordinates of the sorted points
  Dim As Vec2F scnSorted(0 To 3) = { _
      Vec2F(sorted(0).v->p.x, sorted(0).v->p.y), _
      Vec2F(sorted(1).v->p.x, sorted(1).v->p.y), _
      Vec2F(sorted(2).v->p.x, sorted(2).v->p.y), _
      Vec2F(sorted(3).v->p.x, sorted(3).v->p.y)}
          
  Dim As EdgeIterator iterators(0 To 3)
  Dim As Single dxDy(0 To 1)
  Dim As Vec2F delta(0 To 1)
  Dim As Integer updateUsedIterator(0 To 1)
  Dim As EdgeIterator Ptr curIterator(0 To 1)
  
  'check side of breaks
  If ((sorted(0).i + 2) Mod 4) = sorted(3).i Then
    'breaks are over both sides
    delta(0) = scnSorted(1) - scnSorted(0)
    delta(1) = scnSorted(2) - scnSorted(0)
    dxDy(0) = delta(0).x / delta(0).y
    dxDy(1) = delta(1).x / delta(1).y
    if dxDy(0) > dxDy(1) Then
      'first break is to the right
      Dim As Any Ptr unused = New(@iterators(0)) EdgeIterator(sorted(0).v, sorted(2).v, delta(1), dxDy(1), TRUE)
      unused = New(@iterators(1)) EdgeIterator(sorted(0).v, sorted(1).v, delta(0), dxDy(0), FALSE)
      
      Dim As Vec2F tmpDelta = scnSorted(3) - scnSorted(1)
      Dim As Single tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(2)) EdgeIterator(sorted(1).v, sorted(3).v, tmpDelta, tmpDxDy, FALSE)
      tmpDelta = scnSorted(3) - scnSorted(2)
      tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(3)) EdgeIterator(sorted(2).v, sorted(3).v, tmpDelta, tmpDxDy, TRUE)     

      updateUsedIterator(0) = 1
      updateUsedIterator(1) = 0
    Else
      Dim As Any Ptr unused = New(@iterators(0)) EdgeIterator(sorted(0).v, sorted(1).v, delta(0), dxDy(0), TRUE)
      unused = New(@iterators(1)) EdgeIterator(sorted(0).v, sorted(2).v, delta(1), dxDy(1), FALSE)
      
      Dim As Vec2F tmpDelta = scnSorted(3) - scnSorted(1)
      Dim As Single tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(2)) EdgeIterator(sorted(1).v, sorted(3).v, tmpDelta, tmpDxDy, TRUE)
      tmpDelta = scnSorted(3) - scnSorted(2)
      tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(3)) EdgeIterator(sorted(2).v, sorted(3).v, tmpDelta, tmpDxDy, FALSE)     

      updateUsedIterator(0) = 0
      updateUsedIterator(1) = 1
    EndIf
  Else
    'breaks are on the same side
    delta(0) = scnSorted(3) - scnSorted(0)
    delta(1) = scnSorted(1) - scnSorted(0)
    dxDy(0) = delta(0).x / delta(0).y
    dxDy(1) = delta(1).x / delta(1).y
    If dxDy(0) < dxDy(1) Then
      'both breaks are on the right
      Dim As Any Ptr unused = New(@iterators(0)) EdgeIterator(sorted(0).v, sorted(3).v, delta(0), dxDy(0), TRUE)
      unused = New(@iterators(1)) EdgeIterator(sorted(0).v, sorted(1).v, delta(1), dxDy(1), FALSE)

      Dim As Vec2F tmpDelta = scnSorted(2) - scnSorted(1)
      Dim As Single tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(2)) EdgeIterator(sorted(1).v, sorted(2).v, tmpDelta, tmpDxDy, FALSE)
      tmpDelta = scnSorted(3) - scnSorted(2)
      tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(3)) EdgeIterator(sorted(2).v, sorted(3).v, tmpDelta, tmpDxDy, FALSE)     

      updateUsedIterator(0) = 1
      updateUsedIterator(1) = 1
    Else
      Dim As Any Ptr unused = New(@iterators(0)) EdgeIterator(sorted(0).v, sorted(1).v, delta(1), dxDy(1), TRUE)
      unused = New(@iterators(1)) EdgeIterator(sorted(0).v, sorted(3).v, delta(0), dxDy(0), FALSE)

      Dim As Vec2F tmpDelta = scnSorted(2) - scnSorted(1)
      Dim As Single tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(2)) EdgeIterator(sorted(1).v, sorted(2).v, tmpDelta, tmpDxDy, TRUE)
      tmpDelta = scnSorted(3) - scnSorted(2)
      tmpDxDy = tmpDelta.x / tmpDelta.y
      unused = New(@iterators(3)) EdgeIterator(sorted(2).v, sorted(3).v, tmpDelta, tmpDxDy, TRUE)     
            
      updateUsedIterator(0) = 0
      updateUsedIterator(1) = 0
    EndIf
  EndIf
  
  curIterator(0) = @iterators(0)
  curIterator(1) = @iterators(1)
  
  Dim As Integer y
  Dim As Integer lowerBound
  
  'First section
  lowerBound = Int(scnSorted(1).y) - 1
  If lowerBound >= dst->h() Then lowerBound = dst->h() - 1
  For y = Int(scnSorted(0).y) To lowerBound
    If y >= 0 Then drawScanLine_##_METHOD_(src, y, *curIterator(0), *curIterator(1), trimRightEdge, dst)
    curIterator(0)->stepEdge()
    curIterator(1)->stepEdge()
  Next y
  If y >= dst->h() Then Return
  
  Dim As EdgeIterator Ptr appliedIterator(0 To 1)
  
  'Depending on which side gets an update, we may have to use the old iterator's final x position or the
  'new iterators first x position as the x position of the next line. We choose by which iterator causes
  'us to cover more pixels.
  If updateUsedIterator(0) = 0 Then
    appliedIterator(1) = curIterator(1)
    If curIterator(0)->x() > iterators(2).x() Then
      appliedIterator(0) = @iterators(2)
    Else
      appliedIterator(0) = curIterator(0)
    EndIf
    curIterator(0) = @iterators(2)
  Else 'updateUsedIterator(0) = 1 Then
    appliedIterator(0) = curIterator(0)
    If curIterator(1)->x() > iterators(2).x() Then
      appliedIterator(1) = @iterators(2)
    Else
      appliedIterator(1) = curIterator(1)
    EndIf
    curIterator(1) = @iterators(2)
  EndIf

  'Second section
  lowerBound = Int(scnSorted(2).y) - 1
  If lowerBound >= dst->h() Then lowerBound = dst->h() - 1
  For y As Integer = Int(scnSorted(1).y) To Int(scnSorted(2).y) - 1
    If y >= 0 Then drawScanLine_##_METHOD_(src, y, *appliedIterator(0), *appliedIterator(1), trimRightEdge, dst)
    curIterator(0)->stepEdge()
    curIterator(1)->stepEdge()
    appliedIterator(0) = curIterator(0)
    appliedIterator(1) = curIterator(1)
  Next y
  If y >= dst->h() Then Return
    
  If updateUsedIterator(1) = 0 Then
    appliedIterator(1) = curIterator(1)
    If curIterator(0)->x() > iterators(3).x() Then
      appliedIterator(0) = @iterators(3)
    Else
      appliedIterator(0) = curIterator(0)
    EndIf
    curIterator(0) = @iterators(3)
  Else 'updateUsedIterator(1) = 1 Then
    appliedIterator(0) = curIterator(0)
    If curIterator(1)->x() > iterators(3).x() Then
      appliedIterator(1) = @iterators(3)
    Else
      appliedIterator(1) = curIterator(1)
    EndIf
    curIterator(1) = @iterators(3)
  EndIf
  
  'Third section
  lowerBound = Int(scnSorted(3).y) - IIf(trimLowerEdge, 1, 0)
  If lowerBound >= dst->h() Then lowerBound = dst->h() - 1
  For y As Integer = Int(scnSorted(2).y) To lowerBound
    If y >= 0 Then drawScanLine_##_METHOD_(src, y, *appliedIterator(0), *appliedIterator(1), trimRightEdge, dst)
    curIterator(0)->stepEdge()
    curIterator(1)->stepEdge()
    appliedIterator(0) = curIterator(0)
    appliedIterator(1) = curIterator(1)
  Next y
End Sub
#EndMacro

DEFINE_DRAWPLANARQUAD(Textured)
DEFINE_DRAWPLANARQUAD(TexturedModulated)
DEFINE_DRAWPLANARQUAD(Flat)
DEFINE_DRAWPLANARQUAD(TexturedConstant)

End Namespace
