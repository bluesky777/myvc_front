angular.module('myvcFrontApp')

.controller('ListadoProfesoresCtrl',['$scope', 'App', 'Perfil', 'profesores', '$state', ($scope, App, Perfil, profesores, $state)->

	$scope.USER = Perfil.User()
	$scope.profesores = profesores.data.profesores
	$scope.year       = profesores.data.year

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', $scope.profesores.length + '  profesores.'


])

.controller('VerCantAlumnosPorGruposCtrl',['$scope', 'App', 'Perfil', 'grupos', '$state', ($scope, App, Perfil, grupos, $state)->

	$scope.USER               = Perfil.User()
	$scope.grupos_cantidades  = grupos.data.grupos
	$scope.periodos_total     = grupos.data.periodos_total

	$scope.perfilPath       = App.images+'perfil/'


	$scope.cant_total_alumnos = 0

	for grup in $scope.grupos_cantidades
		$scope.cant_total_alumnos = $scope.cant_total_alumnos + grup.cant_alumnos

	$scope.$emit 'cambia_descripcion', $scope.grupos_cantidades.length + '  grupos.'


])




