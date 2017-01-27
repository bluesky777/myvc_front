'use strict'

angular.module("myvcFrontApp")

.controller('MatriculasDetallesCtrl', ['$scope', 'App', '$state', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $state, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()

	$scope.year_ant 				= $scope.USER.year - 1
	$scope.perfilPath 				= App.images+'perfil/'
	$scope.views 					= App.views
	$scope.matricula_detalle 		= false
	$scope.matric_cargando 			= false

	$http.put('::detalles/alumno', { year_id: $scope.USER.year_id, alumno_id: parseInt($state.params.alumno_id) }).then((r)->
		$scope.matriculas = r.data
	)


	$scope.matricSeleccionada = (row)->
		for matric in $scope.matriculas
			if matric.matricula_id == row.matricula_id
				matric.seleccionada = true
			else
				matric.seleccionada = false


		datos = { 
			alumno_id: 		row.alumno_id, 
			year_id: 		row.year_id, 
			matricula_id: 	row.matricula_id
		}

		$scope.matric_cargando 		= true # Para que gire el spinner
		$scope.matricula_detalle 	= false

		$http.put('::detalles/grupos-periodos', datos).then((r)->

			r = r.data
			$scope.matricula_detalle 	= r
			$scope.matric_cargando 		= false

			for matri in $scope.matricula_detalle
				matri.year = row.year


		)



	$scope.setNewAsistente = (fila)->
		
		$http.put('::matriculas/set-new-asistente', {alumno: fila, grupo: $scope.dato.grupo}).then((r)->
			console.log 'Cambios guardados'
		, (r2)->
			toastr.error 'No se pudo crear asistente', 'Error'
		)
		




	return
])

