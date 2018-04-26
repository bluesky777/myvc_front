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



		.state 'panel.informes.ver_cant_alumnos_por_grupos',
			url: '/ver_cant_alumnos_por_grupos'
			views:
				'report_content':
					templateUrl: "==informes2/verCantAlumnosPorGrupos.tpl.html"
					controller: 'VerCantAlumnosPorGruposCtrl'
					resolve:
						grupos: ['$http', '$stateParams', ($http)->
							$http.get('::grupos')
						]
			data:
				displayName: 'Ver alumnos por grupos'
				icon_fa: 'fa fa-print'
				pageTitle: 'Ver alumnos por grupos - MyVc'





])





