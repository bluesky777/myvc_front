angular.module("myvcFrontApp")

.controller('BoletinesPeriodoCtrl', ['$scope', 'alumnosDat', 'escalas', '$uibModal', '$cookieStore', ($scope, alumnos, escalas, $modal, $cookieStore)->
	
	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	$scope.requested_alumnos = $cookieStore.get 'requested_alumnos'
	$scope.requested_alumno = $cookieStore.get 'requested_alumno'

	
	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'


	if $scope.requested_alumnos
		$scope.$emit 'cambia_descripcion', 'Mostrando ' + $scope.alumnos.length + ' boletines de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else if $scope.requested_alumno
		$scope.$emit 'cambia_descripcion', 'Mostrando un boletin de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else
		$scope.$emit 'cambia_descripcion', $scope.alumnos.length + ' boletines del grupo ' + $scope.grupo.nombre_grupo



])