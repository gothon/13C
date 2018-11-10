#Include "puzzles.bi"

#Include "debuglog.bi"

Namespace puzzle
		
Constructor ColorWheel(difficulty As Difficulty)
	DEBUG_ASSERT(difficulty <> puzzle.Difficulty.UNKNOWN)
	This.initialColor = Int(Rnd() * 14)
	'Depending on the difficulty, pick a random set of operators and then pick a target color
	'from the two "hardest to reach" target colors for that set of operators and start color.
	'"Hardest to reach" colors are those with the fewest operator set permutations from a
	'start color that can reach them (favoring non 0 and 8 targets if there is a tie).
	'
	'This gives us 140 unique colors pairs per difficulty level (except for easy where there are 84) 
	Select Case As Const difficulty
		Case puzzle.Difficulty.EASY
			Static As ColorOperator opBasePerms(0 To 2, 0 To 3) = _
					{{ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.COOL, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.HEAT}} 'Const
			Static As UInteger rarestPairs(0 To 2, 0 To 13, 0 To 1) = _
					{{{14, 12}, {11, 15}, {10, 0}, {9, 11}, {8, 12}, {9, 13}, {10, 12}, _
					  {6, 2}, {7, 1}, {8, 2}, {1, 3}, {6, 0}, {1, 5}, {2, 4}}, _
					 {{13, 9}, {14, 12}, {15, 8}, {0, 8}, {9, 15}, {10, 12}, {11, 13}, _
					  {3, 5}, {6, 4}, {1, 7}, {0, 8}, {1, 8}, {2, 4}, {3, 5}}, _
					 {{2, 4}, {3, 5}, {4, 6}, {1, 5}, {2, 6}, {7, 3}, {4, 6}, {12, 10}, _
					  {9, 13}, {10, 14}, {9, 11}, {10, 12}, {11, 13}, {14, 12}}} 'Const
			This.operatorsN = 4
			Dim As Integer randOp = Int(Rnd*3) 'Const
			operators(0) = opBasePerms(randOp, 0)
			operators(1) = opBasePerms(randOp, 1)
			operators(2) = opBasePerms(randOp, 2)
			operators(3) = opBasePerms(randOp, 3)
			This.targetColor = rarestPairs(randOp, This.initialColor, Int(Rnd * 2))		
		Case puzzle.Difficulty.MEDIUM
			Static As ColorOperator opBasePerms(0 To 4, 0 To 4) = _
					{{ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.COOL, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.COOL}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.HEAT, ColorOperator.HEAT}} 'Const
			Static As UInteger rarestPairs(0 To 4, 0 To 13, 0 To 1) = _
					{{{4, 6}, {1, 7}, {8, 2}, {7, 8}, {0, 4}, {1, 5}, {6, 2}, {10, 14}, _
						{9, 11}, {0, 10}, {9, 8}, {8, 10}, {9, 15}, {10, 12}}, _
					 {{3, 5}, {6, 4}, {7, 1}, {0, 8}, {1, 7}, {2, 4}, {3, 5}, {13, 11}, _
					  {14, 12}, {15, 9}, {0, 8}, {9, 11}, {10, 12}, {11, 13}}, _
					 {{10, 12}, {9, 13}, {14, 8}, {9, 15}, {10, 0}, {15, 11}, {14, 12}, _
					  {2, 4}, {1, 5}, {6, 0}, {1, 7}, {2, 8}, {7, 3}, {6, 4}}, _
					 {{9, 11}, {12, 8}, {9, 13}, {10, 14}, {11, 15}, {12, 0}, {15, 13}, _
					  {1, 3}, {4, 0}, {1, 5}, {2, 6}, {3, 7}, {4, 8}, {5, 7}}, _
					 {{9, 13}, {10, 14}, {15, 8}, {0, 8}, {9, 0}, {10, 14}, {11, 15}, _
					  {1, 5}, {2, 6}, {7, 0}, {0, 8}, {1, 8}, {6, 2}, {7, 3}}} 'Const
			This.operatorsN = 5
			Dim As Integer randOp = Int(Rnd*5) 'Const
			operators(0) = opBasePerms(randOp, 0)
			operators(1) = opBasePerms(randOp, 1)
			operators(2) = opBasePerms(randOp, 2)
			operators(3) = opBasePerms(randOp, 3)
			operators(4) = opBasePerms(randOp, 4)
			This.targetColor = rarestPairs(randOp, This.initialColor, Int(Rnd * 2))	
		Case puzzle.Difficulty.HARD
			Static As ColorOperator opBasePerms(0 To 4, 0 To 5) = _
					{{ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, _
						ColorOperator.HEAT, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, _
					  ColorOperator.COOL, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, _
					  ColorOperator.COOL, ColorOperator.COOL, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.INVERT, _
					  ColorOperator.COOL, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.INVERT, _
					  ColorOperator.COOL, ColorOperator.COOL, ColorOperator.HEAT}} 'Const
			Static As UInteger rarestPairs(0 To 4, 0 To 13, 0 To 1) = _
					{{{2, 8}, {3, 7}, {6, 4}, {7, 1}, {6, 2}, {7, 3}, {4, 6}, {10, 12}, _
						{9, 13}, {10, 14}, {9, 15}, {10, 12}, {9, 13}, {14, 8}}, _
					 {{1, 7}, {8, 6}, {8, 7}, {4, 8}, {0, 1}, {0, 6}, {1, 7}, {9, 15}, _
					  {0, 10}, {0, 15}, {12, 8}, {8, 9}, {8, 10}, {9, 15}}, _
					 {{6, 4}, {7, 5}, {8, 6}, {1, 0}, {0, 2}, {1, 3}, {2, 4}, {14, 12}, _
					  {15, 13}, {0, 14}, {15, 0}, {8, 10}, {9, 11}, {10, 12}}, _
					 {{10, 14}, {9, 15}, {0, 10}, {9, 15}, {8, 14}, {9, 15}, {10, 12}, _
					  {6, 4}, {7, 1}, {8, 2}, {1, 7}, {0, 6}, {7, 1}, {6, 2}}, _
					 {{13, 9}, {14, 12}, {15, 8}, {0, 8}, {9, 15}, {10, 12}, {11, 13}, _
					  {5, 3}, {6, 4}, {7, 1}, {0, 8}, {1, 8}, {2, 4}, {3, 7}}} 'Const
			This.operatorsN = 6
			Dim As Integer randOp = Int(Rnd*5) 'Const
			operators(0) = opBasePerms(randOp, 0)
			operators(1) = opBasePerms(randOp, 1)
			operators(2) = opBasePerms(randOp, 2)
			operators(3) = opBasePerms(randOp, 3)
			operators(4) = opBasePerms(randOp, 4)
			operators(5) = opBasePerms(randOp, 5)
			This.targetColor = rarestPairs(randOp, This.initialColor, Int(Rnd * 2))	
		Case puzzle.Difficulty.VERY_HARD
			Static As ColorOperator opBasePerms(0 To 4, 0 To 6) = _
					{{ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.COOL, _
						ColorOperator.HEAT, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.COOL, _
					  ColorOperator.COOL, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, _
					  ColorOperator.COOL, ColorOperator.HEAT, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, ColorOperator.COOL, _
					  ColorOperator.COOL, ColorOperator.COOL, ColorOperator.HEAT}, _
					 {ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.INVERT, ColorOperator.COOL, _
					  ColorOperator.COOL, ColorOperator.COOL, ColorOperator.HEAT}} 'Const
			Static As UInteger rarestPairs(0 To 4, 0 To 13, 0 To 1) = _
					{{{8, 7}, {4, 6}, {1, 7}, {6, 2}, {7, 3}, {4, 6}, {0, 7}, {0, 9}, _
					  {10, 12}, {9, 13}, {10, 14}, {15, 9}, {12, 10}, {8, 9}}, _
					 {{8, 6}, {8, 7}, {8, 6}, {7, 1}, {0, 6}, {0, 1}, {0, 2}, {0, 14}, _
					  {0, 15}, {0, 10}, {9, 15}, {8, 10}, {8, 9}, {8, 10}}, _
					 {{9, 15}, {0, 10}, {0, 15}, {12, 0}, {8, 9}, {8, 10}, {9, 15}, _
					  {7, 1}, {8, 6}, {8, 7}, {4, 0}, {0, 1}, {0, 6}, {7, 1}}, _ 
					 {{7, 1}, {8, 6}, {8, 7}, {0, 2}, {1, 0}, {0, 2}, {1, 3}, {15, 13}, _
					  {0, 14}, {15, 0}, {0, 14}, {8, 9}, {8, 10}, {9, 11}}, _
					 {{14, 12}, {15, 13}, {0, 14}, {8, 15}, {8, 10}, {9, 11}, {10, 12}, _
					  {6, 4}, {7, 5}, {8, 6}, {8, 1}, {0, 2}, {1, 3}, {2, 4}}} 'Const
			This.operatorsN = 7
			Dim As Integer randOp = Int(Rnd*5) 'Const
			operators(0) = opBasePerms(randOp, 0)
			operators(1) = opBasePerms(randOp, 1)
			operators(2) = opBasePerms(randOp, 2)
			operators(3) = opBasePerms(randOp, 3)
			operators(4) = opBasePerms(randOp, 4)
			operators(5) = opBasePerms(randOp, 5)
			operators(6) = opBasePerms(randOp, 6)
			This.targetColor = rarestPairs(randOp, This.initialColor, Int(Rnd * 2))	
		Case Else
			DEBUG_ASSERT(FALSE)
	End Select
	'Since our tables omit 0 and 8, adjust the actual initial color to reflect the start
	'position corresponding to the lookup index.
	This.initialColor += 1
	If This.initialColor > 7 Then This.initialColor += 1
	'Scrumble the operators.
	Do 
		For i As Integer = This.operatorsN - 1 To 1 Step -1
			Swap operators(i), operators(Int(Rnd * (i + 1)))
		Next i
	Loop While getColor(operatorsN) = This.targetColor
