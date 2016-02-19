'use strict'

angular.module("myvcFrontApp")

.controller('VotarCtrl', ['$scope', 'Restangular', 'toastr', ($scope, Restangular, toastr)->


	$scope.votaciones = []
	$scope.indexVotando = 0

	Restangular.one('votaciones/en-accion-inscrito').get().then((r)->
		if r.msg
			toastr.warning r.msg, 'Atención'
		else
			$scope.votaciones = r
			for vot in $scope.votaciones
				if vot.completos
					$scope.indexVotando++
	)

	$scope.$on 'termineDeVotar', ()->
		$scope.indexVotando++
		$scope.$broadcast 'terminaVotacion', $scope.indexVotando
	

	return
])




.controller('chooseCandidatoCtrl', ['$scope', 'Restangular', '$uibModalInstance', 'App', 'candidato', 'aspiracion', 'toastr', ($scope, Restangular, $modalInstance, App, candidato, aspiracion, toastr)->

	$scope.candidato = candidato
	$scope.aspiracion = aspiracion
	$scope.imagesPath = App.images + 'perfil/'

	$scope.ok = ()->
		datos = {}
		datos.candidato_id = candidato.candidato_id

		Restangular.all('votos/store').post('', datos).then((r)->
			if r.msg 
				toastr.info r.msg
			else
				toastr.success 'Voto guardado con éxito'
			$modalInstance.close(r)
		, (r2)->
			console.log 'No se pudo guardar el voto.', r2
			if r2.data
				if r2.data.msg
					toastr.error r2.data.msg # Mensaje que me devuelve el servidor
				else
					toastr.error 'No se pudo guardar el voto.'
			else
				toastr.error 'No se pudo guardar el voto.'

			$modalInstance.dismiss('Error al guardar')
		)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')
])
