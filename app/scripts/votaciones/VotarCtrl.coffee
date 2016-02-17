'use strict'

angular.module("myvcFrontApp")

.controller('VotarCtrl', ['$scope', 'Restangular', ($scope, Restangular)->


	$scope.votaciones = []
	$scope.indexVotando = 0

	Restangular.one('votaciones/en-accion-inscrito').get().then((r)->
		$scope.votaciones = r
	)

	$scope.$on 'termineDeVotar', ()->
		$scope.indexVotando++
		$scope.$broadcast 'terminaVotacion', $scope.indexVotando
	

	return
])




.controller('chooseCandidatoCtrl', ['$scope', 'Restangular', '$modalInstance', 'App', 'candidato', 'aspiracion', 'toastr', ($scope, Restangular, $modalInstance, App, candidato, aspiracion, toastr)->

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
			toastr.error r2.data.msg # Mensaje que me devuelve el servidor
			$modalInstance.dismiss('Error al guardar')
		)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')
])
