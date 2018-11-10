#Include "variant.bi"
#Include "vec2f.bi"
#Include "puzzles.bi"

Randomize Timer
Dim As puzzle.ColorWheel z = puzzle.ColorWheel(puzzle.Difficulty.MEDIUM)

Print z.getInitialColor()
Print z.getTargetColor()
For i As Integer = 0 To z.getOperatorsN() - 1
	Print z.getOperator(i);
Next i
Print

For i As Integer = 0 To z.getOperatorsN()
	Print z.getColor(i); " ";
Next i

 
sleep

