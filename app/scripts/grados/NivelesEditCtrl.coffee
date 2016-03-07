'use strict'

angular.module("myvcFrontApp")

.controller('NivelesEditCtrl', ['$scope', 'toastr', '$state', '$http', ($scope, toastr, $state, $http)->

	$scope.nivel = {}

	$http.get('::niveles_educativos/'+$state.params.nivel_id).then (r)->
		$scope.nivel = r.data
	

	$scope.guardar = ()->
		$http.put('niveles_educativos/'+$state.params.nivel_id, $scope.nivel).then((r)->
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
