angular.module('myvcFrontApp')
.config ['$stateProvider', 'App', 'PERMISSIONS', ($state, App, PERMISSIONS) ->

	$state
		.state 'panel.unidades',
			url: '/unidades/:asignatura_id'
			views: 
				'maincontent':
					templateUrl: "#{App.views}unidades/unidades.tpl.html"
					controller: 'UnidadesCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: ['AuthService', '$q', (AuthService, $q)->
							d = $q.defer()

							console.log 'Entra al resolve de unidades'
							AuthService.verificar().then((r)->
								d.resolve r.unidades_displayname
							, (r2)->
								console.log 'No se resolvió en Unidades, ', r2
								d.resolve 'Unidades'

							)

							return d.promise
						]
			resolve:
				usuario: ['AuthService', (AuthService)->
					AuthService.verificar()
				]

			data: 
				displayName: 'Unidades'
				icon_fa: 'fa fa-graduation-cap'
				pageTitle: 'Unidades - MyVc'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_edit_unidades_subunidades]

]