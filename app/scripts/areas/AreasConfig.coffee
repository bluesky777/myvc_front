angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', ($state, App) ->

		$state
			.state 'panel.areas',
				url: '^/areas'
				views: 
					'maincontent':
						templateUrl: "==areas/areas.tpl.html"
						controller: 'AreasCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Areas'
							]
				data: 
					displayName: 'Areas'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Áreas - MyVc'

		$state
			.state 'panel.materias',
				url: '^/materias'
				views: 
					'maincontent':
						templateUrl: "==areas/materias.tpl.html"
						controller: 'MateriasCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Materias'
							]
				resolve:{
					areas: ['$http', ($http)->
						$http.get('::areas').then((data)->
							return data.data
						)
					]
				}
				data: 
					displayName: 'Materias'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Materias - MyVc'

		$state
			.state 'panel.asignaturas',
				url: '^/asignaturas'
				views: 
					'maincontent':
						templateUrl: "==areas/asignaturas.tpl.html"
						controller: 'AsignaturasCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Asignaturas'
							]
				resolve:{
					materias: ['$http', ($http)->
						$http.get('::materias').then((data)->
							return data.data
						)
					]
					profesores: ['$http', ($http)->
						$http.get('::contratos').then((data)->
							return data.data
						)
					]
					grupos: ['$http', ($http)->
						$http.get('::grupos').then((data)->
							return data.data
						)
					]
				}
				data: 
					displayName: 'Asignaturas'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Asignatura - MyVc'

		$state
			.state 'panel.listasignaturas',
				url: '^/listasignaturas/:profesor_id'
				params:
					profesor_id: { value: null }
				views: 
					'maincontent':
						templateUrl: "==areas/listAsignaturas.tpl.html"
						controller: 'ListAsignaturasCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Listado de asignaturas'
							]
				data: 
					displayName: 'Listado de asignaturas'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Mis asignaturas - MyVc'

		$state
			.state 'panel.frases',
				url: '^/frases'
				views: 
					'maincontent':
						templateUrl: "==areas/frases.tpl.html"
						controller: 'FrasesCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Frases'
							]
				data: 
					displayName: 'Frases'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Frases - MyVc'
]
