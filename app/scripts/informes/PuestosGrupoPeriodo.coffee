angular.module("myvcFrontApp")

.controller('PuestosGrupoPeriodoCtrl', ['$scope', 'App', '$rootScope', '$state', 'alumnos', 'escalas', 'Restangular', '$modal', '$filter', 'AuthService', '$cookieStore', ($scope, App, $rootScope, $state, alumnos, escalas, Restangular, $modal, $filter, AuthService, $cookieStore)->
	
	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	#$scope.alumnos = $filter('orderBy')($scope.alumnos, '-promedio')

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	#$scope.config.orientacion = $scope.orientacion
	#$scope.config.mostrar_foto = $scope.mostrar_foto

	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'

])