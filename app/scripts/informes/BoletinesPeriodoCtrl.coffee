angular.module("myvcFrontApp")

.controller('BoletinesPeriodoCtrl', ['$scope', 'App', '$rootScope', '$state', 'alumnos', 'escalas', 'Restangular', '$modal', '$filter', 'AuthService', ($scope, App, $rootScope, $state, alumnos, escalas, Restangular, $modal, $filter, AuthService)->
	
	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	$scope.escalas = escalas

	$scope.config = {}
	$scope.config.orientacion = $scope.orientacion

])