angular.module('myvcFrontApp')
.controller('ComportamientoCtrl', ['$scope', '$filter', '$rootScope', '$state', '$interval', 'comportamiento', '$uibModal', 'App', 'Restangular', 'AuthService', ($scope, $filter, $rootScope, $state, $interval, comportamiento, $modal, App, Restangular, AuthService) ->

	AuthService.verificar_acceso()

	$scope.perfilPath = App.images+'perfil/'

	$scope.frases = comportamiento[0]
	$scope.alumnos = comportamiento[1]
	$scope.grupo = comportamiento[2]
	$scope.tipos = [
		{tipo_frase:	'Todas'}
		{tipo_frase:	'Debilidad'}
		{tipo_frase:	'Amenaza'}
		{tipo_frase:	'Oportunidad'}
		{tipo_frase:	'Fortaleza'}
	]

	$scope.addFrase = (alumno)->

		alumno.agregando_frase = true

		if alumno.newfrase
			dato = 
				comportamiento_id:	alumno.nota.id
				frase_id:			alumno.newfrase.id

			Restangular.one('definiciones_comportamiento/store').customPOST(dato).then((r)->
				$scope.toastr.success 'Frase agregada con éxito'
				alumno.newfrase.definicion_id = r.id
				alumno.definiciones.push alumno.newfrase
				alumno.newfrase = null
				alumno.agregando_frase = false
			, (r2)->
				$scope.toastr.error 'No se pudo agregar la frase', 'Problema'
				console.log 'No se añadió la frase', r2
				alumno.agregando_frase = false
			)
		else
			$scope.toastr.warning 'Debe seleccionar frase'
			return


	$scope.addFraseEscrita = (alumno)->

		alumno.agregando_frase = true

		if alumno.newfrase_escrita != ''
			dato = 
				comportamiento_id:	alumno.nota.id
				frase:				alumno.newfrase_escrita

			Restangular.one('definiciones_comportamiento/store-escrita').customPOST(dato).then((r)->
				$scope.toastr.success 'Frase agregada con éxito'
				alumno.newfrase_escrita = ''
				alumno.definiciones.push r
				alumno.agregando_frase = false
			, (r2)->
				$scope.toastr.error 'No se pudo agregar la frase', 'Problema'
				console.log 'No se añadió la frase', r2
				alumno.agregando_frase = false
			)
		else
			$scope.toastr.warning 'Debe escribir la frase'
			return


	$scope.cambiaNota = (nota)->
		console.log nota

		temp = nota.nota

		Restangular.one('nota_comportamiento/update', nota.id).customPUT({nota: nota.nota}).then((r)->
			$scope.toastr.success 'Nota cambiada: ' + nota.nota
		, (r2)->
			console.log 'No pudimos guardar la nota ', nota
			$scope.toastr.error 'No pudimos guardar la nota ' + nota.nota
			nota.nota = temp
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

.filter('porTipoFrase', [ ->
	(input, tipo_frase)->

		if tipo_frase == 'Todas' or tipo_frase == undefined then return input

		resultado = []

		for frase in input

			if tipo_frase == frase.tipo_frase

				resultado.push frase



		return resultado

]);



