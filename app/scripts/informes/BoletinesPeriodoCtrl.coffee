angular.module("myvcFrontApp")

.controller('BoletinesPeriodoCtrl', ['$scope', 'alumnosDat', 'escalas', '$uibModal', '$cookieStore', ($scope, alumnos, escalas, $modal, $cookieStore)->
	
	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	$scope.requested_alumnos = $cookieStore.get 'requested_alumnos'
	$scope.requested_alumno = $cookieStore.get 'requested_alumno'

	
	# Cuadro el ancho que van a tener los gráficos de los boletines
	if $scope.alumnos[0].asignaturas.length < 10
		$scope.ancho_chart = 50 * $scope.alumnos[0].asignaturas.length
	else
		$scope.ancho_chart = 35 * $scope.alumnos[0].asignaturas.length

	if $scope.ancho_chart > 800
		$scope.ancho_chart = 800

	
	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'


	if $scope.requested_alumnos
		$scope.$emit 'cambia_descripcion', 'Mostrando ' + $scope.alumnos.length + ' boletines de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else if $scope.requested_alumno
		$scope.$emit 'cambia_descripcion', 'Mostrando un boletin de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else
		$scope.$emit 'cambia_descripcion', $scope.alumnos.length + ' boletines del grupo ' + $scope.grupo.nombre_grupo



])