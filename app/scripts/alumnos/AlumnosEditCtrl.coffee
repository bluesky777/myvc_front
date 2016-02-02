'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosEditCtrl', ['$scope', '$rootScope', '$state', 'Restangular', 'RAlumnos', 'RPaises', 'RCiudades', ($scope, $rootScope, $state, Restangular, RAlumnos, RPaises, RCiudades)->
	$scope.data = {} # Para el popup del Datapicker
	
	$scope.alumno = {}

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]

	Restangular.one('alumnos/show', $state.params.alumno_id).get().then (r)->
		$scope.alumno = r
		#console.log 'Llega: ', $scope.alumno
		$scope.alumno.username = r.user.username if r.user
		$scope.alumno.email2 = r.user.email if r.user

		if $scope.alumno.ciudad_nac == null
			$scope.alumno.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisNacSelect($scope.alumno.pais_nac, $scope.alumno.pais_nac)
		else
			Restangular.one('ciudades/datosciudad', $scope.alumno.ciudad_nac).get().then (r2)->
				$scope.paises = r2.paises
				$scope.departamentosNac = r2.departamentos
				$scope.ciudadesNac = r2.ciudades
				$scope.alumno.pais_nac = r2.pais
				$scope.alumno.departamento_nac = r2.departamento
				$scope.alumno.ciudad_nac = r2.ciudad

			Restangular.one('ciudades/datosciudad', $scope.alumno.ciudad_doc).get().then (r2)->
				$scope.paises = r2.paises
				$scope.departamentos = r2.departamentos
				$scope.ciudades = r2.ciudades
				$scope.alumno.pais_doc = r2.pais
				$scope.alumno.departamento_doc = r2.departamento
				$scope.alumno.ciudad_doc = r2.ciudad


	

	RPaises.getList().then((r)->
		$scope.paises = r
	, (r2)->
		console.log 'No se pudo traer los paises', r2
	)

	Restangular.one('tiposdocumento').get().then (r)->
		$scope.tipos_doc = r
	
	
	$scope.guardar = ()->
		console.log 'A guardar: ', $scope.alumno
		Restangular.one('alumnos/update', $scope.alumno.id).customPUT($scope.alumno).then((r)->
			console.log 'Se guardó alumno', r
			$scope.toastr.success 'Alumno actualizado correctamente'
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
			$scope.toastr.error 'No se pudo guardar el alumno'
		)


	$scope.paisNacSelect = ($item, $model)->
		Restangular.one("ciudades/departamentos", $item.id).get().then((r)->
			$scope.departamentosNac = r

			if typeof $scope.alumno.pais_doc is 'undefined'
				$scope.alumno.pais_doc = $item
				$scope.paisSelecionado($item)
		)

	$scope.departNacSelect = ($item)->
		Restangular.one("ciudades/pordepartamento", $item.departamento).get().then((r)->
			$scope.ciudadesNac = r

			if typeof $scope.alumno.departamento_doc is 'undefined'
				$scope.alumno.departamento_doc = $item
				$scope.departSeleccionado($item)
		)

	$scope.paisSelecionado = ($item, $model)->
		
		Restangular.one("ciudades/departamentos", $item.id).get().then((r)->
			$scope.departamentos = r
		)

	$scope.departSeleccionado = ($item)->
		Restangular.one("ciudades/pordepartamento", $item.departamento).get().then((r)->
			$scope.ciudades = r
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
