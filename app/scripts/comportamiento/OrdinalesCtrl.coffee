'use strict'

angular.module('myvcFrontApp')

.controller('OrdinalesCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$filter', 'App', 'AuthService', 'Acentos', '$interval', '$anchorScroll', '$location', ($scope, toastr, $http, $modal, $state, $filter, App, AuthService, Acentos, $interval, $anchorScroll, $location)->

	AuthService.verificar_acceso()

	$scope.datos 		      	= {}
	$scope.perfilPath 	  	= App.images+'perfil/'
	$scope.views 		      	= App.views
	$scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.gridOptions      = {}
	$scope.creando          = false
	$scope.editando         = false
	$scope.guardando        = false
	$scope.configuracion 		= {
		reinicia_por_periodo: 0
	}

	$scope.ordinal_new 	= {
			ordinal: '',
			descripcion: '',
			pagina: ''
		}


	$scope.configurar = ()->
		$location.hash('configurar-convivencia');
		$anchorScroll();

	$scope.selectYear = (year)->
		$scope.traerOrdinales(year.id, false)


	$scope.verCrear = ()->
		$scope.creando 			= true
		$scope.ordinal_new.year_id = $scope.datos.year.id


	$scope.cancelarCrear = ()->
		$scope.creando 			= false
		$scope.ordinal_new 	= {
			ordinal: '',
			descripcion: '',
			pagina: ''
		}

	$scope.cancelarEditar = ()->
		$scope.editando = false

	$scope.editar = (ordinal)->
		$scope.ordinal_edit = ordinal
		$scope.editando 		= true

	$scope.crear = (ordinal)->
		if !$scope.datos.year
			toastr.warning('Elija el año')
			return

		$scope.guardando = true

		ordinal.year_id = $scope.datos.year.id

		$http.post('::ordinales/store', ordinal).then((r)->
			console.log(r.data, $scope.gridOptions)
			$scope.gridOptions.data.push(r.data)
			toastr.success('Creado con éxito.')
			$scope.guardando = false
		, ()->
			toastr.error 'No se puedo crear'
			$scope.guardando = false
		)




	$scope.eliminar = (ordinal)->
		res = confirm("¿Seguro que desea eliminar?")
		if res

			$http.put('::ordinales/destroy', {ordinal_id: ordinal.id}).then((r)->
				$scope.gridOptions.data.push(r.data)
				toastr.success('Eliminado con éxito.')

				for ordin, indice in $scope.gridOptions.data
					if ordin.id == ordinal.id
						$scope.gridOptions.data.splice(indice, 1)
						return

			, ()->
				toastr.error 'No se puedo crear'
				$scope.guardando = false
			)


	$scope.guardar_cambios = (ordinal)->
		if !$scope.datos.year
			toastr.warning('Elija el año')
			return

		ordinal.year_id = $scope.datos.year.id

		$http.put('::ordinales/update', ordinal).then((r)->
			toastr.success('Editado con éxito.')
			$scope.editando = false
		, ()->
			toastr.error 'No se puedo crear'
		)


	btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
	btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-trash "></i></a>'
	bt1 	= '<span style="padding-left: 2px; padding-top: 4px;" class="btn-group">' + btGrid1 + btGrid2 + '</span>'

	$scope.gridOptions =
		showGridFooter: true,
		showColumnFooter: true,
		showFooter: true,
		enableSorting: true,
		enableFiltering: true,
		enableGridMenu: true,
		enebleGridColumnMenu: false,
		enableCellEditOnFocus: true,

		columnDefs: [
			{ field: 'no', cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row) + 1}}</div>', width: 40, enableCellEdit: false }
			{ name: 'edicion', displayName:'Edit', width: 54, enableSorting: false, enableFiltering: false, cellTemplate: bt1, enableCellEdit: false, enableColumnMenu: true}
			{ field: 'tipo', minWidth: 80, filter: { condition: Acentos.buscarEnGrid } }
			{ field: 'ordinal', minWidth: 70 }
			{ field: 'descripcion', displayName: 'Descripción', minWidth: 210, filter: { condition: Acentos.buscarEnGrid } }
			{ field: 'pagina', displayName: 'Página', minWidth: 70 }
		],
		multiSelect: false,

		onRegisterApi: ( gridApi ) ->
			$scope.gridApi = gridApi
			gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

				if newValue != oldValue


					$http.put('::ordinales/guardar-valor', {ordinal_id: rowEntity.id, propiedad: colDef.field, valor: newValue } ).then((r)->
						toastr.success 'Ordinal actualizado con éxito'
					, (r2)->
						rowEntity[colDef.field] = oldValue
						toastr.error 'Cambio no guardado', 'Error'
					)

			)


	$scope.traerOrdinales = (year_id, con_datos)->
		$http.put('::ordinales/ordinales', {year_id: year_id, con_datos: con_datos}).then((r)->
			r = r.data

			if $scope.configuracion
				$scope.config               = r.configuracion
				$scope.tipos                = r.tipos

			$scope.gridOptions.data       = r.ordinales

		, (r2)->
			toastr.error 'No se pudo traer los datos.'
		)



	$scope.guardarValorConfig = (config, propiedad, valor)->

		$http.put('::ordinales/guardar-valor-config', {config_id: config.id, propiedad: propiedad, valor: valor } ).then((r)->
			toastr.success 'Campo actualizado'
		, (r2)->
			toastr.error 'Cambio no guardado', 'Error'
		)



	if $scope.$parent.years
		for anio in $scope.$parent.years
			if anio.id == $scope.USER.year_id
				$scope.datos.year = anio
		$scope.traerOrdinales()
	else
		$scope.Timer = $interval(()->

			if $scope.$parent.years
				if angular.isDefined($scope.Timer)
					$interval.cancel($scope.Timer)

				for anio in $scope.$parent.years
					if anio.id == $scope.USER.year_id
						$scope.datos.year = anio

				$scope.traerOrdinales()
		, 1000)







])


