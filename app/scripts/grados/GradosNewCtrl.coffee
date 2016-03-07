'use strict'

angular.module("myvcFrontApp")

.controller('GradosNewCtrl', ['$scope', 'toastr', '$http', ($scope, toastr, $http)->

	$scope.grado = {
		orden: 1
	}

	$scope.restarOrden = ()->
		if $scope.grado.orden > 0
			$scope.grado.orden = $scope.grado.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grado.orden < 40
			$scope.grado.orden = $scope.grado.orden + 1

	$scope.crear = ()->
		$http.post('::grados/store', $scope.grado).then((r)->
			r = r.data
			$scope.$emit 'gradocreado', r
			toastr.success 'Grado '+r.nombre+' creado'
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

])
