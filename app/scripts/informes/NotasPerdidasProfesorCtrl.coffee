angular.module('myvcFrontApp')

.controller('NotasPerdidasProfesorCtrl',['$scope', 'App', 'Perfil', 'grupos', '$state', ($scope, App, Perfil, grupos, $state)-> 
	$scope.grupos = grupos.data

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', 'Notas pendientes '

])



