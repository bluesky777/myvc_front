angular.module("myvcFrontApp")

.controller('PuestosGrupoYearCtrl', ['$scope', 'datos_puestos', 'escalas', '$cookies', '$state', ($scope, datos_puestos, escalas, $cookies, $state)->
	datos_puestos = datos_puestos.data

	$scope.fechahora = new Date();


	$scope.grupo = datos_puestos.grupo
	$scope.year = datos_puestos.year
	$scope.alumnos = datos_puestos.alumnos


	if parseInt($state.params.periodo_a_calcular) == 3

		for alumno in $scope.alumnos
			for asig in alumno.notas_asig
				nota_faltante       =  $scope.USER.nota_minima_aceptada * 4 - asig.nota_final_year*3
				asig.nota_faltante  = if nota_faltante <= 0 then '' else nota_faltante



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
