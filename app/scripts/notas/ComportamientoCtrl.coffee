angular.module('myvcFrontApp')
.controller('ComportamientoCtrl', ['$scope', '$filter', '$state', 'comportamiento', '$uibModal', 'App', '$http', 'AuthService', 'toastr', ($scope, $filter, $state, comportamiento, $modal, App, $http, AuthService, toastr) ->

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

			$http.post('::definiciones_comportamiento/store', dato).then((r)->
				toastr.success 'Frase agregada con éxito'
				alumno.newfrase.definicion_id = r.data.id
				alumno.definiciones.push alumno.newfrase
				alumno.newfrase = null
				alumno.agregando_frase = false
			, (r2)->
				toastr.error 'No se pudo agregar la frase', 'Problema'
				alumno.agregando_frase = false
			)
		else
			toastr.warning 'Debe seleccionar frase'
			return


	$scope.addFraseEscrita = (alumno)->

		alumno.agregando_frase = true

		if alumno.newfrase_escrita != ''
			dato = 
				comportamiento_id:	alumno.nota.id
				frase:				alumno.newfrase_escrita

			$http.post('::definiciones_comportamiento/store-escrita', dato).then((r)->
				toastr.success 'Frase agregada con éxito'
				alumno.newfrase_escrita = ''
				alumno.definiciones.push r.data
				alumno.agregando_frase = false
			, (r2)->
				toastr.error 'No se pudo agregar la frase', 'Problema'
				alumno.agregando_frase = false
			)
		else
			toastr.warning 'Debe escribir la frase'
			return


	$scope.cambiaNota = (nota)->
		
		temp = nota.nota

		$http.put('::nota_comportamiento/update/'+nota.id, {nota: nota.nota}).then((r)->
			toastr.success 'Nota cambiada: ' + nota.nota
		, (r2)->
			toastr.error 'No pudimos guardar la nota ' + nota.nota
			nota.nota = temp
		)

	$scope.quitarFrase = (definicion, alumno)->
		$http.delete('::definiciones_comportamiento/destroy/' + definicion.definicion_id).then((r)->
			toastr.success 'Definicion quitada'
			alumno.definiciones = $filter('filter')(alumno.definiciones, {definicion_id: '!'+definicion.definicion_id})
		, (r2)->
			toastr.error 'No pudimos quitar frase', 'Problema'
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



