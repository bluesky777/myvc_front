angular.module('myvcFrontApp')
.config(['$stateProvider', 'App', 'USER_ROLES', 'PERMISSIONS', ($state, App, USER_ROLES, PERMISSIONS) ->

	$state
		.state 'informes.boletines_periodo',
			url: '/boletines_periodo/:grupo_id'
			views: 
				'report_content':
					templateUrl: "#{App.views}informes/boletinesPeriodo.tpl.html"
					controller: 'BoletinesPeriodoCtrl'
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


