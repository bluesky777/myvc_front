angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state
		.state 'panel.usuarios',
			url: '^/usuarios'
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
				icon_fa: 'fa fa-user'
				needed_permissions: [PERMISSIONS.can_edit_usuarios]
				pageTitle: 'Usuarios - MyVc'

		.state 'panel.user',
			url: '^/user/:username'
			views: 
				'maincontent':
					templateUrl: "#{App.views}usuarios/user.tpl.html"
					controller: 'UserCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Perfil'
						]
			data: 
				displayName: 'Perfil'
				icon_fa: 'fa fa-user'

		.state 'panel.user.resumen',
			url: '/r'
			views: 
				'user_detail':
					templateUrl: "#{App.views}usuarios/userResumen.tpl.html"
					controller: 'UserResumenCtrl'
			data: 
				displayName: 'Resumen'
				icon_fa: 'fa fa-user'

		.state 'panel.user.configuracion',
			url: '/c'
			views: 
				'user_detail':
					templateUrl: "#{App.views}usuarios/userConfiguracion.tpl.html"
					controller: 'UserConfiguracionCtrl'
			data: 
				displayName: 'Configuración de perfil'
				icon_fa: 'fa fa-user'


		.state 'panel.usuarios.roles',
			url: '/roles'
			views: 
				'user_roles':
					templateUrl: "#{App.views}usuarios/roles.tpl.html"
					controller: 'RolesCtrl'
			data: 
				displayName: 'Roles'
				icon_fa: 'fa fa-user-secret'

	return
])



