angular.module('myvcFrontApp')
#- Run ejecuta código depués de haber configurado nuestro módulo con config()
.run ['$rootScope', 'cfpLoadingBar', '$state', '$stateParams', '$cookies', 'Perfil', 'AuthService', 'AUTH_EVENTS', 'toastr', ($rootScope, cfpLoadingBar, $state, $stateParams, $cookies, Perfil, AuthService, AUTH_EVENTS, toastr) ->


	#- Asignamos la información de los estados actuales para poder manipularla en las vistas.
	$rootScope.$state = $state
	$rootScope.$stateParams = $stateParams;
	$rootScope.lastState = null; #- Para saber de qué viene cuando se redireccione automáticamente al login.
	$rootScope.lastStateParam = null;
	$rootScope.notaRapida = {enable: false, valorNota: 0}

	$rootScope.menucompacto = false

	#- Evento que se ejecuta cuando envío alguna petición al servidor que requiere autenticación y no está autenticado.
	$rootScope.$on 'event:auth-loginRequired', (r)->
		console.log 'Acceso no permitido, vamos a loguear', r
		$state.transitionTo 'login'

	ingresar = ()->
		#- Si lastState es null, quiere decir que hemos entrado directamente a login sin ser redireccionados.
		if $rootScope.lastState == null or $rootScope.lastState == 'login' or $rootScope.lastState == '/' or $rootScope.lastState == 'main'
			$state.transitionTo 'panel' #- Por lo tanto nos vamos a panel después de autenticarnos.
		else
			$state.transitionTo $rootScope.lastState, $rootScope.lastStateParam #- Si no es null ni login, Nos vamos al último estado.
		#console.log 'Funcion ingresar. lastState: ', $rootScope.lastState

	#- Evento ejecutado cuando nos logueamos despues del servidor haber pedido autenticación.
	$rootScope.$on 'event:auth-loginConfirmed', ()->
		console.log 'Logueado con éxito!'
		ingresar()


	#- Evento que se ejecuta cuando vamos a cambiar de estado.
	$rootScope.$on '$stateChangeStart', (event, next, toParams, fromState, fromParams)->
		#console.log 'Va a empezar a cambiar un estado: ', next, toParams
		if $rootScope.lastState == null or (next.name != 'logout' and next.name != 'login' and next.name != 'main' )
			$rootScope.lastState = next.name
			$rootScope.lastStateParam = toParams


	#- Evento cuando ya hemos cambiado de estado.
	$rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
		#$rootScope.lastState = fromState.name if fromState.name != ''
		#-if $state.current.name == 'login' then cfpLoadingBar.complete() # No me funciona :(
		$rootScope.pageTitle = $state.current.name;


	#- Evento cuando falla la carga del estado, por un resolve rechazado o algo así.
	$rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams)->
		#$rootScope.lastState = fromState.name if fromState.name != ''
		#-if $state.current.name == 'login' then cfpLoadingBar.complete() # No me funciona :(
		console.log 'Evento fallido: ', event
		toastr.warning 'Lo sentimos, hubo un error o no puedes acceder a esta vista'
		if $rootScope.lastState != 'panel'
			$state.transitionTo 'panel'



	$rootScope.$on AUTH_EVENTS.loginSuccess, ()->
		usuario = Perfil.User()
		if usuario
			if usuario.votaciones
				if usuario.votaciones.length == 1
					toastr.success 'Hay 1 votación en ejecución.'
				else
					toastr.success 'Hay ' + usuario.votaciones.length + ' votaciones en ejecución.'
				$state.go 'panel.actividades.votaciones.votar'
			else
				ingresar()



	$rootScope.$on AUTH_EVENTS.loginFailed, (ev)->
		toastr.error 'Datos incorrecto.', 'No se pudo loguear'
		console.log 'Evento loginFailed: ', ev

		

	$rootScope.$on AUTH_EVENTS.notAuthenticated, (ev)->
		toastr.warning 'No está autorizado.', 'Acceso exclusivo'
		console.log 'Evento notAuthenticated: ', ev
		$state.transitionTo 'login'
		


	$rootScope.$on AUTH_EVENTS.notAuthorized, (ev)->
		toastr.warning 'No está autorizado para entrar a esta vista', 'Restringido'
		$state.go 'panel'
		console.log 'Evento notAuthorized: ', ev, $rootScope.lastState

]