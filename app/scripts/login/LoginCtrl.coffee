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
		console.log('imagen existe')
	, ()->
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


	$scope.enviarPass = (correo_electronico)->
		$http.post('::login/ver-pass', {email: correo_electronico, ruta: location.origin + location.pathname }).then((r)->
			alert('Ahora, verifica tu correo');
		, ()->
			alert('Parece que el correo no está registrado.');
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




.controller('ResetPasswordCtrl', ['$scope', '$state', '$stateParams', '$cookies', 'Perfil', 'App', '$http', 'toastr', ($scope, $state, $stateParams, $cookies, Perfil, App, $http, toastr)->

	$scope.reseteando = false
	$scope.username   = $stateParams.username
	$scope.logoPath   = 'images/Logo_Colegio_Header.gif'

	if $stateParams.numero < 10000
		console.log 'Reseteo inválido, deja de intentarlo.'
		$state.go 'login'


	$scope.credentials =
		password1: ''
		password2: ''

	$scope.reset = (credentials)->
		$scope.reseteando = true

		if credentials.password1 != credentials.password2
			toastr.warning 'Las contraseñas no coinciden.'
			$scope.reseteando = false
			return
		if credentials.password1.length < 4
			toastr.warning 'Debe tener al menos 4 caracteres'
			$scope.reseteando = false
			return

		$http.put('::login/reset-password', {password1: credentials.password1, numero: $stateParams.numero, username: $stateParams.username }).then((r)->
			if r.data == 'Token inválido'
				toastr.warning 'Token inválido'
				$scope.reseteando = false
			else
				$state.go 'login'
		, (r2)->
			console.log('No se pudo resetear')
			$scope.reseteando = false
		)


	return

])
