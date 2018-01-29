angular.module('myvcFrontApp')

.controller('NotasPerdidasProfesorCtrl',['$scope', 'App', 'Perfil', 'grupos', '$state', '$stateParams', ($scope, App, Perfil, grupos, $state, $stateParams)->
	$scope.grupos             = grupos.data
	$scope.periodo_a_calcular = $stateParams.periodo_a_calcular

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.perfilPath = App.images+'perfil/'

	$scope.$emit 'cambia_descripcion', 'Notas pendientes '

])



.controller('NotasPerdidasTodosCtrl',['$scope', 'App', 'Perfil', 'profesores', '$state', '$stateParams', ($scope, App, Perfil, profesores, $state, $stateParams)->
	$scope.profesores         = profesores.data
	$scope.periodo_a_calcular = $stateParams.periodo_a_calcular

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.perfilPath = App.images+'perfil/'

	$scope.$emit 'cambia_descripcion', 'Notas pendientes '

])




.controller('VerAusenciasCtrl',['$scope', 'App', 'Perfil', 'grupos_ausencias', '$state', ($scope, App, Perfil, grupos_ausencias, $state)->
	$scope.grupos_ausencias = grupos_ausencias.data

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', 'Ausencias y tardanzas a la institución '

])





.controller('VerSimatCtrl',['$scope', 'App', 'Perfil', 'grupos_simat', '$state', ($scope, App, Perfil, grupos_simat, $state)->
	$scope.grupos_simat = grupos_simat.data

	$scope.USER = Perfil.User()

	$scope.perfilPath = App.images+'perfil/'



	$scope.$emit 'cambia_descripcion', 'Ausencias y tardanzas a la institución '

])



