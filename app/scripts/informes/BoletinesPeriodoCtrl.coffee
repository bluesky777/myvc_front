angular.module("myvcFrontApp")

.controller('BoletinesPeriodoCtrl', ['$scope', 'alumnosDat', 'escalas', '$uibModal', '$cookieStore', ($scope, alumnos, escalas, $modal, $cookieStore)->

	$scope.grupo = alumnos[0]
	$scope.year = alumnos[1]
	$scope.alumnos = alumnos[2]

	$scope.escalas = escalas



	if $scope.year.mostrar_puesto_boletin
		for alumno in $scope.alumnos
			alumno.texto_puesto = ' - Puesto: ' + alumno.puesto + '/' + $scope.grupo.cantidad_alumnos


	$scope.config = $cookieStore.get 'config'
	$scope.requested_alumnos = $cookieStore.get 'requested_alumnos'
	$scope.requested_alumno = $cookieStore.get 'requested_alumno'


	# Cuadro el ancho que van a tener los gráficos de los boletines

	if $scope.alumnos[0].asignaturas

		if $scope.alumnos[0].asignaturas.length < 14
			$scope.ancho_chart = 50 * $scope.alumnos[0].asignaturas.length
		else
			$scope.ancho_chart = 40 * $scope.alumnos[0].asignaturas.length

	else
		cant = 0
		for area in $scope.alumnos[0].areas
			cant = cant + area.cant

		if cant < 14
			$scope.ancho_chart = 50 * cant
		else
			$scope.ancho_chart = 40 * cant


	#$scope.ancho_chart = 50 * $scope.alumnos[0].asignaturas.length

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
