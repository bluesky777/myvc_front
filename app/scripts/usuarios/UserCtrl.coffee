angular.module('myvcFrontApp')
.controller('UserCtrl', ['$scope', '$http', '$state', 'AuthService', 'Perfil', 'App', 'perfilactual', ($scope, $http, $state, AuthService, Perfil, App, perfilactual) ->

	username = $state.params.username
	$scope.perfilactual = perfilactual
	$scope.companieros = []
	$scope.profesores = []
	$scope.materias = []
	$scope.canConfig = false
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

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
		$http.get('::perfiles/profesormispersonas').then((r)->
			r = r.data
			$scope.perfilactual = r[0]
			$scope.setImagenPrincipal()
		,(r2)->
			toastr.error 'No se pudo traer el usuario'
			return $state.transitionTo 'panel'
		)


	
	$scope.nameToShow = ()->
		if $scope.perfilactual.tipo == 'Usu'
			return $scope.perfilactual.username.toUpperCase()
		else
			return $scope.perfilactual.nombres + ' ' + $scope.perfilactual.apellidos

])