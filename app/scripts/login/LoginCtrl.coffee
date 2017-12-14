'use strict'

angular.module('myvcFrontApp')
.controller('LoginCtrl', ['$scope', '$rootScope', 'AUTH_EVENTS', 'AuthService', '$location', '$cookies', 'Perfil', 'App', '$http', ($scope, $rootScope, AUTH_EVENTS, AuthService, $location, $cookies, Perfil, App, $http)->
	
	animation_speed = 300
	$scope.logueando = true
	$scope.recuperando = false
	$scope.registrando = false


	# Si el colegio quiere que aparezca su imagen en el encabezado, puede hacerlo.
	$scope.logoPathDefault = 'images/Logo_MyVc_Header.gif'
	$scope.logoPath = 'images/Logo_Colegio_Header.gif'
	#$scope.paramuser = {'username': Perfil.User().username }


	$http.get($scope.logoPath).then(()->
		#alert('imagen existe')
	).then(()->
		#alert('image not exist')
		$scope.logoPath = $scope.logoPathDefault # set default image
	)


	$scope.credentials = 
		username: ''
		password: ''


	$scope.host = $location.host()

	$scope.login = (credentials)->
		AuthService.login_credentials(credentials).then((r)->
		
			AuthService.verificar().then((r2)->
				#if localStorage.getItem('logueando') == 'token_verificado'
				localStorage.removeItem('token_verificado')
			, (r3)->
				console.log('Falló en Verificar')
			)
			return
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