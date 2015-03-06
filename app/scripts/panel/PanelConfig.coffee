'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

		$state
			.state 'panel.alumnos',
				url: '^/alumnos'
				views: 
					'maincontent':
						templateUrl: "#{App.views}alumnos/alumnos.tpl.html"
						controller: 'AlumnosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Alumnos'
							]
				data: 
					displayName: 'Alumnos'
					icon_fa: 'fa fa-male'
					needed_permissions: [PERMISSIONS.can_edit_alumnos]
					pageTitle: 'Alumnos - MyVc'



			.state 'panel.mensajes',
				url: '^/mensajes'
				views: 
					'maincontent':
						templateUrl: "#{App.views}mensajes/mensajes.tpl.html"
						controller: 'MensajesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Mensajes'
							]
				data: 
					displayName: 'Mensajes'
					icon_fa: 'fa fa-envelope'

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


			.state 'panel.years',
				url: '^/years'
				views: 
					'maincontent':
						templateUrl: "#{App.views}colegio/years.tpl.html"
						controller: 'YearsCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Años'
							]
				data: 
					displayName: 'Años'
					icon_fa: 'fa fa-graduation-cap'
					needed_permissions: [PERMISSIONS.can_work_like_admin]
					pageTitle: 'Años - MyVc'



			.state 'panel.periodos',
				url: '^/periodos'
				views: 
					'maincontent':
						templateUrl: "#{App.views}colegio/periodos.tpl.html"
						controller: 'PeriodosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Periodos'
							]
				data: 
					displayName: 'Periodos'
					icon_fa: 'fa fa-graduation-cap'
					needed_permissions: [PERMISSIONS.can_work_like_admin]
					pageTitle: 'Periodos - MyVc'




			.state 'panel.paises',
				url: '^/paises'
				views: 
					'maincontent':
						templateUrl: "#{App.views}paises/paises.tpl.html"
						controller: 'PaisesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Paises'
							]
				data: 
					displayName: 'Paises'
					icon_fa: 'fa fa-flag-checkered'
					needed_permissions: [PERMISSIONS.can_work_like_admin]
					pageTitle: 'Paises - MyVc'



			.state 'panel.profesores',
				url: '^/profesores'
				views: 
					'maincontent':
						templateUrl: "#{App.views}profesores/profesores.tpl.html"
						controller: 'ProfesoresCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Profesores'
							]
				data: 
					displayName: 'Profesores'
					icon_fa: 'fa fa-graduation-cap'
					needed_permissions: [PERMISSIONS.can_work_like_admin]
					pageTitle: 'Profesores - MyVc'


			.state 'panel.ciudades',
				url: '/ciudades'
				views: 
					'maincontent':
						templateUrl: "#{App.views}ciudades/ciudades.tpl.html"
						controller: 'CiudadesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Ciudades'
							]
				data: 
					displayName: 'Ciudades'
					icon_fa: 'fa fa-map-marker'
					needed_permissions: [PERMISSIONS.can_work_like_admin]
					pageTitle: 'Ciudades - MyVc'


			.state 'panel.disciplinas',
				url: '/disciplinas'
				views: 
					'maincontent':
						templateUrl: "#{App.views}disciplinas/disciplinas.tpl.html"
						controller: 'DisciplinasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Disciplinas'
							]
				data: 
					displayName: 'Disciplinas'
					icon_fa: 'fa fa-align-justify'
					pageTitle: 'Disciplinas - MyVc'

			.state 'panel.eventos',
				url: '/eventos'
				views: 
					'maincontent':
						templateUrl: "#{App.views}eventos/eventos.tpl.html"
						controller: 'EventosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Eventos'
							]
				data: 
					displayName: 'Eventos'
					icon_fa: 'fa fa-laptop'
					needed_permissions: [PERMISSIONS.can_work_like_admin]
					pageTitle: 'Eventos - MyVc'
		return
	]
