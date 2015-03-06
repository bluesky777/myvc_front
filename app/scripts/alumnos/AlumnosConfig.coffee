'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', 'PERMISSIONS', ($state, App, PERMISSIONS) ->

		$state
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


		return
	]
