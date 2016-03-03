'use strict'

angular.module("myvcFrontApp")

.controller('UsuariosEditCtrl', ['$scope', '$rootScope', '$state', 'Restangular', 'toastr', ($scope, $rootScope, $state, Restangular, toastr)->
	$scope.data = {} # Para el popup del Datapicker
	
	$scope.usuario = {}
	$scope.tipos = [
		{'tipo': 'Alumno'}
		{'tipo': 'Profesor'}
		{'tipo': 'Acudiente'}
		{'tipo': 'Solo usuario'}
	]

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]

	Restangular.one('usuarios/show', $state.params.usuario_id).get().then (r)->
		$scope.usuario = r



	
	$scope.guardar = ()->
		Restangular.one('alumnos/update', $scope.alumno.id).customPUT($scope.alumno).then((r)->
			toastr.success 'Alumno actualizado correctamente'
		, (r2)->
			toastr.error 'No se pudo guardar el alumno'
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