End Constructor

Const Function ColorWheel.getInitialColor() As UInteger
	Return initialColor
End Function

Const Function ColorWheel.getTargetColor() As UInteger
	Return targetColor
End Function

Const Function ColorWheel.getOperatorsN() As UInteger
	Return operatorsN
End Function

Sub ColorWheel.setOperator(opIndex As UInteger, op As ColorOperator)
	DEBUG_ASSERT(opIndex < operatorsN)
	operators(opIndex) = op
End Sub

Const Function ColorWheel.getOperator(opIndex As UInteger) As ColorOperator
	DEBUG_ASSERT(opIndex < operatorsN)
	Return operators(opIndex)
End Function

Const Function ColorWheel.getColor(stage As UInteger) As UInteger
	DEBUG_ASSERT(stage <= operatorsN)
	Dim As Integer curColor = initialColor
	For i As Integer = 0 To stage - 1
		Select Case As Const operators(i)
			Case ColorOperator.INVERT
				curColor = (curColor + 8) Mod 16
			Case ColorOperator.COOL
				If (curColor <> 0) AndAlso (curColor <> 8) Then
					If curColor > 8 Then
						curColor -= 1
					Else 
						curColor += 1
					EndIf
				EndIf
			Case ColorOperator.HEAT
				If (curColor <> 0) AndAlso (curColor <> 8) Then
					If curColor > 8 Then
						curColor += 2
						If curColor >= 16 Then curColor = 0
					Else 
						curColor -= 2
						If curColor < 0 Then curColor = 0
					EndIf
				EndIf
			Case Else
				DEBUG_ASSERT(FALSE)
		End Select
	Next i
	Return curColor
End Function

End Namespace
