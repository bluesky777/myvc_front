'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosEditCtrl', ['$scope', '$state', '$http', 'toastr', ($scope, $state, $http, toastr)->
	$scope.data = {} # Para el popup del Datapicker
	
	$scope.alumno = {}

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]

	$http.get('::alumnos/show/'+$state.params.alumno_id).then (r)->
		
		$scope.alumno 				= r.data
		$scope.alumno.username 		= r.data.user.username if r.data.user
		$scope.alumno.email2 		= r.data.user.email if r.data.user
		$scope.alumno.ciudad_nac_id = r.data.ciudad_nac
		$scope.alumno.ciudad_doc_id = r.data.ciudad_doc

		if $scope.alumno.ciudad_nac == null
			$scope.alumno.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisNacSelect($scope.alumno.pais_nac, $scope.alumno.pais_nac)
		else
			$http.get('::ciudades/datosciudad/'+$scope.alumno.ciudad_nac_id).then (r2)->
				$scope.paises 				= r2.data.paises
				$scope.departamentosNac 	= r2.departamentos
				$scope.ciudadesNac 			= r2.ciudades
				$scope.alumno.pais_nac 		= r2.pais
				$scope.alumno.departamento_nac = r2.departamento
				$scope.alumno.ciudad_nac 	= r2.ciudad

		if $scope.alumno.ciudad_doc > 0
			$http.get('::ciudades/datosciudad/'+$scope.alumno.ciudad_doc_id).then (r2)->
				$scope.paises 				= r2.data.paises
				$scope.departamentos 		= r2.departamentos
				$scope.ciudades 			= r2.ciudades
				$scope.alumno.pais_doc 		= r2.pais
				$scope.alumno.departamento_doc = r2.departamento
				$scope.alumno.ciudad_doc 	= r2.ciudad


	

	$http.get('::paises').then((r)->
		$scope.paises = r.data
	)

	$http.get('::tiposdocumento').then (r)->
		$scope.tipos_doc = r.data
	
	
	$scope.guardar = ()->
		$http.put('::alumnos/update/'+$scope.alumno.id, $scope.alumno).then((r)->
			toastr.success 'Alumno actualizado correctamente'
		, (r2)->
			toastr.error 'No se pudo guardar el alumno'
		)


	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data

			if typeof $scope.alumno.pais_doc is 'undefined'
				$scope.alumno.pais_doc = $item
				$scope.paisSelecionado($item)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.alumno.departamento_doc is 'undefined'
				$scope.alumno.departamento_doc = $item
				$scope.departSeleccionado($item)
		)

	$scope.paisSelecionado = ($item, $model)->
		
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data
		)

	$scope.departSeleccionado = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudades = r.data
		)

	$scope.dateOptions = 
		formatYear: 'yyyy'


	$scope.restarEstrato = ()->
		if $scope.alumno.estrato > 0
			$scope.alumno.estrato = $scope.alumno.estrato - 1
	$scope.sumarEstrato = ()->
		if $scope.alumno.estrato < 10
			$scope.alumno.estrato = parseInt($scope.alumno.estrato) + 1

	return
])
