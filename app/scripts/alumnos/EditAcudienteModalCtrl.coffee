'use strict'

angular.module("myvcFrontApp")


.controller('EditAcudienteModalCtrl', ['$scope', 'App', '$uibModalInstance', 'acudiente', 'paises', 'tipos_doc', 'parentescos', '$http', 'toastr', '$filter', '$rootScope', ($scope, App, $modalInstance, acudiente, paises, tipos_doc, parentescos, $http, toastr, $filter, $rootScope)->
	$scope.acudiente 				= acudiente
	$scope.paises 				= paises
	$scope.parentescos 			= parentescos
	$scope.datos 				= {}
	$scope.tipos_doc 			= tipos_doc
	$scope.perfilPath 			= App.images+'perfil/'




	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')




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



	if $scope.acudiente.tipo_doc == null
		$scope.acudiente.tipo_doc = $scope.tipos_doc[0]
	else
		for tipo_d in $scope.tipos_doc
			if $scope.acudiente.tipo_doc == tipo_d.id
				$scope.acudiente.tipo_doc = tipo_d


	if $scope.acudiente.ciudad_nac == null
		$scope.acudiente.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
		$scope.paisNacSelect($scope.acudiente.pais_nac, $scope.acudiente.pais_nac)
	else
		$http.get('::ciudades/datosciudad/' + $scope.acudiente.ciudad_nac).then (r2)->
			$scope.paises             = r2.data.paises
			$scope.departamentosNac   = r2.data.departamentos
			$scope.ciudadesNac        = r2.data.ciudades

			for pais in $scope.paises
				if pais.id == r2.data.pais.id
					$scope.acudiente.pais_nac = pais

			for depart in $scope.departamentosNac
				if depart.departamento == r2.data.departamento.departamento
					$scope.acudiente.departamento_nac = depart

			for ciudad in $scope.ciudadesNac
				if ciudad.id == r2.data.ciudad.id
					$scope.acudiente.ciudad_nac = ciudad


		if $scope.acudiente.ciudad_doc == null
			$scope.acudiente.pais_doc = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisDocSelect($scope.acudiente.pais_doc, $scope.acudiente.pais_doc)
		else
			$http.get('::ciudades/datosciudad/' + $scope.acudiente.ciudad_doc).then (r2)->
				r2 = r2.data
				$scope.paises = r2.paises
				$scope.departamentos = r2.departamentos
				$scope.ciudades = r2.ciudades
				$scope.acudiente.pais_doc = r2.pais
				$scope.acudiente.departamento_doc = r2.departamento
				$scope.acudiente.ciudad_doc = r2.ciudad




])
