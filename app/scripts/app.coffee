'use strict'

angular.module('myvcFrontApp', [
	'ngAnimate'
	'ngAria'
	'ngCookies'
	'ngMessages'
	'ngSanitize'
	'ngTouch'
	#'pascalprecht.translate'
	'ui.bootstrap'
	'ui.router'
	'ui.select'
	'angular-loading-bar'
	#'ngCkeditor'
	#'restangular'
	'uiBreadcrumbs'
	'toastr'
	'http-auth-interceptor'
	'ui.grid'
	'ui.grid.edit'
	'ui.grid.resizeColumns'
	'ui.grid.exporter'
	'ui.grid.selection'
	'ui.grid.cellNav'
	'ui.grid.autoResize'
	'angularFileUpload'
	'FBAngular'
	#'ui.sortable'
	#'as.sortable'
])
#- Valores que usaremos para nuestro proyecto
.constant('App', (()->

	#dominio = 'http://lalvirtual.com/' 
	#dominio = 'http://localhost/' # Pruebas en mi localhost
	#console.log 'Entra al dominio: ', location.hostname
	dominio = location.protocol + '//' + location.hostname + '/'

	if(location.hostname.match('lalvirtual'))
		dominio = 'http://lalvirtual.com/'
	
	#server = dominio + 'myvc_server/public/'
	server = dominio + '5myvc/public/'
	frontapp = dominio + 'myvc_front/'




	return {
		Server: server
		views: 'views/'
		#views: server + 'views/dist/views/' # Para el server Laravel
		images: server + 'images/'
		perfilPath: server + 'images/perfil/'
		imgSharedPath: server + 'images/shared/'
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
	can_work_like_admin:		'can_work_like_admin'
	can_work_like_teacher:		'can_work_like_teacher'
	can_work_like_student:		'can_work_like_student'
	can_work_like_acudiente:	'can_work_like_acudiente'
	can_accept_images:			'can_accept_images'
	can_edit_alumnos:			'can_edit_alumnos'
	can_edit_usuarios:			'can_edit_usuarios'
	can_edit_notas:				'can_edit_notas'
	can_edit_years:				'can_edit_years'
	can_edit_periodos:			'can_edit_periodos'
	can_edit_paises:			'can_edit_paises'
	can_edit_ciudades:			'can_edit_ciudades'
	can_edit_disciplinas:		'can_edit_disciplinas'
	can_edit_profesores:		'can_edit_profesores'
	can_edit_eventos:			'can_edit_eventos'
	can_edit_votaciones:		'can_edit_votaciones'
	can_edit_aspiraciones:		'can_edit_aspiraciones'
	can_edit_participantes:		'can_edit_participantes'
	can_edit_candidatos:		'can_edit_candidatos'
	can_edit_unidades_subunidades:	'can_edit_unidades_subunidades'
})


