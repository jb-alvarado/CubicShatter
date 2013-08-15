rollout CubicShatter "Cubic Shatter" width:520 height:268
(
	button btnInput "Pick Object" pos:[20,30] width:140 height:30
	groupBox grpInput "Ground Settings" pos:[10,10] width:250 height:60
	checkbox chkCopy "Copy Original" pos:[170,30] width:82 height:16 checked:true
	spinner spnWidth "Cube Size X" pos:[30,90] width:110 height:16 range:????
	spinner spnHeight "Cube Size Y" pos:[30,114] width:110 height:16 range:????
	spinner spnDepth "Cube Size Z" pos:[30,138] width:110 height:16 range:????
	groupBox grpCubes "Cubes Settings" pos:[10,70] width:500 height:94
	spinner spnIDXY "Material ID: XY " pos:[160,90] width:100 height:16 range:???? type:#integer
	spinner spnIDYZ "Material ID: YZ " pos:[160,114] width:100 height:16 range:???? type:#integer
	spinner spnIDZY "Material ID: ZY " pos:[160,138] width:100 height:16 range:???? type:#integer
	checkbox chkUVXY "UV in XY" pos:[270,90] width:60 height:16
	checkbox chkUVYZ "UV in YZ" pos:[270,114] width:60 height:16
	checkbox chkUVZY "UV in ZY" pos:[270,138] width:60 height:16
	groupBox grpInfo "Informations" pos:[270,10] width:240 height:60
	label lblCount "Pieces:" pos:[280,30] width:35 height:16
	label lblPiecesCount "0" pos:[320,30] width:54 height:16
	label lblPolys "Polys:" pos:[280,50] width:35 height:16
	label lblPolysCount "0" pos:[320,50] width:54 height:16
	groupBox grpMesh "Mesh Settings" pos:[10,164] width:500 height:40
	checkbox chkTri "Triangulate Cap" pos:[270,182] width:102 height:16
	groupBox grpProgress "Progress" pos:[10,204] width:500 height:54
	progressBar pbProgressBar "" pos:[20,227] width:309 height:15 color:(color 30 10 190)
	button btnProgress "Start Cutting" pos:[340,220] width:160 height:30
	checkbox chkUVSource "UV Size From Source Dimension" pos:[335,90] width:167 height:16
	checkbox chkUVCube "UV Size From Cube Dimension" pos:[335,114] width:167 height:16
	checkbox chkToMesh "Convert To Edit Mesh" pos:[20,182] width:124 height:16
	checkbox chkToPoly "Convert To Edit Poly" pos:[149,182] width:117 height:16
	label lblCutPlanes "Cut Planes Count:" pos:[380,30] width:92 height:16
	label lblPlaneCount "X: 0 | Y: 0 | Z: 0" pos:[380,50] width:120 height:16
	checkbox chkSquare "Square Cubes" pos:[335,138] width:167 height:16
)