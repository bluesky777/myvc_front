'use strict'

angular.module("myvcFrontApp")

.controller('GruposNewCtrl', ['$scope', '$http', 'toastr', ($scope, $http, toastr)->

	$scope.grupo = {
		orden: 1
		caritas: false
		valormatricula: 0
		valorpension: 0
	}

	$http.get('::grados').then((data)->
		$scope.grados = data.data;
	)
	$http.get('::contratos').then((data)->
		$scope.profesores = data.data;
	)

	$scope.restarOrden = ()->
		if $scope.grupo.orden > 0
			$scope.grupo.orden = $scope.grupo.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grupo.orden < 40
			$scope.grupo.orden = $scope.grupo.orden + 1

	$scope.crear = ()->

		$http.post('::grupos/store', $scope.grupo).then((r)->
			$scope.$emit 'grupocreado', r.data
			toastr.success 'Grupo '+r.data.nombre+' creado'
		, (r2)->
			toastr.error 'No se pudo crear el grupo', 'Error'
		)

])
