'use strict'

angular.module('myvcFrontApp')
.controller('LogoutCtrl', ['$scope', 'AUTH_EVENTS', 'authService', '$state', 'Restangular', '$cookies', 'Perfil', ($scope, AUTH_EVENTS, authService, $state, Restangular, $cookies, Perfil)->
	console.log 'A salir!!'
	$state.go 'login'
])