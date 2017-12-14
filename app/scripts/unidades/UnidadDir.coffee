angular.module('myvcFrontApp')

.directive('unidadDir',['App', (App)-> 

	restrict: 'E'
	templateUrl: "#{App.views}unidades/unidadDir.tpl.html"
	transclude: true
	scope: 
		unidad: "="
		indice: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

	controller: ($scope, $http, toastr, $uibModal, $filter)->

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

			$scope.$parent.calcularPorcUnidades()
			

		




		$scope.addSubunidad = (unidad)->

			$scope.activar_crear_subunidad = false
			unidad.newsubunidad.unidad_id = unidad.id

			$http.post('::subunidades', unidad.newsubunidad).then((r)->
				unidad.subunidades.push r.data

				creado = 'creado'
				if $scope.$parent.GENERO_SUB == 'F'
					creado = 'creada'

				toastr.success $scope.$parent.SUBUNIDAD + ' ' + creado + ' con éxito.'
				unidad.newsubunidad.definicion = ''
				$scope.$parent.calcularPorcUnidades()
				$scope.activar_crear_subunidad = true
			, (r2)->
				toastr.error 'No se pudo crear  ' + (if $scope.$parent.GENERO_UNI=="M" then 'el' else 'la') + scope.$parent.SUBUNIDAD, 'Problemas'
				$scope.activar_crear_subunidad = true
			)


		$scope.actualizarSubunidad = (subunidad)->

			datos =
				definicion: subunidad.definicion
				porcentaje: subunidad.porcentaje
				nota_default: subunidad.nota_default
				orden: subunidad.orden

			$http.put('::subunidades/update/' + subunidad.id, datos).then((r)->
				
				actualizado = 'actualizado'
				if $scope.$parent.GENERO_SUB == 'F'
					actualizado = 'actualizada'
				
				toastr.success $scope.$parent.SUBUNIDAD + ' ' + actualizado + ' con éxito.'
				subunidad.editando = false

				$scope.$parent.calcularPorcUnidades()
			, (r2)->
				toastr.error 'No se pudo actualizar ' + $scope.$parent.SUBUNIDAD, 'Problemas'
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
				$scope.$parent.calcularPorcUnidades()
			)



		

])
