angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state



		.state 'panel.informes.listado_profesores',
			url: '/listado_profesores'
			views:
				'report_content':
					templateUrl: "==informes2/listadoProfesores.tpl.html"
					controller: 'ListadoProfesoresCtrl'
					resolve:
						profesores: ['$http', '$stateParams', ($http)->
							$http.put('::profesores/listado')
						]
			data:
				displayName: 'Listado profesores'
				icon_fa: 'fa fa-print'
				pageTitle: 'Listado profesores - MyVc'





])





