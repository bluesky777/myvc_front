angular.module("myvcFrontApp")

.controller('ListAlumnosCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'uiGridConstants', 'uiGridEditConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', '$stateParams', ($scope, App, $rootScope, $state, $interval, uiGridConstants, uiGridEditConstants, $modal, $filter, AuthService, toastr, $http, $stateParams)->

	AuthService.verificar_acceso()


	$scope.$parent.bigLoader			= true
	$scope.dato 						= {}
	$scope.dato.mostrartoolgrupo 		= true
	$scope.gridScope 					= $scope # Para getExternalScopes de ui-Grid
	$scope.views 						= App.views
	$scope.perfilPath 		  	      	= App.images+'perfil/'
	$scope.year_ant 					= $scope.USER.year - 1
	$scope.gridOptions 			        = {}
	$scope.gridOptionsSinMatricula 		= {}
	$scope.paises 						= []
	$scope.religiones					= App.religiones
	$scope.tipos_sangre 				= App.tipos_sangre
	$scope.mostrar_pasado     = false
	$scope.mostrar_retirados  = false
	$scope.es_titular 			= true

	$scope.parentescos 			= App.parentescos



	$scope.dato.grupo = ''
	$http.get('::grupos/con-paises-tipos').then((r)->
		matr_grupo = 0

		if $stateParams.grupo_id
			localStorage.matr_grupo = parseInt($stateParams.grupo_id)
			matr_grupo = parseInt(localStorage.matr_grupo)


		$scope.grupos 		= r.data.grupos
		$scope.paises 		= r.data.paises
		$scope.tipos_doc 	= r.data.tipos_doc
		$scope.grupos_titularia 	= r.data.grupos_titularia

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

		if AuthService.hasRoleOrPerm('Profesor')
			if grupo.es_titular
				$scope.es_titular = true
				###
				for columGrid in $scope.gridOptions.columnDefs
					columGrid.enableCellEdit = true
				###
			else
				$scope.es_titular = false
				###
				for columGrid in $scope.gridOptions.columnDefs
					columGrid.enableCellEdit = false
				###


		$scope.traerAlumnnos = ()->
			$http.put("::grupos/alumnos-con-datos", {grupo_actual: grupo}).then((r)->
				$scope.gridOptions.data 	            = r.data.AlumnosActuales

				for alumno in $scope.gridOptions.data
					alumno.fecha_nac 			= if alumno.fecha_nac then new Date(alumno.fecha_nac.replace(/-/g, '\/')) else alumno.fecha_nac

					for tipo_doc in $scope.tipos_doc
						if tipo_doc.id == alumno.tipo_doc
							alumno.tipo_doc = tipo_doc

					for pariente in alumno.subGridOptions.data
						pariente.fecha_nac_ant 	= pariente.fecha_nac
						pariente.fecha_nac 		= if pariente.fecha_nac then new Date(pariente.fecha_nac.replace(/-/g, '\/')) else pariente.fecha_nac

					if !$scope.es_titular
						return

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



			)

		$scope.traerAlumnnos()


	$scope.agregarAcudiente = (rowAlum)->
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return

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
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return

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
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
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
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
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
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
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
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
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

	$scope.religionSelected = (row, evento)->
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
		if $scope.religiones.indexOf(row.religion) > -1
			$scope.$broadcast(uiGridEditConstants.events.END_CELL_EDIT);


	$scope.religionEditPressEnter = (row)->
		$scope.$broadcast(uiGridEditConstants.events.END_CELL_EDIT);


	$scope.tipoDocSeleccionado = ($item, row)->
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
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
			toastr.error 'Cambio no guardado.', 'Error'
		)


	$scope.cambiaUsernameCheck = (texto)->
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
		$scope.verificandoUsername = true
		return $http.put('::users/usernames-check', {texto: texto}).then((r)->
			$scope.username_match 		= r.data.usernames
			$scope.verificandoUsername 	= false
			return $scope.username_match.map((item)->
				return item.username
			)
		)


	$scope.cambiaEpsCheck = (texto)->
		if !$scope.es_titular
			toastr.warning 'No eres titular', 'No puedes editar.'
			return
		$scope.verificandoEps = true
		return $http.put('::alumnos/eps-check', {texto: texto}).then((r)->
			$scope.eps_match 		= r.data.eps
			$scope.verificandoEps 	= false
			return $scope.eps_match.map((item)->
				return item.eps
			)
		)




	#btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid1 = ''
	btEditReligion = "==alumnos/botonEditReligion.tpl.html"
	btPazysalvo = "==directives/botonPazysalvo.tpl.html"
	btUsuario = "==directives/botonesResetPassword.tpl.html"
	btCiudadNac = "==directives/botonCiudadNac.tpl.html"
	btCiudadDoc = "==directives/botonCiudadDoc.tpl.html"
	btCiudadResid = "==directives/botonCiudadResid.tpl.html"
	btTipoDoc = "==directives/botonTipoDoc.tpl.html"
	btEditUsername = "==alumnos/botonEditUsername.tpl.html"
	btEditEPS = "==alumnos/botonEditEps.tpl.html"

	appendPopover1 = "'==alumnos/popoverAlumnoGrid.tpl.html'"
	appendPopover2 = "'mouseenter'"
	append3 = "' '"
	appendPopover = 'uib-popover-template="views+' + appendPopover1 + '" popover-trigger="'+appendPopover2+'" popover-title="{{ row.entity.nombres + ' + append3 + ' + row.entity.apellidos }}" popover-popup-delay="500" popover-append-to-body="true"'


	$scope.gridOptions =
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		exporterSuppressColumns: [ 'edicion' ],
		exporterCsvColumnSeparator: ';',
		exporterMenuPdf: false,
		exporterMenuExcel: false,
		exporterCsvFilename: "Alumnos - MyVC.csv",
		enableGridMenu: true,
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
			{ field: 'nombres', minWidth: 130, pinnedLeft:true,
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false, cellTemplate: '<div class="ui-grid-cell-contents" style="padding: 0px;" ' + appendPopover + '><img ng-src="{{grid.appScope.perfilPath + row.entity.foto_nombre}}" style="width: 35px" />{{row.entity.nombres}}</div>' }
			{ field: 'apellidos', minWidth: 110, filter: { condition: uiGridConstants.filter.CONTAINS }}
			{ field: 'sexo', displayName: 'Sex', width: 40 }
			{ field: 'no_matricula', displayName: '# matrícula', minWidth: 80, enableColumnMenu: true }
			{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, editableCellTemplate: btEditUsername, minWidth: 135 }
			{ field: 'deuda', displayName: 'Deuda', type: 'number', cellFilter: 'currency:"$":0', minWidth: 70 }
			{ field: 'pazysalvo', displayName: 'A paz?', cellTemplate: btPazysalvo, minWidth: 60, enableCellEdit: false }
			{ field: 'religion', displayName: 'Religión', minWidth: 70, editableCellTemplate: btEditReligion }
			{ field: 'tipo_doc', displayName: 'Tipo documento', minWidth: 120, cellTemplate: btTipoDoc, enableCellEdit: false }
			{ field: 'documento', minWidth: 100, cellFilter: 'formatNumberDocumento' }
			{ field: 'ciudad_doc', displayName: 'Ciud Docu', minWidth: 120, cellTemplate: btCiudadDoc, enableCellEdit: false }
			{ field: 'tipo_sangre', displayName: 'RH', minWidth: 70 }
			{ field: 'estrato', minWidth: 70, type: 'number' }
			{ field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date', minWidth: 100}
			{ field: 'ciudad_nac', displayName: 'Ciud Nacimi', minWidth: 120, cellTemplate: btCiudadNac, enableCellEdit: false }
			{ field: 'direccion', displayName: 'Dirección', minWidth: 70 }
			{ field: 'barrio', minWidth: 70 }
			{ field: 'ciudad_resid', displayName: 'Ciud Resid', minWidth: 120, cellTemplate: btCiudadResid, enableCellEdit: false }
			{ field: 'telefono', displayName: 'Teléfono', minWidth: 80 }
			{ field: 'eps', displayName: 'EPS', minWidth: 100, editableCellTemplate: btEditEPS }
		],
		multiSelect: false,
		#filterOptions: $scope.filterOptions,
		exporterHeaderFilter: ( displayName )->
			if( displayName == 'A paz?' )
				return 'Paz y salvo';
			else if displayName == 'Matrícula'
				return 'Grupo'
			else
				return displayName;
		,
		exporterFieldCallback: ( grid, row, col, input )->
			if col.name == 'no'
				return grid.renderContainers.body.visibleRowCache.indexOf(row) + 1
			if col.name == 'grupo_id'
				return $scope.dato.grupo.nombre
			if col.name == 'ciudad_nac'
				return row.entity.ciudad_nac_nombre

			if( col.name == 'pazysalvo' )
				if input
					return 'Si'
				else
					return 'No'
			else if col.name == 'tipo_doc'
				if input
					if input.tipo
						return input.tipo
					else
						return input
				else
					return input
			else
				return input;
		,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

				if newValue != oldValue


					if AuthService.hasRoleOrPerm('Profesor') and $scope.USER.profes_can_edit_alumnos
						if !$scope.es_titular
							rowEntity[colDef.field] = oldValue
							toastr.warning 'No eres el titular'
							return
					else if !AuthService.hasRoleOrPerm('Admin')
						rowEntity[colDef.field] = oldValue
						toastr.warning 'Actualmente no hay permiso para editar'
						return


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


					if colDef.field == "documento"
						if newValue.length != 10 and newValue.length != 0
							toastr.warning 'Debe ser de diez dígitos'
							#rowEntity.documento = oldValue
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




])
