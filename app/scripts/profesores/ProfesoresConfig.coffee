'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', ($state, App) ->

		$state
			.state 'panel.profesores.nuevo',
				url: '/nuevo'
				views: 
					'edit_profesor':
						templateUrl: "#{App.views}profesores/profesoresNew.tpl.html"
						controller: 'ProfesoresNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo profesor'
							]
				data: 
					displayName: 'Nuevo'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Profesor nuevo - MyVc'


			.state 'panel.profesores.editar',
				url: '/editar/:profe_id'
				views: 
					'edit_profesor':
						templateUrl: "#{App.views}profesores/profesoresEdit.tpl.html"
						controller: 'ProfesoresEditCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve: 
							titulo: [->
								'Editar alumno'
							]
				data: 
					displayName: 'Editar'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Editar profesor - MyVc'


		return
	]
