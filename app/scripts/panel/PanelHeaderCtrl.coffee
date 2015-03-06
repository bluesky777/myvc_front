'use strict'

angular.module('myvcFrontApp')
.controller('PanelHeaderCtrl', ['$scope', 'titulo', '$state', '$stateParams', 'Fullscreen', ($scope, titu, $state, $stateParams, Fullscreen) ->
	$scope.titulo = titu

	$scope.reload = ()->
		$state.go $state.current, $stateParams, {reload: true}

	$scope.setFullScreen = ()->
		Fullscreen.toggleAll()

	return
])
