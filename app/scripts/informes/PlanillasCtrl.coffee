angular.module('myvcFrontApp')

.controller('PlanillasCtrl',['$scope', 'App', 'Perfil', 'asignaturas', '$state', ($scope, App, Perfil, asignaturas, $state)-> 
	asignaturas = asignaturas.data

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	
	$scope.year = asignaturas[0]
	$scope.asignaturas = asignaturas[1]

	$scope.perfilPath = App.images+'perfil/'

	$scope.unidadesdefault = ["  ", "  ", "  "]
	$scope.subunidadesdefault = [
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
	]


	if $state.params.profesor_id
		asig = $scope.asignaturas[0]
		$scope.$emit 'cambia_descripcion', $scope.asignaturas.length + ' planillas  del profesor ' + asig.nombres_profesor + ' ' + asig.apellidos_profesor
	else if $state.params.grupo_id
		asig = $scope.asignaturas[0]
		$scope.$emit 'cambia_descripcion', $scope.asignaturas.length + ' planillas  del grupo ' + asig.nombre_grupo

])