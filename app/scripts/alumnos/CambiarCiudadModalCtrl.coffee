angular.module("myvcFrontApp")

.controller('CambiarCiudadModalCtrl', ['$scope', '$uibModalInstance', 'persona', 'paises', 'tipo_ciudad', 'tipo_persona', '$http', 'toastr', '$filter', ($scope, $modalInstance, persona, paises, tipo_ciudad, tipo_persona, $http, toastr, $filter)->
	$scope.persona 				= persona
	$scope.paises 				= paises
	$scope.tipo_ciudad 			= tipo_ciudad
	$scope.modificarCiudades 	= false
	$scope.datos 				= {}


	$scope.creando_ciudad 		= false
	$scope.creando_departamento = false
	$scope.creando_pais 		= false

	$scope.ciudad_new 			= ''
	$scope.departamento_new 	= ''
	$scope.pais_new 			= ''
	$scope.modificando_depart 	= false

	

	$scope.crearCiudad = ()->
		$scope.creando_ciudad = true
		$scope.$broadcast('paisSeleccionadoEvent2');

	$scope.crearDepartamento = ()->
		$scope.creandodepartamento = true

	$scope.crearPais = ()->
		$scope.creandopais = true

	$scope.guardarCiudad = (ciudad_new, departamento_new)->

		if !$scope.datos.pais
			toastr.warning 'Debes seleccionar un pais.'
			return
		if !$scope.datos.departamento and departamento_new==''
			toastr.warning 'Debe seleccionar departamento o escribir uno nuevo.'
			return
		if ciudad_new==''
			toastr.warning 'Debe escribir la nueva ciudad.'
			return

		if $scope.datos.departamento
			depart_guardar 	= departamento.departamento
		else
			depart_guardar 	= departamento_new

		$http.post('::ciudades/guardar-ciudad', {ciudad: ciudad_new, departamento: depart_guardar, pais_id: $scope.datos.pais.id } ).then( (r)->
			toastr.success 'Creado correctamente: ' + r.data.ciudad
			if $scope.datos.departamento then $scope.ciudades.push r.data
			$scope.creandociudad 	= false
			$scope.ciudad_new 		= '' # No sé por qué no funciona!
			$scope.departamento_new = ''

			$scope.guardar = true

			$http.get('::paises').then((r)->
				$scope.paises = r.data
				$scope.paisSelect($filter('filter')($scope.paises, { id: 1 })[0])
			, (r2)->
				toastr.error 'No se pudo traer las ciudades.'
			)
		, (r2)->
			toastr.error 'No se pudo crear', 'Error'
		)

	$scope.guardarPais = ()->

		$http.post('::paises/guardar', $scope.pais_new ).then( (r)->
			toastr.success 'Creado correctamente: ' + r.data.paisnuevo
			$scope.paises.push r.data
			$scope.paisSelect($scope.ciudad_new.pais)
				
		, (r2)->
			toastr.error 'No se pudo crear', 'Error'
		)

	$scope.escribeEnDepartamentoNew = ()->
		$scope.datos.departamento = undefined

	$scope.actualizarCiudad = (ciudad)->
		$http.put('::ciudades/actualizar-ciudad', ciudad).then( (r)->
			toastr.success 'Actualizado: ' + ciudad.ciudad
			ciudad.editandoCiudad = false
		, (r2)->
			toastr.error 'No se pudo actualizar', 'Error'
		)

	$scope.actualizarDepartamento = (ciudad)->
		$http.put('::ciudades/actualizar-departamento', ciudad).then( (r)->
			toastr.success 'Actualizado: ' + ciudad.departamento
			ciudad.editandoDepart = false
			pais = $scope.ciudad_new.pais

			for ciud in $scope.ciudades
				ciud.departamento = ciudad.departamento

			$scope.modificando_depart = true

		, (r2)->
			toastr.error 'No se pudo actualizar', 'Error'
		)
	$scope.actualizarPais = (pais)->
		$http.put('::paises/actualizar', pais).then( (r)->
			toastr.success 'Actualizado: ' + pais.pais
			pais.editandoPais = false
			pais.editandoAbrev = false
		, (r2)->
			toastr.error 'No se pudo actualizar', 'Error'
		)





	$scope.paisSelect = ($item, numero)->
		$http.put("::ciudades/departamentos-by-id", { pais_id: $item.id }).then((r)->
			$scope.departamentos = r.data.departamentos

			if typeof $scope.datos.pais is 'undefined'
				$scope.datos.pais = $item
			$scope.$broadcast('paisSeleccionadoEvent' + numero);
		)

	# Que inicialmente aparezca la primera opción, Colombia.
	$scope.paisSelect($filter('filter')($scope.paises, { id: 1 })[0], 1)


	$scope.departamentoSelect = ($item, numero)->
		if $item
			$scope.departamento_new = ''
			$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
				$scope.ciudades = r.data

				if typeof $scope.datos.departamento is 'undefined'
					$scope.datos.departamento = $item
				$scope.$broadcast('departamentoSeleccionadoEvent' + numero);
			)
		


	$scope.eliminarCiudad = (ciudad)->

		$http.delete('::ciudades/destroy/'+ciudad.id).then((r)->
			toastr.success 'Ciudad enviada a la papelera.', 'Eliminado'
			$scope.ciudades = $filter('filter')($scope.ciudades, {id: '!'+ciudad.id})
		, (r2)->
			toastr.warning 'No se pudo enviar a la papelera.', 'Problema'
		)

	$scope.ok = (ciudad)->
		if $scope.seleccionandoCiudad
			return
		$scope.seleccionandoCiudad = true

		ciudad_selec = $scope.datos.ciudad
		if ciudad
			ciudad_selec = ciudad

		datos = { propiedad: tipo_ciudad, valor: ciudad_selec.id }

		if tipo_persona == 'acudiente'
			datos.acudiente_id 	= persona.id
			datos.parentesco_id = persona.parentesco_id
			datos.user_acud_id 	= persona.user_id
		else
			datos.alumno_id = persona.alumno_id

		$http.put('::' + tipo_persona + 's/guardar-valor', datos ).then((r)->
			toastr.success 'Seleccionado.'
			persona[tipo_ciudad + '_nombre'] 	= ciudad_selec.ciudad
			persona[tipo_ciudad] 				= ciudad_selec.id
			$modalInstance.close(persona)
		, (r2)->
			toastr.warning 'No se pudo seleccionar.', 'Problema'
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
