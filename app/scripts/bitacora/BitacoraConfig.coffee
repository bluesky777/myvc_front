angular.module('myvcFrontApp')
.config ['$stateProvider', 'App', ($state, App) ->

	$state
		.state 'panel.bitacora',
			url: '/bitacora'
			views: 
				'maincontent':
					templateUrl: "#{App.views}bitacora/bitacora.tpl.html"
					controller: 'BitacoraCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Bitacora'
						]
			data: 
				displayName: 'Bitacora'
				icon_fa: 'fa fa-male'


]