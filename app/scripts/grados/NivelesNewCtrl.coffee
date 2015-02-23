'use strict'

angular.module("myvcFrontApp")

.controller('NivelesNewCtrl', ['$scope', '$rootScope', '$interval', 'Restangular', 'RNiveles', 'RPaises', 'RCiudades', ($scope, $rootScope, $interval, Restangular, RNiveles, RPaises, RCiudades)->

	$scope.nivel = {
		'orden': 0
	}

	$scope.restarOrden = ()->
		if $scope.nivel.orden > 0
			$scope.nivel.orden = $scope.nivel.orden - 1
	$scope.sumarOrden = ()->
		if $scope.nivel.orden < 40
			$scope.nivel.orden = $scope.nivel.orden + 1

	$scope.crear = ()->
		RNiveles.post($scope.nivel).then((r)->
			console.log 'Se hizo el post del nivel', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	return
])
