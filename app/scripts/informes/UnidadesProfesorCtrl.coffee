angular.module('myvcFrontApp')

.controller('UnidadesProfesorCtrl',['$scope', 'App', 'Perfil', 'asignaturas', '$state', 'toastr', '$http', ($scope, App, Perfil, asignaturas, $state, toastr, $http)->
	$scope.asignaturas = asignaturas.data.asignaturas
	$scope.info_profe  = asignaturas.data.info_profesor

	$scope.USER = Perfil.User()
	$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)

	$scope.year = asignaturas[0]

	$scope.perfilPath = App.images+'perfil/'


	$scope.editarUnidad = (unidad)->
		unidad.editando = true

	$scope.cancelarEditUnidad = (unidad)->
		unidad.editando = false

	$scope.guardarCambiosUnidad = (unidad)->
		$http.put('::unidades/update/'+unidad.id, unidad).then((r)->
			toastr.success 'Cambios guardados'
			unidad.editando = false
		, (r2)->
			toastr.error 'No se pudo guardar cambios'
		)




	$scope.editarSubunidad = (subunidad)->
		subunidad.editando = true

	$scope.cancelarEditSubunidad = (subunidad)->
		subunidad.editando = false

	$scope.guardarCambiosSubunidad = (subunidad)->
		$http.put('::subunidades/update/'+subunidad.id, subunidad).then((r)->
			toastr.success 'Cambios guardados'
			subunidad.editando = false
		, (r2)->
			toastr.error 'No se pudo guardar cambios'
		)


	asig = $scope.asignaturas[0]
	$scope.$emit 'cambia_descripcion', $scope.asignaturas.length + ' asignaturas del profesor ' + $scope.info_profe.nombres_profesor + ' ' + $scope.info_profe.apellidos_profesor

])




