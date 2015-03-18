angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state
		.state 'informes.boletines_periodo',
			url: '/boletines_periodo/:grupo_id'
			params:
				grupo_id: {value: null}
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/boletinesPeriodo.tpl.html"
					controller: 'BoletinesPeriodoCtrl'
					resolve:
						alumnos: ['Restangular', '$stateParams', '$q', '$cookieStore', (Restangular, $stateParams, $q, $cookieStore)->

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
				pageTitle: 'Boletines periodo - MyVc'

		.state 'informes.puestos_grupo_periodo',
			url: '/puestos_grupo_periodo/:grupo_id'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/puestosGrupoPeriodo.tpl.html"
					controller: 'PuestosGrupoPeriodoCtrl'
					resolve:
						alumnos: ['Restangular', '$stateParams', (Restangular, $stateParams)->
							Restangular.one('alumnos/detailed-notas', $stateParams.grupo_id).getList()
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				pageTitle: 'Boletines periodo - MyVc'

		.state 'informes.puestos_grupo_year',
			url: '/puestos_grupo_periodo/:grupo_id'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/puestosGrupoYear.tpl.html"
					controller: 'PuestosGrupoYearCtrl'
					resolve:
						alumnos: ['Restangular', '$stateParams', (Restangular, $stateParams)->
							Restangular.one('alumnos/detailed-notas', $stateParams.grupo_id).getList()
						],
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							#debugger
							EscalasValorativasServ.escalas()
						]
			data: 
				pageTitle: 'Boletines periodo - MyVc'


])


.filter('juicioValorativo', [ ->
	(nota, escalas, desempenio)->

		jucio = {}

		angular.forEach escalas, (escala)->
			if nota >= escala.porc_inicial and nota <= escala.porc_final
				jucio.desempenio = escala.desempenio
				jucio.valoracion = escala.valoracion

		if desempenio
			return jucio.desempenio
		else
			return jucio.valoracion
])




