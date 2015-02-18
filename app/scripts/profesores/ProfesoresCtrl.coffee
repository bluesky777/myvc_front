'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresCtrl', ['$scope', '$rootScope', 'RProfesores', 'Restangular', '$interval', ($scope, $rootScope, RProfesores, Restangular, $interval)->


	$scope.editar = (row)->
		console.log 'Presionado para editar fila: ', row
		$state.go('panel.profesores.editar', {profe_id: row.id})

	$scope.eliminar = (row)->
		console.log 'Presionado para eliminar fila: ', row
		$state.go('panel.profesores.eliminar', {profe_id: row.id})


	btGrid1 = '<a tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="getExternalScopes().editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a tooltip="X Eliminar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only danger" ng-click="getExternalScopes().eliminar(row.entity)"><i class="fa fa-times "></i></a>'
	$scope.gridOptions = 
		enableSorting: true,
		enableFiltering: true,
		enebleGridColumnMenu: false,
		columnDefs: [
			{ name: 'edicion', displayName:'Edición', maxWidth: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
			{ field: 'nombres', enableHiding: false }
			{ field: 'apellidos' }
			{ field: 'sexo', maxWidth: 20 }
			{ field: 'fecha_nac', displayName: 'Nacimiento'  }
			{ field: 'user_id', displayName: 'Usuario'  }
			{ field: 'facebook'  }
			{ field: 'celular' }
		]
		multiSelect: false,
		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi

	
	RProfesores.getList().then((data)->
		$scope.gridOptions.data = data;
	)

	return
])