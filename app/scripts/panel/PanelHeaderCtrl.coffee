'use strict'

angular.module('myvcFrontApp')
.controller('PanelHeaderCtrl', ['$scope', 'titulo', '$state', '$stateParams', 'Fullscreen', '$rootScope', ($scope, titu, $state, $stateParams, Fullscreen, $rootScope) ->
	$scope.titulo = titu

	$rootScope.reload = ()->
		$state.go $state.current, $stateParams, {reload: true}

	$scope.setFullScreen = ()->
		Fullscreen.toggleAll()

	return
])
