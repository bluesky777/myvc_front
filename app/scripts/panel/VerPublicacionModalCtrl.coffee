'use strict'

angular.module("myvcFrontApp")


.controller('VerPublicacionModalCtrl', ['$scope', 'App', '$uibModalInstance', 'publicacion_actual', '$http', 'toastr', '$filter', ($scope, App, $modalInstance, publicacion_actual, $http, toastr, $filter)->
	$scope.publicacion_actual 		= publicacion_actual
	$scope.perfilPath             = App.images+'perfil/'


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	$scope.ok = ()->
		$modalInstance.close(publicacion_actual)

])
