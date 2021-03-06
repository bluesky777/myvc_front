'use strict'

angular.module("myvcFrontApp")


.controller('NewAcudienteModalCtrl', ['$scope', 'App', '$uibModalInstance', 'alumno', 'paises', 'tipos_doc', 'parentescos', '$http', 'toastr', '$filter', '$rootScope', '$timeout', ($scope, App, $modalInstance, alumno, paises, tipos_doc, parentescos, $http, toastr, $filter, $rootScope, $timeout)->
	$scope.alumno 				    = alumno
	$scope.paises 				    = paises
	$scope.parentescos 			  = parentescos
	$scope.datos 				      = {}
	$scope.tipos_doc 			    = tipos_doc
	$scope.crearTabSelected 	= false
	$scope.selectTabSelected 	= true
	$scope.perfilPath 			  = App.images+'perfil/'
	$scope.acudiente_cambiar  = $rootScope.acudiente_cambiar


	$scope.acudiente 	= {
		sexo:			'M'
		parentesco: 	$scope.parentescos[0]
		tipo_doc: 		$scope.tipos_doc[0]
	}

	$scope.acudientes = [  ]


	if $scope.acudiente_cambiar
		if $scope.acudiente_cambiar.parentesco
			for paren in $scope.parentescos
				if paren.parentesco.toLowerCase() == $scope.acudiente_cambiar.parentesco.toLowerCase()
					$scope.acudiente.parentesco = paren



	$scope.selectCrearTab = ()->
		$scope.crearTabSelected 	= true
		$scope.selectTabSelected 	= false

	$scope.selectSelectTab = ()->
		$scope.crearTabSelected 	= false
		$scope.selectTabSelected 	= true


	$scope.selecAcudOption = (acudiente)->
		for parentesc in $scope.parentescos
			if parentesc.parentesco == 'Madre' and acudiente.sexo == 'F'
				$scope.acudiente.parentesco = parentesc
			if parentesc.parentesco == 'Padre' and acudiente.sexo == 'M'
				$scope.acudiente.parentesco = parentesc


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

	$scope.$on('modal.closing', (event, reason, closed)->

		switch (reason)
			when "backdrop click", "escape key press"
				if (!confirm('¿Seguro que quiere cerrar sin guardar acudiente?'))
					event.preventDefault();



	)


	$http.put('::acudientes/ultimos').then((r)->
		$scope.sin_repetir(r.data)
	)


	$scope.refreshAcudientes = (termino)->
		if termino
			$http.put('::acudientes/buscar', { termino: termino } ).then((r)->
				$scope.sin_repetir(r.data)
			, (r2)->
				toastr.warning 'No se pudo encontrar nada.', 'Problema'
			)

	$scope.sin_repetir = (respuesta)->
		res = []
		for acudi in respuesta
			$scope.existe = false

			parientes = if alumno.subGridOptions then alumno.subGridOptions.data else alumno.parientes
			for pariente in parientes
				if pariente.id == acudi.id
					$scope.existe = true

			if !$scope.existe
				res.push acudi

		$scope.acudientes = res


	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.acudiente.departamento_doc is 'undefined'
				$scope.acudiente.departamento_doc = $item
				$scope.departSeleccionado($item)
		)

	$scope.paisSelecionado = ($item, $model)->

		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data

			if typeof $scope.acudiente.pais_nac is 'undefined'
				for un_pais in $scope.paises
					if un_pais.id == $item.id
						$scope.acudiente.pais_nac = un_pais
						$scope.paisNacSelect(un_pais)
		)

	$scope.departSeleccionado = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)

	$scope.dateOptions =
		formatYear: 'yy'


	$scope.restarEstrato = ()->
		if $scope.alumno.estrato > 0
			$scope.alumno.estrato = $scope.alumno.estrato - 1
	$scope.sumarEstrato = ()->
		if $scope.alumno.estrato < 10
			$scope.alumno.estrato = $scope.alumno.estrato + 1


	$scope.crearAcudiente = ()->

		$scope.acudiente.alumno_id = alumno.alumno_id

		$http.post('::acudientes/crear', $scope.acudiente ).then((r)->
			toastr.success 'Acudiente creado con éxito.'
			$modalInstance.close(r.data)
		, (r2)->
			toastr.warning 'No se pudo crear al alumno.', 'Problema'
		)


	$scope.seleccionarAcudiente = ()->
		datos = { acudiente_id: $scope.datos.acudiente.id, alumno_id: alumno.alumno_id, parentesco: $scope.acudiente.parentesco.parentesco, ocupacion: $scope.acudiente.ocupacion }

		if $rootScope.acudiente_cambiar
			datos.parentesco_acudiente_cambiar_id = $rootScope.acudiente_cambiar.parentesco_id

		$http.put('::acudientes/seleccionar-parentesco', datos ).then((r)->
			toastr.success 'Acudiente seleccionado.'
			delete $rootScope.acudiente_cambiar
			$modalInstance.close(r.data)
		, (r2)->
			toastr.warning 'No se pudo seleccionar.', 'Problema'
		)


	$scope.ocupacionCheck = (texto)->
		$scope.verificandoOcupacion = true
		return $http.put('::acudientes/ocupaciones-check', {texto: texto}).then((r)->
			$scope.ocupaciones_match 		= r.data.ocupaciones
			$scope.verificandoOcupacion 	= false
			return $scope.ocupaciones_match.map((item)->
				return item.ocupacion
			)
		)

])
