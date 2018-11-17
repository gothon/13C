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

Function ColorWheel.collectOperator(opIndex As UInteger) As ColorOperator
	DEBUG_ASSERT(opIndex < operatorsN)
  operators(opIndex) = ColorOperator.UNKNOWN
	Return operators(opIndex)
End Function

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
  
Constructor Arboretum(difficulty As Difficulty)
	Select Case As Const difficulty
	  Case puzzle.Difficulty.EASY
	    This.variations = 4
	  Case puzzle.Difficulty.MEDIUM
	   	This.variations = 5
		Case puzzle.Difficulty.HARD
			This.variations = 6
		Case puzzle.Difficulty.VERY_HARD
	    This.variations = 7
	End Select
	prepareSolution()
End Constructor

Sub Arboretum.prepareSolution()
  Dim As Boolean tooEasy
  Do
    fillRow(row1())
    fillRow(row2())
    fillRow(row3())
    
    tooEasy = FALSE
    Dim As UInteger shuffleAttempts = 0
    While checkSolution(0) OrElse checkSolution(1) OrElse checkSolution(2)
      shuffleAttempts += 1
      If shuffleAttempts >= 32 Then
        tooEasy = TRUE
        Exit While
      EndIf
      shuffle()
    Wend
  Loop While tooEasy
End Sub

Sub Arboretum.fillRow(row() As UInteger)
  Dim As UInteger m = UBound(row) 'Const
  Do
    clearRow(row())
    Dim As Integer curIndex = -1
    Dim As Integer curValue = -1
    For i As Integer = 0 To m
      Dim As Integer lastIndex = curIndex 'Const
      Dim As Integer lastValue = curValue 'Const
      If curValue = -1 Then
        curIndex = Int(Rnd*3)
        curValue = Int(Rnd*variations)
      ElseIf i <> m Then
        If Rnd < 0.8 Then
          curIndex = (lastIndex + Int(Rnd*m) + 1) Mod 3
          curValue = Int(Rnd*variations)
        EndIf
      EndIf 
      
      If lastValue <> -1 Then row(i, lastIndex) = lastValue
      row(i, curIndex) = curValue 
    Next i
  Loop While ((row(0, 0) = row(m, 0)) AndAlso (row(0, 0) <> -1)) _
      OrElse ((row(0, 1) = row(m, 1)) AndAlso (row(0, 1) <> -1)) _
      OrElse ((row(0, 2) = row(m, 2)) AndAlso (row(0, 2) <> -1))
      
  Dim As Integer rowCopy(0 To m, 0 To 2) 'Const
  For i As Integer = 0 To m
    rowCopy(i, 0) = row(i, 0)
    rowCopy(i, 1) = row(i, 1)
    rowCopy(i, 2) = row(i, 2)
  Next i
  Do
    For i As Integer = 0 To m
      For q As Integer = 0 To 2
        If row(i, q) = -1 Then
          Dim As Integer newValue = Int(Rnd*variations)
          If Rnd() < 0.5 Then
            If i = 0 Then
              While newValue = row(i + 1, q)
                newValue = Int(Rnd*variations)
              Wend
            ElseIf i = m Then
              While newValue = row(i - 1, q)
                newValue = Int(Rnd*variations)
              Wend              
            Else 
              While (newValue = row(i - 1, q)) OrElse (newValue = row(i + 1, q))
                newValue = Int(Rnd*variations)
              Wend      
            EndIf
          EndIf
          row(i, q) = newValue
        EndIf
      Next q 
    Next i
    If (row(0, 0) <> row(m, 0)) AndAlso (row(0, 1) <> row(m, 1)) AndAlso (row(0, 2) <> row(m, 2)) Then Exit Do
    For i As Integer = 0 To m
      row(i, 0) = rowCopy(i, 0)
      row(i, 1) = rowCopy(i, 1)
      row(i, 2) = rowCopy(i, 2)
    Next i    
  Loop
End Sub

Sub Arboretum.clearRow(row() As UInteger)
  For i As Integer = 0 To UBound(row)
    row(i, 0) = -1
    row(i, 1) = -1
    row(i, 2) = -1
  Next i
End Sub

