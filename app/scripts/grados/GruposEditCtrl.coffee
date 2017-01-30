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
		if $scope.grupo.titular.profesor_id
			$scope.grupo.titular_id = $scope.grupo.titular.profesor_id # Así viene cuando ha sido seleccionado el titular mientras está editando
		else
			$scope.grupo.titular_id = $scope.grupo.titular.id # Así viene originalmente al darle editar

		titular = $scope.grupo.titular
		delete $scope.grupo.titular

		$scope.grupo.grado_id = $scope.grupo['grado'].id
		
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
