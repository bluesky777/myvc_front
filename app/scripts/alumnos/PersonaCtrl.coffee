'use strict'

angular.module("myvcFrontApp")


.directive('personaBasicoDir',['App', (App)->
	restrict: 'E'
	templateUrl: "#{App.views}alumnos/personaBasicoDir.tpl.html"
])
.directive('personaMatriculasDir',['App', (App)->
	restrict: 'E'
	templateUrl: "#{App.views}alumnos/personaMatriculasDir.tpl.html"
])
.directive('personaDatosExtrasDir',['App', (App)->
	restrict: 'E'
	templateUrl: "#{App.views}alumnos/personaDatosExtrasDir.tpl.html"
])
.directive('personaEnfermeriaDir',['App', (App)->
	restrict: 'E'
	templateUrl: "#{App.views}alumnos/personaEnfermeriaDir.tpl.html"
])


.controller('PersonaCtrl', ['$scope', '$state', '$http', 'toastr', '$uibModal', 'App', '$rootScope', '$timeout', 'AuthService', ($scope, $state, $http, toastr, $modal, App, $rootScope, $timeout, AuthService)->
	$scope.data                 = {} # Para el popup del Datapicker
	$scope.alumno               = {}
	$scope.religiones           = App.religiones
	$scope.tipos_sangre         = App.tipos_sangre
	$scope.dato 					      = {}
	$scope.hasRoleOrPerm        = AuthService.hasRoleOrPerm
	$scope.enfermedia_cargada   = false
	$scope.opciones_programar   = App.opciones_programar
	$scope.sangres              = App.sangres
	$scope.mostrar_mas          = false
	$scope.mostrar_compromisos  = false
	$scope.mostrar_prematricula = false
	$scope.new_suceso           = {
		fecha_suceso:   new Date()
		signo_fc:       60
		signo_fr:       12
		signo_t:        35.5
	}

	$scope.gridScope = $scope # Para getExternalScopes de ui-Grid



	if localStorage.mostrar_mas_deta_alum
		$scope.mostrar_mas = if localStorage.mostrar_mas_deta_alum == 'true' then true else false

	if localStorage.mostrar_compromisos
		$scope.mostrar_compromisos = if localStorage.mostrar_compromisos == 'true' then true else false

	if localStorage.mostrar_prematricula
		$scope.mostrar_prematricula = if localStorage.mostrar_prematricula == 'true' then true else false



	if $state.params.tipo == 'alumno'

		$http.put('::alumnos/show', { id: $state.params.persona_id, con_grupos: true }).then (r)->

			$scope.grupos 				      = r.data.grupos
			$scope.grupos_siguientes 		= r.data.grupos_siguientes
			$scope.tipos_doc 				    = r.data.tipos_doc
			$scope.alumno 				      = r.data.alumno
			$scope.matriculas 				  = r.data.matriculas
			$scope.alum_copy            = angular.copy($scope.alumno)


			$scope.alumno.next_year.estado_ant = $scope.alumno.next_year.estado
			$scope.alumno.ciudad_nac_id = $scope.alumno.ciudad_nac
			$scope.alumno.ciudad_doc_id = $scope.alumno.ciudad_doc

			$scope.alumno.fecha_retiro      = if $scope.alumno.fecha_retiro     then new Date($scope.alumno.fecha_retiro.replace(/-/g, '\/')) else $scope.alumno.fecha_retiro
			$scope.alumno.fecha_matricula   = if $scope.alumno.fecha_matricula  then new Date($scope.alumno.fecha_matricula.replace(/-/g, '\/')) else $scope.alumno.fecha_matricula
			$scope.alumno.fecha_nac         = if $scope.alumno.fecha_nac        then new Date($scope.alumno.fecha_nac.replace(/-/g, '\/')) else $scope.alumno.fecha_nac

			$scope.alumno.llevo_formulario 	= if $scope.alumno.llevo_formulario then new Date($scope.alumno.llevo_formulario) else $scope.alumno.llevo_formulario
			$scope.alumno.llevo_formulario_bool 	= if $scope.alumno.llevo_formulario then 'Si' else 'No'


			$scope.cant_compromisos = 0;

			for opcion in $scope.opciones_programar
				if $scope.alumno.programar == opcion.opcion
					$scope.dato.programar = opcion
					$scope.cant_compromisos++

				if $scope.alumno.efectuar_una == opcion.opcion
					$scope.dato.efectuar_una = opcion
					$scope.cant_compromisos++

				if $scope.alumno.next_year.programar == opcion.opcion
					$scope.dato.programar_next = opcion

				if $scope.alumno.next_year.efectuar_una == opcion.opcion
					$scope.dato.efectuar_una_next = opcion


			if $scope.alumno.next_year
				$scope.alumno.next_year.prematriculado = if $scope.alumno.next_year.prematriculado then new Date($scope.alumno.next_year.prematriculado.replace(/-/g, '\/')) else $scope.alumno.next_year.prematriculado
				$scope.alumno.next_year.fecha_matricula = if $scope.alumno.next_year.fecha_matricula then new Date($scope.alumno.next_year.fecha_matricula.replace(/-/g, '\/')) else $scope.alumno.next_year.fecha_matricula

				for grup in $scope.grupos_siguientes
					if grup.id == $scope.alumno.next_year.grupo_id
						$scope.dato.grupo_prematr = grup

			if $scope.alumno.ciudad_nac == null
				$scope.alumno.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
				$scope.paisNacSelect($scope.alumno.pais_nac, $scope.alumno.pais_nac)
			else
				$http.get('::ciudades/datosciudad/'+$scope.alumno.ciudad_nac).then (r2)->
					r2 = r2.data
					$scope.paises 									= r2.paises
					$scope.departamentosNac 				= r2.departamentos
					$scope.ciudadesNac 							= r2.ciudades
					$scope.alumno.pais_nac 					= r2.pais
					$scope.alumno.departamento_nac 	= r2.departamento
					$scope.alumno.ciudad_nac 				= r2.ciudad

			if $scope.alumno.ciudad_doc > 0
				$http.get('::ciudades/datosciudad/'+$scope.alumno.ciudad_doc).then (r2)->
					r2 = r2.data
					$scope.paises 									= r2.paises
					$scope.departamentos 						= r2.departamentos
					$scope.ciudades 								= r2.ciudades
					$scope.alumno.pais_doc 					= r2.pais
					$scope.alumno.departamento_doc 	= r2.departamento
					$scope.alumno.ciudad_doc 				= r2.ciudad
			else
				$scope.alumno.pais_doc = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
				$scope.paisSeleccionado($scope.alumno.pais_doc, $scope.alumno.pais_doc)

			if $scope.alumno.ciudad_resid > 0
				$http.get('::ciudades/datosciudad/'+$scope.alumno.ciudad_resid).then (r2)->
					r2 = r2.data
					$scope.paises 									= r2.paises
					$scope.departamentosResid 			= r2.departamentos
					$scope.ciudadesResid 						= r2.ciudades
					$scope.alumno.pais_resid 				= r2.pais
					$scope.alumno.departamento_resid = r2.departamento
					$scope.alumno.ciudad_resid 			= r2.ciudad
			else
				$scope.alumno.pais_resid = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
				$scope.paisResidSeleccionado($scope.alumno.pais_resid, $scope.alumno.pais_resid)


			if $scope.alumno.tipo_doc
				for tipo_doc in $scope.tipos_doc
					if tipo_doc.id == $scope.alumno.tipo_doc
						$scope.alumno.tipo_doc = tipo_doc



	$scope.mostarMasDetalle = ()->
		$scope.mostrar_mas = !$scope.mostrar_mas
		localStorage.mostrar_mas_deta_alum = $scope.mostrar_mas


	$scope.toggleNuevoRepite = (fila, campo)->
		#fila.nuevo = !fila.nuevo

		datos =
			alumno_id: 	    fila.alumno_id
			propiedad: 	    campo
			valor: 		      fila.nuevo
			year_id: 				fila.next_year.year_id

		$http.put('::alumnos/guardar-valor', datos).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			fila.nuevo = !fila.nuevo
			toastr.error 'Cambio no guardado', 'Error'
		)



	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	#btGrid2 = ''
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	bt2 	= '<span style="padding-left: 2px; padding-top: 4px;" class="btn-group">' + btGrid1 + btGrid2 + '</span>'
	btMatricular = "==directives/botonesMatricularMas.tpl.html"
	btEditReligion = "==alumnos/botonEditReligion.tpl.html"
	btPazysalvo = "==directives/botonPazysalvo.tpl.html"
	btIsNuevo = "==directives/botonIsNuevo.tpl.html"
	btIsRepitente = "==directives/botonIsRepitente.tpl.html"
	btIsEgresado = "==directives/botonIsEgresado.tpl.html"
	btIsActive = "==directives/botonIsActive.tpl.html"
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
	gridFooterCartera = "==alumnos/gridFooterCartera.tpl.html"


	$scope.gridOptions =
		showGridFooter: true,
		showColumnFooter: true,
		showFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enableGridMenu: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,
		columnDefs: [
			{ field: 'no', pinnedLeft:true, cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row) + 1}}</div>', width: 40, enableCellEdit: false }
			{ name: 'edicion', displayName:'Edit', width: 54, enableSorting: false, enableFiltering: false, cellTemplate: bt2, enableCellEdit: false, enableColumnMenu: true}
			{ field: 'sexo', displayName: 'Sex', width: 40 }
			{ field: 'grupo_id', displayName: 'Matrícula', enableCellEdit: false, cellTemplate: btMatricular, minWidth: 230, enableFiltering: false }
			{ field: 'fecha_matricula', displayName: 'Fecha matrícula', cellFilter: "date:mediumDate", type: 'date', minWidth: 100 }
			{ field: 'no_matricula', displayName: '# matrícula', minWidth: 80, enableColumnMenu: true }
			{ field: 'pazysalvo', displayName: 'A paz?', cellTemplate: btPazysalvo, minWidth: 60, enableCellEdit: false }
			{ field: 'nuevo', displayName: 'Nuevo?', cellTemplate: btIsNuevo, minWidth: 60, enableCellEdit: false }
			{ field: 'repitente', displayName: 'Repitente?', cellTemplate: btIsRepitente, minWidth: 60, enableCellEdit: false }
			{ field: 'egresado', displayName: 'Egresado?', cellTemplate: btIsEgresado, minWidth: 60, enableCellEdit: false }
			{ field: 'is_active', displayName: 'Activo?', cellTemplate: btIsActive, minWidth: 60, enableCellEdit: false }
			{ field: 'religion', displayName: 'Religión', minWidth: 70, editableCellTemplate: btEditReligion }
			{ field: 'tipo_doc', displayName: 'Tipo documento', minWidth: 120, cellTemplate: btTipoDoc, enableCellEdit: false }
			{ field: 'documento', minWidth: 100, cellFilter: 'formatNumberDocumento' }
			{ field: 'ciudad_doc', displayName: 'Ciud Docu', minWidth: 120, cellTemplate: btCiudadDoc, enableCellEdit: false }
			{ field: 'estrato', minWidth: 70, type: 'number' }
			{ field: 'fecha_nac', displayName:'Nacimiento', cellFilter: "date:mediumDate", type: 'date', minWidth: 100}
		],
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

				if newValue != oldValue
					if colDef.field == "sexo"
						newValue = newValue.toUpperCase()
						if !(newValue == 'M' or newValue == 'F')
							toastr.warning 'Debe usar M o F'
							rowEntity.sexo = oldValue
							return


					$http.put('::enfermeria/guardar-valor', {alumno_id: rowEntity.alumno_id, propiedad: colDef.field, valor: newValue, user_id: user_id_temp } ).then((r)->
						toastr.success 'Alumno(a) actualizado con éxito'
					, (r2)->
						rowEntity[colDef.field] = oldValue
						toastr.error 'Cambio no guardado', 'Error'
					)
				$scope.$apply()
			)



	$scope.crear_alumno = ()->
		$rootScope.grupos_siguientes = $scope.grupos_siguientes
		$state.go('panel.persona.nuevo')


	$scope.crear_suceso = ()->
		$scope.creando_suceso = true

	$scope.cargarEnfermeria = ()->
		$http.put('::enfermeria/datos', {alumno_id: $scope.alumno.alumno_id}).then((r)->

			for sangre in $scope.sangres
				if $scope.alumno.tipo_sangre == sangre.sangre
					$scope.dato.tipo_sangre = sangre

			for regi in r.data.registros_enfermeria
				regi.fecha_suceso = new Date(regi.fecha_suceso)

			$scope.enfermeria 					= r.data.antecedentes
			$scope.gridOptions.data 		= r.data.registros_enfermeria
			$scope.enfermedia_cargada 	= true
		)

	$scope.guardar_nuevo_suceso = (new_suceso)->
		console.log(new_suceso)
		$scope.guardando_suceso = true
		$http.put('::enfermeria/datos', {alumno_id: $scope.alumno.alumno_id}).then((r)->
			$scope.guardando_suceso = false
		, ()->
			toastr.error('Error creando suceso')
			$scope.guardando_suceso = false
		)


	$http.get('::paises').then((r)->
		$scope.paises = r.data
	)


	$scope.toggleMostrarCompromisos = ()->
		$scope.mostrar_compromisos          = !$scope.mostrar_compromisos
		localStorage.mostrar_compromisos    = $scope.mostrar_compromisos
		# Debería traer datos disciplinarios...


	$scope.toggleMostrarPrematricula = ()->
		$scope.mostrar_prematricula         = !$scope.mostrar_prematricula
		localStorage.mostrar_prematricula   = $scope.mostrar_prematricula
		# Debería traer datos disciplinarios...


	$scope.religionSelected = (row, evento)->
		if $scope.religiones.indexOf(row.religion) > -1
			$scope.guardarValor(row, 'religion', row.religion)


	$scope.llevo_formulario = (alumno)->

		datos = {
			alumno_id: alumno.alumno_id,
			llevo_formulario: null,
			year: $scope.USER.year+1
		}

		if !alumno.llevo_formulario
			datos.llevo_formulario = new Date()

		$http.put('::prematriculas/llevo-formulario', datos).then((r)->
			toastr.success('Dato guardado')
			if alumno.llevo_formulario
				alumno.llevo_formulario_bool  = 'No'
				alumno.llevo_formulario       = null
			else
				alumno.llevo_formulario_bool = 'Si'
				alumno.llevo_formulario       = datos.llevo_formulario

		, ()->
			toastr.error('Error cambiando si llevó formulario')
		)



	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data

			if typeof $scope.alumno.pais_doc is 'undefined'
				$scope.alumno.pais_doc = $item
				$scope.paisSeleccionado($item)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.alumno.departamento_doc is 'undefined'
				$scope.alumno.departamento_doc = $item
				$scope.departSeleccionado($item)
		)

	$scope.paisSeleccionado = ($item, $model)->

		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data
		)

	$scope.departSeleccionado = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)


	$scope.paisResidSelecionado = ($item, $model)->

		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosResid = r.data
		)

	$scope.departResidSeleccionado = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesResid = r.data
		)

	$scope.ciudadSeleccionada = ($item, campo)->
		$scope.guardarValor($scope.alumno, campo, $item.id)

	$scope.dateOptions =
		formatYear: 'yyyy'


	$scope.restarEstrato = ()->
		if $scope.alumno.estrato > 0
			$scope.alumno.estrato = $scope.alumno.estrato - 1
	$scope.sumarEstrato = ()->
		if $scope.alumno.estrato < 10
			$scope.alumno.estrato = parseInt($scope.alumno.estrato) + 1




	$scope.cambiarGrupo = ()->
		if $scope.USER.tipo == 'Acudiente' or $scope.USER.tipo == 'Alumno'
			return

		modalInstance = $modal.open({
			templateUrl: '==alumnos/matricularEn.tpl.html'
			controller: 'MatricularEnCtrl'
			resolve:
				alumno: ()->
					$scope.alumno
				grupos: ()->
					$scope.grupos
				USER: ()->
					$scope.USER
		})
		modalInstance.result.then( (alum)->

			for grupo in $scope.grupos
				if grupo.id == alum.grupo_id
					$scope.alumno.grupo_nombre  = grupo.nombre
					$scope.alumno.grupo_id      = grupo.id
		)




	$scope.persona_buscar 		= ''
	$scope.templateTypeahead  = '==alumnos/personaTemplateTypeahead.tpl.html'

	$scope.personaCheck = (texto)->
		$scope.verificandoPersona = true
		return $http.put('::alumnos/personas-check', {texto: texto, todos_anios: $scope.dato.todos_anios }).then((r)->
			$scope.personas_match 		= r.data.personas
			$scope.personas_match.map((perso)->
				perso.perfilPath = $scope.perfilPath
			)
			$scope.verificandoPersona 	= false
			return $scope.personas_match
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


	$scope.ir_a_persona = ($item, $model, $label)->
		datos = { persona_id: $item.alumno_id, tipo: $item.tipo }
		$state.go 'panel.persona', datos


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
			row.tipo_doc = oldValue
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.matricularUno = (row, recargar)->
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
			if recargar
				$scope.traerAlumnnosConGradosAnterior()
			return row
		, (r2)->
			toastr.error 'No se pudo. Tal vez no tienes permiso.', 'Error'

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

		datos = { matricula_id: row.matricula_id }

		$http.put('::matriculas/re-matricularuno', datos).then((r)->
			r = r.data
			toastr.success 'Alumno rematriculado', 'Matriculado'
			return row
		, (r2)->
			toastr.error 'No se pudo. Tal vez no tienes permiso.', 'Error'

		)


	$scope.setAsistente = (fila)->

		$http.put('::matriculas/set-asistente', {matricula_id: fila.matricula_id, grupo_id: $scope.alumno.grupo_id}).then((r)->
			toastr.success 'Guardado como asistente'
		, (r2)->
			toastr.error 'No se pudo. Tal vez no tienes permiso.', 'Error'
		)



	$scope.cambiarFechaRetiro = (row)->

		$http.put('::matriculas/cambiar-fecha-retiro', { matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Fecha retiro guardada'
		, (r2)->
			row.fecha_retiro = row.fecha_retiro_ant
			toastr.error 'No se pudo. Tal vez no tienes permiso.', 'Error'
		)


	$scope.cambiarFechaMatricula = (row)->

		$http.put('::matriculas/cambiar-fecha-matricula', { matricula_id: row.matricula_id, fecha_matricula: row.fecha_matricula }).then((r)->
			toastr.success 'Fecha matrícula guardada'
		, (r2)->
			row.fecha_matricula = row.fecha_matricula_ant
			toastr.error 'No se pudo. Tal vez no tienes permiso.', 'Error'
		)





	$scope.desertar = (row)->
		fecha = row.fecha_retiro
		if row.fecha_retiro_ant == null
			fecha 				= new Date()
			row.fecha_retiro 	= fecha

		$http.put('::matriculas/desertar', {matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Alumno desertado'
		, (r2)->
			toastr.error 'No se pudo desertar. Tal vez no tienes permiso.', 'Problema'
		)




	$scope.retirar = (row)->
		fecha = row.fecha_retiro
		if row.fecha_retiro_ant == null
			fecha 				= new Date()
			row.fecha_retiro 	= fecha

		$http.put('::matriculas/retirar', {matricula_id: row.matricula_id, fecha_retiro: row.fecha_retiro }).then((r)->
			toastr.success 'Alumno retirado'
		, (r2)->
			toastr.error 'No se pudo desmatricular. Tal vez no tienes permiso.', 'Problema'
		)



	# ya es inutil
	$scope.prematricular = (row)->

		if $scope.prematriculando
			return

		if !$scope.dato.grupo_prematr
			toastr.warning 'Debe seleccionar el grupo'
			return

		$scope.prematriculando = true

		datos = {
			matricula_id: 	row.next_year.matricula_id,
			alumno_id: 			row.alumno_id,
			grupo_id: 			$scope.dato.grupo_prematr.id,
			year_id: 				row.next_year.year_id
		}

		$http.put('::matriculas/prematricular', datos).then((r)->
			toastr.success 'Alumno prematriculado'
			$scope.prematriculando    = false
			r.data.matricula.prematriculado = new Date(r.data.matricula.prematriculado.replace(/-/g, '\/'))
			$scope.alumno.next_year   = r.data.matricula
			$timeout(()->
				$scope.$apply()
			, 100)
		, (r2)->
			toastr.error 'Tal vez no existe el ' + ($scope.USER.year+1), 'Problema'
			$scope.prematriculando = false
		)




	$scope.cambiaUsernameCheck = (texto)->
		$scope.username_cambiado = true
		$scope.verificandoUsername = true
		return $http.put('::users/usernames-check', {texto: texto}).then((r)->
			$scope.username_match 		= r.data.usernames
			$scope.verificandoUsername 	= false
			return $scope.username_match.map((item)->
				return item.username
			)
		)

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


	$scope.set_estado_next_matricula = (row)->

		if $scope.matriculando
			return

		if !$scope.dato.grupo_prematr
			toastr.warning 'Debe seleccionar el grupo'
			return

		if row.next_year.estado == 'MATR'
			faltan = 0
			for requisito in $scope.matriculas[0].requisitos
				if requisito.estado == 'falta'
					faltan = faltan+1
			if faltan > 0
				frase = if faltan==1 then faltan+' requisito.' else faltan+' requisitos. '
				res = confirm('A este estudiante aún le falta por cumplir ' + frase + ' ¿Desea matricular de todos modos?')
				if res
					console.log($scope.alumno.next_year.estado, $scope.alumno.next_year.estado_ant)
					$scope.alumno.next_year.estado = $scope.alumno.next_year.estado_ant
				else
					return

		$scope.matriculando = true

		datos = {
			matricula_id: 	row.next_year.matricula_id,
			alumno_id: 			row.alumno_id,
			grupo_id: 			$scope.dato.grupo_prematr.id,
			year_id: 				row.next_year.year_id
			estado: 				row.next_year.estado
		}

		$http.put('::matriculas/prematricular', datos).then((r)->
			toastr.success 'Cambios guardados'
			$scope.matriculando    = false
			r.data.matricula.prematriculado = if r.data.matricula.prematriculado then new Date(r.data.matricula.prematriculado.replace(/-/g, '\/')) else r.data.matricula.prematriculado
			$scope.alumno.next_year   = r.data.matricula
			$scope.alumno.next_year.estado_ant = $scope.alumno.next_year.estado
			$timeout(()->
				$scope.$apply()
			, 100)
		, (r2)->
			toastr.error 'Tal vez no existe el ' + ($scope.USER.year+1), 'Problema'
			$scope.matriculando = false
		)


	#Ya puedo borrar:
	$scope.quitarPrematricula = (row)->

		if $scope.prematriculando
			return

		$scope.prematriculando = true

		datos = {
			matricula_id: 	row.next_year.matricula_id
		}

		$http.put('::matriculas/quitar-prematricula', datos).then((r)->
			toastr.success 'Matrícula quitada'
			$scope.prematriculando = false
			$scope.alumno.next_year = {}
		, (r2)->
			toastr.error 'No se pudo quitar', 'Problema'
			$scope.prematriculando = false
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



	$scope.guardarCambioRequisito = (requisito)->
		#if requisito.estado=='Falta' or requisito.estado=='Ya' or requisito.estado=='N/A'
		$http.post('::requisitos/alumno', requisito ).then((r)->
			toastr.success 'Requisito actualizado'
		, (r2)->
			toastr.error 'Cambio no guardado', 'Error'
		)




	$scope.guardarValor = (rowEntity, colDef, newValue, year_id)->
		datos = {}

		if colDef == 'username'
			if $scope.username_cambiado
				datos.user_id = rowEntity.user_id
			else
				return

		if colDef == 'email'
			datos.user_id = rowEntity.user_id
			if !window.validateEmail(newValue)
				toastr.warning 'No es un correo válido'
				return

		if not rowEntity.alumno_id
			rowEntity.alumno_id = fila.id


		if colDef == "sexo"
			newValue = newValue.toUpperCase()
			if !(newValue == 'M' or newValue == 'F')
				toastr.warning 'Debe usar M o F'
				rowEntity.sexo = $scope.alum_copy['sexo']
				return

		if colDef == "fecha_matricula"
			return $scope.cambiarFechaMatricula(rowEntity)


		if colDef == "tipo_sangre"
			newValue = newValue.toUpperCase()
			if !($scope.tipos_sangre.indexOf(newValue) > -1)
				toastr.warning 'Debe usar: ' + $scope.tipos_sangre.join(' ')
				rowEntity.tipo_sangre = $scope.alum_copy['tipo_sangre']
				return


		if colDef == "estrato"
			if newValue < 0 or newValue > 9
				toastr.warning 'Valor no admitido'
				rowEntity.estrato = $scope.alum_copy['estrato']
				return


		if colDef == "documento"
			if newValue.length != 10 and newValue.length != 0
				toastr.warning 'Debe ser de diez dígitos'
				#rowEntity.documento = oldValue
				return

		datos.alumno_id = rowEntity.alumno_id
		datos.propiedad = colDef
		datos.valor 		= newValue

		if year_id
			datos.year_id = year_id

		$http.put('::alumnos/guardar-valor', datos ).then((r)->
			toastr.success 'Alumno(a) actualizado con éxito'
			if colDef == "tipo_sangre"
				$scope.alumno.tipo_sangre = newValue
		, (r2)->
			rowEntity[colDef] = $scope.alum_copy[colDef]
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.guardarValorEnfermeria = (enferm, propiedad, newValue)->
		datos = {}
		console.log(enferm);
		datos.antec_id    = enferm.id
		datos.propiedad   = propiedad
		datos.valor 		  = newValue


		$http.put('::enfermeria/guardar-valor', datos ).then((r)->
			toastr.success 'Enfermería actualizada'
		, (r2)->
			#rowEntity[colDef] = $scope.alum_copy[colDef]
			toastr.error 'Cambio no guardado', 'Error'
		)


	return
])
