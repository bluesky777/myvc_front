angular.module('myvcFrontApp')
.controller('ComportamientoCtrl', ['$scope', '$filter', '$rootScope', '$state', '$interval', 'RGrupos', 'comportamiento', '$modal', 'App', 'Restangular', ($scope, $filter, $rootScope, $state, $interval, RGrupos, comportamiento, $modal, App, Restangular) ->

	$scope.perfilPath = App.images+'perfil/'

	$scope.frases = comportamiento[0]
	$scope.alumnos = comportamiento[1]
	$scope.grupo = comportamiento[2]

	$scope.addFrase = (alumno)->

		if alumno.newfrase
			dato = 
				comportamiento_id:	alumno.nota.id
				frase_id:			alumno.newfrase.id

			Restangular.one('definiciones_comportamiento/store').customPOST(dato).then((r)->
				$scope.toastr.success 'Frase agregada con éxito'
				alumno.definiciones.push alumno.newfrase
				alumno.newfrase = null
			, (r2)->
				$scope.toastr.error 'No se pudo agregar la frase', 'Problema'
				console.log 'No se añadió la frase', r2
			)
		else
			$scope.toastr.warning 'Debe seleccionar frase'
			return

	$scope.updateNota = (alumno)->
		
		dato = 
			alumno_id:	alumno.id
			nota:		alumno.nota.nota

		Restangular.one('nota_comportamiento/update').customPOST(dato).then((r)->
			$scope.toastr.success 'Comportamiento modificado con éxito'
			alumno.definiciones.push r
		, (r2)->
			$scope.toastr.error 'No se pudo cambiar comportamiento', 'Problema'
			console.log 'No se pudo cambiar comportamiento', r2
		)


	$scope.cambiaNota = (nota)->
		Restangular.one('nota_comportamiento/update', nota.id).customPUT({nota: nota.nota}).then((r)->
			$scope.toastr.success 'Nota cambiada: ' + nota.nota
		, (r2)->
			console.log 'No pudimos guardar la nota ', nota
			$scope.toastr.error 'No pudimos guardar la nota ' + nota.nota
		)

	$scope.quitarFrase = (definicion, alumno)->
		Restangular.one('definiciones_comportamiento/destroy/' + definicion.definicion_id).customDELETE().then((r)->
			$scope.toastr.success 'Definicion quitada'
			alumno.definiciones = $filter('filter')(alumno.definiciones, {definicion_id: '!'+definicion.definicion_id})
			console.log alumno.definiciones, definicion.definicion_id
		, (r2)->
			console.log 'No pudimos quitar frase ', r2
			$scope.toastr.error 'No pudimos quitar frase', 'Problema'
		)


])