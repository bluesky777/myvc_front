'use strict'

angular.module("myvcFrontApp")

.controller('MatriculasCtrl', ['$scope', 'App', '$state', '$interval', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $state, $interval, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()

	$scope.dato = {
		sortMatricula: 			false
		sortMatriculaReverse: 	false
		sortNombres: 			false
		sortNombresReverse: 	false
		sortType: 				'apellidos'
		sortReverse: 			false
	}
	$scope.dato_f = {
		sortMatricula: 			false
		sortMatriculaReverse: 	false
		sortNombres: 			false
		sortNombresReverse: 	false
		sortType: 				'apellidos'
		sortReverse: 			false
	}

	$scope.alumnos_encontrados 	= []
	$scope.texto_a_buscar		= ""

	$scope.year_ant 				= $scope.USER.year - 1
	$scope.perfilPath 				= App.images+'perfil/'
	$scope.views 					= App.views

	$scope.alumnos_all 				= []


	$scope.dato.grupo = ''
	$http.get('::grupos').then((r)->

		matr_grupo = 0

		if localStorage.matr_grupo
			matr_grupo = parseInt(localStorage.matr_grupo)

		$scope.grupos = r.data

		for grupo in $scope.grupos
			if grupo.id == matr_grupo
				$scope.dato.grupo = grupo

		$scope.traerAlumnos($scope.dato.grupo)

	)

	$scope.editar = (row)->
		$state.go('panel.alumnos.editar', {alumno_id: row.alumno_id})


	$scope.onGrupoSelect = ($item, $model)->
		if not $item
			return

		localStorage.setItem('matr_grupo', $item.id)
		$scope.traerAlumnos($item)


	$scope.traerAlumnos = (item)->
		grupos_ant = []

		for grupo in $scope.grupos
			if grupo.orden_grado == (item.orden_grado - 1)
				grupos_ant.push grupo


		# Quería mandar los grupos anteriores, pero solo voy a mandar el grado_id
		if grupos_ant.length > 0
			grado_ant_id 	= grupos_ant[0].grado_id
		else
			grado_ant_id 	= null

		$http.put("::matriculas/alumnos-grado-anterior", {grupo_actual: item, grado_ant_id: grado_ant_id, year_ant: $scope.year_ant}).then((r)->
			$scope.alumnos_all = r.data

			for alumno in $scope.alumnos_all
				#console.log alumno.fecha_retiro, new Date(alumno.fecha_retiro.replace( /(\d{2})-(\d{2})-(\d{4})/, "$2/$1/$3"))
				alumno.estado_ant 			= alumno.estado
				alumno.fecha_retiro_ant 	= alumno.fecha_retiro
				alumno.fecha_retiro 		= new Date(alumno.fecha_retiro)
				alumno.fecha_matricula_ant 	= alumno.fecha_matricula
				alumno.fecha_matricula 		= new Date(alumno.fecha_matricula)
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
			toastr.success 'Fecha matricula guardada'
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




	$scope.buscar_por_nombre = ()->

		if $scope.texto_a_buscar == ""
			toastr.warning 'Escriba término a buscar'
			return

		$http.put('::buscar/por-nombre', {texto_a_buscar: $scope.texto_a_buscar }).then((r)->
			$scope.alumnos_encontrados = r.data
		, (r2)->
			toastr.error 'No se pudo buscar', 'Problema'
		)


	$scope.filterActuales = (item)->
		return item.grupo_id == $scope.dato.grupo.id

	$scope.filterNOActuales = (item)->
		return item.grupo_id != $scope.dato.grupo.id


	return
])


.controller('MatricularEnCtrl', ['$scope', '$uibModalInstance', 'alumno', 'grupos', 'USER', '$http', 'toastr', '$state', ($scope, $modalInstance, alumno, grupos, USER, $http, toastr, $state)->
	$scope.alumno = alumno
	$scope.grupos = grupos
	$scope.$state = $state
	$scope.USER   = USER
	$scope.dato = {}


	if localStorage.matr_grupo
		matr_grupo = parseInt(localStorage.matr_grupo)

	for grupo in $scope.grupos
		if grupo.id == matr_grupo
			$scope.dato.grupo = grupo


	$scope.ok = ()->
		if not $scope.dato.grupo.id
			toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return

		datos = { alumno_id: $scope.alumno.alumno_id, grupo_id: $scope.dato.grupo.id, year_id: $scope.USER.year_id }

		$http.post('::matriculas/matricular-en', datos).then((r)->
			r = r.data
			if r == 'Ya matriculado'
				toastr.warning 'Ya tiene matrícula en ese grupo'
				return

			$scope.alumno.matricula_id = r.id
			$scope.alumno.grupo_id = r.grupo_id
			toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			$modalInstance.close($scope.alumno)
		, (r2)->
			toastr.error 'No se pudo matricular el alumno.', 'Error'

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
			$modalInstance.close($scope.alumno)
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
			$modalInstance.close($scope.alumno)
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
			$modalInstance.close($scope.alumno)
		, (r2)->
			fila.egresado = !fila.egresado
			toastr.error 'Cambio no guardado', 'Error'
		)


	$scope.toggleActive = (fila)->
		fila.is_active = !fila.is_active
		if not fila.alumno_id
			fila.alumno_id = fila.id

		datos =
			alumno_id: 	fila.alumno_id
			user_id:    fila.user_id
			propiedad: 	'is_active'
			valor:      fila.is_active

		$http.put('::alumnos/guardar-valor', datos).then((r)->
			console.log 'Cambios guardados'
			$modalInstance.close($scope.alumno)
		, (r2)->
			fila.is_active = !fila.is_active
			toastr.error 'Cambio no guardado', 'Error'
		)




	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])



