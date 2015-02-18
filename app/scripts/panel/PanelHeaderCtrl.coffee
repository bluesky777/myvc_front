'use strict'

angular.module('myvcFrontApp')
	.controller 'PanelHeaderCtrl', ['$scope', 'titulo', ($scope, titu) ->
		$scope.titulo = titu
		return
	]
