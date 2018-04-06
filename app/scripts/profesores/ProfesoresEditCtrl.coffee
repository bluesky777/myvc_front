'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresEditCtrl', ['$scope', 'toastr', '$http', '$state', '$filter', ($scope, toastr, $http, $state, $filter)->
	$scope.data = {} # Para el popup del Datapicker

	$scope.profesor = {}
	$scope.paises = [{id:1, pais: 'COLOMBIA'}]
	$scope.tipos_doc = [{id:1, tipo: 'CC'}]
	$scope.departamentos = [{id:1, departamento: 'ANTIOQUIA'}]
	$scope.ciudades = [{id:1, ciudad: 'MEDELLÍN'}]


	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]
	$scope.estados_civiles = [{estado_civil: 'Soltero'},{estado_civil: 'Casado'}, {estado_civil: 'Divorciado'}, {estado_civil: 'Viudo'}]



	$http.get('::profesores/show/'+$state.params.profe_id).then (r)->
		$scope.profesor = r.data[0]
		$scope.profesor.fecha_nac = new Date($scope.profesor.fecha_nac)
		$scope.profesor.password  = ''
		$scope.profesor.password2 = ''

		if $scope.profesor.estado_civil
			for estado in $scope.estados_civiles
				if estado.estado_civil == $scope.profesor.estado_civil
					$scope.profesor.estado_civil = estado
		else
			$scope.profesor.estado_civil = $scope.estados_civiles[0]



		if $scope.profesor.ciudad_nac == null
			$scope.profesor.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisNacSelect($scope.profesor.pais_nac, $scope.profesor.pais_nac)
		else
			$http.get('::ciudades/datosciudad/' + $scope.profesor.ciudad_nac).then (r2)->
				$scope.paises             = r2.data.paises
				$scope.departamentosNac   = r2.data.departamentos
				$scope.ciudadesNac        = r2.data.ciudades

				for pais in $scope.paises
					if pais.id == r2.data.pais.id
						$scope.profesor.pais_nac = pais

				for depart in $scope.departamentosNac
					if depart.departamento == r2.data.departamento.departamento
						$scope.profesor.departamento_nac = depart

				for ciudad in $scope.ciudadesNac
					if ciudad.id == r2.data.ciudad.id
						$scope.profesor.ciudad_nac = ciudad


		if $scope.profesor.ciudad_doc == null
			$scope.profesor.pais_doc = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisDocSelect($scope.profesor.pais_doc, $scope.profesor.pais_doc)
		else
			$http.get('::ciudades/datosciudad/' + $scope.profesor.ciudad_doc).then (r2)->
				r2 = r2.data
				$scope.paises = r2.paises
				$scope.departamentos = r2.departamentos
				$scope.ciudades = r2.ciudades
				$scope.profesor.pais_doc = r2.pais
				$scope.profesor.departamento_doc = r2.departamento
				$scope.profesor.ciudad_doc = r2.ciudad

		$http.get('::tiposdocumento').then (r)->
			$scope.tipos_doc = r.data

			if $scope.profesor.tipo_doc == null
				$scope.profesor.tipo_doc = $scope.tipos_doc[0]
			else
				for tipo_d in $scope.tipos_doc
					if $scope.profesor.tipo_doc == tipo_d.id
						$scope.profesor.tipo_doc = tipo_d



	$http.get('::paises').then((r)->
		$scope.paises = r.data
	, (r2)->
		toastr.error 'No se pudo traer los paises'
	)






	$scope.guardar = ()->

		if $scope.profesor.password.length == 0
			if $scope.profesor.password.length > 0
				toastr.warning 'Si lo quieres es cambiar la contraseña, debes copiarla 2 veces.'
				return
		else
			if $scope.profesor.password.length < 3
				toastr.warning 'La contraseña debe tener al menos 3 caracteres'
				return
			else
				if $scope.profesor.password != $scope.profesor.password2
					toastr.warning 'Las contraseñas deben ser iguales'
					return


		$http.put('::profesores/update/'+$scope.profesor.profesor_id, $scope.profesor).then((r)->
			toastr.success 'Profesor actualizado con éxito'
		, (r2)->
			toastr.error 'No se guardaron los cambios', 'Problemas'
		)




	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data

			if typeof $scope.profesor.pais_doc is 'undefined'
				$scope.profesor.pais_doc = $item
				$scope.paisDocSelect($item)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.profesor.departamento_doc is 'undefined'
				$scope.profesor.departamento_doc = $item
				$scope.departDocSelect($item)
		)

	$scope.paisDocSelect = ($item, $model)->

		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data
		)

	$scope.departDocSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)

	$scope.dateOptions =
		formatYear: 'yyyy'


	return
])
