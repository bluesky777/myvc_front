'use strict'

angular.module("myvcFrontApp")

.controller('NivelesNewCtrl', ['$scope', '$http', 'toastr', ($scope, $http, toastr)->

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
		$http.post('::niveles_educativos', $scope.nivel).then((r)->
			toastr.success 'Se hizo el post del nivel'
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

	return
])
