'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', 'App', ($state, App) ->

		$state
			.state 'panel.filemanager',
				url: '/filemanager'
				views: 
					'maincontent':
						templateUrl: "#{App.views}fileManager/fileManager.tpl.html"
						controller: 'FileManagerCtrl'
					'headerContent':
						templateUrl: "#{App.views}panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Administrador de archivos'
							]
				data: 
					displayName: 'Administrador de archivos'
					icon_fa: 'fa fa-cube'



]
