'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresNewCtrl', ['$scope', '$http', 'toastr', '$filter', ($scope, $http, toastr, $filter)->

	$scope.profesor =
		'sexo'			: 'M'
		'fecha_nac'		: new Date('1990-01-01')


	$scope.estados_civiles = [{estado_civil: 'Soltero'},{estado_civil: 'Casado'}, {estado_civil: 'Divorciado'}, {estado_civil: 'Viudo'}]

	$http.get('::paises').then((r)->
		$scope.paises = r.data
	)

	$http.get('::tiposdocumento').then (r)->
		$scope.tipos_doc = r.data


	$scope.crear = ()->
		$scope.profesor.fecha_nac = $filter('date')($scope.profesor.fecha_nac, 'yyyy-MM-dd')

		$http.post('::profesores/store', $scope.profesor).then((r)->
			toastr.success 'Profesor creado'
			$scope.$emit 'profesorcreado', r.data
		, (r2)->
			toastr.error 'Profesor NO creado', 'Problema'
		)


	$scope.paisNacSelect = ($item, $model)->
		$http.get("::ciudades/departamentos/"+$item.id).then((r)->
			$scope.departamentosNac = r.data

			if typeof $scope.profesor.pais_doc is 'undefined'
				$scope.profesor.pais_doc = $item
				$scope.paisSelecionado($item)
		)

	$scope.departNacSelect = ($item)->
		$http.get("::ciudades/por-departamento/"+$item.departamento).then((r)->
			$scope.ciudadesNac = r.data

			if typeof $scope.profesor.departamento_doc is 'undefined'
				$scope.profesor.departamento_doc = $item
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
		formatYear: 'yy'

	return
])
