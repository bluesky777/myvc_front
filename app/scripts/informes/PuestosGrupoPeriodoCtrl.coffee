angular.module("myvcFrontApp")

.controller('PuestosGrupoPeriodoCtrl', ['$scope', '$state', 'alumnosDat', 'escalas', '$cookieStore', ($scope, $state, alumnosDat, escalas, $cookieStore)->
	alumnosDat = alumnosDat.data

	$scope.grupo = alumnosDat[0]
	$scope.year = alumnosDat[1]
	$scope.alumnos = alumnosDat[2]

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	#$scope.config.orientacion = $scope.orientacion
	#$scope.config.mostrar_foto = $scope.mostrar_foto

	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'

])