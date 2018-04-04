angular.module('myvcFrontApp')

.controller('NotasActualesAlumnosCtrl',['$scope', 'App', 'Perfil', 'alumnosDat', 'escalas', '$cookieStore', ($scope, App, Perfil, alumnosDat, escalas, $cookieStore)->

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.perfilPath = App.images+'perfil/'
	$scope.views = App.views


	$scope.grupo = alumnosDat[0]
	$scope.year = alumnosDat[1]
	$scope.alumnos = alumnosDat[2]

	$scope.escalas = escalas


	$scope.config = $cookieStore.get 'config'
	$scope.requested_alumnos = $cookieStore.get 'requested_alumnos'
	$scope.requested_alumno = $cookieStore.get 'requested_alumno'


	for alumno in $scope.alumnos
		alumno.cant_perdidas = 0

		for periodo in alumno.periodos
			periodo.cant_perdidas = 0

			for asignatura in periodo.asignaturas
				asignatura.cant_perdidas = 0

				for unidad in asignatura.unidades
					unidad.cant_perdidas = 0

					for subunidad in unidad.subunidades

						if subunidad.nota < $scope.USER.nota_minima_aceptada
							unidad.cant_perdidas 			+= 1
							asignatura.cant_perdidas 	+= 1
							periodo.cant_perdidas 		+= 1
							alumno.cant_perdidas 			+= 1


	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'


	if $scope.requested_alumnos
		$scope.$emit 'cambia_descripcion', 'Mostrando ' + $scope.alumnos.length + ' boletines de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else if $scope.requested_alumno
		$scope.$emit 'cambia_descripcion', 'Mostrando un boletin de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else
		$scope.$emit 'cambia_descripcion', $scope.alumnos.length + ' boletines del grupo ' + $scope.grupo.nombre_grupo





])



