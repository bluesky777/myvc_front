angular.module('myvcFrontApp')


# Configuración principal de nuestra aplicación.
.config(['$cookiesProvider', '$stateProvider', '$urlRouterProvider', '$httpProvider', 'App', 'PERMISSIONS', 'RestangularProvider', '$intervalProvider', '$rootScopeProvider', 'USER_ROLES', 'toastrConfig', ($cookies, $state, $urlRouter, $httpProvider, App, PERMISSIONS, Restangular, $intervalProvider, $rootScopeProvider, USER_ROLES, toastrConfig)->

	Restangular.setBaseUrl App.Server # Url a la que se harán todas las llamadas.
	

	$httpProvider.defaults.headers.post['X-CSRFToken'] = $cookies.csrftoken;
	$httpProvider.defaults.headers.put['X-CSRFToken'] = $cookies.csrftoken;

	$httpProvider.defaults.useXDomain = true
	$httpProvider.defaults.xsrfCookieName = 'csrftoken';
	$httpProvider.defaults.xsrfHeaderName = 'X-CSRFToken';




	#- Definimos los estados
	$state
	.state('main', { #- Estado raiz que no necesita autenticación.
		url: '/'
		views: 
			'principal':
				templateUrl: App.views+'main/main.tpl.html'
				controller: 'MainCtrl'
		data: 
			displayName: 'principal'
			icon_fa: ''
	})
	.state('login', { 
		url: '/login'
		views:
			'principal':
				templateUrl: "#{App.views}login/login.tpl.html"
				controller: 'LoginCtrl'
		data: 
			displayName: 'Login'
			icon_fa: 'fa fa-user'

	})
	.state('logout', { 
		url: '/logout'
		views:
			'principal':
				templateUrl: "#{App.views}login/logout.tpl.html"
				controller: 'LogoutCtrl'
		data: 
			displayName: 'Logout'
			icon_fa: 'fa fa-user'

	})
	.state('panel', { #- Estado admin.
		url: '/panel'
		views:
			'principal':
				templateUrl: "#{App.views}panel/panel.tpl.html"
				controller: 'PanelCtrl'
		resolve: { 
			resolved_user: ['AuthService', (AuthService)->
				console.log 'Entra al resolve'
				AuthService.verificar()
			]
		}
		data: 
			displayName: 'Inicio'
			icon_fa: 'fa fa-home'
			needed_permissions: [PERMISSIONS.can_see_panel]
	})

	$rootScopeProvider.bigLoader = true

	# Agrego la función findByValues a loDash.
	_.mixin 
		'findByValues': (collection, property, values)->
			filtrado = _.filter collection, (item)->
				_.contains values, item[property]
			if filtrado.length == 0 then return false else filtrado[0]

	angular.extend(toastrConfig, {
		allowHtml: true,
		closeButton: true,
		closeHtml: '<button>&times;</button>',
		containerId: 'toast-container',
		extendedTimeOut: 2000,
		iconClasses: {
			error: 'toast-error',
			info: 'toast-info',
			success: 'toast-success',
			warning: 'toast-warning'
		},
		maxOpened: 6,
		messageClass: 'toast-message',
		newestOnTop: true,
		onHidden: null,
		onShown: null,
		positionClass: 'toast-top-right',
		tapToDismiss: true,
		target: 'body',
		timeOut: 5000,
		titleClass: 'toast-title',
		toastClass: 'toast'
	})

	@
	])

