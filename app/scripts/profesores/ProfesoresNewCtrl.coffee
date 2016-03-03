'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresNewCtrl', ['$scope', 'Restangular', 'toastr', ($scope, Restangular, toastr)->

	$scope.profesor = 
		'nombres'		: 'FRANCISCO'
		'apellidos'		: 'BAEZ'
		'sexo'			: 'M'
		'documento'		: '99817333'
		'fecha_nac'		: '2000-06-26'
		'telefono'		: '8886242'
		'celular'		: '3216478754'
		'direccion'		: 'CRR 45 NO 30-23'
		'barrio'		: 'MORICHAL'
		'email'			: 'miguelito@gmail.com'
		'facebook'		: 'miguelito@gmail.com'


	$scope.estados_civiles = [{estado_civil: 'Soltero'},{estado_civil: 'Casado'}, {estado_civil: 'Divorciado'}, {estado_civil: 'Viudo'}]

	Restangular.one('paises').getList().then((r)->
		$scope.paises = r
	)
	
	Restangular.one('tiposdocumento').getList().then (r)->
		$scope.tipos_doc = r
	

	$scope.crear = ()->
		Restangular.one('profesores/store').customPOST($scope.profesor).then((r)->
			toastr.success 'Profesor creado con éxito'
			$scope.$emit 'profesorcreado', r
		, (r2)->
			toastr.error 'Profesor NO creado', 'Problema'
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
		formatYear: 'yy'

	return
])
