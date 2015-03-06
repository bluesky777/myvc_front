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
					pageTitle: 'Votaciones - MyVc'

		.state 'votaciones.config',
				url: '/config'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/votaciones.tpl.html"
						controller: 'VotacionesCtrl'
				data:
					needed_permissions: [PERMISSIONS.can_edit_votaciones]
					pageTitle: 'Configurar votación - MyVc'

		.state 'votaciones.aspiraciones',
				url: '/aspiraciones'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/aspiraciones.tpl.html"
						controller: 'AspiracionesCtrl'
				data:
					needed_permissions: [PERMISSIONS.can_edit_aspiraciones]
					pageTitle: 'Aspiraciones - MyVc'

		.state 'votaciones.candidatos',
				url: '/candidatos'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/candidatos.tpl.html"
						controller: 'CandidatosCtrl'
				data:
					needed_permissions: [PERMISSIONS.can_edit_candidatos]
					pageTitle: 'Candidatos - MyVc'

		.state 'votaciones.participantes',
				url: '/participantes'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/participantes.tpl.html"
						controller: 'ParticipantesCtrl'
				data:
					needed_permissions: [PERMISSIONS.can_edit_participantes]
					pageTitle: 'Participantes - MyVc'

		.state 'votaciones.votar',
				url: '/votar/:maxi'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/votar.tpl.html"
						controller: 'VotarCtrl'
				data:
					pageTitle: 'Votar - MyVc'

		.state 'votaciones.resultados',
				url: '/resultados'
				views: 
					'maincontent':
						templateUrl: "#{App.views}votaciones/resultados.tpl.html"
						controller: 'ResultadosCtrl'
				data:
					pageTitle: 'Resultados - MyVc'


		return
	]