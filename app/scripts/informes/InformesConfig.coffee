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
				alumnos: ['AlumnosSinMatriculaServ', (AlumnosSinMatriculaServ)->
					#$http.get('::alumnos/sin-matriculas')
					AlumnosSinMatriculaServ.alumnos()
				]
				informes_datos: ['InformesServ', (InformesServ)->
					InformesServ.datos()
				]
			}
			data:
				displayName: 'Informes'
				icon_fa: 'fa fa-print'
				pageTitle: 'Informes - MyVc'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin]
				needed_roles: [USER_ROLES.admin, USER_ROLES.psicologo, USER_ROLES.coord_academico, USER_ROLES.coord_disciplinario]
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


							requested_alumnos   = $cookies.getObject 'requested_alumnos'
							requested_alumno    = $cookies.getObject 'requested_alumno'

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


		.state 'panel.informes.boletines_periodo2',
			url: '/boletines_periodo2/:grupo_id/:periodo_a_calcular'
			params:
				grupo_id: {value: null}
				periodo_a_calcular: {value: null}
			views:
				'report_content':
					templateUrl: "==informes2/boletinesPeriodo2.tpl.html"
					controller: 'BoletinesPeriodoCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'

							if requested_alumnos

								$http.put('::boletines2/detailed-notas/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::boletines2/detailed-notas/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::boletines2/detailed-notas-group/'+$stateParams.grupo_id, {periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
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


		.state 'panel.informes.boletines_periodo3',
			url: '/boletines_periodo3/:grupo_id/:periodo_a_calcular'
			params:
				grupo_id: {value: null}
				periodo_a_calcular: {value: null}
			views:
				'report_content':
					templateUrl: "==informes2/boletinesPeriodo3.tpl.html"
					controller: 'BoletinesPeriodoCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'

							if requested_alumnos

								$http.put('::boletines3/detailed-notas/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::boletines3/detailed-notas/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::boletines3/detailed-notas-group/'+$stateParams.grupo_id, {periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
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




		.state 'panel.informes.boletines_periodo4',
			url: '/boletines_periodo4/:grupo_id/:periodo_a_calcular'
			params:
				grupo_id: {value: null}
				periodo_a_calcular: {value: null}
			views:
				'report_content':
					templateUrl: "==informes2/boletinesPeriodo4.tpl.html"
					controller: 'BoletinesPeriodoCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'

							if requested_alumnos

								$http.put('::boletines3/detailed-notas/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::boletines3/detailed-notas/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::boletines3/detailed-notas-group/'+$stateParams.grupo_id, {periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
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
							$http.put('::puestos/detailed-notas-periodo/'+$stateParams.grupo_id);
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
							EscalasValorativasServ.escalas()
						]
			data:
				displayName: 'Puestos del año'
				icon_fa: 'fa fa-print'
				pageTitle: 'Puestos del año - MyVc'



		.state 'panel.informes.puestos_todos_periodo',
			url: '/puestos_todos_periodo'
			views:
				'report_content':
					templateUrl: "==informes/puestosTodosPeriodo.tpl.html"
					controller: 'PuestosTodosPeriodoCtrl'
					resolve:
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							EscalasValorativasServ.escalas()
						]
			data:
				pageTitle: 'Puestos todos periodo - MyVc'



		.state 'panel.informes.puestos_todos_year',
			url: '/puestos_todos_year/:periodo_a_calcular'
			views:
				'report_content':
					templateUrl: "==informes/puestosTodosYear.tpl.html"
					controller: 'PuestosTodosYearCtrl'
					resolve:
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							EscalasValorativasServ.escalas()
						]
			data:
				pageTitle: 'Puestos todos año - MyVc'










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
			url: '/notas_perdidas_profesor/:profesor_id/:periodo_a_calcular/:solo_periodo'
			views:
				'report_content':
					templateUrl: "==informes/notasPerdidasProfesor.tpl.html"
					controller: 'NotasPerdidasProfesorCtrl'
					resolve:
						grupos: ['$http', '$stateParams', ($http, $stateParams)->
							solo_per = if $stateParams.solo_periodo then true else false
							$http.put('::notas-perdidas/profesor-grupos', {profesor_id: $stateParams.profesor_id, periodo_a_calcular: $stateParams.periodo_a_calcular, solo_periodo: solo_per} )
						]
			data:
				displayName: 'Notas perdidas por profesor'
				icon_fa: 'fa fa-print'
				pageTitle: 'Notas perdidas por profesor - MyVc'


		.state 'panel.informes.notas_perdidas_todos',
			url: '/notas_perdidas_profesor/:periodo_a_calcular/:solo_periodo'
			views:
				'report_content':
					templateUrl: "==informes/notasPerdidasTodos.tpl.html"
					controller: 'NotasPerdidasTodosCtrl'
					resolve:
						profesores: ['$http', '$stateParams', ($http, $stateParams)->
							solo_per = if $stateParams.solo_periodo then true else false
							$http.put('::notas-perdidas/todos', {periodo_a_calcular: $stateParams.periodo_a_calcular, solo_periodo: solo_per} )
						]
			data:
				displayName: 'Todas las notas perdidas'
				icon_fa: 'fa fa-print'
				pageTitle: 'Notas perdidas todas - MyVc'


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



		.state 'panel.informes.ver_simat',
			url: '/ver_simat'
			views:
				'report_content':
					templateUrl: "==informes/verSimat.tpl.html"
					controller: 'VerSimatCtrl' # En NotasPerdidasProfesorCtrl.coffee
					resolve:
						grupos_simat: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::planillas/ver-simat')
						]
			data:
				displayName: 'SIMAT'
				icon_fa: 'fa fa-print'
				pageTitle: 'SIMAT - MyVc'


		.state 'panel.informes.listas_personalizadas',
			url: '/listas_personalizadas'
			views:
				'report_content':
					templateUrl: "==informes/listasPersonalizadas.tpl.html"
					controller: 'ListasPersonalizadasCtrl' # En NotasPerdidasProfesorCtrl.coffee
					resolve:
						grupos_simat: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::planillas/listas-personalizadas')
						]
			data:
				displayName: 'Listas personalizadas'
				icon_fa: 'fa fa-print'
				pageTitle: 'Listas personalizadas - MyVc'


		.state 'panel.informes.planillas-ausencias-acudientes',
			url: '/planillas-ausencias-acudientes'
			views:
				'report_content':
					templateUrl: "==informes2/planillasAusenciasAcudientes.tpl.html"
					controller: 'PlanillasAusenciasAcudientesCtrl' # En NotasPerdidasProfesorCtrl.coffee
					resolve:
						grupos_acud: ['$http', '$stateParams', ($http, $stateParams)->
							$http.put('::acudientes/planillas-ausencias')
						]
			data:
				displayName: 'Asistencia acudientes'
				icon_fa: 'fa fa-print'
				pageTitle: 'Planillas asistencia padres - MyVc'




		.state 'panel.informes.ver_observador_vertical',
			url: '/ver_observador_vertical/:grupo_id'
			params:
				grupo_id: {value: null}
			views:
				'report_content':
					templateUrl: "==informes/verObservadorVertical.tpl.html"
					controller: 'VerObservadorVerticalCtrl' # En NotasPerdidasProfesorCtrl.coffee
					resolve:
						grupos_observador: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::observador/vertical/'+$stateParams.grupo_id)
						]
			data:
				displayName: 'Observador'
				icon_fa: 'fa fa-print'
				pageTitle: 'Observador - MyVc'



		.state 'panel.informes.ver_observador_vertical_todos',
			url: '/ver_observador_vertical_todos'
			views:
				'report_content':
					templateUrl: "==informes/verObservadorVertical.tpl.html"
					controller: 'VerObservadorVerticalCtrl' # En NotasPerdidasProfesorCtrl.coffee
					resolve:
						grupos_observador: ['$http', '$stateParams', ($http, $stateParams)->
							$http.get('::observador/vertical-todos')
						]
			data:
				displayName: 'Observador'
				icon_fa: 'fa fa-print'
				pageTitle: 'Observador - MyVc'



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
			url: '/control_tardanza_entrada'
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



		.state 'panel.informes.control_asistencia_clase',
			url: '/control_asistencia_clase'
			views:
				'report_content':
					templateUrl: "==informes/controlAsistenciaClase.tpl.html" # En archivo PlanillasCtrl.coffee
					controller: 'ControlAsistenciaClaseCtrl'
					resolve:
						grupos: ['$http', '$stateParams', ($http, $stateParams)->
							$http.put('::planillas-ausencias/tardanza-entrada')
						]
			data:
				displayName: 'Control asistencia a Clases'
				icon_fa: 'fa fa-print'
				pageTitle: 'Control asistencia a Clases - MyVc'


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



		.state 'panel.informes.unidades_profesor',
			url: '/unidades_profesor/:profesor_id'
			views:
				'report_content':
					templateUrl: "==informes/unidadesProfesor.tpl.html"
					controller: 'UnidadesProfesorCtrl'
					resolve:
						asignaturas: ['$http', '$stateParams', ($http, $stateParams)->
							$http.put('::unidades/de-profesor', {profesor_id: $stateParams.profesor_id})
						]
			data:
				displayName: 'Unidades profesor'
				icon_fa: 'fa fa-print'
				pageTitle: 'Unidades profesor - MyVc'



		.state 'panel.informes.cumpleanos_por_meses', # En NotasPerdidasProfesorCtrl.coffee
			url: '/cumpleanos_por_meses'
			views:
				'report_content':
					templateUrl: "==informes/cumpleanosPorMeses.tpl.html"
					controller: 'CumpleanosPorMesesCtrl'
					resolve:
						meses_cumple: ['$http', '$stateParams', ($http, $stateParams)->
							$http.put('::informes/cumpleanos-por-meses')
						]
			data:
				displayName: 'Cumpleaños por meses'
				icon_fa: 'fa fa-print'
				pageTitle: 'Cumpleaños por meses - MyVc'












		.state 'panel.informes.boletines_finales',
			url: '/boletines_finales/:grupo_id/year_selected/:year_selected'
			params:
				grupo_id:       {value: null}
				year_selected:   {value: null}
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
								$http.put('::bolfinales/detailed-notas-year/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, year_selected: $stateParams.year_selected}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::bolfinales/detailed-notas-year/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, year_selected: $stateParams.year_selected}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::bolfinales/detailed-notas-year-group/'+$stateParams.grupo_id, {year_selected: $stateParams.year_selected}).then((r)->
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




		.state 'panel.informes.boletines_finales_preescolar',
			url: '/boletines_finales_preescolar/:grupo_id'
			params:
				grupo_id:       {value: null}
			views:
				'report_content':
					templateUrl: "==informes/boletinesFinalesPreescolar.tpl.html"
					controller: 'BoletinesFinalesPreescolarCtrl'  # En el archivo BoletinesFinalesCtrl.coffee
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'

							if requested_alumnos

								#console.log 'Pidiendo por varios alumnos: ', requested_alumnos
								$http.put('::bolfinales-preescolar/detailed-notas-year/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::bolfinales-preescolar/detailed-notas-year/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::bolfinales-preescolar/detailed-notas-year-group/'+$stateParams.grupo_id).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)


							return d.promise
						]
			data:
				displayName: 'Boletines finales preescolar'
				pageTitle: 'Boletines finales preescolar - MyVc'






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






		.state 'panel.informes.certificados_estudio_periodo',
			url: '/certificados-estudio-periodo/:grupo_id/:periodo_a_calcular'
			params:
				grupo_id: {value: null}
				periodo_a_calcular:  {value: null}
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
								$http.put('::bolfinales/detailed-notas-year/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, periodo_a_calcular: $stateParams.periodo_a_calcular, aumentar_contador: true }).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::bolfinales/detailed-notas-year/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, periodo_a_calcular: $stateParams.periodo_a_calcular, aumentar_contador: true }).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								$http.put('::bolfinales/detailed-notas-year/'+$stateParams.grupo_id, { periodo_a_calcular: $stateParams.periodo_a_calcular, aumentar_contador: true } ).then((r)->
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






		###################################################################################
		##################           VARIOS
		###################################################################################
		.state 'panel.informes.notas_actuales_alumnos',
			url: '/notas_actuales_alumnos/:grupo_id/:periodo_a_calcular'
			params:
				grupo_id: {value: null}
				periodo_a_calcular: {value: null}
			views:
				'report_content':
					templateUrl: "==informes2/notasActualesAlumnos.tpl.html"
					controller: 'NotasActualesAlumnosCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'

							if requested_alumnos

								$http.put('::notas-actuales-alumnos/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::notas-actuales-alumnos/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::notas-actuales-alumnos/group/'+$stateParams.grupo_id, {periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
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
				displayName: 'Notas actuales'
				pageTitle: 'Notas actuales - MyVc'



		.state 'panel.informes.notas_perdidas_actuales_alumnos',
			url: '/notas_perdidas_actuales_alumnos/:grupo_id/:periodo_a_calcular'
			params:
				grupo_id: {value: null}
				periodo_a_calcular: {value: null}
			views:
				'report_content':
					templateUrl: "==informes2/notasPerdidasActualesAlumnos.tpl.html"
					controller: 'NotasActualesAlumnosCtrl'
					resolve:
						alumnosDat: ['$http', '$stateParams', '$q', '$cookies', ($http, $stateParams, $q, $cookies)->

							d = $q.defer()


							requested_alumnos = $cookies.getObject 'requested_alumnos'
							requested_alumno = $cookies.getObject 'requested_alumno'

							if requested_alumnos

								$http.put('::notas-actuales-alumnos/'+$stateParams.grupo_id, {requested_alumnos: requested_alumnos, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else if requested_alumno
								$http.put('::notas-actuales-alumnos/'+requested_alumno[0].grupo_id, {requested_alumnos: requested_alumno, periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
									d.resolve r.data
								, (r2)->
									d.reject r2.data
								)
							else
								#console.log 'Pidiendo por grupo:', $stateParams.grupo_id
								$http.put('::notas-actuales-alumnos/group/'+$stateParams.grupo_id, {periodo_a_calcular: $stateParams.periodo_a_calcular}).then((r)->
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
				displayName: 'Notas perdidas actuales'
				pageTitle: 'Notas perdidas actuales - MyVc'






])





