angular.module('myvcFrontApp')
.controller('UnidadesCtrl', ['$scope', '$modal', 'Restangular', '$state', '$filter', '$rootScope', 'AuthService', 'toastr', 'App', 'resolved_user', ($scope, $modal, Restangular, $state, $filter, $rootScope, AuthService, toastr, App, resolved_user) ->

	AuthService.verificar_acceso()

	$scope.asignatura = {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.datos = {}
	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname

	Restangular.all('unidades/deasignaturaperiodo/' + $scope.asignatura_id + '/' + $scope.USER.periodo_id).getList().then((r)->
		$scope.unidades = r
	, (r2)->
		console.log 'No se pudo traer las unidades', r2
		toastr.error 'No se pudo traer las unidades', 'Problemas'
	)

	Restangular.one('asignaturas/show/' + $scope.asignatura_id).get().then((r)->
		$scope.asignatura = r
	, (r2)->
		console.log 'No se pudo traer los datos de la asignatura', r2
		toastr.error 'No se pudo traer los datos de la asignatura'
	)


	$scope.datos.dragSubunidadesListeners =
		accept: (sourceItemHandleScope, destSortableScope)->
			#console.log 'unidad.ordensubunidades: ', sourceItemHandleScope, destSortableScope
			return true
		itemMoved: (event)->
			console.log 'Item movido: ', event
		orderChanged: (event)->
			console.log 'Orden cambiado: ', event
		containment: '.dd-contener'
		containerPositioning: 'relative'
		additionalPlaceholderClass: 'dd-placeholder' 

	$scope.crearUnidad = ()->

		$scope.newunidad.asignatura_id = $scope.asignatura.asignatura_id

		Restangular.one('unidades').customPOST($scope.newunidad).then((r)->
			r.subunidades = []
			$scope.unidades.push r
			toastr.success 'Unidad creada. Ahora agrégale subunidades.'
			$scope.newunidad.definicion = ''
		, (r2)->
			console.log 'No se pudo crear la unidad', r2
			toastr.error 'No se pudo crear la unidad', 'Problemas'
		)


	$scope.addSubunidad = (unidad)->

		unidad.newsubunidad.unidad_id = unidad.id

		Restangular.one('subunidades').customPOST(unidad.newsubunidad).then((r)->
			unidad.subunidades.push r
			toastr.success 'Subunidad creada con éxito.'
			unidad.newsubunidad.definicion = ''
		, (r2)->
			console.log 'No se pudo crear la unidad', r2
			toastr.error 'No se pudo crear la unidad', 'Problemas'
		)

	$scope.actualizarUnidad = (unidad)->

		datos =
			definicion: unidad.definicion
			porcentaje: unidad.porcentaje

		Restangular.one('unidades/update/' + unidad.id).customPUT(datos).then((r)->
			toastr.success $scope.UNIDAD + ' actualizado(a) con éxito.'
			unidad.editando = false
		, (r2)->
			console.log 'No se pudo actualizar ' + $scope.UNIDAD, r2
			toastr.error 'No se pudo actualizar ' + $scope.UNIDAD, 'Problemas'
		)


	$scope.actualizarSubunidad = (subunidad)->

		datos =
			definicion: subunidad.definicion
			porcentaje: subunidad.porcentaje
			nota_default: subunidad.nota_default

		Restangular.one('subunidades/update/' + subunidad.id).customPUT(datos).then((r)->
			toastr.success $scope.SUBUNIDAD + ' actualizado(a) con éxito.'
			subunidad.editando = false
		, (r2)->
			console.log 'No se pudo actualizar ' + $scope.SUBUNIDAD, r2
			toastr.error 'No se pudo actualizar ' + $scope.SUBUNIDAD, 'Problemas'
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
		)

	$scope.removeSubunidad = (unidad, subunidad)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'unidades/removeSubunidad.tpl.html'
			controller: 'RemoveSubunidadCtrl'
			resolve: 
				subunidad: ()->
					subunidad
		})
		modalInstance.result.then( (unid)->
			unidad.subunidades = $filter('filter')(unidad.subunidades, {id: '!'+subunidad.id})
		)




])

.controller('RemoveUnidadCtrl', ['$scope', '$modalInstance', 'unidad', 'Restangular', 'toastr', ($scope, $modalInstance, unidad, Restangular, toastr)->
	$scope.unidad = unidad

	$scope.ok = ()->

		Restangular.all('unidades/destroy/'+unidad.id).remove().then((r)->
			toastr.success 'Unidad eliminada con éxito.', 'Eliminada'
		, (r2)->
			toastr.warning 'No se pudo eliminar al unidad.', 'Problema'
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





