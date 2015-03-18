angular.module('myvcFrontApp')
.controller 'ListAsignaturasCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', ($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user) ->

	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.GENERO_UNI = $scope.USER.genero_unidad
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.GENERO_SUB = $scope.USER.genero_subunidad
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname

	$scope.views = App.views + 'areas/'

	$scope.profesor = {}

	if $state.params.profesor_id

		$scope.profesor_id = true
		
		Restangular.all('asignaturas/listasignaturas/'+$state.params.profesor_id).getList().then((r)->
			$scope.asignaturas = r

			Restangular.one('profesores/show/'+$state.params.profesor_id).get().then((r)->
				$scope.profesor = r
			, (r2)->
				console.log 'No se pudo traer el profesor, ', r2
			)

		, (r2)->
			console.log 'No se pudo traer las asignaturas, ', r2
		)


	else
		$scope.profesor_id = false

		Restangular.all('asignaturas/listasignaturas').getList().then((r)->
			$scope.asignaturas = r
		, (r2)->
			console.log 'No se pudo traer tus asignaturas, ', r2
		)

	ruta1 = 'grupos/titularias'
	ruta2 = if $scope.profesor_id then (ruta1 + '/' + $state.params.profesor_id) else ruta1

	Restangular.all(ruta2).getList().then((r)->
		$scope.gruposcomportamientos = r
	, (r2)->
		console.log 'No se pudo traer las titularías, ', r2
	)

	$scope.open = (asignatura)->
		$state.go 'panel.unidades', {asignatura_id: asignatura.asignatura_id}
		console.log asignatura

]

