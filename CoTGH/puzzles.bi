#Ifndef PUZZLES_BI
#Define PUZZLES_BI

Namespace puzzle
	
Enum Difficulty Explicit
	UNKNOWN = 0
	EASY = 1
	MEDIUM = 2
	HARD = 3
	VERY_HARD = 4
End Enum

'A puzzle about modular arithmetic. Colors are from 0 - 15.
Type ColorWheel
 Public:
	Const As UInteger MAX_COLORS = 12
	
	Enum ColorOperator Explicit
		UNKNOWN = 0
		HEAT = 1
		COOL = 2
		INVERT = 3
	End Enum
	
	Declare Constructor(difficulty As Difficulty)
	
	Declare Const Function getInitialColor() As UInteger
	Declare Const Function getTargetColor() As UInteger
	
	Declare Const Function getOperatorsN() As UInteger

	Declare Function collectOperator(opIndex As UInteger) As ColorOperator	
	Declare Const Function getOperator(opIndex As UInteger) As ColorOperator 
	
	Declare Sub setOperator(opIndex As UInteger, op As ColorOperator)

	'Get the color before the given stage. Specifying stage = getOperatorsN() will provide the
	'final color after passing through each operator.	
	Declare Const Function getColor(stage As UInteger) As UInteger

 Private:
 	Const As UInteger MAX_OPERATORS = 6
 	
 	As UInteger operatorsN 'Const
 	As ColorOperator operators(0 To MAX_OPERATORS - 1)
 	
 	As UInteger initialColor 'Const
	As UInteger targetColor 'Const
End Type
	
Type Arboretum
 Public:
  Const As UInteger ROW_1_N = 3
  Const As UInteger ROW_2_N = 4
  Const As UInteger ROW_3_N = 5
  
	Declare Constructor(difficulty As Difficulty)
	
	Declare Const Function checkSolution(row As UInteger) As Boolean
	Declare Const Function checkSolution() As Boolean
	
	Declare Sub collectPot(row As UInteger, index As UInteger, pot() As Integer)
	Declare Sub setPot(row As UInteger, index As UInteger, pot() As Const Integer)
	Declare Const Sub getPot(row As UInteger, index As UInteger, pot() As Integer)
	
	Declare Const Function getVariations() As UInteger
	
 Private:
  Declare Static Function checkRow(row() As Const UInteger) As Boolean
  
  Declare Sub prepareSolution()
  Declare Sub fillRow(row() As UInteger)
  Declare Sub clearRow(row() As UInteger)
  Declare Sub shuffle()
 
  As UInteger variations 'Const
 
	As Integer row1(0 To ROW_1_N - 1, 0 To 2)
	As Integer row2(0 To ROW_2_N - 1, 0 To 2)
	As Integer row3(0 To ROW_3_N - 1, 0 To 2)
End Type
	
End Namespace

#EndIf
