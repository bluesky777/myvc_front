angular.module('myvcFrontApp')

.directive('unidadDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}unidades/unidadDir.tpl.html"
	scope: 
		unidad: "="
		indice: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: ($scope, Restangular, toastr, $modal, $filter)->

		$scope.activar_crear_subunidad = true



		idContainment = '#sortable-container' + $scope.unidad.id

		# Configuración para el sortable
		$scope.sortableOptions = 
			containment: idContainment
		
			dragEnd: (sourceItemHandleScope, destSortableScope)->
				
				sortHash = []

				for subunidad, index in $scope.unidad.subunidades
					if subunidad.id != -1
						hashEntry = {}
						hashEntry["" + subunidad.id] = index
						sortHash.push(hashEntry)
				
				datos = 
					unidad_id: $scope.unidad.id
					sortHash: sortHash
				
				Restangular.one('unidades/update-orden').customPUT(datos).then((r)->
					console.log('Orden guardado', r)
					return true
				, (r2)->
					console.log('No se pudo guardar el orden', r2)
					toastr.warning 'No se pudo ordenar', 'Problema'
					#ui.item.sortable.cancel() # Cancelamos el intento de ordenar
					return false;
				)

			


			

		

		$scope.subirSubunidad = (subunidad, indice)->

			indice_new = indice - 1

			datos = 
				subunidad_id: 	subunidad.id
				unidad_id:		subunidad.unidad_id
				indice_new: 	indice_new

			
			Restangular.one('subunidades/subir-subunidad').customPUT(datos).then((r)->
				
				subsacambiar = $filter('filter')($scope.unidad.subunidades, {orden: indice_new})
				subsacambiar = $filter('orderBy')(subsacambiar, '-id')[0]
				subsacambiar.orden = indice


				subuni 			= $filter('filter')($scope.unidad.subunidades, {id: subunidad.id})[0]
				subuni.orden 	= indice_new
				
				$scope.unidad.subunidades = $filter('orderBy')($scope.unidad.subunidades, 'orden')

				console.log 'Subunidad subida', $scope.unidad.subunidades
				toastr.success 'Ordenada correctamente'

			, (r2)->
				console.log 'No se pudo subir ', r2
				toastr.error 'No se pudo subir '
			)


		$scope.cambiaOrden = ()->
			console.log "Sisassss"

		$scope.bajarSubunidad = (subunidad, indice)->

			indice_new = indice + 1

			datos = 
				subunidad_id: 	subunidad.id
				unidad_id:		subunidad.unidad_id
				indice_new: 	indice_new

			
			Restangular.one('subunidades/bajar-subunidad').customPUT(datos).then((r)->

				subsacambiar = $filter('filter')($scope.unidad.subunidades, {orden: indice_new})
				if subsacambiar.length > 0
					subsacambiar[0].orden = indice
				
				subuni 			= $filter('filter')($scope.unidad.subunidades, {id: subunidad.id})[0]
				subuni.orden 	= indice_new

				$scope.unidad.subunidades = $filter('orderBy')($scope.unidad.subunidades, 'orden')

				console.log 'Subunidad bajada', $scope.unidad.subunidades
				toastr.success 'Ordenada correctamente'

			, (r2)->
				console.log 'No se pudo bajar ', r2
				toastr.error 'No se pudo bajar '
			)


		$scope.addSubunidad = (unidad)->

			$scope.activar_crear_subunidad = false
			unidad.newsubunidad.unidad_id = unidad.id

			Restangular.one('subunidades').customPOST(unidad.newsubunidad).then((r)->
				unidad.subunidades.push r

				creado = 'creado'
				if $scope.$parent.GENERO_SUB == 'F'
					creado = 'creada'

				toastr.success $scope.$parent.SUBUNIDAD + ' ' + creado + ' con éxito.'
				unidad.newsubunidad.definicion = ''
				$scope.$parent.calcularPorcUnidades()
				$scope.activar_crear_subunidad = true
			, (r2)->
				console.log 'No se pudo crear  ' + (if $scope.$parent.GENERO_UNI=="M" then 'el' else 'la') + scope.$parent.SUBUNIDAD, r2
				toastr.error 'No se pudo crear  ' + (if $scope.$parent.GENERO_UNI=="M" then 'el' else 'la') + scope.$parent.SUBUNIDAD, 'Problemas'
				$scope.activar_crear_subunidad = true
			)


		$scope.actualizarSubunidad = (subunidad)->

			datos =
				definicion: subunidad.definicion
				porcentaje: subunidad.porcentaje
				nota_default: subunidad.nota_default
				orden: subunidad.orden

			Restangular.one('subunidades/update/' + subunidad.id).customPUT(datos).then((r)->
				
				actualizado = 'actualizado'
				if $scope.$parent.GENERO_SUB == 'F'
					actualizado = 'actualizada'
				
				toastr.success $scope.$parent.SUBUNIDAD + ' ' + actualizado + ' con éxito.'
				subunidad.editando = false

				$scope.$parent.calcularPorcUnidades()
			, (r2)->
				console.log 'No se pudo actualizar ' + $scope.$parent.SUBUNIDAD, r2
				toastr.error 'No se pudo actualizar ' + $scope.$parent.SUBUNIDAD, 'Problemas'
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
				$scope.$parent.calcularPorcUnidades()
			)



		

])