'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresEditCtrl', ['$scope', 'toastr', '$http', '$state', ($scope, toastr, $http, $state)->
	$scope.data = {} # Para el popup del Datapicker
	
	$scope.profesor = {}
	$scope.paises = [{id:1, pais: 'COLOMBIA'}]
	$scope.tipos_doc = [{id:1, tipo: 'CC'}]
	$scope.departamentos = [{id:1, departamento: 'ANTIOQUIA'}]
	$scope.ciudades = [{id:1, ciudad: 'MEDELLÍN'}]


	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]
	$scope.estados_civiles = [{estado_civil: 'Soltero'},{estado_civil: 'Casado'}, {estado_civil: 'Divorciado'}, {estado_civil: 'Viudo'}]

	$http.get('::profesores/show/'+$state.params.profe_id).then (r)->
		r = r.data
		$scope.profesor = r[0]
		$scope.profesor.estado_civil = {estado_civil: r[0].estado_civil}


		if $scope.profesor.ciudad_nac == null
			$scope.profesor.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisNacSelect($scope.profesor.pais_nac, $scope.profesor.pais_nac)
		else
			$http.get('::ciudades/datosciudad', $scope.profesor.ciudad_nac).then (r2)->
				$scope.paises = r2.paises
				$scope.departamentosNac = r2.departamentos
				$scope.ciudadesNac = r2.ciudades
				$scope.profesor.pais_nac = r2.pais
				$scope.profesor.departamento_nac = r2.departamento
				$scope.profesor.ciudad_nac = r2.ciudad

		if $scope.profesor.ciudad_doc == null
			$scope.profesor.pais_doc = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisDocSelect($scope.profesor.pais_doc, $scope.profesor.pais_doc)
		else
			$http.get('::ciudades/datosciudad', $scope.profesor.ciudad_doc).then (r2)->
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
				$scope.profesor.tipo_doc = {id: 1, tipo: 'CÉDULA', abrev: 'CC'}
			else
				$scope.profesor.tipo_doc = $filter('filter')($scope.tipos_doc, {id: $scope.profesor.tipo_doc})


	

	$http.get('::paises').then((r)->
		$scope.paises = r.data
	, (r2)->
		toastr.error 'No se pudo traer los paises'
	)

	
	
	
	$scope.guardar = ()->
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
		$http.get("::ciudades/pordepartamento/"+$item.departamento).then((r)->
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
		$http.get("::ciudades/pordepartamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)

	$scope.dateOptions = 
		formatYear: 'yyyy'


	return
])
