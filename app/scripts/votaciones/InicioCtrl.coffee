'use strict'

angular.module("myvcFrontApp")

.controller('InicioCtrl', ['$scope', '$rootScope', '$interval', 'resolved_user', ($scope, $rootScope, $interval, resolved_user)->

	
	$scope.verificar_acceso()

	$scope.USER = resolved_user

	return
])