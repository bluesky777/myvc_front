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
		if $scope.grupo.orden < 10
			$scope.grupo.orden = $scope.grupo.orden + 1

	$scope.crear = ()->
		console.log 'Datos a guardar: ', $scope.grupo, $scope.grupo.caritas
		RGrupos.post($scope.grupo).then((r)->
			console.log 'Se hizo el post del grupo', r
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
		)

])
