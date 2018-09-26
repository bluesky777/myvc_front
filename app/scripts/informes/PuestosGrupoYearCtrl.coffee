angular.module("myvcFrontApp")

.controller('PuestosGrupoYearCtrl', ['$scope', 'datos_puestos', 'escalas', '$cookies', ($scope, datos_puestos, escalas, $cookies)->
	datos_puestos = datos_puestos.data

	$scope.fechahora = new Date();


	$scope.grupo = datos_puestos.grupo
	$scope.year = datos_puestos.year
	$scope.alumnos = datos_puestos.alumnos

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
