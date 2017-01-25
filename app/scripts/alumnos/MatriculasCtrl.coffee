'use strict'

angular.module("myvcFrontApp")

.controller('MatriculasCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'uiGridConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $rootScope, $state, $interval, uiGridConstants, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()

	$scope.dato = {
		sortMatricula: 			false
		sortMatriculaReverse: 	false
		sortNombres: 			false
		sortNombresReverse: 	false
	}

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
			row.matricula_id = r.id
			row.grupo_id = r.grupo_id
			row.estado 	= 'MATR'
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


	$scope.setAsistente = (fila)->
		
		$http.put('::matriculas/set-asistente', {matricula_id: fila.matricula_id, grupo_id: $scope.dato.grupo.grupo_id}).then((r)->
			toastr.success 'Guardado como asistente'
		, (r2)->
			toastr.error 'No se pudo guardar como asistente', 'Error'
		)
		

	$scope.setNewAsistente = (fila)->
		
		$http.put('::matriculas/set-new-asistente', {alumno: fila, grupo: $scope.dato.grupo}).then((r)->
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


	return
])

.controller('RemoveAlumnoCtrl', ['$scope', '$uibModalInstance', 'alumno', '$http', 'toastr', ($scope, $modalInstance, alumno, $http, toastr)->
	$scope.alumno = alumno

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
