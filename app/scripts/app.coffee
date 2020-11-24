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
	'ckeditor'
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
	'ui.grid.pinning'
	'ui.grid.expandable'
	'ui.grid.moveColumns'
	#'angular-ui-grid-translate'
	#'angularFileUpload'
	'ngFileUpload'
	'FBAngular'
	'nvd3' # Para los gráficos
	#'ui.sortable'
	#'as.sortable'
	'angular-sortable-view'
	'ui.calendar'
])
#- Valores que usaremos para nuestro proyecto
.constant('App', (()->

	#dominio = 'http://lalvirtual.com/'
	#dominio = 'http://localhost/' # Pruebas en mi localhost
	#console.log 'Entra al dominio: ', location.hostname

	#if(location.hostname.match('lalvirtual'))
	#	dominio = location.protocol + '//lalvirtual.com/'

	#server = dominio + 'myvc_server/public/'
	#server 		= dominio + '5myvc/public/'
	#frontapp 	= dominio + 'myvc_front/'

	dominio 	= location.protocol + '//' + location.hostname + '/'
	
	if location.hostname == 'localhost'
		dominio 	= location.protocol + '//' + location.hostname + ':8080/'
		
	server 		= dominio + '5myvc/public/'
	frontapp 	= location.origin + '/myvc_front/'

	# Para el demo
	if(location.href.indexOf('demo') > 0)
		server = dominio + 'demo/5myvc/public/'


	return {
		Server: server
		views: 'views/'
		#views: server + 'views/dist/views/' # Para el server Laravel
		images: server + 'images/'
		perfilPath: server + 'images/perfil/'
		imgSharedPath: server + 'images/shared/'
		parentescos: [
			{ parentesco: 	'Padre' }
			{ parentesco: 	'Madre' }
			{ parentesco: 	'Hermano' }
			{ parentesco: 	'Hermana' }
			{ parentesco: 	'Abuelo' }
			{ parentesco: 	'Abuela' }
			{ parentesco: 	'Tío' }
			{ parentesco: 	'Tía' }
			{ parentesco: 	'Primo(a)' }
			{ parentesco: 	'Otro' }
		]
		opciones_programar: [
			{ opcion: 	'MATRIC CONDICIONAL' }
			{ opcion: 	'COMPROM ACADÉMICO' }
			{ opcion: 	'COMPROM DISCIPLINARIO' }
			{ opcion: 	'COMPROM ACADÉMICO Y DISCIPLINARIO' }
			{ opcion: 	'PÉRDIDA DE CUPO' }
			{ opcion: 	'CAMBIO INSTITUCIÓN' }
			{ opcion: 	'OTRO' }
		]
		sangres: [
			{sangre: 'O+'},
			{sangre: 'O-'},
			{sangre: 'A+'},
			{sangre: 'A-'},
			{sangre: 'B+'},
			{sangre: 'B-'},
			{sangre: 'AB+'},
			{sangre: 'AB-'}
		]
		religiones:     ['Adventista', 'Católico', 'Pentecostal', 'Cuadrangular', 'Testigo de Jehová', 'Mormón', 'Otra', 'Ninguna']
		tipos_sangre:   ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-']
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
	rector: 'rector'
	enfermero: 'enfermero'
	psicologo: 'psicólogo'
	coord_academico: 'Coord académico'
	coord_disciplinario: 'Coord disciplinario'
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



window.validateEmail = (email)->
	re = /\S+@\S+\.\S+/;
	return re.test(email);

window.fixHora = (ti)->
	hora 	= ti.getHours();
	if (hora<10)
		hora = '0' + hora;
	min 	= ti.getMinutes();
	if (min<10)
		min = '0' + min;
	sec 	= ti.getSeconds();
	if (sec<10)
		sec = '0' + sec;

	time 	= hora + ':' + min + ':' + sec;

	return time;

