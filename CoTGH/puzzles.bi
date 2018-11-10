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
	
Type ColorWheel
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

	Declare Const Function getOperator(opIndex As UInteger) As ColorOperator	
	Declare Sub setOperator(opIndex As UInteger, op As ColorOperator)
	
	Declare Const Function getColor(stage As UInteger) As UInteger

 Private:
 	Const As UInteger MAX_OPERATORS = 6
 	
 	As UInteger operatorsN 'Const
 	As ColorOperator operators(0 To MAX_OPERATORS - 1)
 	
 	As UInteger initialColor 'Const
	As UInteger targetColor 'Const
End Type
	
	
	
End Namespace

#EndIf
