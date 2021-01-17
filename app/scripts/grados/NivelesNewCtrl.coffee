'use strict'

angular.module("myvcFrontApp")

.controller('NivelesNewCtrl', ['$scope', '$http', 'toastr', '$state', ($scope, $http, toastr, $state)->

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
		$http.post('::niveles_educativos/store', $scope.nivel).then((r)->
			toastr.success 'Nivel creado.'
			$state.go('panel.niveles', {}, {reload: true})
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

	return
])
