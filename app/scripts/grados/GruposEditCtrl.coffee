'use strict'

angular.module("myvcFrontApp")

.controller('GruposEditCtrl', ['$scope', '$state', '$http', 'toastr', ($scope, $state, $http, toastr)->


	$http.get('::grupos/show/'+$state.params.grupo_id).then (r)->
		$scope.grupo = r.data

	$http.get('::grados').then((data)->
		$scope.grados = data.data
	)
	$http.get('::contratos').then((data)->
		$scope.profesores = data.data
	)

	$scope.guardar = ()->
		$scope.grupo.titular_id = $scope.grupo.titular.profesor_id
		titular = $scope.grupo.titular
		delete $scope.grupo.titular
		
		$http.put('::grupos/update', $scope.grupo).then((r)->
			toastr.success 'Grupo '+r.data.nombre+' editado.'
			$scope.grupo.titular = titular
		, (r2)->
			$scope.grupo.titular = titular
		)

	$scope.restarOrden = ()->
		if $scope.grupo.orden > 0
			$scope.grupo.orden = $scope.grupo.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grupo.orden < 40
			$scope.grupo.orden = $scope.grupo.orden + 1


])
