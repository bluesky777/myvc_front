'use strict'

angular.module('myvcFrontApp')
.controller('LogoutCtrl', ['$scope', '$state', 'Perfil', ($scope, $state, Perfil)->
	console.log 'A salir!!'
	$state.go 'login'
])
