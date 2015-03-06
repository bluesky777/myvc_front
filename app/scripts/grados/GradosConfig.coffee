'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', ($state, App) ->

		$state
			.state 'panel.niveles',
				url: '/niveles'
				views: 
					'maincontent':
						templateUrl: "#{App.views}grados/niveles.tpl.html"
						controller: 'NivelesCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Niveles educativos'
							]
				data: 
					displayName: 'Niveles'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Niveles - MyVc'

		$state
			.state 'panel.niveles.nuevo',
				url: '/nuevo'
				views: 
					'edit_nivel':
						templateUrl: "#{App.views}grados/nivelesNew.tpl.html"
						controller: 'NivelesNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo'
							]
				data: 
					displayName: 'Nuevo'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Nivel nuevo - MyVc'

		$state
			.state 'panel.niveles.editar',
				url: '/editar/:nivel_id'
				views: 
					'edit_nivel':
						templateUrl: "#{App.views}grados/nivelesEdit.tpl.html"
						controller: 'NivelesEditCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Editar'
							]
				data: 
					displayName: 'Editar'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Editar nivel - MyVc'

		$state
			.state 'panel.grados',
				url: '/grados'
				views: 
					'maincontent':
						templateUrl: "#{App.views}grados/grados.tpl.html"
						controller: 'GradosCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Grados'
							],
				resolve: {
					niveles: ['RNiveles', (RNiveles)->
						RNiveles.getList().then((data)->
							return data
						)
					]
				}
				data: 
					displayName: 'Grados'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Grados - MyVc'

		$state
			.state 'panel.grados.nuevo',
				url: '/nuevo'
				views: 
					'edit_grado':
						templateUrl: "#{App.views}grados/gradosNew.tpl.html"
						controller: 'GradosNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo'
							]
				data: 
					displayName: 'Nuevo'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Grado nuevo - MyVc'


		$state
			.state 'panel.grados.editar',
				url: '/editar/:grado_id'
				views: 
					'edit_grado':
						templateUrl: "#{App.views}grados/gradosEdit.tpl.html"
						controller: 'GradosEditCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Editar'
							]
				data: 
					displayName: 'Editar'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Editar grado - MyVc'


		$state
			.state 'panel.grupos',
				url: '/grupos'
				views: 
					'maincontent':
						templateUrl: "#{App.views}grados/grupos.tpl.html"
						controller: 'GruposCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Grupos'
							]
				resolve:
					grados: ['RGrados', (RGrados)->
						RGrados.getList().then((data)->
							return data
						)
					],
					profesores: ['RProfesores', (RProfesores)->
						RProfesores.getList().then((data)->
							return data
						)
					]
				data: 
					displayName: 'Grupos'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Grupos - MyVc'

		$state
			.state 'panel.grupos.nuevo',
				url: '/nuevo'
				views: 
					'edit_grupo':
						templateUrl: "#{App.views}grados/gruposNew.tpl.html"
						controller: 'GruposNewCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Nuevo'
							]
				data: 
					displayName: 'Nuevo'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Grupo nuevo - MyVc'


		$state
			.state 'panel.grupos.editar',
				url: '/editar/:grupo_id'
				views: 
					'edit_grupo':
						templateUrl: "#{App.views}grados/gruposEdit.tpl.html"
						controller: 'GruposEditCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Editar'
							]
				data: 
					displayName: 'Editar'
					icon_fa: 'fa fa-graduation-cap'
					pageTitle: 'Editar grupo - MyVc'



]
