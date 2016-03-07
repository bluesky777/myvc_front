angular.module('myvcFrontApp')

.directive('votarPanelDir',['App', 'Perfil', '$http', (App, Perfil, $http)-> 

	restrict: 'EA'
	templateUrl: "==votaciones/votarPanel.tpl.html"
	scope: 
		votacion: "="


	controller: ($scope, App, toastr, $window, $uibModal)->

		$scope.USER = Perfil.User()

		$scope.hover = false
		$scope.maxi = false
		$scope.windowHeight = angular.element($window).height()-100
		$scope.wzStep = 0



		$scope.currentImg = 'default_male.jpg'
		$scope.imagesPath = App.images + 'perfil/'


		# Maximizo esta votación si es la actual para votar
		if $scope.$parent.$index == $scope.$parent.indexVotando
			$scope.maxi = true


		$scope.$on 'terminaVotacion', (evento, indexVotando)->
			if $scope.$parent.$index == indexVotando
				$scope.maxi = true


		# Si ya hizo todos los votos en esta votación
		if $scope.votacion.completos
			$scope.wzStep = $scope.votacion.aspiraciones.length



		$scope.mostrarImagen = (candidato)->
			candidato.iluminado = true
			$scope.currentImg = candidato.imagen_nombre

		$scope.ocultarImagen = (candidato)->
			candidato.iluminado = false

		$scope.nextAspiracion = ()->
			$scope.wzStep += 1 if $scope.wzStep < ($scope.votacion.aspiraciones.length)
			
		$scope.prevAspiracion = ()->
			$scope.wzStep -= 1 if $scope.wzStep > 0

		$scope.goAspiracion = (num)->
			$scope.wzStep = parseInt $scope.wzStep
			num = parseInt(num)

			$scope.wzStep = num if num < $scope.wzStep


		$scope.open = (candidato, aspiracion)->
			
			if $scope.votacion.locked
				toastr.warning 'Usted está bloqueado en esta votación.'
				return
			else if $scope.votacion.locked_votacion
				toastr.warning 'Usted está bloqueado en esta votación.'
				return
			else
				modalInstance = $uibModal.open({
					templateUrl: '==votaciones/chooseCandidato.tpl.html'
					controller: 'chooseCandidatoCtrl'
					resolve: 
						candidato: ()->
							candidato
						aspiracion: ()->
							aspiracion.aspiracion
						votacion_id: ()->
							$scope.votacion.votacion_id

				})
				modalInstance.result.then( (selectedItem)->
					aspiracion.votado = selectedItem

					cantVot = 0
					for aspi in $scope.votacion.aspiraciones
						if aspi.votado
							cantVot++
					
					if $scope.votacion.aspiraciones.length == cantVot
						$scope.$emit 'termineDeVotar'
						$scope.maxi = false
						toastr.info 'Ahora continúa con la siguiente votación.'

					$scope.nextAspiracion()
				, ()->
					#console.log 'Modal dismissed at: ' + new Date()
				)


		return

	

])






