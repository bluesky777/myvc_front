angular.module('myvcFrontApp')

.directive('configuracionEscalas',['App', (App)->

	restrict: 'E'
	templateUrl: "#{App.views}colegio/configEscalas.tpl.html"


	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if
	controller: 'ConfigEscalasCtrl'

])

.controller 'ConfigEscalasCtrl', ['$scope', 'App', '$http', '$state', '$cookies', 'toastr', 'uiGridConstants', '$filter', ($scope, App, $http, $state, $cookies, toastr, uiGridConstants, $filter) ->

	$scope.creando_escala = false

	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminarEscala(row.entity)"><i class="fa fa-trash "></i></a>'


	$scope.gridOptions =
		showGridFooter: true,
		enableSorting: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ field: 'id', displayName:'Id', width: 50, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'desempenio', displayName:'Desempeño', enableSorting: false, enableColumnMenu: false }
			{ name: 'eliminar', displayName:'Elimin', width: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid2, enableCellEdit: false, enableColumnMenu: false}
			{ field: 'descripcion', displayName:'Descripción' }
			{ field: 'icono_adolescente', displayName:'Ícono adolescente' }
			{ field: 'icono_infantil', displayName:'Ícono infantil' }
			{ field: 'orden', type: 'number' }
			{ field: 'perdido', type:'boolean', cellTemplate: '<input type="checkbox" ng-model="row.entity.perdido" ng-true-value="1" ng-false-value="0">' }
			{ field: 'valoracion', displayName:'Valoración'}
		],
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

				if newValue != oldValue

					$http.put('::escalas/update', rowEntity).then((r)->
						toastr.success 'Escala modificada', 'Actualizada'
					, (r2)->
						toastr.error 'Cambio no guardado', 'Error'
					)

				$scope.$apply()
			)



	$scope.gridOptions.data = $scope.year.escalas;




	$scope.crearEscala = ()->
		$http.post('::escalas/store').then((r)->
			toastr.success 'Escala creada.'
			$scope.creando_escala = false
			$scope.year.escalas.push r.data
			$scope.gridOptions.data = $scope.year.escalas
		, (r2)->
			toastr.error 'Escala no guardada', 'Error'
		)





	$scope.eliminarEscala = (escala)->
		$http.delete('::escalas/destroy/'+escala.id).then((r)->
			toastr.success 'Escala eliminada.'
			$scope.year.escalas = $filter('filter')($scope.year.escalas, {id: '!'+escala.id})
			$scope.gridOptions.data = $scope.year.escalas
		, (r2)->
			toastr.error 'Escala no eliminada', 'Error'
		)



	return
]
