'use strict'

angular.module("myvcFrontApp")

.controller('NivelesEditCtrl', ['$scope', 'toastr', '$state', 'Restangular', ($scope, toastr, $state, Restangular)->

	$scope.nivel = {}

	Restangular.one('niveles_educativos', $state.params.nivel_id).get().then (r)->
		$scope.nivel = r
	

	$scope.guardar = ()->
		$scope.nivel.put().then((r)->
			toastr.success 'Se guardó nivel'
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

	$scope.restarOrden = ()->
		if $scope.nivel.orden > 0
			$scope.nivel.orden = $scope.nivel.orden - 1
	$scope.sumarOrden = ()->
		if $scope.nivel.orden < 40
			$scope.nivel.orden = $scope.nivel.orden + 1


])
