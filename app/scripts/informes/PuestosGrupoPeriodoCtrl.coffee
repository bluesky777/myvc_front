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
