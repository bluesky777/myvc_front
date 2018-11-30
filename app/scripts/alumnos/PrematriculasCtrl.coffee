'use strict'

angular.module("myvcFrontApp")

.controller('PrematriculasCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'uiGridConstants', 'uiGridEditConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', 'DownloadServ', 'Upload', ($scope, App, $rootScope, $state, $interval, uiGridConstants, uiGridEditConstants, $modal, $filter, AuthService, toastr, $http, DownloadServ, Upload)->

	AuthService.verificar_acceso()

	if AuthService.hasRoleOrPerm('Profesor') and !$scope.USER.profes_can_edit_alumnos
		toastr.warning 'No tienes permiso para editar alumnos'
		$state.transitionTo 'panel'

	#$scope.$parent.bigLoader			= true
	$scope.dato 						= {}
	$scope.dato.mostrartoolgrupo 		= true
	$scope.gridScope 					= $scope # Para getExternalScopes de ui-Grid
	$scope.views 						= App.views
	$scope.perfilPath 		  	      	= App.images+'perfil/'
	$scope.year_ant 					= $scope.USER.year - 1
	$scope.gridOptions 			        = {}
	$scope.gridOptionsSinMatricula 		= {}
	$scope.paises 						= []
	$scope.tipos_sangre 				= App.tipos_sangre
	$scope.mostrar_pasado     = true
	$scope.mostrar_retirados  = false
	$scope.texto_a_buscar    = ''
	$scope.hombresGrupo       = 0
	$scope.mujeresGrupo       = 0

	$scope.parentescos 			= App.parentescos



	$scope.dato.grupo = ''
	$http.get('::grupos/con-paises-tipos-next-year').then((r)->
		matr_grupo = 0

		if localStorage.matr_grupo_premat
			matr_grupo = parseInt(localStorage.matr_grupo_premat)

		$scope.grupos 		= r.data.grupos
		$scope.paises 		= r.data.paises
		$scope.tipos_doc 	= r.data.tipos_doc

		for grupo in $scope.grupos

			if parseInt(grupo.id) == parseInt(matr_grupo)
				$scope.dato.grupo = grupo
				$scope.selectGrupo($scope.dato.grupo)


		cant_matr   = 0
		sin_matr    = 0
		cant_cupo   = 0
		faltan      = 0
		formus      = 0
		matris      = 0

		for grup in $scope.grupos
			cant_matr   += grup.cantidad
			sin_matr    += grup.sin_matricular
			cant_cupo   += grup.cupo
			faltan      += grup.cant_faltantes
			formus      += grup.cant_formularios
			matris      += grup.cant_matriculados

			grup.active = false

		$scope.total_prematriculados  = cant_matr
		$scope.total_sin_prematric    = sin_matr
		$scope.total_cupo             = cant_cupo
		$scope.total_taltantes        = faltan
		$scope.total_formularios      = formus
		$scope.total_matriculados     = matris

		#$scope.$parent.bigLoader 	= false
	)


	$scope.selectGrupo = (grupo)->
		localStorage.matr_grupo_premat = grupo.id
		$scope.dato.grupo 		= grupo

		cant_matr   = 0
		sin_matr    = 0

		for grup in $scope.grupos
			cant_matr   += grup.cantidad
			sin_matr    += grup.sin_matricular

			grup.active = false

		$scope.total_prematriculados  = cant_matr
		$scope.total_sin_prematric    = sin_matr

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


		$scope.traerAlumnnosConGradosAnterior = ()->
			$http.put("::prematriculas/alumnos-con-grado-anterior", {grupo_actual: grupo, grado_ant_id: grado_ant_id, year_ant: $scope.year_ant}).then((r)->
				$scope.gridOptions.data 	            = r.data.AlumnosActuales
				$scope.gridOptionsSinMatricula.data 	= r.data.AlumnosSinMatricula
				$scope.AlumnosFormularios 	          = r.data.AlumnosFormularios

				for alumno in $scope.gridOptions.data
					#console.log alumno.fecha_retiro, new Date(alumno.fecha_retiro.replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3"))
					alumno.estado_ant 			= alumno.estado
					alumno.fecha_retiro_ant 	= alumno.fecha_retiro
					alumno.fecha_retiro 		= if alumno.fecha_retiro then new Date(alumno.fecha_retiro.replace(/-/g, '\/')) else alumno.fecha_retiro
					alumno.fecha_matricula_ant 	= alumno.fecha_matricula
					alumno.fecha_matricula 		= if alumno.fecha_matricula then new Date(alumno.fecha_matricula.replace(/-/g, '\/')) else alumno.fecha_matricula
					alumno.premarticulado_ant 	= alumno.prematriculado
					alumno.prematriculado 		= if alumno.prematriculado then new Date(alumno.prematriculado.replace(/-/g, '\/')) else alumno.prematriculado

					for tipo_doc in $scope.tipos_doc
						if tipo_doc.id == alumno.tipo_doc
							alumno.tipo_doc = tipo_doc

					for pariente in alumno.subGridOptions.data
						pariente.fecha_nac_ant 	= pariente.fecha_nac
						pariente.fecha_nac 		= if pariente.fecha_nac then new Date(pariente.fecha_nac.replace(/-/g, '\/')) else pariente.fecha_nac



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

				for alumno in $scope.gridOptionsSinMatricula.data
					#console.log alumno.fecha_retiro, new Date(alumno.fecha_retiro.replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3"))
					alumno.estado_ant 			= alumno.estado
					alumno.fecha_retiro_ant 	= alumno.fecha_retiro
					alumno.fecha_retiro 		= if alumno.fecha_retiro then new Date(alumno.fecha_retiro.replace(/-/g, '\/')) else alumno.fecha_retiro
					alumno.fecha_matricula_ant 	= alumno.fecha_matricula
					alumno.fecha_matricula 		= if alumno.fecha_matricula then new Date(alumno.fecha_matricula.replace(/-/g, '\/')) else alumno.fecha_matricula

			)

		$scope.traerAlumnnosConGradosAnterior()




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


	$scope.restaurar = (row)->
		$scope.restaurando = true
		$http.put('::alumnos/restore/' + row.alumno_id).then((r)->
			toastr.success 'Alumno restaurado, para verlo, debe recargar la página'
			$scope.restaurando = false
			row.restaurado = true
		, (r2)->
			toastr.error 'Alumno no restaurado', 'Error'
			$scope.restaurando = false
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

	$scope.cantidadDeudores = ()->
		sum = 0
		hombres = 0
		mujeres = 0

		if $scope.gridOptions.data
			for alumno in $scope.gridOptions.data
				if !alumno.pazysalvo
					sum = sum + 1
				if alumno.sexo == 'M'
					hombres++
				else
					mujeres++
		$scope.hombresGrupo = hombres
		$scope.mujeresGrupo = mujeres

		return sum



	$scope.crear_alumno = ()->
		$rootScope.grupos_siguientes = $scope.grupos
		$state.go('panel.prematriculas.nuevo')

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



	$scope.toggleNuevo = (fila)->
		fila.nuevo = !fila.nuevo
		if not fila.alumno_id
			fila.alumno_id = fila.id

		datos =
			alumno_id: 	fila.alumno_id
			propiedad: 	'nuevo'
			valor: 		fila.nuevo

		$http.put('::alumnos/guardar-valor', datos).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.nuevo = !fila.nuevo
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.toggleRepitente = (fila)->
		fila.repitente = !fila.repitente
		if not fila.alumno_id
			fila.alumno_id = fila.id

		datos =
			alumno_id: 	fila.alumno_id
			propiedad: 	'repitente'
			valor: 		fila.repitente

		$http.put('::alumnos/guardar-valor', datos).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.repitente = !fila.repitente
			toastr.error 'Cambio no guardado', 'Error'
		)



	$scope.toggleEgresado = (fila)->
		fila.egresado = !fila.egresado
		if not fila.alumno_id
			fila.alumno_id = fila.id

		datos =
			alumno_id: 	fila.alumno_id
			propiedad: 	'egresado'
			valor: 		fila.egresado

		$http.put('::alumnos/guardar-valor', datos).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.egresado = !fila.egresado
			toastr.error 'Cambio no guardado', 'Error'
		)



	$scope.crearUsuario = (row)->

		if row.user_id
			toastr.warning 'Ya tiene usuario'
			return

		if row.tipo == 'Acudiente'

			if !row.id
				toastr.info 'Sólo con acudientes creados'
				return

			$http.post('::acudientes/crear-usuario', {acudiente: row}).then((r)->
				$scope.usuario_creado = true
				row.user_id 	= r.data.id
				row.username 	= r.data.username
				toastr.success 'Usuario creado'

			, ()->
				toastr.error 'No se pudo crear el usuario'
			)

		if row.tipo != 'Acudiente'
			toastr.info 'Aquí solo puede crear usuario de acudiente', 'Lo sentimos'


	$scope.resetPass = (row)->

		if !row.user_id
			toastr.warning 'Aún no tiene usuario'
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


	$scope.cambiaUsernameCheck = (texto)->
		$scope.verificandoUsername = true
		return $http.put('::users/usernames-check', {texto: texto}).then((r)->
			$scope.username_match 		= r.data.usernames
			$scope.verificandoUsername 	= false
			return $scope.username_match.map((item)->
				return item.username
			)
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
	btGrid2 = ''
	#btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	bt2 	= '<span style="padding-left: 2px; padding-top: 4px;" class="btn-group">' + btGrid1 + btGrid2 + '</span>'
	btMatricular = "==directives/botonesMatricularMas.tpl.html"
	btPazysalvo = "==directives/botonPazysalvo.tpl.html"
	btIsNuevo = "==directives/botonIsNuevo.tpl.html"
	btIsRepitente = "==directives/botonIsRepitente.tpl.html"
	btIsEgresado = "==directives/botonIsEgresado.tpl.html"
	btUsuario = "==directives/botonesResetPassword.tpl.html"
	btCiudadDoc = "==directives/botonCiudadDoc.tpl.html"
	btTipoDoc = "==directives/botonTipoDoc.tpl.html"
	btEditUsername = "==alumnos/botonEditUsername.tpl.html"

	appendPopover1 = "'==alumnos/popoverAlumnoGrid.tpl.html'"
	appendPopover2 = "'mouseenter'"
	append3 = "' '"
	appendPopover = 'uib-popover-template="views+' + appendPopover1 + '" popover-trigger="'+appendPopover2+'" popover-title="{{ row.entity.nombres + ' + append3 + ' + row.entity.apellidos }}" popover-popup-delay="500" popover-append-to-body="true"'
	gridFooterCartera = "==alumnos/gridFooterCartera.tpl.html"


	$scope.gridOptions =
		showGridFooter: true,
		showColumnFooter: true,
		gridFooterTemplate: gridFooterCartera,
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
		expandableRowHeight: 120,
		expandableRowScope:
			agregarAcudiente: 		$scope.agregarAcudiente
			quitarAcudiente: 			$scope.quitarAcudiente
			cambiarAcudiente: 		$scope.cambiarAcudiente
			crearUsuario: 				$scope.crearUsuario
			resetPass: 						$scope.resetPass
			cambiarCiudad: 				$scope.cambiarCiudad
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
			{ name: 'edicion', displayName:'Edit', width: 54, enableSorting: false, enableFiltering: false, cellTemplate: bt2, enableCellEdit: false, enableColumnMenu: true}
			{ field: 'sexo', displayName: 'Sex', width: 40 }
			{ field: 'grupo_id', displayName: 'Matrícula', enableCellEdit: false, cellTemplate: btMatricular, minWidth: 230, enableFiltering: false }
			{ field: 'prematriculado', displayName: 'Fech prematriculado', cellFilter: "date:mediumDate", type: 'date', minWidth: 120 }
			{ field: 'fecha_matricula', displayName: 'Fecha matrícula', cellFilter: "date:mediumDate", type: 'date', minWidth: 100 }
			{ field: 'no_matricula', displayName: '# matrícula', minWidth: 80, enableColumnMenu: true }
			{ field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, editableCellTemplate: btEditUsername, minWidth: 135 }
			{ field: 'deuda', displayName: 'Deuda', type: 'number', cellFilter: 'currency:"$":0', minWidth: 70 }
			{ field: 'pazysalvo', displayName: 'A paz?', cellTemplate: btPazysalvo, minWidth: 60, enableCellEdit: false }
			{ field: 'nuevo', displayName: 'Nuevo?', cellTemplate: btIsNuevo, minWidth: 60, enableCellEdit: false }
			{ field: 'repitente', displayName: 'Repitente?', cellTemplate: btIsRepitente, minWidth: 60, enableCellEdit: false }
			{ field: 'egresado', displayName: 'Egresado?', cellTemplate: btIsEgresado, minWidth: 60, enableCellEdit: false }
			{ field: 'tipo_doc', displayName: 'Tipo documento', minWidth: 120, cellTemplate: btTipoDoc, enableCellEdit: false }
			{ field: 'documento', minWidth: 100, cellFilter: 'formatNumberDocumento' }
			{ field: 'ciudad_doc', displayName: 'Ciud Docu', minWidth: 120, cellTemplate: btCiudadDoc, enableCellEdit: false }
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

			if( col.name == 'pazysalvo' or col.name == 'nuevo' )
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
				$scope.$apply()
			)







	### ---------------- ---------------- ---------------- ---------------- ----------------
	Alumnos del año pasado Grid
	---------------- ---------------- ---------------- ---------------- ---------------- ###
	btMatr0 = '<label ng-click="grid.appScope.setPrematriculado(row.entity)" uib-tooltip="Prematricular" tooltip-append-to-body="true" class="btn btn-success shiny btn-xs">Prem</label>'
	btMatr1 = '<label ng-click="grid.appScope.setNewAsistente(row.entity)" uib-tooltip="Inscribir como asistente" tooltip-append-to-body="true" class="btn btn-success shiny btn-xs">Asis</label>'
	btMatr2 = '<label ng-click="grid.appScope.matricularUno(row.entity, true)" uib-tooltip="Matricular" tooltip-append-to-body="true" tooltip-popup-delay="1000" class="btn btn-success shiny btn-xs">Matric</label>'
	btMatr3 = '<label ng-click="grid.appScope.matricularEn(row.entity)" uib-tooltip="Prematricular en..." tooltip-append-to-body="true" tooltip-placement="right" class="btn btn-success shiny btn-xs">Otro grupo...</label>'
	btMatrCom 	= '<span style="padding-left: 2px; padding-top: 4px;" class="btn-group">' + btMatr0 + btMatr1 + btMatr2 + btMatr3 + '</span>'


	$scope.gridOptionsSinMatricula =
		showGridFooter: true,
		enableSorting: true,
		enableFiltering: true,
		columnDefs: [
			{ field: 'no', cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row) + 1}}</div>', width: 40 }
			{ field: 'nombres', minWidth: 120,
			filter: {
				condition: (searchTerm, cellValue, row)->
					entidad = row.entity
					return (entidad.nombres.toLowerCase().indexOf(searchTerm.toLowerCase()) > -1)
			}
			enableHiding: false, cellTemplate: '<div class="ui-grid-cell-contents" style="padding: 0px;" ' + appendPopover + '><img ng-src="{{grid.appScope.perfilPath + row.entity.foto_nombre}}" style="width: 35px" />{{row.entity.nombres}}</div>' }
			{ field: 'apellidos', minWidth: 80, filter: { condition: uiGridConstants.filter.CONTAINS }}
			{ field: 'sexo', displayName: 'Sex', width: 40 }
			{ field: 'grupo_id', displayName: 'Matrícula', cellTemplate: btMatrCom, minWidth: 230, enableFiltering: false }
			{ field: 'fecha_matricula', displayName: 'Fecha matrícula', cellFilter: "date:mediumDate", type: 'date', minWidth: 100 }
			{ field: 'no_matricula', displayName: '# matrícula', minWidth: 80, enableColumnMenu: true }
			{ field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date', minWidth: 100}
		],
		multiSelect: true,


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
			row.tipo_doc = oldValue
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.matricularUno = (row, recargar)->
		if not $scope.dato.grupo.id
			toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return

		datos = { alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id, year_id: $scope.dato.grupo.year_id }

		$http.post('::matriculas/matricularuno', datos).then((r)->
			r = r.data
			row.matricula_id 			= r.id
			row.grupo_id 				= r.grupo_id
			row.estado 					= 'MATR'
			row.fecha_matricula_ant 	= r.fecha_matricula.date
			row.fecha_matricula 		= new Date(r.fecha_matricula.date)
			toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			if recargar
				$scope.traerAlumnnosConGradosAnterior()
			return row
		, (r2)->
			toastr.error 'No se pudo matricular el alumno.', 'Error'

		)

	$scope.cambiaEpsCheck = (texto)->
		$scope.verificandoEps = true
		return $http.put('::alumnos/eps-check', {texto: texto}).then((r)->
			$scope.eps_match 		= r.data.eps
			$scope.verificandoEps 	= false
			return $scope.eps_match.map((item)->
				return item.eps
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
				USER: ()->
					$scope.USER
		})
		modalInstance.result.then( (alum)->
			console.log 'Cierra'
			$scope.traerAlumnnosConGradosAnterior()
		)



	$scope.setAsistente = (fila)->

		$http.put('::matriculas/set-asistente', {matricula_id: fila.matricula_id, grupo_id: $scope.dato.grupo.grupo_id}).then((r)->
			toastr.success 'Guardado como asistente'
		, (r2)->
			toastr.error 'No se pudo guardar como asistente', 'Error'
		)


	$scope.setPrematriculado = (fila)->

		$http.put('::matriculas/prematricular', {alumno_id: fila.alumno_id, grupo_id: $scope.dato.grupo.id}).then((r)->
			console.log 'Cambios guardados'
			$scope.traerAlumnnosConGradosAnterior()
		, (r2)->
			toastr.error 'No se pudo crear asistente', 'Error'
		)


	$scope.setNewAsistente = (fila)->

		$http.put('::matriculas/set-new-asistente', {alumno_id: fila.alumno_id, grupo_id: $scope.dato.grupo.id}).then((r)->
			console.log 'Cambios guardados'
			$scope.traerAlumnnosConGradosAnterior()
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



	$scope.buscar_por = (campo)->

		if $scope.texto_a_buscar == ""
			toastr.warning 'Escriba término a buscar'
			return

		$http.put('::buscar/por-'+campo, {texto_a_buscar: $scope.texto_a_buscar }).then((r)->
			$scope.alumnos_encontrados = r.data
		, (r2)->
			toastr.error 'No se pudo buscar', 'Problema'
		)






	$scope.exportarAlumnos = ()->
		DownloadServ.download('::simat/alumnos-exportar', 'Alumnos a importar '+$scope.USER.year+'.xls')


	$scope.importarSimat = (file, errFiles)->
		$scope.f = file;
		$scope.errFile = errFiles && errFiles[0];
		if (file)
			file.upload = Upload.upload({
					url: App.Server + 'importar/algo/'+$scope.USER.year,
					data: {file: file}
			});

			file.upload.then( (response)->
					$timeout( ()->
							file.result = response.data;
					);
			,  (response)->
					if (response.status > 0)
							$scope.errorMsg = response.status + ': ' + response.data;
			, (evt)->
					file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total));
			);








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
