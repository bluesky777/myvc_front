'use strict'

angular.module("myvcFrontApp")

.controller('ActividadesCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', 'uiGridConstants', '$uibModal', '$filter', 'AuthService', ($scope, App, $rootScope, $state, $http, uiGridConstants, $modal, $filter, AuthService)->

	AuthService.verificar_acceso()

	
	$rootScope.menucompacto = true


	$scope.editar = (row)->
		$state.go('panel.alumnos.editar', {alumno_id: row.alumno_id})

	$scope.eliminar = (row)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'alumnos/removeAlumno.tpl.html'
			controller: 'RemoveAlumnoCtrl'
			resolve: 
				alumno: ()->
					row
		})
		modalInstance.result.then( (alum)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
		)

	$scope.matricularUno = (row)->
		if not $scope.dato.grupo.id
			$scope.toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return
		
		datos = {alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id}
		

		$http.post('::matriculas/matricularuno', {alumno_id: datos.alumno_id, grupo_id: datos.grupo_id, year_id: $scope.USER.year_id}).then((r)->
			r = r.data
			row.matricula_id = r.id
			row.grupo_id = r.grupo_id
			row.nombregrupo = $scope.dato.grupo.nombre
			row.abrevgrupo = $scope.dato.grupo.abrev
			row.actual = 1
			$scope.toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			return row
		, (r2)->
			$scope.toastr.error 'No se pudo matricular el alumno.', 'Error'
		)




	return
])


