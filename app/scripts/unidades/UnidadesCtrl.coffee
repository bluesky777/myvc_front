angular.module('myvcFrontApp')
.controller('UnidadesCtrl', ['$scope', '$uibModal', '$http', '$state', '$filter', 'AuthService', 'toastr', 'resolved_user', ($scope, $uibModal, $http, $state, $filter, AuthService, toastr, resolved_user) ->

	AuthService.verificar_acceso()

	$scope.$parent.bigLoader 	= true

	$scope.asignatura 		= {}
	$scope.asignatura_id 	= $state.params.asignatura_id
	$scope.datos 			= {}
	$scope.UNIDAD 			= $scope.USER.unidad_displayname
	$scope.GENERO_UNI 		= $scope.USER.genero_unidad
	$scope.SUBUNIDAD 		= $scope.USER.subunidad_displayname
	$scope.GENERO_SUB 		= $scope.USER.genero_subunidad
	$scope.UNIDADES 		= $scope.USER.unidades_displayname
	$scope.SUBUNIDADES 		= $scope.USER.subunidades_displayname

	$scope.activar_crear_unidad = true
	$scope.unidades = []
	


	$http.get('::unidades/deasignaturaperiodo/' + $scope.asignatura_id + '/' + $scope.USER.periodo_id).then((r)->
		if r.data.length > 0
			$scope.unidades = r.data
			$scope.unidades = $filter('orderBy')($scope.unidades, 'orden')

			for unidad in $scope.unidades
				unidad.subunidades = $filter('orderBy')(unidad.subunidades, 'orden')
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
			unidad.subunidades.unidad_id = unidad.id # El ordenador me borra esta propiedad a cada rato, por eso la pongo aquí

		$scope.unidades.porc_unidades 	= sum
		$scope.$parent.bigLoader 		= false
		







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



	$scope.onSortUnidades = ($item, $partFrom, $partTo, $indexFrom, $indexTo)->
		
		sortHash = []

		for unidad, index in $partFrom
			unidad.orden = index

			hashEntry = {}
			hashEntry["" + unidad.id] = index
			sortHash.push(hashEntry)
		
		datos = 
			sortHash: sortHash
		
		$http.put('::unidades/update-orden', datos).then((r)->
			return true
		, (r2)->
			toastr.warning 'No se pudo ordenar', 'Problema'
			return false;
		)


		$scope.calcularPorcUnidades()
		






	$scope.activar_crear_subunidad = true


	$scope.onSortSubunidades = ($item, $partFrom, $partTo, $indexFrom, $indexTo)->
		
		if $partFrom == $partTo

			sortHash = []

			for subunidad, index in $partFrom #subunidades
				subunidad.orden = index

				hashEntry = {}
				hashEntry["" + subunidad.id] = index
				sortHash.push(hashEntry)
			
			datos = 
				sortHash: sortHash
			
			$http.put('::subunidades/update-orden', datos).then((r)->
				return true
			, (r2)->
				toastr.warning 'No se pudo ordenar', 'Problema'
				return false;
			)

		else

			sortHash1 	= []
			sortHash2 	= []
			datos 		= {}

			# Actualizamos la primera parte
			for subunidad, index in $partFrom #subunidades
				subunidad.orden = index

				hashEntry = {}
				hashEntry["" + subunidad.id] = index
				sortHash1.push(hashEntry)
			

			if sortHash1.length > 0
				datos.unidad1_id 	= $partFrom.unidad_id
				datos.sortHash1 	= sortHash1
			
			# Actualizamos la Segunda parte
			for subunidad, index in $partTo 
				subunidad.orden = index

				hashEntry = {}
				hashEntry["" + subunidad.id] = index
				sortHash2.push(hashEntry)
			

			if sortHash1.length > 0
				datos.unidad2_id 	= $partTo.unidad_id
				datos.sortHash2 	= sortHash2
			
			$http.put('::subunidades/update-orden-varias', datos).then((r)->
				return true
			, (r2)->
				toastr.warning 'No se pudo ordenar', 'Problema'
				return false;
			)

		$scope.calcularPorcUnidades()
		

	




	$scope.addSubunidad = (unidad)->

		$scope.activar_crear_subunidad = false
		unidad.newsubunidad.unidad_id = unidad.id

		$http.post('::subunidades', unidad.newsubunidad).then((r)->
			unidad.subunidades.push r.data

			creado = 'creado'
			if $scope.GENERO_SUB == 'F'
				creado = 'creada'

			toastr.success $scope.SUBUNIDAD + ' ' + creado + ' con éxito.'
			unidad.newsubunidad.definicion = ''
			$scope.calcularPorcUnidades()
			$scope.activar_crear_subunidad = true
		, (r2)->
			toastr.error 'No se pudo crear  ' + (if $scope.GENERO_UNI=="M" then 'el' else 'la') + scope.SUBUNIDAD, 'Problemas'
			$scope.activar_crear_subunidad = true
		)

	$scope.ir_a_notas = (datos)->
		$scope.$parent.bigLoader 	= true
		$state.go 'panel.notas', datos

	$scope.actualizarSubunidad = (subunidad)->

		datos =
			definicion: subunidad.definicion
			porcentaje: subunidad.porcentaje
			nota_default: subunidad.nota_default
			orden: subunidad.orden

		$http.put('::subunidades/update/' + subunidad.id, datos).then((r)->
			
			actualizado = 'actualizado'
			if $scope.GENERO_SUB == 'F'
				actualizado = 'actualizada'
			
			toastr.success $scope.SUBUNIDAD + ' ' + actualizado + ' con éxito.'
			subunidad.editando = false

			$scope.calcularPorcUnidades()
		, (r2)->
			toastr.error 'No se pudo actualizar ' + $scope.SUBUNIDAD, 'Problemas'
		)

	$scope.removeSubunidad = (unidad, subunidad)->

		modalInstance = $uibModal.open({
			templateUrl: '==unidades/removeSubunidad.tpl.html'
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





