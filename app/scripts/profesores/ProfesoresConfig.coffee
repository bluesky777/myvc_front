'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', ($state) ->

		$state
			.state 'panel.profesores.nuevo',
				url: '/nuevo'
				views: 
					'edit_profesor':
						templateUrl: "==profesores/profesoresNew.tpl.html"
						controller: 'ProfesoresNewCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
						templateUrl: "==profesores/profesoresEdit.tpl.html"
						controller: 'ProfesoresEditCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
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
