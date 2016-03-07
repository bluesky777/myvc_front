'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'USER_ROLES', 'PERMISSIONS', ($state, USER_ROLES, PERMISSIONS) ->

		$state
			.state 'panel.alumnos',
				url: '^/alumnos'
				views: 
					'maincontent':
						templateUrl: "==alumnos/alumnos.tpl.html"
						controller: 'AlumnosCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
						templateUrl: "==mensajes/mensajes.tpl.html"
						controller: 'MensajesCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Mensajes'
							]
				data: 
					displayName: 'Mensajes'
					icon_fa: 'fa fa-envelope'

			.state 'panel.years',
				url: '^/years'
				views: 
					'maincontent':
						templateUrl: "==colegio/years.tpl.html"
						controller: 'YearsCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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





			.state 'panel.paises',
				url: '^/paises'
				views: 
					'maincontent':
						templateUrl: "==paises/paises.tpl.html"
						controller: 'PaisesCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
						templateUrl: "==profesores/profesores.tpl.html"
						controller: 'ProfesoresCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
						templateUrl: "==ciudades/ciudades.tpl.html"
						controller: 'CiudadesCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
						templateUrl: "==disciplinas/disciplinas.tpl.html"
						controller: 'DisciplinasCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
						templateUrl: "==eventos/eventos.tpl.html"
						controller: 'EventosCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
