'use strict'

angular.module("myvcFrontApp")

.controller('GruposEditCtrl', ['$scope', '$state', '$rootScope', '$interval', 'Restangular', 'RGrados', 'RGrupos', 'RProfesores', ($scope, $state, $rootScope, $interval, Restangular, RGrados, RGrupos, RProfesores)->


	Restangular.one('grupos/show', $state.params.grupo_id).get().then (r)->
		$scope.grupo = r

	RGrados.getList().then((data)->
		$scope.grados = data
	)
	RProfesores.getList().then((data)->
		$scope.profesores = data
	)

	$scope.guardar = ()->
		Restangular.one('grupos/update').customPUT($scope.grupo).then((r)->
			console.log 'Se guardó grupo', r
			$scope.toastr.success 'Grupo '+r.nombre+' editado.'
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

	$scope.restarOrden = ()->
		if $scope.grupo.orden > 0
			$scope.grupo.orden = $scope.grupo.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grupo.orden < 40
			$scope.grupo.orden = $scope.grupo.orden + 1


])
