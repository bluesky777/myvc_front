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
					needed_permissions: [PERMISSIONS.can_work_like_admin]


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
					needed_permissions: [PERMISSIONS.can_work_like_admin]


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
					needed_permissions: [PERMISSIONS.can_work_like_teacher]


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
					needed_permissions: [PERMISSIONS.can_work_like_admin]


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
					needed_permissions: [PERMISSIONS.can_work_like_teacher]

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
					needed_permissions: [PERMISSIONS.can_work_like_teacher]


		return
	]
