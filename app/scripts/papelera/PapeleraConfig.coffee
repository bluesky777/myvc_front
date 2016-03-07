angular.module('myvcFrontApp')
.config ['$stateProvider', 'USER_ROLES', 'PERMISSIONS', ($state, USER_ROLES, PERMISSIONS) ->

	$state
		.state 'panel.papelera',
			url: '^/papelera'
			views: 
				'maincontent':
					templateUrl: "==papelera/papelera.tpl.html"
					controller: 'PapeleraCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Papelera de reciclaje'
						]
			data: 
				displayName: 'Papelera'
				icon_fa: 'fa fa-trash'
				#Permissions: [PERMISSIONS.can_see_alumnos]
				pageTitle: 'Papelera - MyVc'

]