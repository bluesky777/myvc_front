angular.module('myvcFrontApp')
.controller('UnidadesCtrl', ['$scope', '$modal', 'Restangular', '$state', '$filter', '$rootScope', 'AuthService', 'toastr', 'App', 'resolved_user', ($scope, $modal, Restangular, $state, $filter, $rootScope, AuthService, toastr, App, resolved_user) ->

	AuthService.verificar_acceso()

	$scope.asignatura = {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.datos = {}
	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.GENERO_UNI = $scope.USER.genero_unidad
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.GENERO_SUB = $scope.USER.genero_subunidad
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname

	$scope.activar_crear_unidad = true
	


	Restangular.all('unidades/deasignaturaperiodo/' + $scope.asignatura_id + '/' + $scope.USER.periodo_id).getList().then((r)->
		$scope.unidades = r
		$scope.calcularPorcUnidades()
	, (r2)->
		console.log 'No se pudo traer las ' + $scope.UNIDADES, r2
		toastr.error 'No se pudo traer las ' + $scope.UNIDADES, 'Problemas'
	)

	Restangular.one('asignaturas/show/' + $scope.asignatura_id).get().then((r)->
		$scope.asignatura = r
		$scope.inicializado = true
	, (r2)->
		console.log 'No se pudo traer los datos de la asignatura', r2
		toastr.error 'No se pudo traer los datos de la asignatura'
	)





	$scope.calcularPorcUnidades = ()->
		sum = 0
		angular.forEach $scope.unidades, (unidad, key) ->
			sum = sum + unidad.porcentaje

			subsum = 0
			angular.forEach unidad.subunidades, (subunidad, key) ->
				subsum = subsum + subunidad.porcentaje

			unidad.subunidades.porc_subunidades = subsum

		$scope.unidades.porc_unidades = sum
		console.log '$scope.unidades.porc_unidades: ', $scope.unidades.porc_unidades







	$scope.crearUnidad = ()->

		$scope.activar_crear_unidad = false

		$scope.newunidad.asignatura_id = $scope.asignatura.asignatura_id

		Restangular.one('unidades').customPOST($scope.newunidad).then((r)->
			r.subunidades = []
			$scope.unidades.push r

			creado = 'creado'
			if $scope.GENERO_UNI == 'F'
				creado = 'creada'

			toastr.success $scope.UNIDAD + ' ' + creado + ' . Ahora agrégale ' + $scope.SUBUNIDADES
			$scope.newunidad.definicion = ''
			$scope.calcularPorcUnidades()
			$scope.activar_crear_unidad = true
		, (r2)->
			console.log 'No se pudo crear la unidad', r2
			toastr.error 'No se pudo crear la unidad', 'Problemas'
			$scope.activar_crear_unidad = true
		)



	$scope.actualizarUnidad = (unidad)->

		datos =
			definicion: unidad.definicion
			porcentaje: unidad.porcentaje

		Restangular.one('unidades/update/' + unidad.id).customPUT(datos).then((r)->
			
			actualizado = 'actualizado'
			if $scope.GENERO_UNI == 'F'
				actualizado = 'actualizada'
			
			toastr.success $scope.UNIDAD + ' ' + actualizado + ' con éxito.'
			unidad.editando = false
			$scope.calcularPorcUnidades()
		, (r2)->
			console.log 'No se pudo actualizar ' + $scope.UNIDAD, r2
			toastr.error 'No se pudo actualizar ' + $scope.UNIDAD, 'Problemas'
		)



	$scope.removeUnidad = (unidad)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'unidades/removeUnidad.tpl.html'
			controller: 'RemoveUnidadCtrl'
			resolve: 
				unidad: ()->
					unidad
		})
		modalInstance.result.then( (unidad)->
			$scope.unidades = $filter('filter')($scope.unidades, {id: '!'+unidad.id})
			$scope.calcularPorcUnidades()
		)



])

.controller('RemoveUnidadCtrl', ['$scope', '$modalInstance', 'unidad', 'Restangular', 'toastr', ($scope, $modalInstance, unidad, Restangular, toastr)->
	$scope.unidad = unidad

	$scope.ok = ()->

		Restangular.all('unidades/destroy/'+unidad.id).remove().then((r)->
			toastr.success 'Unidad eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la unidad.', 'Problema'
			console.log 'Error eliminando unidad: ', r2
		)
		$modalInstance.close(unidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('RemoveSubunidadCtrl', ['$scope', '$modalInstance', 'subunidad', 'Restangular', 'toastr', ($scope, $modalInstance, subunidad, Restangular, toastr)->
	$scope.subunidad = subunidad

	$scope.ok = ()->

		Restangular.all('subunidades/destroy/'+subunidad.id).remove().then((r)->
			toastr.success 'Subunidad eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la subunidad.', 'Problema'
			console.log 'Error eliminando subunidad: ', r2
		)
		$modalInstance.close(subunidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])





