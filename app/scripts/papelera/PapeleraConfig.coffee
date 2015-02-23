angular.module('myvcFrontApp')
.config ['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state
		.state 'panel.papelera',
			url: '^/papelera'
			views: 
				'maincontent':
					templateUrl: "#{App.views}papelera/papelera.tpl.html"
					controller: 'PapeleraCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Papelera de reciclaje'
						]
			data: 
				displayName: 'Papelera'
				icon_fa: 'fa fa-trash'
				#Permissions: [PERMISSIONS.can_see_alumnos]

]