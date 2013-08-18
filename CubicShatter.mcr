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
:: 2013-08-18 add features and improve code
----------------------------------------------------------------------------------------------------------------------
::
::
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
--
-- Cubic Shatter v 0.85
-- Author: Jonathan Baecker (jb_alvarado) blog.pixelcrusher.de | www.pixelcrusher.de
-- Createt: 2013-08-15
--
----------------------------------------------------------------------------------------------------------------------
*/
macroScript CubicShatter
 category:"jb_scripts"
 ButtonText:"CubicShatter"
 Tooltip:"Cubic Shatter"
( --start script
global CubicShatter
try (destroyDialog CubicShatter) catch ()
rollout CubicShatter "Cubic Shatter" width:520 height:248 (
	
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
		label lblCutPlanes "Cube Number In Axis:" pos:[380,30] width:110 height:16
		label lblPlaneCount "X: 0 | Y: 0 | Z: 0" pos:[380,50] width:120 height:16
	
	groupBox grpCubes "Cubes Settings" pos:[10,70] width:500 height:94
		spinner spnWidth "Cube Size X " pos:[68,90] width:75 height:16 range:[0.00,100000.00,10.00] type:#worldunits
		spinner spnHeight "Cube Size Y " pos:[68,114] width:75 height:16 range:[0.00,100000.00,10.00] type:#worldunits
		spinner spnDepth "Cube Size Z " pos:[68,138] width:75 height:16 range:[0.00,100000.00,10.00] type:#worldunits
		checkbox chkSquare "Square Cubes" pos:[152,90] width:100 height:16
		spinner spnMatID "Material ID " pos:[215,114] width:45 height:16 type:#integer
		spinner spnMapID "Map Channel " pos:[215,138] width:45 height:16 range:[1,10,2] type:#integer
		checkbox chkMap "Generate Mapping Coords." pos:[270,90] width:170 height:16
		checkbox chkRWMS "Real-World Map Size" pos:[270,114] width:167 height:16
		checkbox chkTri "Triangulate Cap" pos:[270,138] width:102 height:16
		
	groupBox grpProgress "Progress" pos:[10,164] width:500 height:74
		progressBar pbProgressBar "" pos:[20,187] width:309 height:15 color:[0,200,0]
		button btnProgress "Start Cutting" pos:[340,187] width:160 height:40
		label lblProgress "" pos:[20,210] width:250 height:16
	
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
		lblPlaneCount.text = "X: 2 | Y: 2 | Z: 2"
		)
		
	fn countPieces valX valY valZ objDim = (
		if (tmpMesh != undefined) do (
				
			-- calculate how many cuts in every dimension			
			if (chkSquare.checked == false) then (
				planeCountX = (objDim.x / valX) as integer
				planeCountY = (objDim.y / valY) as integer
				planeCountZ = (objDim.z / valZ) as integer
				) else (
					planeCountX = (objDim.x / valX) as integer
					planeCountY = (objDim.y / valX) as integer
					planeCountZ = (objDim.z / valX) as integer
					)

				if (planeCountX == 0 ) do planeCountX = 1
				if (planeCountY == 0 ) do planeCountY = 1
				if (planeCountZ == 0 ) do planeCountZ = 1
				--count the number of cubes
				sum = planeCountX * planeCountY * planeCountZ as integer
				lblPiecesCount.text = sum as string
				
				-- count the number of polygons
				if (chkTri.checked == true) then (
						NumPolys = (tmpMesh.NumFaces * sum * 2) as string
						) else (
							NumPolys = (tmpMesh.NumFaces * sum) as string
							)
				lblPolysCount.text = "~ " + NumPolys
				
				if (chkSquare.checked == true) do (
					spnHeight.value = spnWidth.value
					spnDepth.value = spnWidth.value
					)
				
				-- plane count
				spnWidth.value = objDim.x / planeCountX
				plnCX = (planeCountX) as string

				spnHeight.value = objDim.Y / planeCountY
				plnCY = (planeCountY) as string

				spnDepth.value = objDim.Z / planeCountZ
				plnCZ = (planeCountZ) as string

				lblPlaneCount.text = "X: " + plnCX as string + " | Y: " + plnCY + " | Z: " + plnCZ
			)
		)	

	-- checkboxen change state	
	on chkSquare changed theState do (
		if (chkSquare.checked == true) then (
			spnHeight.enabled = false
			spnDepth.enabled = false
			spnHeight.value = spnWidth.value
			spnDepth.value = spnWidth.value
			valX = spnWidth.value
			valY = spnWidth.value
			valZ = spnWidth.value
			countPieces valX valY valZ objDim
			) else (
				spnHeight.enabled = true
				spnDepth.enabled = true
				valX = spnWidth.value
				valY = spnHeight.value
				valZ = spnDepth.value
				countPieces valX valY valZ objDim
				)
	)
	
	on chkTri changed theState do (
		valX = spnWidth.value
		valY = spnHeight.value
		valZ = spnDepth.value
		countPieces valX valY valZ objDim
		)
		
	-- spinner change value
	on spnWidth changed valX do (
		valY = spnHeight.value
		valZ = spnDepth.value
		countPieces valX valY valZ objDim
		)
		
	on spnHeight changed valY do (
		valX = spnWidth.value
		valZ = spnDepth.value
		countPieces valX valY valZ objDim
		)
		
	on spnDepth changed valZ do (
		valX = spnWidth.value
		valY = spnHeight.value
		countPieces valX valY valZ objDim
		)	
	
	-- button process cut cubes
	on btnProgress pressed do (
		if (orgObj != undefined) then (
			if ( sum > 4000) do (
				if queryBox ("Warning: You want to cut \"" + sum as string + "\" pieces. Are you sure that you want to continue?") title:"Cubic Shatter" then (
					) else (
						return false
						)
				)
					startPr = timeStamp()
				
					disableSceneRedraw()
					clearSelection()
					pbProgressBar.value = 0
					if (chkCopy.checked == true) then obj = copy orgObj else obj = orgObj
					CenterPivot obj
					obj.pivot.z = obj.min.z
					resetXForm obj
					convertToMesh obj
				
					if (chkTri.checked == true) then (tris = 1) else (tris = 0)
					
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
						lblProgress.text = "Cutting Cubes in X Axis ..."
						objArray1 = #()	
						for a = 1 to planeSumX.count do (
							ob1 = copy obj
							addModifier ob1 (sliceModifier name:"cutPlane1" slice_type:2)
							ob1.cutPlane1.slice_plane.transform = planeSumX[a]
							addModifier ob1 (sliceModifier name:"cutPlane2" slice_type:3)
							if (a-1 > 0) do (ob1.cutPlane2.slice_plane.transform = planeSumX[a-1])
							addModifier ob1 (cap_holes Make_All_New_Edges_Visible:tris)

							if (planeSumY == undefined AND planeSumZ == undefined) then (
								CenterPivot ob1
								resetXForm ob1
								convertToMesh ob1
								) else (
									convertToMesh ob1
									)
							join objArray1 #(ob1)
							pbProgressBar.value = 100.000 / planeSumX.count * a
							)
						addModifier obj (sliceModifier name:"cutPlane3" slice_type:3)
						obj.cutPlane3.slice_plane.transform = planeSumX[planeSumX.count]
						addModifier obj (cap_holes Make_All_New_Edges_Visible:tris)

						if (planeSumY == undefined) then (
							CenterPivot obj
							resetXForm obj
							convertToMesh
							) else (
								convertToMesh
								)
						join objArray1 #(obj)
					)
					
					-- cut objects in y direction
					if (planeSumY != undefined) do (
						lblProgress.text = "Cutting Cubes in Y Axis ..."
						objArray2 = #()
						if (objArray1 != undefined) then (
							for b = 1 to objArray1.count do (
								for c = 1 to planeSumY.count do (
									ob2 = copy objArray1[b]
									addModifier ob2 (sliceModifier name:"cutPlane1" slice_type:3)
									if (c+1 <= planeSumY.count) do (ob2.cutPlane1.slice_plane.transform = planeSumY[c+1])
									addModifier ob2 (sliceModifier name:"cutPlane2" slice_type:2)
									ob2.cutPlane2.slice_plane.transform = planeSumY[c]
									addModifier ob2 (cap_holes Make_All_New_Edges_Visible:tris)

									convertToMesh ob2
									join objArray2 #(ob2)
									)
								addModifier objArray1[b] (sliceModifier name:"cutPlane3" slice_type:3)
								objArray1[b].cutPlane3.slice_plane.transform = planeSumY[1]
								addModifier objArray1[b] (cap_holes Make_All_New_Edges_Visible:tris)

								if (planeSumZ == undefined) then (
										CenterPivot objArray1[b]
										resetXForm objArray1[b]
										convertToMesh objArray1[b]
										) else (
											convertToMesh objArray1[b]
											)
								join objArray2 #(objArray1[b])
								pbProgressBar.value = 100.000 / objArray1.count * b
								windows.processPostedMessages()
								)	
							) else (
								for c = 1 to planeSumY.count do (
									ob2 = copy obj
									addModifier ob2 (sliceModifier name:"cutPlane1" slice_type:3)
									if (c+1 <= planeSumY.count) do (ob2.cutPlane1.slice_plane.transform = planeSumY[c+1])
									addModifier ob2 (sliceModifier name:"cutPlane2" slice_type:2)
									ob2.cutPlane2.slice_plane.transform = planeSumY[c]
									addModifier ob2 (cap_holes Make_All_New_Edges_Visible:tris)

									if (planeSumZ == undefined) then (
										CenterPivot ob2
										resetXForm ob2
										convertToMesh ob2
										) else (
											convertToMesh ob2
											)
									join objArray2 #(ob2)
									pbProgressBar.value = 100.000 / planeSumY.count * c
									)
								addModifier obj (sliceModifier name:"cutPlane3" slice_type:3)
								obj.cutPlane3.slice_plane.transform = planeSumY[1]
								addModifier obj (cap_holes Make_All_New_Edges_Visible:tris)

								if (planeSumZ == undefined) then (
									CenterPivot obj
									resetXForm obj
									convertToMesh obj
									) else (
										convertToMesh obj
										)
								join objArray2 #(obj)
								)		
						)

					-- cut objects in z direction
					if (planeSumZ != undefined) do (
						lblProgress.text = "Cutting Cubes in Z Axis ..."
						objArray3 = #()
						if (objArray2 != undefined) then (
							for i = 1 to objArray2.count do (
								for j = 1 to planeSumZ.count do (
									ob3 = copy objArray2[i]
									addModifier ob3 (sliceModifier name:"cutPlane1" slice_type:2)
									ob3.cutPlane1.slice_plane.transform = planeSumZ[j]
									addModifier ob3 (sliceModifier name:"cutPlane2" slice_type:3)
									if (j-1 > 0) do (ob3.cutPlane2.slice_plane.transform = planeSumZ[j-1])
									addModifier ob3 (cap_holes Make_All_New_Edges_Visible:tris)

									CenterPivot ob3
									resetXForm ob3
									convertToMesh ob3
									join objArray3 #(ob3)
									)
									addModifier objArray2[i] (sliceModifier name:"cutPlane3" slice_type:3)
									objArray2[i].cutPlane3.slice_plane.transform = planeSumZ[planeSumZ.count]
									addModifier objArray2[i] (cap_holes Make_All_New_Edges_Visible:tris)

									CenterPivot objArray2[i]
									resetXForm objArray2[i]
									convertToMesh objArray2[i]
									join objArray3 #(objArray2[i])
									pbProgressBar.value = 100.000 / objArray2.count * i
									windows.processPostedMessages()
								)
							) else if (objArray1 != undefined) then (
								for i = 1 to objArray1.count do (
									for j = 1 to planeSumZ.count do (
										ob3 = copy objArray1[i]
										addModifier ob3 (sliceModifier name:"cutPlane1" slice_type:2)
										ob3.cutPlane1.slice_plane.transform = planeSumZ[j]
										addModifier ob3 (sliceModifier name:"cutPlane2" slice_type:3)
										if (j-1 > 0) do (ob3.cutPlane2.slice_plane.transform = planeSumZ[j-1])
										addModifier ob3 (cap_holes Make_All_New_Edges_Visible:tris)

										CenterPivot ob3
										resetXForm ob3
										convertToMesh ob3
										join objArray3 #(ob3)
										)
										addModifier objArray1[i] (sliceModifier name:"cutPlane3" slice_type:3)
										objArray1[i].cutPlane3.slice_plane.transform = planeSumZ[planeSumZ.count]
										addModifier objArray1[i] (cap_holes Make_All_New_Edges_Visible:tris)

										CenterPivot objArray1[i]
										resetXForm objArray1[i]
										convertToMesh objArray1[i]
										join objArray3 #(objArray1[i])
										pbProgressBar.value = 100.000 / objArray1.count * i
										windows.processPostedMessages()
									)
								) else (
									for j = 1 to planeSumZ.count do (
										ob3 = copy obj
										addModifier ob3 (sliceModifier name:"cutPlane1" slice_type:2)
										ob3.cutPlane1.slice_plane.transform = planeSumZ[j]
										addModifier ob3 (sliceModifier name:"cutPlane2" slice_type:3)
										if (j-1 > 0) do (ob3.cutPlane2.slice_plane.transform = planeSumZ[j-1])
										addModifier ob3 (cap_holes Make_All_New_Edges_Visible:tris)

										CenterPivot ob3
										resetXForm ob3
										convertToMesh ob3
										join objArray3 #(ob3)
										pbProgressBar.value = 100.000 / planeSumZ.count * j
										)
										addModifier obj (sliceModifier name:"cutPlane3" slice_type:3)
										obj.cutPlane3.slice_plane.transform = planeSumZ[planeSumZ.count]
										addModifier obj (cap_holes Make_All_New_Edges_Visible:tris)

										CenterPivot obj
										resetXForm obj
										convertToMesh obj
										join objArray3 #(obj)
										windows.processPostedMessages()
									)
						)
						
					-- process Material IDs
					startID = timeStamp()

					if (spnMatID.value > 0) do (
							lblProgress.text = "Process Material IDs ..."
							for k = 1 to objArray3.count do (
								for f in getFaceSelection objArray3[k] do setFaceMatID objArray3[k] f spnMatID.value
								setFaceSelection objArray3[k] -(getFaceSelection objArray3[k])
								if (spnMatID.value > 1) then (
									for g in getFaceSelection objArray3[k] do setFaceMatID objArray3[k] g 1
									) else (for g in getFaceSelection objArray3[k] do setFaceMatID objArray3[k] g 2)
								setFaceSelection objArray3[k] #{}
								pbProgressBar.value = 100.000 / objArray3.count * k
								stampID = timeStamp()
								if (((stampID - startID) / 1000.0) >= 5.00) do (
									startID = timeStamp()
									windows.processPostedMessages()
									)	
								)
							windows.processPostedMessages()	
							)
							
						-- process UVs
						startUV = timeStamp()

						if (chkMap.checked == true) do (
							lblProgress.text = "Generate Mapping Coords. ..."
							for l = 1 to objArray3.count do (
								addModifier objArray3[l] (uvwMap maptype:4 length:objDim.y width:objDim.z height:objDim.x realWorldMapSize:chkRWMS.checked mapChannel:spnMapID.value)								
								convertToMesh objArray3[l]
								pbProgressBar.value = 100.000 / objArray3.count * l
								stampUV = timeStamp()
								if (((stampUV - startUV) / 1000.0) >= 5.00) do (
									startUV = timeStamp()
									windows.processPostedMessages()
									)
								)
							)
					pbProgressBar.value = 100
					
					endPr = timeStamp()
							
					lblProgress.text = "Done, in " + (((endPr - startPr) / 1000.0) as Integer) as string + " seconds! ..."
					
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
	
	on CubicShatter close do try (delete tmpMesh) catch ()
	) -- rollout end
createDialog CubicShatter style:#(#style_toolwindow, #style_border, #style_sysmenu)

) --end script