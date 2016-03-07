'use strict'

angular.module("myvcFrontApp")

.controller('GradosEditCtrl', ['$scope', '$state', '$http', 'toastr', ($scope, $state, $http, toastr)->


	$http.get('::grados/show/'+$state.params.grado_id).then (r)->
		$scope.grado = r.data
	
	$scope.guardar = ()->
		$http.put('::grados/update/'+$scope.grado.id, $scope.grado).then((r)->
			toastr.success 'Se guardaron los cambios.'
		, (r2)->
			toastr.error 'Falló al intentar guardar'
		)

	$scope.restarOrden = ()->
		if $scope.grado.orden > 0
			$scope.grado.orden = $scope.grado.orden - 1
	$scope.sumarOrden = ()->
		if $scope.grado.orden < 40
			$scope.grado.orden = $scope.grado.orden + 1

])
