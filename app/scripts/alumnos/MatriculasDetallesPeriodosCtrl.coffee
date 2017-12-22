'use strict'

angular.module("myvcFrontApp")

.directive('matriculasDetallesPeriodosDir',[()-> 

	restrict: 'E'
	templateUrl: "==alumnos/matriculasDetallesPeriodos.tpl.html"
	controller: 'MatriculasDetallesPeriodosCtrl'
])


.controller('MatriculasDetallesPeriodosCtrl', ['$scope', 'App', '$rootScope', '$state', '$interval', 'uiGridConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $rootScope, $state, $interval, uiGridConstants, $modal, $filter, AuthService, toastr, $http)->



	$scope.eliminarNotasPeriodo = (periodo, grupo)->

		res = confirm('¿Está seguro? estas notas no se podrán recuperar si las borra.')
		if res 
			$http.put('::detalles/eliminar-notas-periodo', {alumno_id: parseInt($state.params.alumno_id), grupo_id: grupo.id, periodo_id: periodo.id}).then((r)->
				
				if parseInt(r.data) == 0
					toastr.warning 'No se eliminó ninguna nota'
				else 
					toastr.success 'Notas eliminadas: ' + r.data
			, (r2)->
				toastr.error 'No se pudo eliminar las notas', 'Error'
			)
	


	$scope.eliminarMatriculaDestroy = (matriculas_year_grupo, matricula_id)->
		res = false

		if matriculas_year_grupo.length == 1
			res = confirm('Solo queda esta matricula para este grupo, ¿Está seguro que quiere eliminarla definitivamente?')
		else 	
			res = confirm('¿Está seguro que quiere eliminar la matricula ' + matricula_id + ' definitivamente?')

		if res 
			
			$http.put('::detalles/eliminar-matricula-destroy', {matricula_id: matricula_id}).then((r)->
				
				if parseInt(r.data) == 0
					toastr.warning 'No se eliminó matricula'
				else 
					toastr.success 'Matricula ' + matricula_id + ' eliminada.'
					$scope.matriculas 			= $filter('filter')($scope.matriculas, {matricula_id: '!'+matricula_id})
					matriculas_year_grupo 		= $filter('filter')(matriculas_year_grupo, {matricula_id: '!'+matricula_id})
			, (r2)->
				toastr.error 'No se pudo eliminar la matricula ' + matricula_id, 'Error'
			)



	return
])
