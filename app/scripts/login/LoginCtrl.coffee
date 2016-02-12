'use strict'

angular.module('myvcFrontApp')
.controller('LoginCtrl', ['$scope', '$rootScope', 'AUTH_EVENTS', 'AuthService', '$location', 'Restangular', '$cookies', 'Perfil', 'App', '$http', ($scope, $rootScope, AUTH_EVENTS, AuthService, $location, Restangular, $cookies, Perfil, App, $http)->
	
	animation_speed = 300
	$scope.logueando = true
	$scope.recuperando = false
	$scope.registrando = false
	

	# Si el colegio quiere que aparezca su imagen en el encabezado, puede hacerlo.
	$scope.logoPathDefault = 'images/Logo_MyVc_Header.gif'
	$scope.logoPath = 'images/Logo_Colegio_Header.gif'
	#$scope.paramuser = {'username': Perfil.User().username }


	$http.get($scope.logoPath).success(()->
		#alert('imagen existe')
	).error(()->
		#alert('image not exist')
		$scope.logoPath = $scope.logoPathDefault # set default image
	)


	$scope.credentials = 
		username: ''
		password: ''


	$scope.host = $location.host()

	$scope.login = (credentials)->
		user = AuthService.login_credentials(credentials)
		
		user.then((r)->
			#console.log 'Promise ganada', r
			return
		, (r2)->
			console.log 'Promise de login_credentials rechazada', r2
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