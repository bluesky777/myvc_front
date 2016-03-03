'use strict'

angular.module("myvcFrontApp")

.controller('NivelesNewCtrl', ['$scope', 'Restangular', 'toastr', ($scope, Restangular, toastr)->

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
		Restangular.one('niveles_educativos').customPOST($scope.nivel).then((r)->
			toastr.success 'Se hizo el post del nivel'
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

	return
])
