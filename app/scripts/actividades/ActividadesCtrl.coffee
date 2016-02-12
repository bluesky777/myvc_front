'use strict'

angular.module("myvcFrontApp")

.controller('ActividadesCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'RAlumnos', 'Restangular', 'uiGridConstants', 'GruposServ', '$modal', '$filter', 'AuthService', ($scope, App, $rootScope, $state, $interval, RAlumnos, Restangular, uiGridConstants, GruposServ, $modal, $filter, AuthService)->

	AuthService.verificar_acceso()

	
	$rootScope.menucompacto = true


	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.alumnos.editar', {alumno_id: row.alumno_id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row

		modalInstance = $modal.open({
			templateUrl: App.views + 'alumnos/removeAlumno.tpl.html'
			controller: 'RemoveAlumnoCtrl'
			resolve: 
				alumno: ()->
					row
		})
		modalInstance.result.then( (alum)->
			$scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
			console.log 'Resultado del modal: ', alum
		)

	$scope.matricularUno = (row)->
		if not $scope.dato.grupo.id
			$scope.toastr.warning 'Debes definir el grupo al que vas a matricular.', 'Falta grupo'
			return
		
		datos = {alumno_id: row.alumno_id, grupo_id: $scope.dato.grupo.id}
		

		Restangular.all('matriculas/matricularuno/'+datos.alumno_id+'/'+datos.grupo_id).post().then((r)->
			console.log 'Matriculado. ', r
			row.matricula_id = r.id
			row.grupo_id = r.grupo_id
			row.nombregrupo = $scope.dato.grupo.nombre
			row.abrevgrupo = $scope.dato.grupo.abrev
			row.actual = 1
			$scope.toastr.success 'Alumno matriculado con éxito', 'Matriculado'
			return row
		, (r2)->
			console.log 'Falla al matricularlo. ', r2
			$scope.toastr.error 'No se pudo matricular el alumno.', 'Error'

		)




	return
])

.controller('RemoveAlumnoCtrl', ['$scope', '$modalInstance', 'alumno', 'Restangular', 'toastr', ($scope, $modalInstance, alumno, Restangular, toastr)->
	$scope.alumno = alumno

	$scope.ok = ()->

		Restangular.all('alumnos/destroy/'+alumno.alumno_id).remove().then((r)->
			toastr.success 'Alumno eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al alumno.', 'Problema'
			console.log 'Error eliminando alumno: ', r2
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

