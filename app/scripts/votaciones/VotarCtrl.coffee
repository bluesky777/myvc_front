'use strict'

angular.module("myvcFrontApp")

.controller('VotarCtrl', ['$scope', '$http', 'toastr', ($scope, $http, toastr)->


	$scope.votaciones = []
	$scope.indexVotando = 0

	$http.get('::votaciones/en-accion-inscrito').then((r)->
		r = r.data
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




.controller('chooseCandidatoCtrl', ['$scope', '$http', '$uibModalInstance', 'App', 'candidato', 'aspiracion', 'votacion_id', 'toastr', ($scope, $http, $modalInstance, App, candidato, aspiracion, votacion_id, toastr)->

	$scope.candidato = candidato
	$scope.aspiracion = aspiracion
	$scope.imagesPath = App.images + 'perfil/'

	$scope.ok = ()->
		datos = {}
		datos.votacion_id = votacion_id

		if candidato.voto_blanco
			datos.blanco_aspiracion_id 	= aspiracion.id
			datos.voto_blanco 					= true
		else
			datos.candidato_id = candidato.candidato_id

		$http.post('::votos/store', datos).then((r)->
			r = r.data
			if r.msg
				toastr.info r.msg
			else
				toastr.success 'Voto guardado con éxito'
			$modalInstance.close(r)
		, (r2)->
			r2 = r2.data
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
