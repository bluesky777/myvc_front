'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosNewCtrl', ['$scope', '$rootScope', 'toastr', '$http', '$filter', '$state', ($scope, $rootScope, toastr, $http, $filter, $state)->
	$scope.data = {} # Para el popup del Datapicker
	$scope.$state = $state;

	$scope.alumno = 
		'no_matricula'	: ''
		'nombres'		: ''
		'apellidos'		: ''
		'sexo'			: 'M'
		'documento'		: ''
		'fecha_nac'		: new Date('2000-06-26')
		'tipo_sangre'	: {}
		'eps'			: ''
		'telefono'		: ''
		'celular'		: ''
		'direccion'		: ''
		'barrio'		: ''
		'estrato'		: 1
		'religion'		: 'PENTECOSTAL UNIDA'
		'email'			: '@gmail.com'
		'facebook'		: '@gmail.com'
		'foto'			: 'perfil/default_male.jpg'
		'pazysalvo'		: true
		'deuda'			: 0
		'pais_nac'		: {id: 1, pais: 'COLOMBIA', abrev: 'CO' }

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]

	$http.get('::paises').then((r)->
		r = r.data
		$scope.paises = r
		$scope.pais_nac = r[0]
		$scope.paisNacSelect(r[0], $scope.pais_nac)
	, ()->
		console.log 'No se pudo traer los paises'
	)
	$http.get('::grupos').then((r)->
		$scope.grupos = r.data
	, ()->
		console.log 'No se pudo traer los grupos'
	)
	
	$http.get('::tiposdocumento').then (r)->
		$scope.tipos_doc = r.data
	
	
	$scope.crear = ()->

		$scope.alumno.fecha_nac = $filter('date')($scope.alumno.fecha_nac, 'yyyy-MM-dd')

		$http.post('::alumnos/store', $scope.alumno).then((r)->
			toastr.success 'Alumno '+r.data.nombres+' creado'
			$scope.$emit 'alumnoguardado', r.data
		, (r2)->
			toastr.warning 'No se pudo guardar alumno', 'Problema'
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
		formatYear: 'yy'


	$scope.restarEstrato = ()->
		if $scope.alumno.estrato > 0
			$scope.alumno.estrato = $scope.alumno.estrato - 1
	$scope.sumarEstrato = ()->
		if $scope.alumno.estrato < 10
			$scope.alumno.estrato = $scope.alumno.estrato + 1

	return
])
