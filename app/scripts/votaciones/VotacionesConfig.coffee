'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', 'PERMISSIONS', ($state, App, PERMISSIONS) ->

		$state
			.state 'votaciones',
				url: '/votaciones'
				views: 
					'principal':
						templateUrl: "#{App.views}votaciones/inicio.tpl.html"
						controller: 'InicioCtrl'
				resolve: {
					resolved_user: ['AuthService', (AuthService)->
						AuthService.verificar()
					]
				}
				data:
					needed_permissions: [PERMISSIONS.can_see_panel] #Si puede ver el panel, puede ver Votaciones

		.state 'votaciones.config',
				url: '/config'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/votaciones.tpl.html"
						controller: 'VotacionesCtrl'

		.state 'votaciones.aspiraciones',
				url: '/aspiraciones'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/aspiraciones.tpl.html"
						controller: 'AspiracionesCtrl'

		.state 'votaciones.candidatos',
				url: '/candidatos'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/candidatos.tpl.html"
						controller: 'CandidatosCtrl'

		.state 'votaciones.participantes',
				url: '/participantes'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/participantes.tpl.html"
						controller: 'ParticipantesCtrl'

		.state 'votaciones.votar',
				url: '/votar/:maxi'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/votar.tpl.html"
						controller: 'VotarCtrl'

		.state 'votaciones.resultados',
				url: '/resultados'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/resultados.tpl.html"
						controller: 'ResultadosCtrl'


		return
	]