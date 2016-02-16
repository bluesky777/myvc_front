angular.module("myvcFrontApp")

.controller('PuestosGrupoYearCtrl', ['$scope', 'App', '$rootScope', '$state', 'datos_puestos', 'escalas', 'Restangular', '$modal', '$filter', 'AuthService', '$cookieStore', ($scope, App, $rootScope, $state, datos_puestos, escalas, Restangular, $modal, $filter, AuthService, $cookieStore)->
	
	$scope.grupo = datos_puestos.grupo
	$scope.year = datos_puestos.year
	$scope.alumnos = datos_puestos.alumnos

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