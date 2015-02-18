'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', ($state, App) ->

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


		return
	]
