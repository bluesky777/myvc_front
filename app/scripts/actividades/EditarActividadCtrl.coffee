'use strict'

angular.module("myvcFrontApp")

.controller('EditarActividadCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', '$stateParams', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, $stateParams)->

	AuthService.verificar_acceso()

	$scope.actividad_id 		= $stateParams.actividad_id

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	
	$scope.matricularUno = (row)->
		$http.post('::matriculas/matricularuno', {alumno_id: datos.alumno_id, grupo_id: datos.grupo_id, year_id: $scope.USER.year_id}).then((r)->
			r = r.data
			
			$scope.toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			return row
		, (r2)->
			$scope.toastr.error 'No se pudo matricular el alumno.', 'Error'
		)




	return
])


