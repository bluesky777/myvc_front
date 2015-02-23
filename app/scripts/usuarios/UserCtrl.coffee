angular.module('myvcFrontApp')
.controller('UserCtrl', ['$scope', '$http', 'Restangular', '$state', '$rootScope', 'AuthService', 'Perfil', 'App', ($scope, $http, Restangular, $state, $rootScope, AuthService, Perfil, App) ->

	username = $state.params.username
	$scope.perfilactual = {}
	$scope.companieros = []
	$scope.profesores = []
	$scope.materias = []

	if username
		Restangular.one('perfiles/username').getList(username).then((r)->
			$scope.perfilactual = r[0]
			$scope.setImagenPrincipal()
		,(r2)->
			console.log 'No se pudo traer el usuario, ', r2
			return $state.transitionTo 'panel'
		)


	$scope.setImagenPrincipal = ()->
		ini = App.images+'perfil/'

		imgUsuario = $scope.perfilactual.imagen_nombre
		imgOficial = $scope.perfilactual.foto_nombre
		
		pathUsu = ini + imgUsuario
		pathOfi = ini + imgOficial
		
		$scope.imagenPrincipal = pathUsu
		$scope.imagenOficial = pathOfi

	traerDatos = ()->
		Restangular.one('perfiles/profesormispersonas').getList().then((r)->
			$scope.perfilactual = r[0]
			$scope.setImagenPrincipal()
		,(r2)->
			console.log 'No se pudo traer el usuario, ', r2
			return $state.transitionTo 'panel'
		)


	
	$scope.nameToShow = ()->
		if $scope.perfilactual.tipo == 'Usu'
			return $scope.perfilactual.username.toUpperCase()
		else
			return $scope.perfilactual.nombres + ' ' + $scope.perfilactual.apellidos

])