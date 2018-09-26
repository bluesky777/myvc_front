angular.module("myvcFrontApp")

.controller('BoletinesFinalesCtrl', ['$scope', 'alumnosDat', 'escalas', '$cookies', ($scope, alumnos, escalas, $cookies)->

	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	$scope.escalas = escalas

	$scope.config = $cookies.getObject 'config'
	$scope.requested_alumnos = $cookies.getObject 'requested_alumnos'
	$scope.requested_alumno = $cookies.getObject 'requested_alumno'


	$scope.$on 'change_config', ()->
		$scope.config = $cookies.getObject 'config'


	if $scope.requested_alumnos
		$scope.$emit 'cambia_descripcion', 'Mostrando ' + $scope.alumnos.length + ' boletines de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else if $scope.requested_alumno
		$scope.$emit 'cambia_descripcion', 'Mostrando un boletin de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else
		$scope.$emit 'cambia_descripcion', $scope.alumnos.length + ' boletines del grupo ' + $scope.grupo.nombre_grupo



])
