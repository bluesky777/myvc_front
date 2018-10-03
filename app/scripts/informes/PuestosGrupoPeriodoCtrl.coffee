angular.module("myvcFrontApp")

.controller('PuestosGrupoPeriodoCtrl', ['$scope', '$state', 'alumnosDat', 'escalas', '$cookies', ($scope, $state, alumnosDat, escalas, $cookies)->
	alumnosDat = alumnosDat.data

	$scope.fechahora = new Date();

	$scope.grupo = alumnosDat.grupo
	$scope.year = alumnosDat.year
	$scope.alumnos = alumnosDat.alumnos

	$scope.escalas = escalas

	$scope.config = $cookies.getObject 'config'
	#$scope.config.orientacion = $scope.orientacion
	#$scope.config.mostrar_foto = $scope.mostrar_foto

	$scope.$on 'change_config', ()->
		$scope.config = $cookies.getObject 'config'



	####################################################################
	#########    Edición de notas de materia      ######################
	####################################################################


	$scope.alumnos_materias = []

	$scope.add_alum_materia = (asig, alum)->
		$scope.alumnos_materias.push {asignatura: asig, alumno: alum}


])



.controller('PuestosTodosPeriodoCtrl', ['$scope', '$state', 'escalas', '$http', 'toastr', '$cookies', ($scope, $state, escalas, $http, toastr, $cookies)->


	$scope.fechahora  = new Date();
	$scope.escalas    = escalas


	$scope.grupos_puestos_temp  = JSON.parse(localStorage.grupos_puestos)
	$scope.grupos_puestos       = []

	angular.forEach($scope.grupos_puestos_temp, (grupo, key)->
		$http.put('::puestos/detailed-notas-periodo/'+grupo.id).then((r)->
			grupo.year      = r.data.year
			grupo.alumnos   = r.data.alumnos
			grupo.grupo     = r.data.grupo
			$scope.grupos_puestos.push(grupo)
		, ()->
			toastr.error 'No se trajo grupo '+grupo.nombre
		)
	)


	$scope.config = $cookies.getObject 'config'

	$scope.$on 'change_config', ()->
		$scope.config = $cookies.getObject 'config'



	####################################################################
	#########    Edición de notas de materia      ######################
	####################################################################


	$scope.alumnos_materias = []

	$scope.add_alum_materia = (asig, alum)->
		$scope.alumnos_materias.push {asignatura: asig, alumno: alum}


])


.controller('PuestosTodosYearCtrl', ['$scope', '$state', 'escalas', '$http', 'toastr', '$stateParams', '$cookies', ($scope, $state, escalas, $http, toastr, $stateParams, $cookies)->


	$scope.fechahora          = new Date();
	$scope.escalas            = escalas


	$scope.grupos_puestos_temp  = JSON.parse(localStorage.grupos_puestos)
	$scope.grupos_puestos       = []

	angular.forEach($scope.grupos_puestos_temp, (grupo, key)->
		$http.put('::puestos/detailed-notas-year', { grupo_id: grupo.id, periodo_a_calcular: $stateParams.periodo_a_calcular }).then((r)->
			grupo.year      = r.data.year
			grupo.alumnos   = r.data.alumnos
			grupo.grupo     = r.data.grupo

			if parseInt($state.params.periodo_a_calcular) == 3

				for alumno in grupo.alumnos
					for asig in alumno.notas_asig
						nota_faltante       =  $scope.USER.nota_minima_aceptada * 4 - asig.nota_final_year*3
						asig.nota_faltante  = if nota_faltante <= 0 then '' else nota_faltante


			$scope.grupos_puestos.push(grupo)
		, ()->
			toastr.error 'No se trajo grupo '+grupo.nombre
		)
	)


	$scope.config = $cookies.getObject 'config'

	$scope.$on 'change_config', ()->
		$scope.config = $cookies.getObject 'config'



	####################################################################
	#########    Edición de notas de materia      ######################
	####################################################################


	$scope.alumnos_materias = []

	$scope.add_alum_materia = (asig, alum)->
		$scope.alumnos_materias.push {asignatura: asig, alumno: alum}


])
