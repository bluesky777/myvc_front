angular.module('myvcFrontApp')

.controller('ListadoProfesoresCtrl',['$scope', 'App', 'Perfil', 'profesores', '$state', ($scope, App, Perfil, profesores, $state)->

	$scope.USER = Perfil.User()
	$scope.profesores = profesores.data.profesores
	$scope.year       = profesores.data.year

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', $scope.profesores.length + '  profesores.'


])




