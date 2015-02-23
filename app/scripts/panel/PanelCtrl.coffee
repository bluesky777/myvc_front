'use strict'

angular.module('myvcFrontApp')
.controller 'PanelCtrl', ['$scope', '$http', 'Restangular', '$state', '$cookies', '$rootScope', 'AuthService', 'Perfil', 'App', 'resolved_user', ($scope, $http, Restangular, $state, $cookies, $rootScope, AuthService, Perfil, App, resolved_user) ->

	$scope.USER = resolved_user
	$scope.pageTitle = $rootScope.pageTitle
	$scope.logoPath = 'images/MyVc-1.gif'
	$scope.paramuser = {'username': $scope.USER.username }

	$scope.verificar_acceso()

	$scope.setImagenPrincipal = ()->
		ini = App.images+'perfil/'

		imgUsuario = $scope.USER.imagen_nombre
		imgOficial = $scope.USER.foto_nombre
		
		pathUsu = ini + imgUsuario
		pathOfi = ini + imgOficial
		
		$scope.imagenPrincipal = pathUsu
		$scope.imagenOficial = pathOfi

	$scope.setImagenPrincipal()
	
	
	$scope.nameToShow = Perfil.nameToShow



	$scope.toggleCompactMenu = ()->
		$rootScope.menucompacto = !$rootScope.menucompacto

	$scope.seeDropdownPeriodos = false

	$scope.togglePeriodos = ()->
		$scope.seeDropdownPeriodos = !$scope.seeDropdownPeriodos
		console.log $scope.seeDropdownPeriodos

	$scope.logout = ->
		AuthService.logout();

	$scope.goFileManager = ()->
		$state.go 'panel.filemanager'

	#console.log Restangular.all('disciplinas').getList()

	$scope.$on 'cambianImgs', (event, data)->
		$scope.USER = Perfil.User()
		$scope.setImagenPrincipal()

	return
]
