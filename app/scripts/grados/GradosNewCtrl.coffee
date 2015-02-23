'use strict'

angular.module("myvcFrontApp")

.controller('GradosNewCtrl', ['$scope', '$rootScope', '$interval', 'Restangular', 'RNiveles', 'RGrados', ($scope, $rootScope, $interval, Restangular, RNiveles, RGrados)->

	$scope.grado = {
		orden: 1
	}

	RNiveles.getList().then((data)->
		$scope.niveles = data;
	)

	$scope.restarOrden = ()->
		if $scope.grado.orden > 0
			$scope.grado.orden = $scope.grado.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grado.orden < 40
			$scope.grado.orden = $scope.grado.orden + 1

	$scope.crear = ()->
		RGrados.post($scope.grado).then((r)->
			console.log 'Se hizo el post del grado', r
			$scope.$emit 'gradocreado', r
			$scope.toastr.success 'Grado '+r.nombre+' creado'
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

])
