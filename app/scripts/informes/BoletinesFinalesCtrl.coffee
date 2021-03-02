angular.module("myvcFrontApp")

.controller('BoletinesFinalesCtrl', ['$scope', 'alumnosDat', 'escalas', '$cookies', '$state', ($scope, alumnos, escalas, $cookies, $state)->

	$scope.grupo        = alumnos[0]
	$scope.year         = alumnos[1]
	$scope.alumnos      = alumnos[2]
	$scope.escalas_val  = alumnos[3]
	$scope.$state		= $state

	$scope.escalas = escalas

	$scope.config = $cookies.getObject 'config'
	$scope.requested_alumnos = $cookies.getObject 'requested_alumnos'
	$scope.requested_alumno = $cookies.getObject 'requested_alumno'


	$scope.$on 'change_config', ()->
		$scope.config = $cookies.getObject 'config'


	if $scope.requested_alumnos
		$scope.$emit 'cambia_descripcion', 'Mostrando ' + $scope.alumnos.length + ' boletines de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else if $scope.requested_alumno
		$scope.$emit 'cambia_descripcion', 'Mostrando un boletin de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else
		$scope.$emit 'cambia_descripcion', $scope.alumnos.length + ' boletines del grupo ' + $scope.grupo.nombre_grupo



])


.controller('BoletinesFinalesPreescolarCtrl', ['$scope', 'alumnosDat', '$cookies', '$http', 'toastr', ($scope, alumnos, $cookies, $http, toastr)->

	$scope.grupo        = alumnos[0]
	$scope.year         = alumnos[1]
	$scope.alumnos      = alumnos[2]

	$scope.config = $cookies.getObject 'config'
	$scope.requested_alumnos = $cookies.getObject 'requested_alumnos'
	$scope.requested_alumno = $cookies.getObject 'requested_alumno'

	$scope.guardar_frase = (frase, asignatura)->
		console.log(frase);
		$http.put('::bolfinales-preescolar/guardar-frase', { definicion: frase, asignatura_id: asignatura.asignatura_id, id: asignatura.frases[0].id }).then((r)->
			toastr.success('Frase guardada');
			asignatura.frases[0].definicion = frase.definicion

			for alumn in $scope.alumnos
				for asig in alumn.asignaturas
					if asig.asignatura_id == asignatura.asignatura_id
						asig.frases[0] = frase.definicion


		, ()->
			toastr.error('No se pudo crear frase')
		)

	$scope.crear_frase = (asignatura)->
		console.log(asignatura);
		$http.put('::bolfinales-preescolar/crear-frase', { asignatura_id: asignatura.asignatura_id }).then((r)->
			toastr.success('Frase creada');
			asignatura.frases.push(r.data)

			for alumn in $scope.alumnos
				for asig in alumn.asignaturas
					if asig.asignatura_id == asignatura.asignatura_id
						asig.frases.push(r.data)


		, ()->
			toastr.error('No se pudo crear frase')
		)




	$scope.$on 'change_config', ()->
		$scope.config = $cookies.getObject 'config'


	if $scope.requested_alumnos
		$scope.$emit 'cambia_descripcion', 'Mostrando ' + $scope.alumnos.length + ' boletines de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else if $scope.requested_alumno
		$scope.$emit 'cambia_descripcion', 'Mostrando un boletin de ' + $scope.grupo.cantidad_alumnos + ' del grupo ' + $scope.grupo.nombre_grupo
	else
		$scope.$emit 'cambia_descripcion', $scope.alumnos.length + ' boletines del grupo ' + $scope.grupo.nombre_grupo



])
