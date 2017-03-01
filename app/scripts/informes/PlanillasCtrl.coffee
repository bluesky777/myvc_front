angular.module('myvcFrontApp')

.controller('PlanillasCtrl',['$scope', 'App', 'Perfil', 'asignaturas', '$state', ($scope, App, Perfil, asignaturas, $state)-> 
	asignaturas = asignaturas.data

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	
	$scope.year = asignaturas[0]
	$scope.asignaturas = asignaturas[1]

	$scope.perfilPath = App.images+'perfil/'

	$scope.unidadesdefault = ["  ", "  ", "  "]
	$scope.subunidadesdefault = [
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
			"  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
	]


	if $state.params.profesor_id
		asig = $scope.asignaturas[0]
		$scope.$emit 'cambia_descripcion', $scope.asignaturas.length + ' planillas  del profesor ' + asig.nombres_profesor + ' ' + asig.apellidos_profesor
	else if $state.params.grupo_id
		asig = $scope.asignaturas[0]
		$scope.$emit 'cambia_descripcion', $scope.asignaturas.length + ' planillas  del grupo ' + asig.nombre_grupo

])




.controller('ControlTardanzaEntradaCtrl',['$scope', 'App', 'Perfil', '$state', 'grupos', ($scope, App, Perfil, $state, grupos)-> 

	$scope.USER = Perfil.User()

	r = grupos.data[0]
	$scope.year = r
	$scope.grupos = r.grupos


	$scope.perfilPath = App.images+'perfil/'

	$scope.numberColumExt = 21;
	$scope.numberColumInt = 4;
	$scope.getNumber = (num)->
		return new Array(num)

	for grupo in $scope.grupos 
		cont = 0
		for alumno in grupo.alumnos
			cont++
			if cont == 3
				alumno.gris = true
				cont = 0
			else
				alumno.gris = false


	$scope.$emit 'cambia_descripcion', 'Planillas para el control de tardanzas en la entrada.'


	$scope.dato = {}
	
	

	$scope.mesSeleccionado = ()->
		if $scope.mesMostrar == '-1'
			$scope.numberColumExt = 21;
		else
			$scope.dato.mes = '' + $scope.mesMostrar
			$scope.dias = $scope.getAllDaysInMonth($scope.dato.mes)
			$scope.numberColumExt = $scope.dias.length

])