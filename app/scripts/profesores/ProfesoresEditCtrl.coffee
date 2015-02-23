'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresEditCtrl', ['$scope', '$rootScope', '$interval', 'Restangular', '$state', 'RPaises', 'RCiudades', ($scope, $rootScope, $interval, Restangular, $state, RPaises, RCiudades)->
	$scope.data = {} # Para el popup del Datapicker
	
	$scope.profesor = {}

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]
	$scope.estados_civiles = [{estado_civil: 'Soltero'},{estado_civil: 'Casado'}, {estado_civil: 'Divorciado'}, {estado_civil: 'Viudo'}]

	Restangular.one('profesores/show', $state.params.profe_id).get().then (r)->
		$scope.profesor = r
		console.log 'Llega: ', $scope.profesor
		$scope.profesor.username = r.user.username if r.user
		$scope.profesor.email2 = r.user.email if r.user
		$scope.profesor.estado_civil = {estado_civil: r.estado_civil}

		if $scope.profesor.ciudad_nac == null
			$scope.profesor.pais_nac = {id: 1, pais: 'COLOMBIA', abrev: 'CO'}
			$scope.paisNacSelect($scope.profesor.pais_nac, $scope.profesor.pais_nac)
		else
			Restangular.one('ciudades/datosciudad', $scope.profesor.ciudad_nac).get().then (r2)->
				$scope.paises = r2.paises
				$scope.departamentosNac = r2.departamentos
				$scope.ciudadesNac = r2.ciudades
				$scope.profesor.pais_nac = r2.pais
				$scope.profesor.departamento_nac = r2.departamento
				$scope.profesor.ciudad_nac = r2.ciudad

			Restangular.one('ciudades/datosciudad', $scope.profesor.ciudad_doc).get().then (r2)->
				$scope.paises = r2.paises
				$scope.departamentos = r2.departamentos
				$scope.ciudades = r2.ciudades
				$scope.profesor.pais_doc = r2.pais
				$scope.profesor.departamento_doc = r2.departamento
				$scope.profesor.ciudad_doc = r2.ciudad


	

	RPaises.getList().then((r)->
		$scope.paises = r
	, (r2)->
		console.log 'No se pudo traer los paises', r2
	)

	Restangular.one('tiposdocumento').get().then (r)->
		$scope.tipos_doc = r
	
	
	$scope.guardar = ()->
		console.log 'A guardar: ', $scope.profesor
		Restangular.one('profesores/update', $scope.profesor.id).customPUT($scope.profesor).then((r)->
			console.log 'Se guardó profesor', r
			$scope.toastr.success 'Profesor actualizado con éxito'
		, (r2)->
			console.log 'Falló al intentar guardar: ', r2
			$scope.toastr.error 'No se guardaron los cambios', 'Problemas'
		)


	$scope.paisNacSelect = ($item, $model)->
		Restangular.one("ciudades/departamentos", $item.id).get().then((r)->
			$scope.departamentosNac = r

			if typeof $scope.profesor.pais_doc is 'undefined'
				$scope.profesor.pais_doc = $item
				$scope.paisSelecionado($item)
		)

	$scope.departNacSelect = ($item)->
		Restangular.one("ciudades/pordepartamento", $item.departamento).get().then((r)->
			$scope.ciudadesNac = r

			if typeof $scope.profesor.departamento_doc is 'undefined'
				$scope.profesor.departamento_doc = $item
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


	return
])
