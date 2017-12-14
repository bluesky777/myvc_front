'use strict'

angular.module("myvcFrontApp")

.controller('UsuariosEditCtrl', ['$scope', '$rootScope', '$state', '$http', 'toastr', ($scope, $rootScope, $state, $http, toastr)->
	$scope.data = {} # Para el popup del Datapicker
	
	$scope.usuario = {}
	$scope.tipos = [
		{'tipo': 'Alumno'}
		{'tipo': 'Profesor'}
		{'tipo': 'Acudiente'}
		{'tipo': 'Solo usuario'}
	]

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]

	$http.get('::usuarios/show/'+$state.params.usuario_id).then (r)->
		$scope.usuario = r.data



	
	$scope.guardar = ()->
		$http.put('::alumnos/update/'+ $scope.alumno.id, $scope.alumno).then((r)->
			toastr.success 'Alumno actualizado correctamente'
		, (r2)->
			toastr.error 'No se pudo guardar el alumno'
		)


	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+ $item.id).then((r)->
			$scope.departamentosNac = r

			if typeof $scope.alumno.pais_doc is 'undefined'
				$scope.alumno.pais_doc = $item
				$scope.paisSelecionado($item)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/pordepartamento/"+$item.departamento).get().then((r)->
			$scope.ciudadesNac = r

			if typeof $scope.alumno.departamento_doc is 'undefined'
				$scope.alumno.departamento_doc = $item
				$scope.departSeleccionado($item)
		)

	$scope.paisSelecionado = ($item, $model)->
		
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentos = r.data
		)

	$scope.departSeleccionado = ($item)->
		$http.get("::ciudades/pordepartamento/"+$item.departamento).then((r)->
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
