angular.module('myvcFrontApp')
.controller('CopiarCtrl', ['$scope', '$modal', 'Restangular', '$filter', '$rootScope', 'AuthService', 'toastr', 'App', 
	($scope, $modal, Restangular, $filter, $rootScope, AuthService, toastr, App) ->
		debugger
		AuthService.verificar_acceso()

	]
)
