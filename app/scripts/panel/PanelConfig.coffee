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
					Permissions: [PERMISSIONS.can_see_alumnos]


			.state 'panel.usuarios',
				url: '^/users'
				views: 
					'maincontent':
						templateUrl: "#{App.views}usuarios/usuarios.tpl.html"
						controller: 'UsuariosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Usuarios'
							]
				data: 
					displayName: 'Usuarios'
					icon_fa: 'fa fa-users'
					Permissions: [PERMISSIONS.can_see_usuarios]


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
				url: '^/notas'
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
				data: 
					displayName: 'Notas'
					icon_fa: 'fa fa-graduation-cap'
					Permissions: [PERMISSIONS.can_see_notas]


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
					Permissions: [PERMISSIONS.can_see_years]



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
					Permissions: [PERMISSIONS.can_see_periodos]




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
					Permissions: [PERMISSIONS.can_see_paises]



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
					Permissions: [PERMISSIONS.can_see_all_paises]


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
					Permissions: [PERMISSIONS.can_see_ciudades]


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
					Permissions: [PERMISSIONS.can_see_disciplinas]

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
					Permissions: [PERMISSIONS.can_see_eventos]
		return
	]
