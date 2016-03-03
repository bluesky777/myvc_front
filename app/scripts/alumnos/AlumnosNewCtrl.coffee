'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosNewCtrl', ['$scope', '$rootScope', 'toastr', 'Restangular', '$filter', ($scope, $rootScope, toastr, Restangular, $filter)->
	$scope.data = {} # Para el popup del Datapicker

	$scope.alumno = 
		'no_matricula'	: ''
		'nombres'		: ''
		'apellidos'		: ''
		'sexo'			: 'M'
		'documento'		: ''
		'fecha_nac'		: '2000-06-26'
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

	Restangular.one('paises').getList().then((r)->
		$scope.paises = r
		$scope.pais_nac = r[0]
		$scope.paisNacSelect(r[0], $scope.pais_nac)
	, ()->
		console.log 'No se pudo traer los paises'
	)
	Restangular.one('grupos').getList().then((r)->
		$scope.grupos = r
	, ()->
		console.log 'No se pudo traer los grupos'
	)
	
	Restangular.one('tiposdocumento').get().then (r)->
		$scope.tipos_doc = r
	
	
	$scope.crear = ()->

		$scope.alumno.fecha_nac = $filter('date')($scope.alumno.fecha_nac, 'yyyy-MM-dd')

		Restangular.all('alumnos/store').post($scope.alumno).then((r)->
			toastr.success 'Alumno '+r.nombres+' creado'
			$scope.$emit 'alumnoguardado', r
		, (r2)->
			toastr.warning 'No se pudo guardar alumno', 'Problema'
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
		formatYear: 'yy'


	$scope.restarEstrato = ()->
		if $scope.alumno.estrato > 0
			$scope.alumno.estrato = $scope.alumno.estrato - 1
	$scope.sumarEstrato = ()->
		if $scope.alumno.estrato < 10
			$scope.alumno.estrato = $scope.alumno.estrato + 1

	return
])
