'use strict'

angular.module("myvcFrontApp")

.controller('GruposNewCtrl', ['$scope', '$rootScope', '$interval', 'Restangular', 'RGrupos', 'RGrados', 'RProfesores', ($scope, $rootScope, $interval, Restangular, RGrupos, RGrados, RProfesores)->

	$scope.grupo = {
		orden: 1
		caritas: false
		valormatricula: 0
		valorpension: 0
	}

	RGrados.getList().then((data)->
		$scope.grados = data;
	)
	RProfesores.getList().then((data)->
		$scope.profesores = data;
	)

	$scope.restarOrden = ()->
		if $scope.grupo.orden > 0
			$scope.grupo.orden = $scope.grupo.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grupo.orden < 40
			$scope.grupo.orden = $scope.grupo.orden + 1

	$scope.crear = ()->
		console.log 'Datos a guardar: ', $scope.grupo, $scope.grupo.caritas
		Restangular.one('grupos/store').customPOST($scope.grupo).then((r)->
			console.log 'Se hizo el post del grupo', r
			$scope.$emit 'grupocreado', r
			$scope.toastr.success 'Grupo '+r.nombre+' creado'
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
			$scope.toastr.error 'No se pudo crear el grupo', 'Error'
		)

])
