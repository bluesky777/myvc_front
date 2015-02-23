'use strict'

angular.module("myvcFrontApp")

.controller('InicioCtrl', ['$scope', '$rootScope', '$interval', 'resolved_user', 'App', 'AuthService', ($scope, $rootScope, $interval, resolved_user, App, AuthService)->

	
	$scope.verificar_acceso()
	$scope.logoPath = 'images/MyVc-1.gif'

	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

	$scope.USER = resolved_user


	$scope.setImagenPrincipal = ()->
		ini = App.images+'perfil/'

		imgUsuario = $scope.USER.imagen_nombre
		imgOficial = $scope.USER.foto_nombre
		
		pathUsu = ini + imgUsuario
		pathOfi = ini + imgOficial
		
		$scope.imagenPrincipal = pathUsu
		$scope.imagenOficial = pathOfi

	$scope.setImagenPrincipal()
	
	$scope.nameToShow = ()->
		if $scope.USER.tipo == 'Usu'
			return $scope.USER.username.toUpperCase()
		else
			return $scope.USER.nombres + ' ' + $scope.USER.apellidos


	return
])