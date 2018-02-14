'use strict'

angular.module("myvcFrontApp")

.controller('VotarPruebaCtrl', ['$scope', '$filter', '$http', 'App', '$state', '$uibModal', '$window', ($scope, $filter, $http, App, $state, $modal, $window)->


	$scope.hover = false
	$scope.aspiraciones = []
	$scope.maxi = $state.params.maxi
	$scope.windowHeight = angular.element($window).height()-100
	$scope.wzStep = 0


	$scope.votacion = {
		locked: false
		is_action: false
		fecha_inicio: ''
		fecha_fin: ''
	}

	$http.get('::votaciones/actual').then((r)->
		$scope.votacion = r.data
		if $scope.votacion.locked
			$scope.toastr.warning 'La votación actual está bloqueada'
			#$state.transitionTo 'panel'

	)


	$http.get('::candidatos/conaspiraciones').then((r)->
		$scope.aspiraciones = r.data
	, (r2)->
		$scope.toastr.error 'No se pudo traer las aspiraciones', 'Problema'
	)

	$http.get('::participantes/allinscritos').then((r)->
		$scope.allinscritos = r.data
	, (r2)->
		$scope.toastr.error 'No se pudo traer los inscritos', 'Problema'
	)


	$scope.currentImg = 'default_male.jpg'
	$scope.imagesPath = App.images + 'perfil/'

	$scope.mostrarImagen = (candidato)->
		candidato.iluminado = true
		$scope.currentImg = candidato.imagen_nombre

	$scope.ocultarImagen = (candidato)->
		candidato.iluminado = false

	$scope.nextAspiracion = ()->
		$scope.wzStep += 1 if $scope.wzStep < ($scope.aspiraciones.length)

	$scope.prevAspiracion = ()->
		$scope.wzStep -= 1 if $scope.wzStep > 0

	$scope.goAspiracion = (num)->
		$scope.wzStep = parseInt $scope.wzStep
		num = parseInt(num)

		$scope.wzStep = num if num < $scope.wzStep


	$scope.open = (candidato, aspiracion)->

		if $scope.votacion.locked
			$scope.toastr.warning 'La votación actual está bloqueada'
			return
		else
			modalInstance = $modal.open({
				templateUrl: '==votaciones/chooseCandidato.tpl.html'
				controller: 'chooseCandidatoCtrl'
				resolve:
					candidato: ()->
						candidato
					aspiracion: ()->
						aspiracion
					votacion_id: ()->
						$scope.votacion.id

			})
			modalInstance.result.then( (selectedItem)->
				aspiracion.votado.push selectedItem
				$scope.nextAspiracion()
			, ()->
				#console.log 'Modal dismissed at: ' + new Date()
			)


	return
])

.controller('chooseCandidatoPruebaCtrl', ['$scope', '$http', '$uibModalInstance', 'App', 'candidato', 'aspiracion', 'toastr', ($scope, $http, $modalInstance, App, candidato, aspiracion, toastr)->

	$scope.candidato = candidato
	$scope.aspiracion = aspiracion
	$scope.imagesPath = App.images + 'perfil/'

	$scope.ok = ()->
		datos = {}
		datos.candidato_id = candidato.candidato_id

		r = {
			locked: false
			is_action: false
			fecha_inicio: ''
			fecha_fin: ''
			completo: false
		}

		toastr.success 'Voto guardado con éxito'
		$modalInstance.close(r)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')
])
