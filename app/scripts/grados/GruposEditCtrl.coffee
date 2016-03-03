'use strict'

angular.module("myvcFrontApp")

.controller('GruposEditCtrl', ['$scope', '$state', 'Restangular', 'toastr', ($scope, $state, Restangular, toastr)->


	Restangular.one('grupos/show', $state.params.grupo_id).get().then (r)->
		$scope.grupo = r

	Restangular.one('grados').getList().then((data)->
		$scope.grados = data
	)
	Restangular.one('contratos').getList().then((data)->
		$scope.profesores = data
	)

	$scope.guardar = ()->
		$scope.grupo.titular_id = $scope.grupo.titular.profesor_id
		titular = $scope.grupo.titular
		delete $scope.grupo.titular
		
		Restangular.one('grupos/update').customPUT($scope.grupo).then((r)->
			toastr.success 'Grupo '+r.nombre+' editado.'
			$scope.grupo.titular = titular
		, (r2)->
			$scope.grupo.titular = titular
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.restarOrden = ()->
		if $scope.grupo.orden > 0
			$scope.grupo.orden = $scope.grupo.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grupo.orden < 40
			$scope.grupo.orden = $scope.grupo.orden + 1


])
