'use strict'

angular.module("myvcFrontApp")

.controller('GradosEditCtrl', ['$scope', '$state', '$rootScope', '$interval', 'Restangular', 'RGrados', 'RNiveles', ($scope, $state, $rootScope, $interval, Restangular, RGrados, RNiveles)->


	Restangular.one('grados', $state.params.grado_id).get().then (r)->
		$scope.grado = r
		console.log 'Traje ', r
	
	RNiveles.getList().then((data)->
		$scope.niveles = data
	)

	$scope.guardar = ()->
		$scope.grado.put().then((r)->
			console.log 'Se guardó grado', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.restarOrden = ()->
		if $scope.grado.orden > 0
			$scope.grado.orden = $scope.grado.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grado.orden < 10
			$scope.grado.orden = $scope.grado.orden + 1

])
