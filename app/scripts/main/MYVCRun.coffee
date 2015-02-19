angular.module('myvcFrontApp')

#- Run ejecuta código depués de haber configurado nuestro módulo con config()
.run ['$rootScope', 'cfpLoadingBar', '$state', '$stateParams', '$translate', '$cookies', 'Restangular', 'Perfil', 'AuthService', 'AUTH_EVENTS',  ($rootScope, cfpLoadingBar, $state, $stateParams, $translate, $cookies, Restangular, Perfil, AuthService, AUTH_EVENTS) ->


	#- Asignamos la información de los estados actuales para poder manipularla en las vistas.
	$rootScope.$state = $state
	$rootScope.$stateParams = $stateParams;
	$rootScope.lastState = null; #- Para saber de qué viene cuando se redireccione automáticamente al login.

	$rootScope.menucompacto = false

	#- Evento que se ejecuta cuando envío alguna petición al servidor que requiere autenticación y no está autenticado.
	$rootScope.$on 'event:auth-loginRequired', (r)->
		console.log 'Acceso no permitido, vamos a loguear', r
		$state.transitionTo 'login'

	ingresar = ()->
		#- Si lastState es null, quiere decir que hemos entrado directamente a login sin ser redireccionados.
		if $rootScope.lastState == null or $rootScope.lastState == 'login' or $rootScope.lastState == '/'
			$state.transitionTo 'panel' #- Por lo tanto nos vamos a panel después de autenticarnos.
		else
			$state.transitionTo $rootScope.lastState #- Si no es null ni login, Nos vamos al último estado.
		console.log 'Funcion ingresar. lastState: ', $rootScope.lastState

	#- Evento ejecutado cuando nos logueamos despues del servidor haber pedido autenticación.
	$rootScope.$on 'event:auth-loginConfirmed', ()->
		console.log 'Logueado con éxito!'
		ingresar()


	#- Evento que se ejecuta cuando vamos a cambiar de estado.
	$rootScope.$on '$stateChangeStart', (event, next, toParams, fromState, fromParams)->
		console.log 'Va a empezar a cambiar un estado: ', next
		if $rootScope.lastState == null or (next.name != 'logout' and next.name != 'login')
			$rootScope.lastState = next.name


	#- Evento cuando ya hemos cambiado de estado.
	$rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
		#$rootScope.lastState = fromState.name if fromState.name != ''
		#-if $state.current.name == 'login' then cfpLoadingBar.complete() # No me funciona :(
		$rootScope.pageTitle = $state.current.name;


	#- Se ejecuta cuando se trae un nuevo trozo de traducciones
	$rootScope.$on '$translatePartialLoaderStructureChanged', () ->
		$translate.refresh()
		console.log('Translate refrescado supuestamente.')


	$rootScope.votacionActual = undefined

	$rootScope.$on AUTH_EVENTS.loginSuccess, ()->
		
		if !$rootScope.votacionActual
			Restangular.one('eventos').get().then((r)->
				if r.rutear
					$state.go r.state
				else
					ingresar()
			, (r2)->

			)

	$rootScope.$on AUTH_EVENTS.loginFailed, (ev)->
		
		console.log 'Evento loginFailed: ', ev

		

	$rootScope.$on AUTH_EVENTS.notAuthenticated, (ev)->
		$state.transitionTo 'login' 
		console.log 'Evento notAuthenticated: ', ev
		


	$rootScope.$on AUTH_EVENTS.notAuthorized, (ev)->
		$state.go 'login'
		console.log 'Evento notAuthorized: ', ev, $rootScope.lastState

]