'use strict'

angular.module("myvcFrontApp")

.controller('GradosNewCtrl', ['$scope', '$rootScope', 'toastr', 'Restangular', ($scope, $rootScope, toastr, Restangular)->

	$scope.grado = {
		orden: 1
	}

	Restangular.one('niveles_educativos').getList().then((data)->
		$scope.niveles = data;
	)

	$scope.restarOrden = ()->
		if $scope.grado.orden > 0
			$scope.grado.orden = $scope.grado.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grado.orden < 40
			$scope.grado.orden = $scope.grado.orden + 1

	$scope.crear = ()->
		Restangular.one('grados').post($scope.grado).then((r)->
			$scope.$emit 'gradocreado', r
			toastr.success 'Grado '+r.nombre+' creado'
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

])
