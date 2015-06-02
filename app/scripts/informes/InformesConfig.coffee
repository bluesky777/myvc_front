angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state


		.state('panel.informes', { #- Estado admin.
			url: '^/informes'
			views:
				'maincontent':
					templateUrl: "#{App.views}informes/informes.tpl.html"
					controller: 'InformesCtrl'
				'headerContent':
					templateUrl: "#{App.views}panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Informes interactivos'
						]
			resolve: { 
				resolved_user: ['AuthService', (AuthService)->
					AuthService.verificar()
				]
				alumnos: ['AlumnosServ', (AlumnosServ)->
					AlumnosServ.getAlumnos()
				]
			}
			data: 
				displayName: 'Informes'
				icon_fa: 'fa fa-print'
				pageTitle: 'Informes - MyVc'
		})

		.state 'panel.informes.boletines_periodo',
			url: '/boletines_periodo/:grupo_id'
			params:
				grupo_id: {value: null}
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/boletinesPeriodo.tpl.html"
					controller: 'BoletinesPeriodoCtrl'
					resolve:
						alumnosDat: ['Restangular', '$stateParams', '$q', '$cookieStore', (Restangular, $stateParams, $q, $cookieStore)->

							d = $q.defer()


							requested_alumnos = $cookieStore.get 'requested_alumnos'
							requested_alumno = $cookieStore.get 'requested_alumno'
							
							if requested_alumnos

								console.log 'Pidiendo por varios alumnos: ', requested_alumnos
								Restangular.one('alumnos/detailed-notas', $stateParams.grupo_id).customPUT({requested_alumnos: requested_alumnos}).then((r)->
									d.resolve r
								, (r2)->
									d.reject r2
								)
							else if requested_alumno
								Restangular.one('alumnos/detailed-notas', requested_alumno[0].grupo_id).customPUT({requested_alumnos: requested_alumno}).then((r)->
									d.resolve r
								, (r2)->
									d.reject r2
								)
							else
								console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								Restangular.one('alumnos/detailed-notas', $stateParams.grupo_id).getList().then((r)->
									d.resolve r
								, (r2)->
									d.reject r2
								)


							return d.promise
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				displayName: 'Boletines periodo'
				pageTitle: 'Boletines periodo - MyVc'

		.state 'panel.informes.puestos_grupo_periodo',
			url: '/puestos_grupo_periodo/:grupo_id'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/puestosGrupoPeriodo.tpl.html"
					controller: 'PuestosGrupoPeriodoCtrl'
					resolve:
						alumnosDat: ['Restangular', '$stateParams', (Restangular, $stateParams)->
							Restangular.one('alumnos/detailed-notas', $stateParams.grupo_id).getList()
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				pageTitle: 'Puestos periodo - MyVc'

		.state 'panel.informes.puestos_grupo_year',
			url: '/puestos_grupo_year/:grupo_id'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/puestosGrupoYear.tpl.html"
					controller: 'PuestosGrupoYearCtrl'
					resolve:
						alumnosDat: ['Restangular', '$stateParams', (Restangular, $stateParams)->
							Restangular.one('alumnos/detailed-notas-year', $stateParams.grupo_id).getList()
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				displayName: 'Puestos del año'
				icon_fa: 'fa fa-print'
				pageTitle: 'Puestos del año - MyVc'


		.state 'panel.informes.planillas_grupo',
			url: '/planillas_grupo/:grupo_id'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/planillas.tpl.html"
					controller: 'PlanillasCtrl'
					resolve:
						asignaturas: ['Restangular', '$stateParams', (Restangular, $stateParams)->
							Restangular.one('planillas/show-grupo', $stateParams.grupo_id).getList()
						]
			data: 
				displayName: 'Planillas grupo'
				icon_fa: 'fa fa-print'
				pageTitle: 'Planillas grupo - MyVc'


		.state 'panel.informes.planillas_profesor',
			url: '/planillas_profesor/:profesor_id'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/planillas.tpl.html"
					controller: 'PlanillasCtrl'
					resolve:
						asignaturas: ['Restangular', '$stateParams', (Restangular, $stateParams)->
							Restangular.one('planillas/show-profesor', $stateParams.profesor_id).getList()
						]
			data: 
				displayName: 'Planillas profesor'
				icon_fa: 'fa fa-print'
				pageTitle: 'Planillas profesor - MyVc'


])




