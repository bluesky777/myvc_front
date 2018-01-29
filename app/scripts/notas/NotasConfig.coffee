angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state

		.state 'panel.notas',
			url: '^/notas/:asignatura_id'
			views:
				'maincontent':
					templateUrl: "==notas/notas.tpl.html"
					controller: 'NotasCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
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




		.state 'panel.definitivas_periodos',
			url: '^/definitivas-periodos'
			views:
				'maincontent':
					templateUrl: "==notas/definitivasPeriodos.tpl.html"
					controller: 'DefinitivasPeriodosCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Definitivas periodos'
						]
			resolve:
				escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
					#debugger
					EscalasValorativasServ.escalas()
				]
				asignaturas_definitivas: ['$http', 'AuthService', ($http, AuthService)->
					if AuthService.hasRoleOrPerm(['alumno', 'acudiente'])
						return 'Sin alumnos'
					$http.get('::definitivas_periodos')
				]
			data:
				displayName: 'Notas'
				icon_fa: 'fa fa-graduation-cap'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_notas]
				pageTitle: 'Definitivas - MyVc'





		.state 'panel.comportamiento',
			url: '^/comportamiento/:grupo_id'
			views:
				'maincontent':
					templateUrl: "==notas/comportamiento.tpl.html"
					controller: 'ComportamientoCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
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
					templateUrl: "==notas/notasAlumno.tpl.html"
					controller: 'NotasAlumnoCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Notas alumno'
						]
			resolve:
				alumnos: ['$http', 'AuthService', 'resolved_user', ($http, AuthService, resolved_user)->
					if AuthService.hasRoleOrPerm(['alumno', 'acudiente'])
						return 'Sin alumnos'
					$http.get('::alumnos/sin-matriculas')
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



		.state 'panel.notas_perdidas_profesor_edit',
			url: '^/notas_perdidas_profesor_edit'
			views:
				'maincontent':
					templateUrl: "==notas/notasPerdidasProfesorEdit.tpl.html"
					controller: 'NotasPerdidasProfesorEditCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Notas perdidas a editar'
						]


			data:
				displayName: 'Notas perdidas a editar'
				icon_fa: 'fa fa-graduation-cap'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_notas]
				pageTitle: 'Notas perdidas a editar - MyVc'



])






