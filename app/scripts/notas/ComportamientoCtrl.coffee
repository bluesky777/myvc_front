angular.module('myvcFrontApp')
.controller('ComportamientoCtrl', ['$scope', '$filter', '$state', 'comportamiento', '$uibModal', 'App', '$http', 'AuthService', 'toastr', 'EscalasValorativasServ', ($scope, $filter, $state, comportamiento, $modal, App, $http, AuthService, toastr, EscalasValorativasServ) ->

	AuthService.verificar_acceso()

	$scope.perfilPath 	= App.images+'perfil/'
	$scope.profesor_id 	= localStorage.profesor_id
	

	$scope.frases 	= comportamiento[0]
	$scope.alumnos 	= comportamiento[1]
	$scope.grupo 	  = comportamiento[2]
	$scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm
	$scope.tipos 	= [
		{tipo_frase:	'Todas'}
		{tipo_frase:	'Debilidad'}
		{tipo_frase:	'Amenaza'}
		{tipo_frase:	'Oportunidad'}
		{tipo_frase:	'Fortaleza'}
	]


	EscalasValorativasServ.escalas().then((r)->
		$scope.escalas = r
		$scope.escala_maxima = EscalasValorativasServ.escala_maxima()
	, (r2)->
		console.log 'No se trajeron las escalas valorativas', r2
	)


	$scope.fraseCheck = (texto)->
		$scope.verificandoFrase = true
		return $http.put('::nota_comportamiento/frases-check', {texto: texto}).then((r)->
			$scope.frases_match 		  = r.data.frases
			$scope.verificandoFrase 	= false
			return $scope.frases_match.map((item)->
				return item.frase
			)
		)
		
	################################
	# LIBRO ROJO
		
	$scope.comprobadorLibro = (alumno)->
		# para el badge
		alumno.libro.per1_conta = 0
		alumno.libro.per1_conta = if alumno.libro.per1_col1 then alumno.libro.per1_conta+1 else alumno.libro.per1_conta
		alumno.libro.per1_conta = if alumno.libro.per1_col2 then alumno.libro.per1_conta+1 else alumno.libro.per1_conta
		alumno.libro.per1_conta = if alumno.libro.per1_col3 then alumno.libro.per1_conta+1 else alumno.libro.per1_conta

		alumno.libro.per2_conta = 0
		alumno.libro.per2_conta = if alumno.libro.per2_col1 then alumno.libro.per2_conta+1 else alumno.libro.per2_conta
		alumno.libro.per2_conta = if alumno.libro.per2_col2 then alumno.libro.per2_conta+1 else alumno.libro.per2_conta
		alumno.libro.per2_conta = if alumno.libro.per2_col3 then alumno.libro.per2_conta+1 else alumno.libro.per2_conta

		alumno.libro.per3_conta = 0
		alumno.libro.per3_conta = if alumno.libro.per3_col1 then alumno.libro.per3_conta+1 else alumno.libro.per3_conta
		alumno.libro.per3_conta = if alumno.libro.per3_col2 then alumno.libro.per3_conta+1 else alumno.libro.per3_conta
		alumno.libro.per3_conta = if alumno.libro.per3_col3 then alumno.libro.per3_conta+1 else alumno.libro.per3_conta

		alumno.libro.per4_conta = 0
		alumno.libro.per4_conta = if alumno.libro.per4_col1 then alumno.libro.per4_conta+1 else alumno.libro.per4_conta
		alumno.libro.per4_conta = if alumno.libro.per4_col2 then alumno.libro.per4_conta+1 else alumno.libro.per4_conta
		alumno.libro.per4_conta = if alumno.libro.per4_col3 then alumno.libro.per4_conta+1 else alumno.libro.per4_conta

		
	for alumno in $scope.alumnos
		alumno.periodoLibro = 1 # Cambiar por el USER.periodo
		$scope.comprobadorLibro(alumno)
		
	$scope.selectPeriodo = (per, alum)->
		alum.periodoLibro = per
		
	$scope.cambiaLibro = (valor, alum, campo)->
		$http.put('::nota_comportamiento/guardar-libro', {valor: valor, campo: campo, libro_id: alum.libro.id}).then((r)->
			$scope.comprobadorLibro(alum)
			toastr.success 'Cambios guardados'
		, (item)->
			toastr.error 'Error guardando libro' 
		)

	
	################################
	# Comportamiento boletín
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
				frase:				      alumno.newfrase_escrita

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
		defin_id = if definicion.definicion_id then definicion.definicion_id else definicion.id
		$http.delete('::definiciones_comportamiento/destroy/' + defin_id).then((r)->
			toastr.success 'Definicion quitada'
			if definicion.definicion_id
				alumno.definiciones = $filter('filter')(alumno.definiciones, {definicion_id: '!'+defin_id})
			else
				alumno.definiciones = $filter('filter')(alumno.definiciones, {id: '!'+defin_id})
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



