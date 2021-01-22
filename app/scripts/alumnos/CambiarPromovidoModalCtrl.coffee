angular.module("myvcFrontApp")

.controller('CambiarPromovidoModalCtrl', ['$scope', '$uibModalInstance', 'persona', '$http', 'toastr', ($scope, $modalInstance, persona, $http, toastr)->
	$scope.persona 				= persona
	$scope.opciones_promo 		= [
		{id: 1, disabled: false, valor: 'Automático', descripcion: 'Aún no se ha definido su promoción'},
		{id: 2, disabled: true, valor: 'Promovido (calculado)', descripcion: 'Ya se calculó en Informes y se definió como Promovido'},
		{id: 3, disabled: true, valor: 'No promovido (calculado)', descripcion: 'Ya se calculó en Informes y se definió como NO Promovido'},
		{id: 4, disabled: true, valor: 'Promoción pendiente (calculado)', descripcion: 'Ya se calculó en Informes y se definió como Promoción pendiente'},
		{id: 5, disabled: false, valor: 'Promovido (manual)', descripcion: 'Un usuario administrador lo ha definido como Promovido'},
		{id: 6, disabled: false, valor: 'No promovido (manual)', descripcion: 'Un administrador lo ha definido como NO Promovido'},
		{id: 7, disabled: false, valor: 'Promoción pendiente (manual)', descripcion: 'Un administrador lo ha definido como Promoción pendiente'}
	]

	$scope.setPromovido = (opcion)->
		console.log(opcion);
		if opcion.disabled == false
			$http.put('::matriculas/set-promovido', {valor: opcion.valor, matricula_id: persona.matricula_id}).then( (r)->
				toastr.success 'Actualizado: ' + valor

			, (r2)->
				toastr.error 'No se pudo actualizar', 'Error'
			)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
