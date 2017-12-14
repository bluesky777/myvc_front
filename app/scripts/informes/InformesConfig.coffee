angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state


		.state('panel.informes', { #- Estado admin.
			url: '^/informes'
			views:
				'maincontent':
					templateUrl: "==informes/informes.tpl.html"
					controller: 'InformesCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Informes interactivos'
						]
			resolve: { 
				resolved_user: ['AuthService', (AuthService)->
					AuthService.verificar()
				]
				alumnos: ['$http', ($http)->
					$http.get('::alumnos/sin-matriculas')
				]
			}
			data: 
				displayName: 'Informes'
				icon_fa: 'fa fa-print'
				pageTitle: 'Informes - MyVc'
		})

		.state 'panel.informes.boletines_periodo',
			url: '/boletines_periodo/:grupo_id/:periodo_a_calcular'
			params:
				grupo_id: {value: null}
				periodo_a_calcular: {value: null}
			views: 
				'report_content':
					templateUrl: "==informes/boletinesPeriodo.tpl.html"
					controller: 'BoletinesPeriodoCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'
							
							if requested_alumnos

								$http.put('::boletines/detailed-notas/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::boletines/detailed-notas/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::boletines/detailed-notas-group/'+$stateParams.grupo_id, {periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
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
					templateUrl: "==informes/puestosGrupoPeriodo.tpl.html"
					controller: 'PuestosGrupoPeriodoCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', ($http, $stateParams)->
							$http.put('::boletines/detailed-notas/'+$stateParams.grupo_id);
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				pageTitle: 'Puestos periodo - MyVc'






		.state 'panel.informes.puestos_grupo_year',
			url: '/puestos_grupo_year/:grupo_id/:periodo_a_calcular'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/puestosGrupoYear.tpl.html"
					controller: 'PuestosGrupoYearCtrl'
					resolve:
						datos_puestos: ['$http', '$stateParams', ($http, $stateParams)->
							datos = 
								grupo_id: $stateParams.grupo_id
								periodo_a_calcular: $stateParams.periodo_a_calcular
							$http.put('::puestos/detailed-notas-year', datos)
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
			url: '/planillas_grupo/:grupo_id/:periodos_a_calcular'
			views: 
				'report_content':
					templateUrl: "==informes/planillas.tpl.html"
					controller: 'PlanillasCtrl'
					resolve:
						asignaturas: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::planillas/show-grupo/'+$stateParams.grupo_id)
						]
			data: 
				displayName: 'Planillas grupo'
				icon_fa: 'fa fa-print'
				pageTitle: 'Planillas grupo - MyVc'



		.state 'panel.informes.notas_perdidas_profesor',
			url: '/notas_perdidas_profesor/:profesor_id/:periodo_a_calcular'
			views: 
				'report_content':
					templateUrl: "==informes/notasPerdidasProfesor.tpl.html"
					controller: 'NotasPerdidasProfesorCtrl'
					resolve:
						grupos: ['$http', '$stateParams', ($http, $stateParams)->
							$http.put('::notas-perdidas/profesor-grupos', {profesor_id: $stateParams.profesor_id, periodo_a_calcular: $stateParams.periodo_a_calcular} )
						]
			data: 
				displayName: 'Notas perdidas por profesor'
				icon_fa: 'fa fa-print'
				pageTitle: 'Notas perdidas por profesor - MyVc'


		.state 'panel.informes.ver_ausencias',
			url: '/ver_ausencias'
			views: 
				'report_content':
					templateUrl: "==informes/verAusencias.tpl.html"
					controller: 'VerAusenciasCtrl' # En NotasPerdidasProfesorCtrl.coffee
					resolve:
						grupos_ausencias: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::planillas/ver-ausencias')
						]
			data: 
				displayName: 'Ausencias'
				icon_fa: 'fa fa-print'
				pageTitle: 'Ausencias - MyVc'



		.state 'panel.informes.planillas_profesor',
			url: '/planillas_profesor/:profesor_id/:periodos_a_calcular'
			views: 
				'report_content':
					templateUrl: "==informes/planillas.tpl.html"
					controller: 'PlanillasCtrl'
					resolve:
						asignaturas: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::planillas/show-profesor/'+$stateParams.profesor_id)
						]
			data: 
				displayName: 'Planillas profesor'
				icon_fa: 'fa fa-print'
				pageTitle: 'Planillas profesor - MyVc'


		.state 'panel.informes.control_tardanza_entrada',
			url: '/control_tardanza_entrada/:grupo_id'
			views: 
				'report_content':
					templateUrl: "==informes/controlTardanzaEntrada.tpl.html" # En archivo PlanillasCtrl.coffee
					controller: 'ControlTardanzaEntradaCtrl'
					resolve:
						grupos: ['$http', '$stateParams', ($http, $stateParams)->
							$http.put('::planillas-ausencias/tardanza-entrada')
						]
			data: 
				displayName: 'Control de tardanza entrada'
				icon_fa: 'fa fa-print'
				pageTitle: 'Control de tardanza entrada - MyVc'


		.state 'panel.informes.planillas_ausencias1',
			url: '/planillas_ausencias1/:profesor_id'
			views: 
				'report_content':
					templateUrl: "==informes/planillasAusencias1.tpl.html"
					controller: 'PlanillasAusencias1Ctrl'
					resolve:
						asignaturas: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::planillas-ausencias/show-profesor/'+$stateParams.profesor_id)
						]
			data: 
				displayName: 'Planillas profesor'
				icon_fa: 'fa fa-print'
				pageTitle: 'Planillas profesor - MyVc'











		.state 'panel.informes.boletines_finales',
			url: '/boletines_finales/:grupo_id'
			params:
				grupo_id: {value: null}
			views: 
				'report_content':
					templateUrl: "==informes/boletinesFinales.tpl.html"
					controller: 'BoletinesFinalesCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'
							
							if requested_alumnos

								#console.log 'Pidiendo por varios alumnos: ', requested_alumnos
								$http.put('::bolfinales/detailed-notas-year/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::bolfinales/detailed-notas-year/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::bolfinales/detailed-notas-year-group/'+$stateParams.grupo_id).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)


							return d.promise
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				displayName: 'Boletines finales'
				pageTitle: 'Boletines finales - MyVc'






		.state 'panel.informes.certificados_estudio',
			url: '/certificados_estudio/:grupo_id'
			params:
				grupo_id: {value: null}
			views: 
				'report_content':
					templateUrl: "==informes/certificadosEstudio.tpl.html"
					controller: 'CertificadosEstudioCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'
							
							if requested_alumnos

								#console.log 'Pidiendo por varios alumnos: ', requested_alumnos
								$http.put('::bolfinales/detailed-notas-year/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::bolfinales/detailed-notas-year/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								$http.put('::bolfinales/detailed-notas-year/'+$stateParams.grupo_id).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
								


							return d.promise
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				displayName: 'Certificados de estudio'
				pageTitle: 'Certificados de estudio - MyVc'





])





