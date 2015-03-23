angular.module('myvcFrontApp')
.controller('UserCtrl', ['$scope', '$http', 'Restangular', '$state', '$rootScope', 'AuthService', 'Perfil', 'App', 'perfilactual', ($scope, $http, Restangular, $state, $rootScope, AuthService, Perfil, App, perfilactual) ->

	username = $state.params.username
	$scope.perfilactual = perfilactual
	$scope.companieros = []
	$scope.profesores = []
	$scope.materias = []
	$scope.canConfig = false


	$scope.setImagenPrincipal()

	if $scope.USER.user_id == $scope.perfilactual.user_id
		$scope.canConfig = true



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