angular.module("myvcFrontApp")

.controller('PuestosGrupoPeriodoCtrl', ['$scope', '$state', 'alumnosDat', 'escalas', '$cookieStore', ($scope, $state, alumnosDat, escalas, $cookieStore)->
	alumnosDat = alumnosDat.data

	$scope.fechahora = new Date();

	$scope.grupo = alumnosDat.grupo
	$scope.year = alumnosDat.year
	$scope.alumnos = alumnosDat.alumnos

	$scope.escalas = escalas

	$scope.config = $cookieStore.get 'config'
	#$scope.config.orientacion = $scope.orientacion
	#$scope.config.mostrar_foto = $scope.mostrar_foto

	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'



	####################################################################
	#########    Edición de notas de materia      ######################
	####################################################################


	$scope.alumnos_materias = []

	$scope.add_alum_materia = (asig, alum)->
		$scope.alumnos_materias.push {asignatura: asig, alumno: alum}


])



.controller('PuestosTodosPeriodoCtrl', ['$scope', '$state', 'escalas', '$cookieStore', '$http', 'toastr', ($scope, $state, escalas, $cookieStore, $http, toastr)->


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


	$scope.config = $cookieStore.get 'config'

	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'



	####################################################################
	#########    Edición de notas de materia      ######################
	####################################################################


	$scope.alumnos_materias = []

	$scope.add_alum_materia = (asig, alum)->
		$scope.alumnos_materias.push {asignatura: asig, alumno: alum}


])


.controller('PuestosTodosYearCtrl', ['$scope', '$state', 'escalas', '$cookieStore', '$http', 'toastr', '$stateParams', ($scope, $state, escalas, $cookieStore, $http, toastr, $stateParams)->


	$scope.fechahora  = new Date();
	$scope.escalas    = escalas


	$scope.grupos_puestos_temp  = JSON.parse(localStorage.grupos_puestos)
	$scope.grupos_puestos       = []

	angular.forEach($scope.grupos_puestos_temp, (grupo, key)->
		$http.put('::puestos/detailed-notas-year', { grupo_id: grupo.id, periodo_a_calcular: $stateParams.periodo_a_calcular }).then((r)->
			grupo.year      = r.data.year
			grupo.alumnos   = r.data.alumnos
			grupo.grupo     = r.data.grupo
			$scope.grupos_puestos.push(grupo)
		, ()->
			toastr.error 'No se trajo grupo '+grupo.nombre
		)
	)


	$scope.config = $cookieStore.get 'config'

	$scope.$on 'change_config', ()->
		$scope.config = $cookieStore.get 'config'



	####################################################################
	#########    Edición de notas de materia      ######################
	####################################################################


	$scope.alumnos_materias = []

	$scope.add_alum_materia = (asig, alum)->
		$scope.alumnos_materias.push {asignatura: asig, alumno: alum}


])
