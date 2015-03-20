angular.module('myvcFrontApp')

.controller('PlanillasGrupoCtrl',['$scope', 'App', 'Perfil', 'alumnos', ($scope, App, Perfil, alumnos)-> 

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	
	$scope.year = alumnos[0]
	$scope.grupo = alumnos[1]

	$scope.perfilPath = App.images+'perfil/'

	$scope.unidadesdefault = ["  ", "  ", "  "]
	$scope.subunidadesdefault = [
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
	]

])