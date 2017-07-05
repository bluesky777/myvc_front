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


		$state
			.state 'panel.respuestas',
				url: '^/respuestas?actividad_id'
				params: {
					actividad_id: null
				}
				views: 
					'maincontent':
						templateUrl: "#{App.views}actividades/respuestas.tpl.html"
						controller: 'RespuestasCtrl'
						resolve:
							datos: ['$q', '$http', '$stateParams', ($q, $http, $stateParams)->
								d = $q.defer();

								parametros = {
									actividad_id: $stateParams.actividad_id
								}

								$http.put('::respuestas/actividad', parametros).then((r)->
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
								'Respuestas'
							]

				data: 
					displayName: 'Respuestas'
					icon_fa: 'fa fa-soccer-ball-o'
					pageTitle: 'Respuestas - MyVc'



		$state
			.state 'panel.mis_actividades',
				url: '^/mis-actividades?alumno_id&asign_id'
				params: {
					alumno_id: null
					asign_id: null
				}
				views: 
					'maincontent':
						templateUrl: "#{App.views}actividades/misActividades.tpl.html"
						controller: 'MisActividadesCtrl'
						resolve:
							datos: ['$q', '$http', '$stateParams', ($q, $http, $stateParams)->
								d = $q.defer();

								parametros = {
									alumno_id: $stateParams.alumno_id
									asign_id: $stateParams.asign_id
								}

								$http.put('::mis-actividades/datos', parametros).then((r)->
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
								'Mis actividades'
							]

				data: 
					displayName: 'Mis actividades'
					icon_fa: 'fa fa-soccer-ball-o'
					pageTitle: 'Mis actividades - MyVc'


		$state
			.state 'panel.mi_actividad',
				url: '^/mi-actividad?actividad_id'
				params: {
					actividad_id: null
				}
				views: 
					'maincontent':
						templateUrl: "#{App.views}actividades/miActividad.tpl.html"
						controller: 'MiActividadCtrl'
						resolve:
							datos: ['$q', '$http', '$stateParams', ($q, $http, $stateParams)->
								d = $q.defer();

								parametros = {
									actividad_id: $stateParams.actividad_id
								}

								$http.put('::mis-actividades/mi-actividad', parametros).then((r)->
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
								'Actividad'
							]

				data: 
					displayName: 'Actividad'
					icon_fa: 'fa fa-soccer-ball-o'
					pageTitle: 'Actividad - MyVc'



			.state 'panel.editar_actividad',
				url: '^/editar-actividad?actividad_id'
				params: {
					actividad_id: null
				}
				views: 
					'maincontent':
						templateUrl: "#{App.views}actividades/editarActividad.tpl.html"
						controller: 'EditarActividadCtrl'
						resolve:
							datos: ['$q', '$http', '$stateParams', ($q, $http, $stateParams)->
								d = $q.defer();

								actividad_id = 0
								
								if $stateParams.actividad_id
									actividad_id = $stateParams.actividad_id
								else
									actividad_id = localStorage.pregunta_edit.actividad_id
								
								$http.put('::actividades/edicion', { actividad_id: $stateParams.actividad_id }).then((r)->
									if localStorage.pregunta_edit
										for preg in r.data.actividad.preguntas
											pregunta_edit = JSON.parse(localStorage.pregunta_edit)
											localStorage.pregunta_edit = JSON.stringify(preg) if preg.id==pregunta_edit.id
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
					pageTitle: 'Editar actividad - MyVc'


			.state 'panel.editar_actividad.pregunta',
				url: '/pregunta?pregunta_id'
				views: 
					'preguntacontent':
						templateUrl: "#{App.views}actividades/editarPregunta.tpl.html"
						controller: 'EditarPreguntaCtrl'
						resolve:
							datos: ['$q', '$http', '$stateParams', '$location', ($q, $http, $stateParams, $location)->
								d = $q.defer();
								
								if $stateParams.pregunta_id

									$http.put('::preguntas/edicion', { pregunta_id: $stateParams.pregunta_id }).then((r)->
										d.resolve r.data
									, (r2)->
										d.reject r2
									)

								else if localStorage.pregunta_edit
									preg = JSON.parse(localStorage.pregunta_edit)
									#$location.search('pregunta_id', preg.id)
									d.resolve preg
								else
									console.log 'No se ha provisto id ni pregunta'
									d.reject 'No se ha provisto id ni pregunta'

								return d.promise
							]
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Pregunta'
							]

				data: 
					displayName: 'Pregunta'
					icon_fa: 'fa fa-question'
					pageTitle: 'Pregunta - MyVc'



		return
	]
