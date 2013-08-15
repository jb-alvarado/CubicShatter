/*
----------------------------------------------------------------------------------------------------------------------
::
::    Description: This MaxScript is for cutting objects in little cube pieces 
::
----------------------------------------------------------------------------------------------------------------------
:: LICENSE ----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
::
::    Copyright (C) 2013 Jonathan Baecker (jb_alvarado)
::
::    This program is free software: you can redistribute it and/or modify
::    it under the terms of the GNU General Public License as published by
::    the Free Software Foundation, either version 3 of the License, or
::    (at your option) any later version.
::
::    This program is distributed in the hope that it will be useful,
::    but WITHOUT ANY WARRANTY; without even the implied warranty of
::    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::    GNU General Public License for more details.
::
::    You should have received a copy of the GNU General Public License
::    along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
:: History --------------------------------------------------------------------------------------------------------
:: 2013-08-12 writing a simple script
:: 2013-08-15 writing the GUI and more functions
----------------------------------------------------------------------------------------------------------------------
::
::
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
--
-- Cubic Shatter v 0.5
-- Author: Jonathan Baecker (jb_alvarado) blog.pixelcrusher.de | www.pixelcrusher.de
-- Createt: 2013-08-15
--
----------------------------------------------------------------------------------------------------------------------
*/
( --start script
clearlistener()

try ( destroyDialog CubicShatter )
catch (	MessageBox "Dialog not found!" )	

rollout CubicShatter "Cubic Shatter" width:520 height:228 (
	
	--input
	fn geoFilter InputObj = (
		superClassOf InputObj == GeometryClass
		)
		
	groupBox grpInput "Object Input" pos:[10,10] width:250 height:60
		pickButton btnInput "Pick Object" pos:[20,30] width:140 height:30 filter:geoFilter
		checkbox chkCopy "Copy Original" pos:[170,30] width:82 height:16 checked:true
	
	groupBox grpInfo "Informations" pos:[270,10] width:240 height:60
		label lblCount "Pieces:" pos:[280,30] width:35 height:16
		label lblPiecesCount "0" pos:[320,30] width:54 height:16
		label lblPolys "Polys:" pos:[280,50] width:35 height:16
		label lblPolysCount "0" pos:[320,50] width:54 height:16
		label lblCutPlanes "Cut Planes Count:" pos:[380,30] width:92 height:16
		label lblPlaneCount "X: 0 | Y: 0 | Z: 0" pos:[380,50] width:120 height:16
	
	groupBox grpCubes "Cubes Settings" pos:[10,70] width:500 height:94
		spinner spnWidth "Cube Size X " pos:[68,90] width:75 height:16 range:[0.00,100000.00,10.00]
		spinner spnHeight "Cube Size Y " pos:[68,114] width:75 height:16 range:[0.00,100000.00,10.00]
		spinner spnDepth "Cube Size Z " pos:[68,138] width:75 height:16 range:[0.00,100000.00,10.00]
		spinner spnID " Cut Material ID " pos:[215,90] width:45 height:16 type:#integer
		checkbox chkUVXY "UV in XY" pos:[270,90] width:60 height:16
		checkbox chkUVYZ "UV in YZ" pos:[270,114] width:60 height:16
		checkbox chkUVZY "UV in ZY" pos:[270,138] width:60 height:16
		checkbox chkRWMS "Real-World Map Size" pos:[335,90] width:167 height:16
		checkbox chkTri "Triangulate Cap" pos:[335,114] width:102 height:16
		checkbox chkSquare "Square Cubes" pos:[335,138] width:167 height:16
		
	groupBox grpProgress "Progress" pos:[10,164] width:500 height:54
		progressBar pbProgressBar "" pos:[20,187] width:309 height:15 color:[0,200,0]
		button btnProgress "Start Cutting" pos:[340,180] width:160 height:30
	
	local orgObj
	local objDim
	local planeCountX = 2
	local planeCountY = 2
	local planeCountZ = 2
	local sum
	local tmpMesh = undefined
	local sendVariables = #()
	
	--button input
	on btnInput picked InputObj do (
		btnInput.text = InputObj.name
		orgObj = InputObj
		
		-- object dimensions
		objDim = orgObj.max - orgObj.min
		
		spnWidth.value = objDim.x / 2
		spnHeight.value = objDim.y / 2
		spnDepth.value = objDim.z / 2

		tmpMesh = snapshotAsMesh orgObj
		sum = 8
		
		lblPiecesCount.text = sum as string
		NumPolys = (tmpMesh.NumFaces * sum) as string
		lblPolysCount.text = "~ " + NumPolys

		-- plane count
		lblPlaneCount.text = "X: 1 | Y: 1 | Z: 1"
		)

	-- checkboxen change state
	on chkUVSource changed theState do (
		chkUVCube.checked = false
		)
		
	on chkUVCube changed theState do (
		chkUVSource.checked = false
		)	
		
	on chkToMesh changed theState do (
		if (chkToPoly.checked == false) then (chkToPoly.checked = true) else (chkToPoly.checked = false)
		)
		
	on chkToPoly changed theState do (
		if (chkToMesh.checked == false) then (chkToMesh.checked = true) else (chkToMesh.checked = false)
		)	
	
	on chkSquare changed theState do (
		if (chkSquare.checked == true) then (
			spnHeight.enabled = false
			spnDepth.enabled = false
			spnHeight.value = spnWidth.value
			spnDepth.value = spnWidth.value
			) else (
				spnHeight.enabled = true
				spnDepth.enabled = true
				)
	)
		
	-- spinner change value
	on spnWidth changed valX do (
		if (tmpMesh != undefined) do (
				
			-- calculate how many cuts in every dimension
			planeCountX = (objDim.x / valX) as integer
			
			if (chkSquare.checked == false) then (
				planeCountY = (objDim.y / spnHeight.value) as integer
				planeCountZ = (objDim.z / spnDepth.value) as integer
				) else (
					planeCountY = (objDim.y / valX) as integer
					planeCountZ = (objDim.z / valX) as integer
					)
			
			if (planeCountX > 0) then (
				--count the number of cubes
				sum = planeCountX * planeCountY * planeCountZ as integer
				lblPiecesCount.text = sum as string
				
				-- count the number of polygons
				NumPolys = (tmpMesh.NumFaces * sum) as string
				lblPolysCount.text = "~ " + NumPolys
				spnWidth.value = objDim.X / planeCountX
				
				if (chkSquare.checked == true) do (
					spnHeight.value = spnWidth.value
					spnDepth.value = spnWidth.value
					)
				
				-- plane count
				if (planeCountY >= 1) then (plnCY = (planeCountY-1) as string) else (plnCY = 0 as string)
				if (planeCountY >= 1) then (plnCZ = (planeCountZ-1) as string) else (plnCZ = 0 as string)
				lblPlaneCount.text = "X: " + (planeCountX-1) as string + " | Y: " + plnCY + " | Z: " + plnCZ
				) else (
					planeCountX = 1
					spnWidth.value = (objDim.X / 2)
					sum = planeCountX * planeCountY * planeCountZ as integer
					lblPiecesCount.text = sum as string

					NumPolys = (tmpMesh.NumFaces * sum) as string
					lblPolysCount.text = "~ " + NumPolys
					)
			)
		)
		
	on spnHeight changed valY do (
		if (tmpMesh != undefined) do (
				
			-- calculate how many cuts in every dimension
			planeCountX = (objDim.x / spnWidth.value) as integer
			planeCountY = (objDim.y / valY) as integer
			planeCountZ = (objDim.z / spnDepth.value) as integer
			
			if (planeCountY > 0) then (
				--count the number of cubes
				sum = planeCountX * planeCountY * planeCountZ as integer
				lblPiecesCount.text = sum as string
				
				-- count the number of polygons
				NumPolys = (tmpMesh.NumFaces * sum) as string
				lblPolysCount.text = "~ " + NumPolys
				spnHeight.value = objDim.y / planeCountY
				
				-- plane count
				lblPlaneCount.text = "X: " + (planeCountX-1) as string + " | Y: " + (planeCountY-1) as string + " | Z: " + (planeCountZ-1) as string
				) else (
					planeCountY = 1
					spnHeight.value = (objDim.y / 2)
					sum = planeCountX * planeCountY * planeCountZ as integer
					lblPiecesCount.text = sum as string

					NumPolys = (tmpMesh.NumFaces * sum) as string
					lblPolysCount.text = "~ " + NumPolys
					)
			)
		)
		
	on spnDepth changed valZ do (
		if (tmpMesh != undefined) do (
				
			-- calculate how many cuts in every dimension
			planeCountX = (objDim.x / spnWidth.value) as integer
			planeCountY = (objDim.y / spnHeight.value) as integer
			planeCountZ = (objDim.z / valZ) as integer
			
			if (planeCountZ > 0) then (
				--count the number of cubes
				sum = planeCountX * planeCountY * planeCountZ as integer
				lblPiecesCount.text = sum as string
				
				-- count the number of polygons
				NumPolys = (tmpMesh.NumFaces * sum) as string
				lblPolysCount.text = "~ " + NumPolys
				spnDepth.value = objDim.Z / planeCountZ
				
				-- plane count
				lblPlaneCount.text = "X: " + (planeCountX-1) as string + " | Y: " + (planeCountY-1) as string + " | Z: " + (planeCountZ-1) as string
				) else (
					planeCountZ = 1
					spnDepth.value = (objDim.Z / 2)
					sum = planeCountX * planeCountY * planeCountZ as integer
					lblPiecesCount.text = sum as string

					NumPolys = (tmpMesh.NumFaces * sum) as string
					lblPolysCount.text = "~ " + NumPolys
					)
			)
		)	
	
	-- button process cut cubes
	on btnProgress pressed do (
		if (orgObj != undefined) then (
			if ( sum > 4000) do (
				if queryBox ("Warning: You want to cut \"" + sum as string + "\" pieces. Are you sure that you want to continue?") title:"Cubic Shatter" then (
					return true
					) else (
						return false
						)
				)
					delete tmpMesh
					deselect orgObj
					pbProgressBar.value = 0
					if (chkCopy.checked == true) then obj = copy orgObj else obj = orgObj
					CenterPivot obj
					obj.pivot.z = obj.min.z
					resetXForm obj
					convertToMesh obj
					
					if (planeCountX > 1) then (
						planeSumX = for x = 1 to planeCountX - 1 collect (matrix3 [0,0,-1] [0,1,0] [1,0,0] [(objDim.x / planeCountX * x + obj.min.x - obj.pos.x), (obj.max.y + obj.min.y) / 2, (obj.max.z + obj.min.z) / 2])
						) else (planeSumX = undefined)
						
					if (planeCountY > 1) then (	
						planeSumY = for y = 1 to planeCountY - 1 collect (matrix3 [1,0,0] [0,0,1] [0,-1,0] [(obj.max.x + obj.min.x) / 2, (objDim.y / planeCountY * y + obj.min.y - obj.pos.y), (obj.max.z + obj.min.z) / 2])
						) else (planeSumY = undefined)
						
					if (planeCountZ > 1) then (	
						planeSumZ = for z = 1 to planeCountZ - 1 collect (matrix3 [0,1,0] [-1,0,0] [0,0,1] [(obj.max.x + obj.min.x) / 2, (obj.max.y + obj.min.y) / 2, (objDim.z / planeCountZ * z + obj.min.z - obj.pos.z)])
						) else (planeSumZ = undefined)
			
					-- cut object in the x direction
					if (planeSumX != undefined) do (
						objArray1 = #()	
						for a = 1 to planeSumX.count do (
							ob1 = copy obj
							addModifier ob1 (sliceModifier name:"cutPlane1" slice_type:2)
							ob1.cutPlane1.slice_plane.transform = planeSumX[a]
							addModifier ob1 (sliceModifier name:"cutPlane2" slice_type:3)
							if (a-1 > 0) do (ob1.cutPlane2.slice_plane.transform = planeSumX[a-1])
							addModifier ob1 (cap_holes())
							
							if (chkTri.checked == true) do (
								ob1.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
								)
								
							if (planeSumY == undefined AND planeSumZ == undefined) then (
								CenterPivot ob1
								resetXForm ob1
								convertToMesh ob1
								) else (
									convertToMesh ob1
									)
							join objArray1 #(ob1)
							pbProgressBar.value = 100.000 / sum * a	
							)
						addModifier obj (sliceModifier name:"cutPlane3" slice_type:3)
						obj.cutPlane3.slice_plane.transform = planeSumX[planeSumX.count]
						addModifier obj (cap_holes())
						
						if (chkTri.checked == true) do (
								obj.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
								)
								
						if (planeSumY == undefined) then (
							CenterPivot obj
							resetXForm obj
							convertToMesh
							) else (
								convertToMesh
								)
						join objArray1 #(obj)

						pbProgressBar.value = 100.000 / sum * (planeSumX.count + 1)	
					)
					
					-- cut objects in y direction
					if (planeSumY != undefined) do (
						objArray2 = #()
						if (objArray1 != undefined) then (
							for b = 1 to objArray1.count do (
								for c = 1 to planeSumY.count do (
									ob2 = copy objArray1[b]
									addModifier ob2 (sliceModifier name:"cutPlane1" slice_type:3)
									if (c+1 <= planeSumY.count) do (ob2.cutPlane1.slice_plane.transform = planeSumY[c+1])
									addModifier ob2 (sliceModifier name:"cutPlane2" slice_type:2)
									ob2.cutPlane2.slice_plane.transform = planeSumY[c]
									addModifier ob2 (cap_holes())
									
									if (chkTri.checked == true) do (
										ob2.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
										)
									convertToMesh ob2
									join objArray2 #(ob2)
									pbProgressBar.value = 100.000 / sum * (planeSumX.count + b)	
									)
								addModifier objArray1[b] (sliceModifier name:"cutPlane3" slice_type:3)
								objArray1[b].cutPlane3.slice_plane.transform = planeSumY[1]
								addModifier objArray1[b] (cap_holes())
									
								if (chkTri.checked == true) do (
									objArray1[b].modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
									)	
								
								if (planeSumZ == undefined) then (
										CenterPivot objArray1[b]
										resetXForm objArray1[b]
										convertToMesh objArray1[b]
										) else (
											convertToMesh objArray1[b]
											)
								join objArray2 #(objArray1[b])
								pbProgressBar.value = 100.000 / sum * (planeSumX.count + planeSumY.count + 1)
								)	
							) else (
								for c = 1 to planeSumY.count do (
									ob2 = copy obj
									addModifier ob2 (sliceModifier name:"cutPlane1" slice_type:3)
									if (c+1 <= planeSumY.count) do (ob2.cutPlane1.slice_plane.transform = planeSumY[c+1])
									addModifier ob2 (sliceModifier name:"cutPlane2" slice_type:2)
									ob2.cutPlane2.slice_plane.transform = planeSumY[c]
									addModifier ob2 (cap_holes())
										
									if (chkTri.checked == true) do (
										ob2.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
										)	
									
									if (planeSumZ == undefined) then (
										CenterPivot ob2
										resetXForm ob2
										convertToMesh ob2
										) else (
											convertToMesh ob2
											)
									join objArray2 #(ob2)
									pbProgressBar.value = 100.000 / sum * c
									)
								addModifier obj (sliceModifier name:"cutPlane3" slice_type:3)
								obj.cutPlane3.slice_plane.transform = planeSumY[1]
								addModifier obj (cap_holes())
									
								if (chkTri.checked == true) do (
									obj.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
									)	

								if (planeSumZ == undefined) then (
									CenterPivot obj
									resetXForm obj
									convertToMesh obj
									) else (
										convertToMesh obj
										)
								join objArray2 #(obj)
								pbProgressBar.value = 100.000 / sum * (planeSumY.count + 1)
								)		
						)

					-- cut objects in y direction
					if (planeSumZ != undefined) do (
						objArray3 = #()
						if (objArray2 != undefined) then (
							for i = 1 to objArray2.count do (
								for j = 1 to planeSumZ.count do (
									ob3 = copy objArray2[i]
									addModifier ob3 (sliceModifier name:"cutPlane1" slice_type:2)
									ob3.cutPlane1.slice_plane.transform = planeSumZ[j]
									addModifier ob3 (sliceModifier name:"cutPlane2" slice_type:3)
									if (j-1 > 0) do (ob3.cutPlane2.slice_plane.transform = planeSumZ[j-1])
									addModifier ob3 (cap_holes())
										
									if (chkTri.checked == true) do (
										ob3.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
										)
								
									CenterPivot ob3
									resetXForm ob3
									convertToMesh ob3
									join objArray3 #(ob3)
									pbProgressBar.value = 100.000 / sum * (planeSumX.count + planeSumY.count + j)
									)
									addModifier objArray2[i] (sliceModifier name:"cutPlane3" slice_type:3)
									objArray2[i].cutPlane3.slice_plane.transform = planeSumZ[planeSumZ.count]
									addModifier objArray2[i] (cap_holes())
										
									if (chkTri.checked == true) do (
										objArray2[i].modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
										)	
										
									CenterPivot objArray2[i]
									resetXForm objArray2[i]
									convertToMesh objArray2[i]
									join objArray3 #(objArray2[i])
									pbProgressBar.value = 100.000 / sum * (planeSumX.count + planeSumY.count + planeSumZ.count + i)
								)
							) else if (objArray1 != undefined) then (
								for i = 1 to objArray1.count do (
									for j = 1 to planeSumZ.count do (
										ob3 = copy objArray1[i]
										addModifier ob3 (sliceModifier name:"cutPlane1" slice_type:2)
										ob3.cutPlane1.slice_plane.transform = planeSumZ[j]
										addModifier ob3 (sliceModifier name:"cutPlane2" slice_type:3)
										if (j-1 > 0) do (ob3.cutPlane2.slice_plane.transform = planeSumZ[j-1])
										addModifier ob3 (cap_holes())
											
										if (chkTri.checked == true) do (
											ob3.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
											)
											
										CenterPivot ob3
										resetXForm ob3
										convertToMesh ob3
										join objArray3 #(ob3)
										pbProgressBar.value = 100.000 / sum * (planeSumX.count + j)
										)
										addModifier objArray1[i] (sliceModifier name:"cutPlane3" slice_type:3)
										objArray1[i].cutPlane3.slice_plane.transform = planeSumZ[planeSumZ.count]
										addModifier objArray1[i] (cap_holes())
											
										if (chkTri.checked == true) do (
											objArray1[i].modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
											)
								
										CenterPivot objArray1[i]
										resetXForm objArray1[i]
										convertToMesh objArray1[i]
										join objArray3 #(objArray1[i])
										pbProgressBar.value = 100.000 / sum * (planeSumX.count + planeSumZ.count + i)
									)
								) else (
									for j = 1 to planeSumZ.count do (
										ob3 = copy obj
										addModifier ob3 (sliceModifier name:"cutPlane1" slice_type:2)
										ob3.cutPlane1.slice_plane.transform = planeSumZ[j]
										addModifier ob3 (sliceModifier name:"cutPlane2" slice_type:3)
										if (j-1 > 0) do (ob3.cutPlane2.slice_plane.transform = planeSumZ[j-1])
										addModifier ob3 (cap_holes())
											
										if (chkTri.checked == true) do (
											ob3.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
											)
								
										CenterPivot ob3
										resetXForm ob3
										convertToMesh ob3
										join objArray3 #(ob3)
										pbProgressBar.value = 100.000 / sum * j
										)
										addModifier obj (sliceModifier name:"cutPlane3" slice_type:3)
										obj.cutPlane3.slice_plane.transform = planeSumZ[planeSumZ.count]
										addModifier obj (cap_holes())
											
										if (chkTri.checked == true) do (
											obj.modifiers[#Cap_Holes].Make_All_New_Edges_Visible = 1
											)
										CenterPivot obj
										resetXForm obj
										convertToMesh obj
										join objArray3 #(obj)
										pbProgressBar.value = 100.000 / sum * (planeSumZ.count + 1)
									)
						if (spnID.value > 0) do (
							for obZ in objArray3 do (
								for f in getFaceSelection obZ do setFaceMatID obZ f spnID.value
								setFaceSelection obZ -(getFaceSelection obZ)
								if (spnID.value > 1) then (
									for g in getFaceSelection obZ do setFaceMatID obZ g 1
									) else (for g in getFaceSelection obZ do setFaceMatID obZ g 2)
								setFaceSelection obZ #{}
								)
							)			
						)
					pbProgressBar.value = 100
					
					-- clear variables and clean script cache
					objArray1 = undefined
					objArray2 = undefined
					objArray3 = undefined
					enableSceneRedraw()
					CompleteRedraw()
					gc()	
			) else (
				messageBox "Please pick one object first!" title:"Cubic Shatter"
				)
	)
	
	
	) -- rollout end
createDialog CubicShatter style:#(#style_toolwindow, #style_border, #style_sysmenu)
) --end script