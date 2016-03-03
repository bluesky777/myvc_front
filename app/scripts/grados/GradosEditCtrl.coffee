'use strict'

angular.module("myvcFrontApp")

.controller('GradosEditCtrl', ['$scope', '$state', 'Restangular', 'toastr', ($scope, $state, Restangular, toastr)->


	Restangular.one('grados/show', $state.params.grado_id).get().then (r)->
		$scope.grado = r
	
	Restangular.one('niveles_educativos').getList().then((data)->
		$scope.niveles = data
	)

	$scope.guardar = ()->
		Restangular.one('grupos/update').customPUT($scope.grado).then((r)->
			toastr.success 'Se guardó grado el grado'
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
