'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'uiGridConstants', 'uiGridEditConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $rootScope, $state, $interval, uiGridConstants, uiGridEditConstants, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()

	$scope.$parent.bigLoader 	= true
	$scope.dato 				= {} # Seguro puedo eliminarlo
	$scope.dato.mostrartoolgrupo = true
	$scope.gridScope 			= $scope # Para getExternalScopes de ui-Grid
	$scope.perfilPath 			= App.images+'perfil/'
	$scope.year_ant 			= $scope.USER.year - 1
	$scope.gridOptions 			= {}
	$scope.paises 				= []
	$scope.religiones			= ['Adventista', 'Católico', 'Pentecostal', 'Cuadrangular', 'Testigo de Jehová', 'Mormón', 'Otra', 'Ninguna']
	$scope.tipos_sangre 		= ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-']

	$scope.parentescos 			= [
		{ parentesco: 	'Padre' }
		{ parentesco: 	'Madre' }
		{ parentesco: 	'Hermano(a)' }
		{ parentesco: 	'Tío(a)' }
		{ parentesco: 	'Primo(a)' }
		{ parentesco: 	'Responsable' }
	]



	$scope.dato.grupo = ''
	$http.get('::grupos/con-paises-tipos').then((r)->
		matr_grupo = 0

		if localStorage.matr_grupo 
			matr_grupo = parseInt(localStorage.matr_grupo)

		$scope.grupos 		= r.data.grupos
		$scope.paises 		= r.data.paises
		$scope.tipos_doc 	= r.data.tipos_doc

		for grupo in $scope.grupos
			if parseInt(grupo.id) == parseInt(matr_grupo)
				$scope.dato.grupo = grupo
				$scope.selectGrupo($scope.dato.grupo)

		$scope.$parent.bigLoader 	= false
	)


	$scope.selectGrupo = (grupo)->
		localStorage.matr_grupo = grupo.id
		$scope.dato.grupo 		= grupo

		for grup in $scope.grupos
			grup.active = false

		grupo.active = true

		# Traer alumnos
		grupos_ant = []

		for grup in $scope.grupos
			if grup.orden_grado == (grupo.orden_grado - 1)
				grupos_ant.push grup


		# Quería mandar los grupos anteriores, pero solo voy a mandar el grado_id
		if grupos_ant.length > 0
			grado_ant_id 	= grupos_ant[0].grado_id
		else 
			grado_ant_id 	= null

		$http.put("::matriculas/alumnos-con-grado-anterior", {grupo_actual: grupo, grado_ant_id: grado_ant_id, year_ant: $scope.year_ant}).then((r)->
			$scope.gridOptions.data 	= r.data.AlumnosActuales
			$scope.AlumnosDesertRetir 	= r.data.AlumnosDesertRetir
			$scope.AlumnosSinMatricula 	= r.data.AlumnosSinMatricula

			for alumno in $scope.gridOptions.data
				#console.log alumno.fecha_retiro, new Date(alumno.fecha_retiro.replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3"))
				alumno.estado_ant 			= alumno.estado
				alumno.fecha_retiro_ant 	= alumno.fecha_retiro
				alumno.fecha_retiro 		= new Date(alumno.fecha_retiro)
				alumno.fecha_matricula_ant 	= alumno.fecha_matricula
				alumno.fecha_matricula 		= new Date(alumno.fecha_matricula)
				alumno.fecha_nac 			= new Date(alumno.fecha_nac)

				for tipo_doc in $scope.tipos_doc
					if tipo_doc.id == alumno.tipo_doc
						alumno.tipo_doc = tipo_doc

				for pariente in alumno.subGridOptions.data
					pariente.fecha_nac_ant 	= pariente.fecha_nac
					pariente.fecha_nac 		= new Date(pariente.fecha_nac)


				alumno.subGridOptions.onRegisterApi = ( gridApi ) ->
					gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
						if newValue != oldValue
							if colDef.field == "sexo"
								newValue = newValue.toUpperCase()
								if !(newValue == 'M' or newValue == 'F')
									toastr.warning 'Debe usar M o F'
									rowEntity.sexo = oldValue
									return

							if colDef.field == 'email'
								re = /\S+@\S+\.\S+/
								if !re.test(newValue)
									toastr.warning 'Email no válido'
									rowEntity.email = oldValue
									return

							$http.put('::acudientes/guardar-valor', {parentesco_id: rowEntity.parentesco_id, acudiente_id: rowEntity.id, user_id: rowEntity.user_id, propiedad: colDef.field, valor: newValue } ).then((r)->
								toastr.success 'Acudiente actualizado con éxito'
							, (r2)->
								rowEntity[colDef.field] = oldValue
								toastr.error 'Cambio no guardado', 'Error'
							)
						$scope.$apply()
					)


			for alumno in $scope.AlumnosDesertRetir
				#console.log alumno.fecha_retiro, new Date(alumno.fecha_retiro.replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3"))
				alumno.estado_ant 			= alumno.estado
				alumno.fecha_retiro_ant 	= alumno.fecha_retiro
				alumno.fecha_retiro 		= new Date(alumno.fecha_retiro)
				alumno.fecha_matricula_ant 	= alumno.fecha_matricula
				alumno.fecha_matricula 		= new Date(alumno.fecha_matricula)

			for alumno in $scope.AlumnosSinMatricula
				#console.log alumno.fecha_retiro, new Date(alumno.fecha_retiro.replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3"))
				alumno.estado_ant 			= alumno.estado
				alumno.fecha_retiro_ant 	= alumno.fecha_retiro
				alumno.fecha_retiro 		= new Date(alumno.fecha_retiro)
				alumno.fecha_matricula_ant 	= alumno.fecha_matricula
				alumno.fecha_matricula 		= new Date(alumno.fecha_matricula)

		)




	$scope.editar = (row)->
		$state.go('panel.alumnos.editar', {alumno_id: row.alumno_id})

	$scope.eliminar = (row)->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/removeAlumno.tpl.html'
			controller: 'RemoveAlumnoCtrl'
			resolve: 
				alumno: ()->
					row
		})
		modalInstance.result.then( (alum)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
		, ()->
			# nada
		)

	$scope.agregarAcudiente = (rowAlum)->
		delete $rootScope.acudiente_cambiar

		modalInstance = $modal.open({
			templateUrl: '==alumnos/newAcudienteModal.tpl.html'
			controller: 'NewAcudienteModalCtrl'
			resolve: 
				alumno: ()->
					rowAlum
				paises: ()->
					$scope.paises
				tipos_doc: ()->
					$scope.tipos_doc
				parentescos: ()->
					$scope.parentescos
		})
		modalInstance.result.then( (acud)->
			rowAlum.subGridOptions.data.splice(rowAlum.subGridOptions.data.length-1, 0, acud)
		, ()->
			# nada
		)


	$scope.cambiarAcudiente = (rowAlum, acudiente)->
		$rootScope.acudiente_cambiar = acudiente

		modalInstance = $modal.open({
			templateUrl: '==alumnos/newAcudienteModal.tpl.html'
			controller: 'NewAcudienteModalCtrl'
			resolve: 
				alumno: ()->
					rowAlum
				paises: ()->
					$scope.paises
				tipos_doc: ()->
					$scope.tipos_doc
				parentescos: ()->
					$scope.parentescos
		})
		modalInstance.result.then( (acud)->
			for pariente, indice in rowAlum.subGridOptions.data
				if pariente
					if pariente.id == acudiente.id
						rowAlum.subGridOptions.data.splice(indice, 1, acud)
		, ()->
			# nada
		)


	$scope.quitarAcudiente = (rowAlum, acudiente)->
		
		modalInstance = $modal.open({
			templateUrl: '==alumnos/quitarAcudienteModalConfirm.tpl.html'
			controller: 'QuitarAcudienteModalConfirmCtrl'
			resolve: 
				alumno: ()->
					rowAlum
				acudiente: ()->
					acudiente
		})
		modalInstance.result.then( (acud)->
			for pariente, indice in rowAlum.subGridOptions.data
				if pariente
					if pariente.id == acud.id
						rowAlum.subGridOptions.data.splice(indice, 1)
		, ()->
			# nada
		)


	$scope.cambiarCiudad = (row, tipo_ciudad)->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/cambiarCiudadModal.tpl.html'
			controller: 'CambiarCiudadModalCtrl'
			resolve: 
				persona: ()->
					row
				paises: ()->
					$scope.paises
				tipo_ciudad: ()->
					tipo_ciudad
				tipo_persona: ()->
					if row.subGridOptions
						return 'alumno'
					else
						return 'acudiente'
		})
		modalInstance.result.then( (alum)->
			row = alum
		)



	$scope.cambiarPazysalvo = (fila)->
		fila.pazysalvo = !fila.pazysalvo
		if not fila.alumno_id
			fila.alumno_id = fila.id

		#datosAlum = angular.copy(fila)
		#delete datosAlum.subGridOptions

		datos = 
			alumno_id: 	fila.alumno_id
			propiedad: 	'pazysalvo'
			valor: 		fila.pazysalvo

		$http.put('::alumnos/guardar-valor', datos).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.pazysalvo = !fila.pazysalvo
			toastr.error 'Cambio no guardado', 'Error'
		)
		

	$scope.resetPass = (row)->
		
		modalInstance = $modal.open({
			templateUrl: App.views + 'usuarios/resetPass.tpl.html'
			controller: 'ResetPassCtrl'
			resolve: 
				usuario: ()->
					row
		})
		modalInstance.result.then( (user)->
			#console.log 'Resultado del modal: ', user
		)




	$scope.eliminarMatricula = (row)->

		$http.delete('::matriculas/destroy/'+row.matricula_id).then((r)->
			row.currentyear = 0
			toastr.success 'Alumno desmatriculado'
			return row
		, (r2)->
			toastr.error 'No se pudo desmatricular', 'Problema'
		)

	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	bt2 	= '<span style="padding-left: 2px; padding-top: 4px;" class="btn-group">' + btGrid1 + btGrid2 + '</span>'
	btMatricular = "==directives/botonesMatricularMas.tpl.html"
	btEditReligion = "==alumnos/botonEditReligion.tpl.html"
	btPazysalvo = "==directives/botonPazysalvo.tpl.html"
	btUsuario = "==directives/botonesResetPassword.tpl.html"
	btCiudadNac = "==directives/botonCiudadNac.tpl.html"
	btTipoDoc = "==directives/botonTipoDoc.tpl.html"
	btEditUsername = "==alumnos/botonEditUsername.tpl.html"

	appendPopover1 = "'==alumnos/popoverAlumnoGrid.tpl.html'"
	appendPopover2 = "'mouseenter'"
	append3 = "' '"
	appendPopover = 'uib-popover-template="views+' + appendPopover1 + '" popover-trigger="'+appendPopover2+'" popover-title="{{ row.entity.nombres + ' + append3 + ' + row.entity.apellidos }}" popover-popup-delay="500" popover-append-to-body="true"'


	$scope.gridOptions = 
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		expandableRowTemplate: '==alumnos/expandableRowTemplate.tpl.html',
		expandableRowHeight: 110,
		expandableRowScope: 
			agregarAcudiente: 		$scope.agregarAcudiente
			quitarAcudiente: 		$scope.quitarAcudiente
			cambiarAcudiente: 		$scope.cambiarAcudiente
			resetPass: 				$scope.resetPass
			cambiarCiudad: 			$scope.cambiarCiudad
			cambiaUsernameCheck: 	$scope.cambiaUsernameCheck

		columnDefs: [
			{ field: 'no', pinnedLeft:true, cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row) + 1}}</div>', width: 40, enableCellEdit: false }
			{ field: 'nombres', minWidth: 120, pinnedLeft:true,
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false, cellTemplate: '<div class="ui-grid-cell-contents" style="padding: 0px;" ' + appendPopover + '><img ng-src="{{grid.appScope.perfilPath + row.entity.foto_nombre}}" style="width: 35px" />{{row.entity.nombres}}</div>' }
			{ field: 'apellidos', minWidth: 80, filter: { condition: uiGridConstants.filter.CONTAINS }}
			{ name: 'edicion', displayName:'Edici', width: 54, enableSorting: false, enableFiltering: false, cellTemplate: bt2, enableCellEdit: false, enableColumnMenu: true}
			{ field: 'sexo', displayName: 'Sex', width: 40 }
			{ field: 'grupo_id', displayName: 'Matrícula', enableCellEdit: false, cellTemplate: btMatricular, minWidth: 180, enableFiltering: false }
			{ field: 'fecha_matricula', displayName: 'Fecha matrícula', cellFilter: "date:mediumDate", type: 'date', minWidth: 100 }
			{ field: 'no_matricula', displayName: '# matrícula', minWidth: 80, enableColumnMenu: true }
			{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, editableCellTemplate: btEditUsername, minWidth: 135 }
			{ field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date', minWidth: 100}
			{ field: 'deuda', displayName: 'Deuda', type: 'number', cellFilter: 'currency:"$":0', minWidth: 70 }
			{ field: 'pazysalvo', displayName: 'A paz?', cellTemplate: btPazysalvo, minWidth: 60, enableCellEdit: false }
			{ field: 'religion', displayName: 'Religión', minWidth: 70, editableCellTemplate: btEditReligion }
			{ field: 'ciudad_nac', displayName: 'Ciud Nacimi', minWidth: 120, cellTemplate: btCiudadNac, enableCellEdit: false }
			{ field: 'tipo_doc', displayName: 'Tipo documento', minWidth: 120, cellTemplate: btTipoDoc, enableCellEdit: false }
			{ field: 'documento', minWidth: 80 }
			{ field: 'tipo_sangre', displayName: 'RH', minWidth: 70 }
			{ field: 'direccion', displayName: 'Dirección', minWidth: 70 }
			{ field: 'barrio', minWidth: 70 }
			{ field: 'telefono', displayName: 'Teléfono', minWidth: 70 }
			{ field: 'eps', displayName: 'EPS', minWidth: 70 }
			{ field: 'estrato', minWidth: 70, type: 'number' }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->
				
				if newValue != oldValue
				
					if not rowEntity.alumno_id
						rowEntity.alumno_id = fila.id

					
					if colDef.field == "sexo"
						newValue = newValue.toUpperCase()
						if !(newValue == 'M' or newValue == 'F')
							toastr.warning 'Debe usar M o F'
							rowEntity.sexo = oldValue
							return
						
					if colDef.field == "fecha_matricula"
						return $scope.cambiarFechaMatricula(rowEntity)
					

					if colDef.field == "tipo_sangre"
						newValue = newValue.toUpperCase()
						if !($scope.tipos_sangre.indexOf(newValue) > -1)
							toastr.warning 'Debe usar: ' + $scope.tipos_sangre.join(' ')
							rowEntity.tipo_sangre = oldValue
							return
						

					if colDef.field == "estrato"
						if newValue < 0 or newValue > 9 
							toastr.warning 'Valor no admitido'
							rowEntity.estrato = oldValue
							return
						

					$http.put('::alumnos/guardar-valor', {alumno_id: rowEntity.alumno_id, propiedad: colDef.field, valor: newValue } ).then((r)->
						toastr.success 'Alumno(a) actualizado con éxito'
					, (r2)->
						rowEntity[colDef.field] = oldValue
						toastr.error 'Cambio no guardado', 'Error'
					)
				if !(colDef.field == "religion")
					$scope.$apply()
			)





	$scope.religionSelected = (row, evento)->
		if $scope.religiones.indexOf(row.religion) > -1
			$scope.$broadcast(uiGridEditConstants.events.END_CELL_EDIT);


	$scope.religionEditPressEnter = (row)->
		$scope.$broadcast(uiGridEditConstants.events.END_CELL_EDIT);

	
	$scope.tipoDocSeleccionado = ($item, row)->
		datos = { propiedad: 'tipo_doc', valor: $item.id }
		person = 'acudientes'

		if row.subGridOptions
			person 			= 'alumnos'
			datos.alumno_id = row.alumno_id
		else
			datos.acudiente_id 	= row.acudiente_id
			datos.parentesco_id = row.parentesco_id
			datos.user_acud_id 	= row.user_id

		$http.put('::' + person + '/guardar-valor', datos ).then((r)->
			toastr.success 'Alumno(a) actualizado con éxito', 'Actualizado'
		, (r2)->
			rowEntity[colDef.field] = oldValue
			toastr.error 'Cambio no guardado', 'Error'
		)

	
	$scope.matricularUno = (row)->
		if not $scope.dato.grupo.id
			toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return
		
		datos = { alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id, year_id: $scope.USER.year_id }
		
		$http.post('::matriculas/matricularuno', datos).then((r)->
			r = r.data
			row.matricula_id 			= r.id
			row.grupo_id 				= r.grupo_id
			row.estado 					= 'MATR'
			row.fecha_matricula_ant 	= r.fecha_matricula.date
			row.fecha_matricula 		= new Date(r.fecha_matricula.date)
			toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			return row
		, (r2)->
			toastr.error 'No se pudo matricular el alumno.', 'Error'

		)



	$scope.cambiaUsernameCheck = (texto)->
		$scope.verificandoUsername = true
		return $http.put('::users/usernames-check', {texto: texto}).then((r)->
			$scope.username_match 		= r.data.usernames
			$scope.verificandoUsername 	= false
			return $scope.username_match.map((item)->
				return item.username
			)
		)

	$scope.reMatricularUno = (row)->

		if not $scope.dato.grupo.id
			toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return
		
		datos = { matricula_id: row.matricula_id }
		
		$http.put('::matriculas/re-matricularuno', datos).then((r)->
			r = r.data
			toastr.success 'Alumno rematriculado', 'Matriculado'
			return row
		, (r2)->
			toastr.error 'No se pudo matricular el alumno.', 'Error'

		)


	$scope.matricularEn = (row)->
		modalInstance = $modal.open({
			templateUrl: '==alumnos/matricularEn.tpl.html'
			controller: 'MatricularEnCtrl'
			resolve: 
				alumno: ()->
					row
				grupos: ()->
					$scope.grupos
				year_id: ()->
					$scope.USER.year_id
		})
		modalInstance.result.then( (alum)->
			console.log 'Cierra'
		)



	$scope.setAsistente = (fila)->
		
		$http.put('::matriculas/set-asistente', {matricula_id: fila.matricula_id, grupo_id: $scope.dato.grupo.grupo_id}).then((r)->
			toastr.success 'Guardado como asistente'
		, (r2)->
			toastr.error 'No se pudo guardar como asistente', 'Error'
		)
		

	$scope.setNewAsistente = (fila)->
		
		$http.put('::matriculas/set-new-asistente', {alumno_id: fila.alumno_id, grupo_id: $scope.dato.grupo.id}).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			toastr.error 'No se pudo crear asistente', 'Error'
		)
		

	$scope.cambiarFechaRetiro = (row)->
		
		$http.put('::matriculas/cambiar-fecha-retiro', { matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Fecha retiro guardada'
		, (r2)->
			row.fecha_retiro = row.fecha_retiro_ant
			toastr.error 'No se pudo guardar la fecha', 'Error'
		)
		

	$scope.cambiarFechaMatricula = (row)->

		$http.put('::matriculas/cambiar-fecha-matricula', { matricula_id: row.matricula_id, fecha_matricula: row.fecha_matricula }).then((r)->
			toastr.success 'Fecha matrícula guardada'
		, (r2)->
			row.fecha_matricula = row.fecha_matricula_ant
			toastr.error 'No se pudo guardar la fecha', 'Error'
		)
		




	$scope.desertar = (row)->
		fecha = row.fecha_retiro
		if row.fecha_retiro_ant == null
			fecha 				= new Date()
			row.fecha_retiro 	= fecha

		$http.put('::matriculas/desertar', {matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Alumno desertado'
		, (r2)->
			toastr.error 'No se pudo desertar', 'Problema'
		)




	$scope.retirar = (row)->
		fecha = row.fecha_retiro
		if row.fecha_retiro_ant == null
			fecha 				= new Date()
			row.fecha_retiro 	= fecha

		$http.put('::matriculas/retirar', {matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Alumno retirado'
		, (r2)->
			toastr.error 'No se pudo desmatricular', 'Problema'
		)



	$scope.$on 'alumnoguardado', (data, alum)->
		$scope.gridOptions.data.push alum

	return
])

.controller('RemoveAlumnoCtrl', ['$scope', '$uibModalInstance', 'alumno', '$http', 'toastr', 'App', ($scope, $modalInstance, alumno, $http, toastr, App)->
	$scope.alumno 		= alumno
	$scope.perfilPath 	= App.images+'perfil/'

	$scope.ok = ()->

		$http.delete('::alumnos/destroy/'+alumno.alumno_id).then((r)->
			toastr.success 'Alumno enviado a la papelera.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo enviar a la papelera.', 'Problema'
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
