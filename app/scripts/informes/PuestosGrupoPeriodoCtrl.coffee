angular.module("myvcFrontApp")

.controller('PuestosGrupoPeriodoCtrl', ['$scope', 'App', '$rootScope', '$state', 'alumnosDat', 'escalas', 'Restangular', '$modal', '$filter', 'AuthService', '$cookieStore', ($scope, App, $rootScope, $state, alumnosDat, escalas, Restangular, $modal, $filter, AuthService, $cookieStore)->
	
	$scope.grupo = alumnosDat[0]
	$scope.year = alumnosDat[1]
	$scope.alumnos = alumnosDat[2]

	console.log '$scope.USER.nota_minima_aceptada', $scope.USER.nota_minima_aceptada

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	#$scope.config.orientacion = $scope.orientacion
	#$scope.config.mostrar_foto = $scope.mostrar_foto

	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'

])