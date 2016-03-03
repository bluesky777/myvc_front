'use strict'

angular.module("myvcFrontApp")

.controller('GruposNewCtrl', ['$scope', 'Restangular', 'toastr', ($scope, Restangular, toastr)->

	$scope.grupo = {
		orden: 1
		caritas: false
		valormatricula: 0
		valorpension: 0
	}

	Restangular.one('grados').getList().then((data)->
		$scope.grados = data;
	)
	Restangular.one('contratos').getList().then((data)->
		$scope.profesores = data;
	)

	$scope.restarOrden = ()->
		if $scope.grupo.orden > 0
			$scope.grupo.orden = $scope.grupo.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grupo.orden < 40
			$scope.grupo.orden = $scope.grupo.orden + 1

	$scope.crear = ()->

		Restangular.one('grupos/store').customPOST($scope.grupo).then((r)->
			$scope.$emit 'grupocreado', r
			toastr.success 'Grupo '+r.nombre+' creado'
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
			toastr.error 'No se pudo crear el grupo', 'Error'
		)

])
