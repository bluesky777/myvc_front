'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', 'PERMISSIONS', ($state, App, PERMISSIONS) ->

		$state
			.state 'panel.actividades',
				url: '^/actividades?grupo_id&asign_id'
				params: {
					grupo_id: null
					asign_id: null
				}
				views: 
					'maincontent':
						templateUrl: "#{App.views}actividades/actividades.tpl.html"
						controller: 'ActividadesCtrl'
						resolve:
							datos: ['$q', '$http', '$stateParams', ($q, $http, $stateParams)->
								d = $q.defer();

								parametros = {
									grupo_id: $stateParams.grupo_id
									asign_id: $stateParams.asign_id
								}

								$http.put('::actividades/datos', parametros).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2
								)
								return d.promise
							]
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



			.state 'panel.editar_actividad',
				url: '^/editar-actividad?actividad_id'
				views: 
					'maincontent':
						templateUrl: "#{App.views}actividades/editarActividad.tpl.html"
						controller: 'EditarActividadCtrl'
						resolve:
							datos: ['$q', '$http', '$stateParams', ($q, $http, $stateParams)->
								d = $q.defer();

								$http.put('::actividades/edicion', { actividad_id: $stateParams.actividad_id }).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2
								)
								return d.promise
							]
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Editar actividad'
							]

				data: 
					displayName: 'Editar actividad'
					icon_fa: 'fa fa-soccer-ball-o'
					pageTitle: 'Editar actividades - MyVc'



		return
	]
