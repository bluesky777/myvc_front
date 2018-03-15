angular.module('myvcFrontApp')
.config(['$stateProvider', 'USER_ROLES', 'PERMISSIONS', ($state, USER_ROLES, PERMISSIONS) ->

	$state
		.state 'panel.usuarios',
			url: '^/usuarios'
			views:
				'maincontent':
					templateUrl: "==usuarios/usuarios.tpl.html"
					controller: 'UsuariosCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
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
					templateUrl: "==usuarios/user.tpl.html"
					controller: 'UserCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Perfil'
						]
			resolve:
				perfilactual: ['$http', '$stateParams', '$q', '$state', 'toastr', ($http, $stateParams, $q, $state, toastr)->
					d = $q.defer()

					username = $stateParams.username

					if username or username == ''
						$http.get('::perfiles/username/'+username).then((r)->
							#console.log 'Perfilactual en el resolve:', r[0]
							if r.data[0].fecha_nac
								r.data[0].fecha_nac = if r.data[0].fecha_nac then new Date(r.data[0].fecha_nac.replace(/-/g, '\/')) else r.data[0].fecha_nac
							d.resolve r.data[0]
						, (r2)->
							#$state.transitionTo 'panel'
							d.reject r2
						)
					else
						toastr.warning 'Lo sentimos, nombre de usuario no encontrado'
						$state.go 'panel'

					return d.promise
				]

			data:
				displayName: 'Perfil'
				icon_fa: 'fa fa-user'


		.state 'panel.user.resumen',
			url: '/r'
			views:
				'user_detail':
					templateUrl: "==usuarios/userResumen.tpl.html"
					controller: 'UserResumenCtrl'
			data:
				displayName: 'Resumen'
				icon_fa: 'fa fa-user'

		.state 'panel.user.configuracion',
			url: '/c'
			views:
				'user_detail':
					templateUrl: "==usuarios/userConfiguracion.tpl.html"
					controller: 'UserConfiguracionCtrl'
			data:
				displayName: 'Configuración de perfil'
				icon_fa: 'fa fa-user'


		.state 'panel.usuarios.roles',
			url: '/roles'
			views:
				'user_roles':
					templateUrl: "==usuarios/roles.tpl.html"
					controller: 'RolesCtrl'
			data:
				displayName: 'Roles'
				icon_fa: 'fa fa-user-secret'





		.state 'panel.usuarios.editar',
			url: '/editar/:user_id'
			views:
				'edit_user':
					templateUrl: "==usuarios/usuariosEdit.tpl.html"
					controller: 'UsuariosEditCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Editar alumno'
						]
			data:
				displayName: 'Editar'
				icon_fa: 'fa fa-users'
				pageTitle: 'Editar alumno - MyVc'


	return
])



