#Include "puzzles.bi"
Randomize Timer 
Dim As puzzle.Arboretum a = puzzle.Arboretum(puzzle.Difficulty.VERY_HARD)

For i As Integer = 0 To 2
  Dim As Integer pot(0 To 2)
  a.getPot(0, i, pot())
  Print pot(0) & ", " & pot(1) & ", " & pot(2)
Next i
Print
For i As Integer = 0 To 3
  Dim As Integer pot(0 To 2)
  a.getPot(1, i, pot())
  Print pot(0) & ", " & pot(1) & ", " & pot(2)
Next i
Print 
For i As Integer = 0 To 4
  Dim As Integer pot(0 To 2)
  a.getPot(2, i, pot())
  Print pot(0) & ", " & pot(1) & ", " & pot(2)
Next i

Sleep
