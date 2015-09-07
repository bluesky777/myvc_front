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
	$scope.activar_crear_subunidad = true


	Restangular.all('unidades/deasignaturaperiodo/' + $scope.asignatura_id + '/' + $scope.USER.periodo_id).getList().then((r)->
		$scope.unidades = r
		$scope.calcularPorcUnidades()
	, (r2)->
		console.log 'No se pudo traer las unidades', r2
		toastr.error 'No se pudo traer las unidades', 'Problemas'
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


	# Configuración para el sortable
	$scope.sortableOptions =
		'ui-floating': true

		update: (e, ui)->
			# console.log e, ui

			sortHash = []

			for opcion, index in $scope.preguntatraduc.opciones
				if opcion.id != -1
					hashEntry = {}
					hashEntry["" + opcion.id] = index
					sortHash.push(hashEntry)
			
			datos = 
				pregunta_traduc_id: $scope.preguntatraduc.id
				sortHash: sortHash
			
			Restangular.one('unidades/update-orden').customPUT(datos).then((r)->
				console.log('Orden guardado')
			, (r2)->
				console.log('No se pudo guardar el orden', r2)
				#ui.item.sortable.cancel() # Cancelamos el intento de ordenar
			)



	
	"""
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
	"""

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


	$scope.addSubunidad = (unidad)->

		$scope.activar_crear_subunidad = false
		unidad.newsubunidad.unidad_id = unidad.id

		Restangular.one('subunidades').customPOST(unidad.newsubunidad).then((r)->
			unidad.subunidades.push r

			creado = 'creado'
			if $scope.GENERO_SUB == 'F'
				creado = 'creada'

			toastr.success $scope.SUBUNIDAD + ' ' + creado + ' con éxito.'
			unidad.newsubunidad.definicion = ''
			$scope.calcularPorcUnidades()
			$scope.activar_crear_subunidad = true
		, (r2)->
			console.log 'No se pudo crear  ' + (if $scope.GENERO_UNI=="M" then 'el' else 'la') + $scope.SUBUNIDAD, r2
			toastr.error 'No se pudo crear  ' + (if $scope.GENERO_UNI=="M" then 'el' else 'la') + $scope.SUBUNIDAD, 'Problemas'
			$scope.activar_crear_subunidad = true
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


	$scope.actualizarSubunidad = (subunidad)->

		datos =
			definicion: subunidad.definicion
			porcentaje: subunidad.porcentaje
			nota_default: subunidad.nota_default

		Restangular.one('subunidades/update/' + subunidad.id).customPUT(datos).then((r)->
			
			actualizado = 'actualizado'
			if $scope.GENERO_SUB == 'F'
				actualizado = 'actualizada'
			
			toastr.success $scope.SUBUNIDAD + ' ' + actualizado + ' con éxito.'
			subunidad.editando = false

			$scope.calcularPorcUnidades()
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
			$scope.calcularPorcUnidades()
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





