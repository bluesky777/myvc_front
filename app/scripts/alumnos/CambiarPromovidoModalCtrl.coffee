angular.module("myvcFrontApp")

.controller('CambiarPromovidoModalCtrl', ['$scope', '$uibModalInstance', 'persona', '$http', 'toastr', ($scope, $modalInstance, persona, $http, toastr)->
	$scope.persona 				= persona
	$scope.opciones_promo 		= [
		{id: 1, disabled: false, valor: 'Automático', descripcion: 'Significa que aún no se ha definido su promoción'},
		{id: 2, disabled: true, valor: 'Promovido (calculado)', descripcion: 'Que ya se calculó en Informes y se definió como Promovido'},
		{id: 3, disabled: true, valor: 'No promovido (calculado)', descripcion: 'Que ya se calculó en Informes y se definió como NO Promovido'},
		{id: 4, disabled: true, valor: 'Promoción pendiente (calculado)', descripcion: 'Que ya se calculó en Informes y se definió como Promoción pendiente'},
		{id: 5, disabled: false, valor: 'Promovido (manual)', descripcion: 'Que un usuario administrador lo ha definido como Promovido'},
		{id: 6, disabled: false, valor: 'No promovido (manual)', descripcion: 'Que un administrador lo ha definido como NO Promovido'},
		{id: 7, disabled: false, valor: 'Promoción pendiente (manual)', descripcion: 'Que un administrador lo ha definido como Promoción pendiente'}
	]

	$scope.setPromovido = (opcion)->
		console.log(opcion);
		if opcion.disabled == false
			$http.put('::matriculas/set-promovido', {valor: opcion.valor, matricula_id: persona.matricula_id}).then( (r)->
				toastr.success 'Actualizado: ' + opcion.valor
				$modalInstance.close(persona)
			, (r2)->
				toastr.error 'No se pudo actualizar', 'Error'
			)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
