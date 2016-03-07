'use strict'

angular.module('myvcFrontApp')
	.config ['$stateProvider', ($state) ->

		$state
			.state 'panel.filemanager',
				url: '/filemanager'
				views: 
					'maincontent':
						templateUrl: "==fileManager/fileManager.tpl.html"
						controller: 'FileManagerCtrl'
					'headerContent':
						templateUrl: "==panel/panelHeader.tpl.html"
						controller: 'PanelHeaderCtrl'
						resolve:
							titulo: [->
								'Administrador de archivos'
							]
				data: 
					displayName: 'Administrador de archivos'
					icon_fa: 'fa fa-cube'



]
