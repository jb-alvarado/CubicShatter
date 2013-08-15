orgObj = selection[1]

-- process slices
fn process orgObj = (
	if (orgObj != undefined) then (
		
		-- copy original for processing, set pivot and reset all transformations
		obj = copy orgObj
		obj.pivot = obj.center
		obj.pivot.z = obj.min.z
		resetXForm obj
		convertToMesh obj
		objDim = obj.max - obj.min
		
		-- size of the quad pieces in scene units
		PlaneDistance = 20

		-- calculate how many cuts in every dimension
		planeCountX = (objDim.x / PlaneDistance) as integer
		planeCountY = (objDim.y / PlaneDistance) as integer
		planeCountZ = (objDim.z / PlaneDistance) as integer
		
		--check if count come to the "soft" limit
		sum = planeCountX * planeCountY * planeCountZ
		if ( sum > 4000) do (
			if queryBox ("Warning: You want to cut \"" + sum as string + "\" pieces. Are you sure that you want to continue?") then (
			
			) else (
				delete obj
				return false
				)
		) 	

		--set the cut plane matrixes
		planeSumX = for x = 1 to planeCountX - 1 collect (matrix3 [0,0,-1] [0,1,0] [1,0,0] [(objDim.x / planeCountX * x + obj.min.x - obj.pos.x), (obj.max.y + obj.min.y) / 2, (obj.max.z + obj.min.z) / 2])
		planeSumY = for y = 1 to planeCountY - 1 collect (matrix3 [1,0,0] [0,0,1] [0,-1,0] [(obj.max.x + obj.min.x) / 2, (objDim.y / planeCountY * y + obj.min.y - obj.pos.y), (obj.max.z + obj.min.z) / 2])
		planeSumZ = for z = 1 to planeCountZ - 1 collect (matrix3 [0,1,0] [-1,0,0] [0,0,1] [(obj.max.x + obj.min.x) / 2, (obj.max.y + obj.min.y) / 2, (objDim.z / planeCountZ * z + obj.min.z - obj.pos.z)])

		-- cut object in the x direction
		objArray1 = #()	
		for a = 1 to planeSumX.count do (
			ob1 = copy obj
			addModifier ob1 (sliceModifier name:"cutPlane1" slice_type:2)
			ob1.cutPlane1.slice_plane.transform = planeSumX[a]
			addModifier ob1 (sliceModifier name:"cutPlane2" slice_type:3)
			if (a-1 > 0) do (ob1.cutPlane2.slice_plane.transform = planeSumX[a-1])
			addModifier ob1 (cap_holes())
			convertToMesh ob1
			join objArray1 #(ob1)
			)
		addModifier obj (sliceModifier name:"cutPlane3" slice_type:3)
		obj.cutPlane3.slice_plane.transform = planeSumX[planeSumX.count]
		addModifier obj (cap_holes())
		convertToMesh obj
		join objArray1 #(obj)

		-- cut objects in y direction
		objArray2 = #()		
		for b = 1 to objArray1.count do (
			for c = 1 to planeSumY.count do (
				ob2 = copy objArray1[b]
				addModifier ob2 (sliceModifier name:"cutPlane1" slice_type:3)
				if (c+1 <= planeSumY.count) do (ob2.cutPlane1.slice_plane.transform = planeSumY[c+1])
				addModifier ob2 (sliceModifier name:"cutPlane2" slice_type:2)
				ob2.cutPlane2.slice_plane.transform = planeSumY[c]
				addModifier ob2 (cap_holes())
				convertToMesh ob2
				join objArray2 #(ob2)
				)
			addModifier objArray1[b] (sliceModifier name:"cutPlane3" slice_type:3)
			objArray1[b].cutPlane3.slice_plane.transform = planeSumY[1]
			addModifier objArray1[b] (cap_holes())
			convertToMesh objArray1[b]
			join objArray2 #(objArray1[b])
			)	

		-- cut objects in y direction
		--objArray3 = #()		
		for i = 1 to objArray2.count do (
			for j = 1 to planeSumZ.count do (
				ob3 = copy objArray2[i]
				addModifier ob3 (sliceModifier name:"cutPlane1" slice_type:2)
				ob3.cutPlane1.slice_plane.transform = planeSumZ[j]
				addModifier ob3 (sliceModifier name:"cutPlane2" slice_type:3)
				if (j-1 > 0) do (ob3.cutPlane2.slice_plane.transform = planeSumZ[j-1])
				addModifier ob3 (cap_holes())
				convertToMesh ob3
				ob3.pivot = ob3.center
				--join objArray3 #(ob3)
				)
				addModifier objArray2[i] (sliceModifier name:"cutPlane3" slice_type:3)
				objArray2[i].cutPlane3.slice_plane.transform = planeSumZ[planeSumZ.count]
				addModifier objArray2[i] (cap_holes())
				convertToMesh objArray2[i]
				objArray2[i].pivot = objArray2[i].center
				--join objArray3 #(objArray2[i])
			)

		-- clear variables and clean script cache
		objArray1 = #()
		objArray2 = #()
		--objArray3 = #()
		enableSceneRedraw()
		CompleteRedraw()
		gc()
		) else (
			messageBox "Please select one object first!"
			)
	) -- fn end

process orgObj