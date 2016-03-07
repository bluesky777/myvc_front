angular.module('myvcFrontApp')
.controller('UnidadesCtrl', ['$scope', '$uibModal', '$http', '$state', '$filter', 'AuthService', 'toastr', 'resolved_user', ($scope, $uibModal, $http, $state, $filter, AuthService, toastr, resolved_user) ->

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
	$scope.unidades = []
	


	$http.get('::unidades/deasignaturaperiodo/' + $scope.asignatura_id + '/' + $scope.USER.periodo_id).then((r)->
		if r.data.length > 0
			$scope.unidades = r.data
			$scope.calcularPorcUnidades()
	, (r2)->
		toastr.error 'No se pudo traer las ' + $scope.UNIDADES, 'Problemas'
	)

	$http.get('::asignaturas/show/' + $scope.asignatura_id).then((r)->
		r = r.data
		$scope.asignatura = r
		$scope.inicializado = true
		if not r
			$scope.no_asignatura = true
	, (r2)->
		toastr.error 'No se pudo traer los datos de la asignatura'
		$scope.no_asignatura = true
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
		







	$scope.crearUnidad = ()->

		$scope.activar_crear_unidad = false

		$scope.newunidad.asignatura_id = $scope.asignatura.asignatura_id

		$http.post('::unidades', $scope.newunidad).then((r)->
			r = r.data
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
			toastr.error 'No se pudo crear la unidad', 'Problemas'
			$scope.activar_crear_unidad = true
		)



	$scope.actualizarUnidad = (unidad)->

		datos =
			definicion: unidad.definicion
			porcentaje: unidad.porcentaje

		$http.put('::unidades/update/' + unidad.id, datos).then((r)->
			
			actualizado = 'actualizado'
			if $scope.GENERO_UNI == 'F'
				actualizado = 'actualizada'
			
			toastr.success $scope.UNIDAD + ' ' + actualizado + ' con éxito.'
			unidad.editando = false
			$scope.calcularPorcUnidades()
		, (r2)->
			toastr.error 'No se pudo actualizar ' + $scope.UNIDAD, 'Problemas'
		)



	$scope.removeUnidad = (unidad)->

		modalInstance = $uibModal.open({
			templateUrl: '==unidades/removeUnidad.tpl.html'
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

.controller('RemoveUnidadCtrl', ['$scope', '$uibModalInstance', 'unidad', '$http', 'toastr', ($scope, $modalInstance, unidad, $http, toastr)->
	$scope.unidad = unidad

	$scope.ok = ()->

		$http.delete('::unidades/destroy/'+unidad.id).then((r)->
			toastr.success 'Unidad eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la unidad.', 'Problema'
		)
		$modalInstance.close(unidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('RemoveSubunidadCtrl', ['$scope', '$uibModalInstance', 'subunidad', '$http', 'toastr', ($scope, $modalInstance, subunidad, $http, toastr)->
	$scope.subunidad = subunidad

	$scope.ok = ()->

		$http.delete('::subunidades/destroy/'+subunidad.id).then((r)->
			toastr.success 'Subunidad eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar la subunidad.', 'Problema'
		)
		$modalInstance.close(subunidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])





