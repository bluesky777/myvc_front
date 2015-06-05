angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state

		.state 'panel.notas',
			url: '^/notas/:asignatura_id'
			views: 
				'maincontent':
					templateUrl: "#{App.views}notas/notas.tpl.html"
					controller: 'NotasCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve: 
						titulo: [->
							'Notas'
						]
			resolve: 
				notas: ['NotasServ', '$stateParams', (NotasServ, $stateParams)->
					NotasServ.detalladas($stateParams.asignatura_id)
				]
				escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
					#debugger
					EscalasValorativasServ.escalas()
				]
			data: 
				displayName: 'Notas'
				icon_fa: 'fa fa-graduation-cap'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_notas]
				pageTitle: 'Notas - MyVc'

		.state 'panel.ausencias',
			url: '^/ausencias/:asignatura_id'
			views: 
				'maincontent':
					templateUrl: "#{App.views}notas/ausencias.tpl.html"
					controller: 'AusenciasCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve: 
						titulo: [->
							'Ausencias'
						]
			resolve: 
				ausencias: ['AusenciasServ', '$stateParams', (AusenciasServ, $stateParams)->
					AusenciasServ.detalladas($stateParams.asignatura_id)
				]
			data: 
				displayName: 'Ausencias'
				icon_fa: 'fa fa-apple'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_notas]
				pageTitle: 'Ausencias - MyVc'


		.state 'panel.comportamiento',
			url: '^/comportamiento/:grupo_id'
			views: 
				'maincontent':
					templateUrl: "#{App.views}notas/comportamiento.tpl.html"
					controller: 'ComportamientoCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve: 
						titulo: [->
							'Comportamiento'
						]
			resolve: 
				comportamiento: ['ComportamientoServ', '$stateParams', (ComportamientoServ, $stateParams)->
					ComportamientoServ.detallados($stateParams.grupo_id)
				]
			data: 
				displayName: 'Comportamiento'
				icon_fa: 'fa fa-street-view'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_notas]
				pageTitle: 'Comportamiento - MyVc'


		.state 'panel.notas_alumno',
			url: '^/notas_alumno/:alumno_id'
			params:
				alumno_id:
					value: null
			views: 
				'maincontent':
					templateUrl: "#{App.views}notas/notasAlumno.tpl.html"
					controller: 'NotasAlumnoCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve: 
						titulo: [->
							'Notas alumno'
						]
			resolve: 
				resolved_user: ['AuthService', (AuthService)->
					AuthService.verificar()
				]
				alumnos: ['AlumnosServ', 'AuthService', (AlumnosServ, AuthService)->
					if AuthService.hasRoleOrPerm(['alumno', 'acudiente'])
						return 'Sin alumnos'
					AlumnosServ.getAlumnos()
				]
				escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
					#debugger
					EscalasValorativasServ.escalas()
				]

			data: 
				displayName: 'Notas alumno'
				icon_fa: 'fa fa-graduation-cap'
				needed_permissions: [PERMISSIONS.can_work_like_student, PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_notas]
				pageTitle: 'Notas alumno - MyVc'



])






