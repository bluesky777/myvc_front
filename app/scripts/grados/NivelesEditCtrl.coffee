'use strict'

angular.module("myvcFrontApp")

.controller('NivelesEditCtrl', ['$scope', '$rootScope', '$state', 'Restangular', 'RNiveles', ($scope, $rootScope, $state, Restangular, RNiveles)->

	$scope.nivel = {}

	Restangular.one('niveles_educativos', $state.params.nivel_id).get().then (r)->
		$scope.nivel = r
	

	$scope.guardar = ()->
		$scope.nivel.put().then((r)->
			console.log 'Se guardó nivel', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.restarOrden = ()->
		if $scope.nivel.orden > 0
			$scope.nivel.orden = $scope.nivel.orden - 1
	$scope.sumarOrden = ()->
		if $scope.nivel.orden < 10
			$scope.nivel.orden = $scope.nivel.orden + 1


])
