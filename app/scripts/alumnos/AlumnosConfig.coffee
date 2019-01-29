'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', 'PERMISSIONS', 'USER_ROLES', ($state, App, PERMISSIONS, USER_ROLES) ->

		$state

			.state 'panel.prematriculas',
				url: '^/prematriculas'
				views:
					'maincontent':
						templateUrl: "==alumnos/prematriculas.tpl.html"
						controller: 'PrematriculasCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Prematrículas'
							]
				data:
					displayName: 'Prematrículas'
					icon_fa: 'fa fa-male'
					needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]
					pageTitle: 'Prematrículas - MyVc'

			.state 'panel.prematriculas.nuevo',
				url: '/nuevo'
				views:
					'edit_alumno':
						templateUrl: "#{App.views}alumnos/alumnosNew.tpl.html"
						controller: 'AlumnosNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo alumno'
							]
				data:
					displayName: 'Nuevo'
					icon_fa: 'fa fa-male'
					pageTitle: 'Nuevo alumno - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]




			.state 'panel.requisitos',
				url: '^/requisitos'
				views:
					'maincontent':
						templateUrl: "==alumnos/requisitos.tpl.html"
						controller: 'RequisitosCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Requisitos'
							]
				data:
					displayName: 'Requisitos'
					icon_fa: 'fa fa-file'
					needed_permissions: [PERMISSIONS.can_work_like_admin]
					pageTitle: 'Requisitos - MyVc'


			.state 'panel.promocionar_notas',
				url: '/promocionar_notas'
				views:
					'maincontent':
						templateUrl: "#{App.views}alumnos/promocionarNotas.tpl.html"
						controller: 'PromocionarNotasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Promocionar notas de alumno promovido'
							]
				data:
					displayName: 'Promocionar notas'
					icon_fa: 'fa fa-apple'
					pageTitle: 'Promocionar notas - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher]


			.state 'panel.alumnos.nuevo',
				url: '/nuevo'
				views:
					'edit_alumno':
						templateUrl: "#{App.views}alumnos/alumnosNew.tpl.html"
						controller: 'AlumnosNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo alumno'
							]
				data:
					displayName: 'Nuevo'
					icon_fa: 'fa fa-male'
					pageTitle: 'Nuevo alumno - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]


			.state 'panel.alumnos.editar',
				url: '/editar/:alumno_id'
				views:
					'edit_alumno':
						templateUrl: "#{App.views}alumnos/alumnosEdit.tpl.html"
						controller: 'AlumnosEditCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Editar alumno'
							]
				data:
					displayName: 'Editar'
					icon_fa: 'fa fa-users'
					pageTitle: 'Editar alumno - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]


			.state 'panel.listalumnos',
				url: '^/listalumnos/:grupo_id'
				param:
					grupo_id: null
				views:
					'maincontent':
						templateUrl: "#{App.views}alumnos/listAlumnos.tpl.html"
						controller: 'ListAlumnosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Listado de alumnos'
							]
				data:
					displayName: 'Listado'
					icon_fa: 'fa fa-users'
					pageTitle: 'Listado alumnos - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher]



			.state 'panel.matriculas',
				url: '^/matriculas'
				views:
					'maincontent':
						templateUrl: "#{App.views}alumnos/matriculas.tpl.html"
						controller: 'MatriculasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Matrículas de alumnos'
							]
				data:
					displayName: 'matriculas'
					icon_fa: 'fa fa-users'
					pageTitle: 'Matrículas alumnos - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]


		$state
			.state 'panel.matriculas.nuevo',
				url: '/nuevo'
				views:
					'edit_alumno':
						templateUrl: "#{App.views}alumnos/alumnosNew.tpl.html"
						controller: 'AlumnosNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo alumno'
							]
				data:
					displayName: 'Nuevo'
					icon_fa: 'fa fa-male'
					pageTitle: 'Nuevo alumno - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]


		$state
			.state 'panel.persona.nuevo',
				url: '/nuevo'
				views:
					'edit_alumno':
						templateUrl: "#{App.views}alumnos/alumnosNew.tpl.html"
						controller: 'AlumnosNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo alumno'
							]
				data:
					displayName: 'Nuevo'
					icon_fa: 'fa fa-male'
					pageTitle: 'Nuevo alumno - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]


			.state 'panel.persona.ver_todos_los_certificados',
				url: '/todos_los_certificados'
				params:
					alumno_id: {value: null}
				views:
					'report_content':
						templateUrl: "#{App.views}persona/certificadoEstudioPersona.tpl.html"
						controller: 'VerTodosLosCertificadosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Ver todos los certificados'
							]
				data:
					displayName: 'Todos los certificados'
					icon_fa: 'fa fa-print'
					pageTitle: 'Todos los certificados - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin, PERMISSIONS.can_edit_alumnos]



			.state 'panel.matriculas.detalles',
				url: '^/matriculas/detalles/:alumno_id'
				param:
					alumno_id: null
				views:
					'matricula_detalle':
						templateUrl: "#{App.views}alumnos/matriculasDetalles.tpl.html"
						controller: 'MatriculasDetallesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Matrículas detalladas'
							]
				data:
					displayName: 'detalles'
					icon_fa: 'fa fa-pencil'
					pageTitle: 'Matrículas alumnos - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_admin ]

			.state 'panel.alumnos.matricula_detalles',
				url: '^/alumnos/matricula_detalles/:alumno_id'
				param:
					alumno_id: null
				views:
					'matricula_detalle':
						templateUrl: "#{App.views}alumnos/matriculasDetalles.tpl.html"
						controller: 'MatriculasDetallesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Matrículas detalladas'
							]
				data:
					displayName: 'detalles'
					icon_fa: 'fa fa-pencil'
					pageTitle: 'Matrículas alumnos - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_admin ]

			.state 'panel.prematriculas.matricula_detalles',
				url: '^/prematriculas/matricula_detalles/:alumno_id'
				param:
					alumno_id: null
				views:
					'matricula_detalle':
						templateUrl: "#{App.views}alumnos/matriculasDetalles.tpl.html"
						controller: 'MatriculasDetallesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Matrículas detalladas'
							]
				data:
					displayName: 'detalles'
					icon_fa: 'fa fa-pencil'
					pageTitle: 'Matrículas alumnos - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_admin ]

			.state 'panel.matriculas.detalles.periodos',
				url: '^/matriculas/detalles/:alumno_id/periodos'
				param:
					alumno_id: null
				views:
					'matricula_detalle_periodos':
						templateUrl: "#{App.views}alumnos/matriculasDetallesPeriodos.tpl.html"
						controller: 'MatriculasDetallesPeriodosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Matrículas detalladas'
							]
				data:
					displayName: 'periodos'
					icon_fa: 'fa fa-ioxhost'
					pageTitle: 'Matrículas alumnos - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_admin]





			.state 'panel.cartera',
				url: '^/cartera'
				views:
					'maincontent':
						templateUrl: "#{App.views}alumnos/cartera.tpl.html"
						controller: 'CarteraCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Cartera'
							]
				data:
					displayName: 'cartera'
					icon_fa: 'fa fa-money'
					pageTitle: 'Cartera - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher]


			.state 'panel.cartera.editar',
				url: '/editar/:alumno_id'
				views:
					'edit_alumno':
						templateUrl: "#{App.views}alumnos/alumnosEdit.tpl.html"
						controller: 'AlumnosEditCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Editar'
							]
				data:
					displayName: 'editar'
					icon_fa: 'fa fa-users'
					pageTitle: 'Editar alumno - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher]



			.state 'panel.acudientes',
				url: '^/acudientes'
				views:
					'maincontent':
						templateUrl: "#{App.views}alumnos/acudientes.tpl.html"
						controller: 'AcudientesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Acudientes'
							]
				data:
					displayName: 'Acudientes'
					icon_fa: 'fa fa-users'
					pageTitle: 'Acudientes - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher]


			.state 'panel.asistencias',
				url: '^/asistencias'
				views:
					'maincontent':
						templateUrl: "#{App.views}alumnos/asistencias.tpl.html"
						controller: 'AsistenciasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Asistencias a la institución'
							]
				data:
					displayName: 'Asistencias a la institución'
					icon_fa: 'fa fa-users'
					pageTitle: 'Asistencias - MyVc'
					needed_permissions: [PERMISSIONS.can_work_like_teacher]




			.state 'panel.persona',
				url: '^/persona/:persona_id/:tipo'
				param:
					persona_id:  null
					tipo:       null
				views:
					'maincontent':
						templateUrl: "#{App.views}alumnos/persona.tpl.html"
						controller: 'PersonaCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Detalle de persona'
							]
				data:
					displayName: 'Persona'
					icon_fa: 'fa fa-users'
					pageTitle: 'Persona - MyVc'
					needed_roles: [USER_ROLES.admin, USER_ROLES.psicologo, USER_ROLES.enfermero, USER_ROLES.acudiente, USER_ROLES.alumno, USER_ROLES.coord_academico, USER_ROLES.coord_disciplinario]



		return
	]
