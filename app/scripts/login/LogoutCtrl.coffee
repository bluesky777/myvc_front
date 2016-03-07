'use strict'

angular.module('myvcFrontApp')
.controller('LogoutCtrl', ['$scope', '$state', '$cookieStore', 'Perfil', ($scope, $state, $cookieStore, Perfil)->
	console.log 'A salir!!'
	$state.go 'login'
])