angular.module('myvcFrontApp')

.controller('CalcularPromovidosModalCtrl', ['$scope', '$uibModalInstance', 'USER', '$http', 'toastr', '$interval', 'grupos', ($scope, $modalInstance, USER, $http, toastr, $interval, grupos)->

	$scope.USER = USER
	$scope.grupos = grupos
	
	$scope.calcularTodos = ()->

		$scope.porcentajePromov   = 0
		$scope.bloqueadoPromov   = true

		$scope.grupo_temp_calculado_promov = true
		$scope.grupo_temp_indce_promov     = 0

		$scope.intervalo_promov = $interval(()->

			if $scope.grupo_temp_calculado_promov

				$scope.grupo_temp_calculado_promov = false
				grupo 							      = $scope.grupos[$scope.grupo_temp_indce_promov]
				$scope.porcentajePromov 	= parseInt(($scope.grupo_temp_indce_promov+1) * 100 / $scope.grupos.length)

				$http.put('::promovidos/calcular-grupo', {grupo_id: grupo.grupo_id}).then((r)->
					toastr.success grupo.nombre + ' calculado con éxito'
					$scope.grupo_temp_calculado_promov = true
					$scope.grupo_temp_indce_promov     = $scope.grupo_temp_indce_promov + 1
					if $scope.grupo_temp_indce_promov == $scope.grupos.length
						$interval.cancel($scope.intervalo_promov)

				, (r2)->
					$scope.grupo_temp_calculado_promov = true
					toastr.warning 'No se pudo calcular ' + grupo.nombre + '. Intentaremos de nuevo.'
				)

		, 20)



	$scope.calcularGrupo = (grupo)->

		if grupo.calculando
			console.log('Calculando')
		else
			grupo.calculando = true
			
			$http.put('::promovidos/calcular-grupo', {grupo_id: grupo.grupo_id}).then((r)->
				toastr.success grupo.nombre + ' calculado con éxito'
				grupo.calculando = false

			, (r2)->
				grupo.calculando = false
				toastr.warning 'No se pudo calcular ' + grupo.nombre
			)




	$scope.ok = ()->
		$modalInstance.close()



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