Sub Arboretum.shuffle()
  For i As Integer = (ROW_1_N + ROW_2_N + ROW_3_N) - 1 To 1 Step -1
    Dim As UInteger Ptr elementA
    If i < ROW_1_N Then
      elementA = @(row1(i, 0))
    ElseIf i < (ROW_1_N + ROW_2_N) Then
      elementA = @(row2(i - ROW_1_N, 0))
    Else
      elementA = @(row3(i - ROW_1_N - ROW_2_N, 0))
    EndIf
    
    Dim As UInteger Ptr elementB
    Dim As UInteger q = Int(Rnd*i) 'Const
    If q < ROW_1_N Then
      elementB = @(row1(q, 0))
    ElseIf q < (ROW_1_N + ROW_2_N) Then
      elementB = @(row2(q - ROW_1_N, 0))
    Else
      elementB = @(row3(q - ROW_1_N - ROW_2_N, 0))
    EndIf
    
    Swap elementA[0], elementB[0]
    Swap elementA[1], elementB[1]
    Swap elementA[2], elementB[2]
  Next i
End Sub

Const Function Arboretum.checkSolution(row As UInteger) As Boolean
  DEBUG_ASSERT((row >= 0) AndAlso (row <= 2))
  Select Case As Const row
    Case 0
      Return checkRow(row1())
    Case 1
      Return checkRow(row2())
    Case 2
      Return checkRow(row3())
    Case Else
      DEBUG_ASSERT(FALSE)
  End Select
End Function

Const Function Arboretum.checkSolution() As Boolean
  Return checkSolution(0) AndAlso checkSolution(1) AndAlso checkSolution(2)
End Function
	
Sub Arboretum.collectPot(row As UInteger, index As UInteger, pot() As Integer)
  DEBUG_ASSERT((row >= 0) AndAlso (row <= 2))
  Select Case As Const row
    Case 0 
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row1)))
      pot(0) = row1(index, 0)
      pot(1) = row1(index, 1)
      pot(2) = row1(index, 2)
      row1(index, 0) = -1
      row1(index, 1) = -1
      row1(index, 2) = -1
    Case 1
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row2)))
      pot(0) = row2(index, 0)
      pot(1) = row2(index, 1)
      pot(2) = row2(index, 2)
      row2(index, 0) = -1
      row2(index, 1) = -1
      row2(index, 2) = -1
    Case 2
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row3)))
      pot(0) = row3(index, 0)
      pot(1) = row3(index, 1)
      pot(2) = row3(index, 2)
      row3(index, 0) = -1
      row3(index, 1) = -1
      row3(index, 2) = -1
    Case Else
      DEBUG_ASSERT(FALSE)
  End Select
End Sub

Sub Arboretum.setPot(row As UInteger, index As UInteger, pot() As Const Integer)
  DEBUG_ASSERT((row >= 0) AndAlso (row <= 2))
  Select Case As Const row
    Case 0 
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row1)))
      row1(index, 0) = pot(0)
      row1(index, 1) = pot(1)
      row1(index, 2) = pot(2)
    Case 1
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row2)))
      row2(index, 0) = pot(0)
      row2(index, 1) = pot(1)
      row2(index, 2) = pot(2)
    Case 2
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row3)))
      row3(index, 0) = pot(0)
      row3(index, 1) = pot(1)
      row3(index, 2) = pot(2)
    Case Else
      DEBUG_ASSERT(FALSE)
  End Select 
End Sub

Const Sub Arboretum.getPot(row As UInteger, index As UInteger, pot() As Integer) 
  DEBUG_ASSERT((row >= 0) AndAlso (row <= 2))
  Select Case As Const row
    Case 0 
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row1)))
      pot(0) = row1(index, 0)
      pot(1) = row1(index, 1)
      pot(2) = row1(index, 2)
    Case 1
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row2)))
      pot(0) = row2(index, 0)
      pot(1) = row2(index, 1)
      pot(2) = row2(index, 2)
    Case 2
      DEBUG_ASSERT((index >= 0) AndAlso (index <= UBound(row3)))
      pot(0) = row3(index, 0)
      pot(1) = row3(index, 1)
      pot(2) = row3(index, 2)
    Case Else
      DEBUG_ASSERT(FALSE)
  End Select
End Sub
	
Const Function Arboretum.getVariations() As UInteger
  Return variations
End Function

Function Arboretum.checkRow(row() As Const UInteger) As Boolean
  For i As Integer = 1 To UBound(row)
    If (row(i, 0) <> row(i - 1, 0)) AndAlso (row(i, 1) <> row(i - 1, 1)) AndAlso (row(i, 2) <> row(i - 1, 2)) Then
      Return FALSE
    EndIf
  Next i
  Return TRUE
End Function

End Namespace
