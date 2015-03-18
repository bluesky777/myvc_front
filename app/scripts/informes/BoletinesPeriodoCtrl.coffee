angular.module("myvcFrontApp")

.controller('BoletinesPeriodoCtrl', ['$scope', 'App', '$rootScope', '$state', 'alumnos', 'escalas', 'Restangular', '$modal', '$filter', 'AuthService', '$cookieStore', ($scope, App, $rootScope, $state, alumnos, escalas, Restangular, $modal, $filter, AuthService, $cookieStore)->
	
	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	$scope.requested_alumnos = $cookieStore.get 'requested_alumnos'
	$scope.requested_alumno = $cookieStore.get 'requested_alumno'

	
	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'



])