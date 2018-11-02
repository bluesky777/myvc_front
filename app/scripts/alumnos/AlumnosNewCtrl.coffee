'use strict'

angular.module("myvcFrontApp")

.controller('AlumnosNewCtrl', ['$scope', '$rootScope', 'toastr', '$http', '$filter', '$state', ($scope, $rootScope, toastr, $http, $filter, $state)->
	$scope.data       			= {} # Para el popup del Datapicker
	$scope.$state     			= $state;
	$scope.data.proceso    	= 'matriculando'

	$scope.formatear_nuevo = ()->
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
			'email'			: '@gmail.com'
			'foto'			: 'perfil/default_male.jpg'
			'pazysalvo'		: true
			'deuda'			: 0
			'nuevo'			: 0
			'repitente'			: 0
			'pais_nac'		: {id: 1, pais: 'COLOMBIA', abrev: 'CO' }

	$scope.formatear_nuevo()

	$scope.sangres = [{sangre: 'O+'},{sangre: 'O-'}, {sangre: 'A+'}, {sangre: 'A-'}, {sangre: 'B+'}, {sangre: 'B-'}, {sangre: 'AB+'}, {sangre: 'AB-'}]

	if localStorage.mostrar_mas_new
		$scope.mostrar_mas_new = if localStorage.mostrar_mas_new == 'true' then true else false

	$http.get('::paises').then((r)->
		r = r.data
		$scope.paises = r
		$scope.pais_nac = r[0]
		$scope.paisNacSelect(r[0], $scope.pais_nac)
	, ()->
		console.log 'No se pudo traer los paises'
	)

	$http.get('::tiposdocumento').then (r)->
		$scope.tipos_doc = r.data



	$scope.mostarMasDetalleNew = ()->
		$scope.mostrar_mas_new = !$scope.mostrar_mas_new
		localStorage.mostrar_mas_new = $scope.mostrar_mas_new


	if $rootScope.grupos_siguientes
		$scope.grupos_siguientes    = $rootScope.grupos_siguientes
		$scope.data.proceso         = 'prematriculando'
	else
		$http.get('::grupos/next-year').then (r)->
			$scope.grupos_siguientes = r.data
		, ()->
			console.log 'No se pudo traer los grupos del siguiente año'



	$http.get('::grupos').then((r)->
		$scope.grupos = r.data
	, ()->
		console.log 'No se pudo traer los grupos'
	)


	$scope.crear = (alumno, proceso)->

		console.log(alumno)

		$scope.guardando = true

		if !alumno.grupo and proceso=='matriculando'
			toastr.warning 'Debe seleccionar el grupo.'
			return

		if !alumno.grupo_sig and proceso=='prematriculando'
			toastr.warning 'Debe seleccionar el grupo.'
			return

		if alumno.nombres.length == 0
			toastr.warning 'Debe copiar el nombre.'
			return

		alumno.fecha_nac = $filter('date')(alumno.fecha_nac, 'yyyy-MM-dd')

		if proceso == 'prematriculando'
			alumno.prematricula = true
			alumno.grupo = alumno.grupo_sig

		if proceso == 'formulario'
			alumno.llevo_formulario = true
			alumno.grupo = alumno.grupo_sig

		$http.post('::alumnos/store', alumno).then((r)->
			toastr.success 'Alumno '+r.data.nombres+' creado'
			if proceso == 'prematriculando'
				$state.go('panel.persona', {persona_id: r.data.id, tipo: 'alumno' })

			$scope.guardando = false
			$rootScope.grupos_siguientes = null

			$scope.formatear_nuevo()

			$scope.$emit 'alumnoguardado', r.data
		, (r2)->
			$scope.guardando = false
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



	$scope.cambiaUsernameCheck = (texto)->
		$scope.verificandoUsername = true
		return $http.put('::users/usernames-check', {texto: texto}).then((r)->
			$scope.username_match 		= r.data.usernames
			$scope.verificandoUsername 	= false
			return $scope.username_match.map((item)->
				return item.username
			)
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
