angular.module('myvcFrontApp')


# Configuración principal de nuestra aplicación.
.config(['$stateProvider', 'App', 'PERMISSIONS', ($state, App, PERMISSIONS)->


	$state

		.state 'panel.disciplina',
			url: '^/disciplina'
			views:
				'maincontent':
					templateUrl: "==comportamiento/disciplina.tpl.html"
					controller: 'DisciplinaCtrl'
					resolve:
						escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
							EscalasValorativasServ.escalas()
						]
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Comportamiento'
						]
			data:
				displayName: 'Comportamiento'
				icon_fa: 'fa fa-user'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin]
				pageTitle: 'Comportamiento - MyVc'


		.state 'panel.ordinales',
			url: '^/ordinales'
			views:
				'maincontent':
					templateUrl: "==comportamiento/ordinales.tpl.html"
					controller: 'OrdinalesCtrl'
				'headerContent':
					templateUrl: "==panel/panelHeader.tpl.html"
					controller: 'PanelHeaderCtrl'
					resolve:
						titulo: [->
							'Ordinales'
						]
			data:
				displayName: 'Ordinales'
				icon_fa: 'fa fa-user'
				needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin]
				pageTitle: 'Ordinales - MyVc'





	return
])
