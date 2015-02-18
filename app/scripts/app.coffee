'use strict'

angular.module('myvcFrontApp', [
	'ngAnimate'
	'ngAria'
	'ngCookies'
	'ngMessages'
	'ngSanitize'
	'ngTouch'
	'pascalprecht.translate'
	'ui.bootstrap'
	'ui.router'
	'ui.select'
	'angular-loading-bar'
	#'ngCkeditor'
	'restangular'
	'uiBreadcrumbs'
	'toastr'
	'http-auth-interceptor'
	'ui.grid'
	'ui.grid.edit'
	'ui.grid.resizeColumns'
	'ui.grid.exporter'
	'ui.grid.selection'
	'angularFileUpload'
])
#- Valores que usaremos para nuestro proyecto
.constant('App', (()->

	dominio = 'http://lalvirtual.com/' # Pruebas en mi localhost
	#server = dominio + 'myvc_server/public/'
	server = ''
	frontapp = dominio + 'myvc_front/'

	return {
		Server: server
		views: 'views/'
		#views: server + 'views/dist/views/' # Para el server Laravel
		images: server + 'images/'
	}
)())
.constant('AUTH_EVENTS', {
	loginSuccess: 'auth-login-success',
	loginFailed: 'auth-login-failed',
	logoutSuccess: 'auth-logout-success',
	sessionTimeout: 'auth-session-timeout',
	notAuthenticated: 'auth-not-authenticated',
	notAuthorized: 'auth-not-authorized'
})
.constant('USER_ROLES', {
	all: '*',
	admin: 'admin',
	alumno: 'alumno',
	acudiente: 'acudiente'
	profesor: 'profesor'
	guest: 'guest'
})
.constant('PERMISSIONS', {
	can_see_panel:			'can_see_panel'
	can_edit_alumnos:		'can_edit_alumnos'
	can_edit_usuarios:		'can_edit_usuarios'
	can_edit_notas:			'can_edit_notas'
	can_edit_years:			'can_edit_years'
	can_edit_periodos:		'can_edit_periodos'
	can_edit_paises:		'can_edit_paises'
	can_edit_ciudades:		'can_edit_ciudades'
	can_edit_disciplinas:	'can_edit_disciplinas'
	can_edit_profesores:	'can_edit_profesores'
	can_edit_eventos:		'can_edit_eventos'
	can_edit_votaciones:	'can_edit_votaciones'
	can_edit_aspiraciones:	'can_edit_aspiraciones'
	can_edit_participantes:	'can_edit_participantes'
	can_edit_candidatos: 	'can_edit_candidatos'
})


