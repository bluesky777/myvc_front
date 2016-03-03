angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', ($state, App) ->

		$state
			.state 'panel.areas',
				url: '^/areas'
				views: 
					'maincontent':
						templateUrl: "#{App.views}areas/areas.tpl.html"
						controller: 'AreasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
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
						templateUrl: "#{App.views}areas/materias.tpl.html"
						controller: 'MateriasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Materias'
							]
				resolve:{
					areas: ['RAreas', (RAreas)->
						RAreas.getList().then((data)->
							return data
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
						templateUrl: "#{App.views}areas/asignaturas.tpl.html"
						controller: 'AsignaturasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Asignaturas'
							]
				resolve:{
					materias: ['Restangular', (Restangular)->
						Restangular.one('materias').getList().then((data)->
							return data
						)
					]
					profesores: ['Restangular', (Restangular)->
						Restangular.one('contratos').getList().then((data)->
							return data
						)
					]
					grupos: ['Restangular', (Restangular)->
						Restangular.one('grupos').getList().then((data)->
							return data
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
						templateUrl: "#{App.views}areas/listAsignaturas.tpl.html"
						controller: 'ListAsignaturasCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
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
						templateUrl: "#{App.views}areas/frases.tpl.html"
						controller: 'FrasesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
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
