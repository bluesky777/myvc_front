'use strict'

angular.module("myvcFrontApp")


.controller('AsignarAcudienteAOtroModalCtrl', ['$scope', 'App', '$uibModalInstance', 'elemento', '$uibModal', '$http', 'toastr', '$filter', '$rootScope', '$timeout', ($scope, App, $modalInstance, acudiente, $modal, $http, toastr, $filter, $rootScope, $timeout)->
	$scope.acudiente 				  = acudiente
	$scope.datos 				      = {}
	$scope.perfilPath 			  = App.images+'perfil/'
	$scope.repetido 					= false
	$scope.alumno             = {}
	$scope.parentescos        = App.parentescos


	for parentesc in $scope.parentescos
		if parentesc.parentesco == 'Madre' and acudiente.sexo == 'F'
			$scope.acudiente.parentesco = parentesc
		if parentesc.parentesco == 'Padre' and acudiente.sexo == 'M'
			$scope.acudiente.parentesco = parentesc



	$scope.seleccionarAcudiente = ()->
		datos = { acudiente_id: $scope.acudiente.id, alumno_id: $scope.alumno.alumno_id, parentesco: $scope.acudiente.parentesco.parentesco, ocupacion: $scope.acudiente.ocupacion }

		$http.put('::acudientes/seleccionar-parentesco', datos ).then((r)->
			if $scope.acudiente.parentesco
				$scope.acudiente.parentesco = $scope.acudiente.parentesco.parentesco
			$modalInstance.close(r.data)
		, (r2)->
			toastr.warning 'No se pudo seleccionar.', 'Problema'
		)




	$scope.quitarAcudiente = (rowAlum, acudiente)->

		modalInstance = $modal.open({
			templateUrl: '==alumnos/quitarAcudienteModalConfirm.tpl.html'
			controller: 'QuitarAcudienteModalConfirmCtrl'
			resolve:
				alumno: ()->
					rowAlum
				acudiente: ()->
					acudiente
		})
		modalInstance.result.then( (acud)->
			for pariente, indice in $scope.acudientes
				if pariente
					if pariente.id == acud.id
						$scope.acudientes.splice(indice, 1)
		, ()->
			# nada
		)



	$scope.personaCheck = (texto)->
		$scope.verificandoPersona = true
		return $http.put('::alumnos/personas-check', {texto: texto, todos_anios: true }).then((r)->
			$scope.personas_match 		= r.data.personas
			$scope.personas_match.map((perso)->
				perso.perfilPath = $scope.perfilPath
			)
			$scope.verificandoPersona 	= false
			return $scope.personas_match
		)


	$scope.seleccionarPersona = ($item, $model, $label)->
		$scope.alumno = $item

		$http.put('::acudientes/de-persona', {alumno_id: $item.alumno_id}).then((r)->

			for pariente in r.data.acudientes
				if pariente.id == $scope.acudiente.id
					toastr.warning('Ya tiene este acudiente.')
					$scope.repetido     = true
					pariente.repetido   = true

			$scope.acudientes 		  = r.data.acudientes

		, ()->
			toastr.error('Error trayendo acudientes de ' + $item.nombres)
		)



	$scope.cancel = ()->
		if $scope.acudiente.parentesco
			$scope.acudiente.parentesco = $scope.acudiente.parentesco.parentesco
		$modalInstance.dismiss('cancel')


])






.controller('QuitarAcudienteModalConfirmCtrl', ['$scope', 'App', '$uibModalInstance', 'alumno', 'acudiente', '$http', 'toastr', ($scope, App, $modalInstance, alumno, acudiente, $http, toastr)->
	$scope.acudiente 				  = acudiente
	$scope.alumno             = alumno
	$scope.perfilPath 			  = App.images+'perfil/'

	$scope.ok = ()->
		datos = { parentesco_id: $scope.acudiente.parentesco_id }

		$http.put('::acudientes/quitar-parentesco-alumno', datos ).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.warning 'No se pudo seleccionar.', 'Problema'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')



])
