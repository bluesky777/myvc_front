'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', 'PERMISSIONS', ($state, App, PERMISSIONS) ->

		$state
			.state 'panel.actividades',
				url: '^/actividades'
				views: 
					'maincontent':
						templateUrl: "#{App.views}actividades/actividades.tpl.html"
						controller: 'ActividadesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Actividades'
							]
				data: 
					displayName: 'Actividades'
					icon_fa: 'fa fa-soccer-ball-o'
					pageTitle: 'Actividades - MyVc'



		return
	]
