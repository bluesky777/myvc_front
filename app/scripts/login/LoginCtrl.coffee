'use strict'

angular.module('myvcFrontApp')
.controller('LoginCtrl', ['$scope', '$rootScope', 'AUTH_EVENTS', 'AuthService', '$http', 'Restangular', '$cookies', 'Perfil', 'App', ($scope, $rootScope, AUTH_EVENTS, AuthService, $http, Restangular, $cookies, Perfil, App)->
	
	animation_speed = 300
	$scope.logueando = true
	$scope.recuperando = false
	$scope.registrando = false
	$scope.logoPath = App.images + 'MyVc-1.gif'

	$scope.credentials = 
		username: ''
		password: ''


	$scope.login = (credentials)->
		user = AuthService.login_credentials(credentials)
		
		user.then((r)->
			#console.log 'Promise ganada', r
			return
		, (r2)->
			console.log 'Promise rechazada', r2
		)


	$scope.to_recuperando = ->
		$scope.logueando = false
		$scope.recuperando = true
		$scope.registrando = false
	$scope.to_registrando = ->
		$scope.logueando = false
		$scope.recuperando = false
		$scope.registrando = true
	$scope.to_logueando = ->
		$scope.logueando = true
		$scope.recuperando = false
		$scope.registrando = false

	return

])