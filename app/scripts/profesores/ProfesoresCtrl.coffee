'use strict'

angular.module("myvcFrontApp")

.controller('ProfesoresCtrl', ['$scope', '$uibModal', 'toastr', 'uiGridConstants', '$http', '$state', 'App', '$filter', 'Acentos', ($scope, $uibModal, toastr, uiGridConstants, $http, $state, App, $filter, Acentos)->

  $scope.gridScope = $scope # Para getExternalScopes de ui-Grid
  $scope.current_year = $scope.USER.year_id
  $scope.views 						= App.views
  $scope.perfilPath 		  	      	= App.images+'perfil/'

  $scope.editar = (row)->
    $state.go('panel.profesores.editar', {profe_id: row.id})

  $scope.eliminar = (row)->
    modalInstance = $uibModal.open({
      templateUrl: '==profesores/removeProfesor.tpl.html'
      controller: 'RemoveProfesorCtrl'
      resolve:
        profesor: ()->
          row
    })
    modalInstance.result.then( (alum)->
      $scope.gridOptions.data = $filter('filter')($scope.gridOptions.data, {alumno_id: '!'+alum.alumno_id})
    )



  btGrid1 = '<a uib-tooltip="Editar" tooltip-placement="left" class="btn btn-default btn-xs shiny icon-only info" ng-click="grid.appScope.editar(row.entity)"><i class="fa fa-edit "></i></a>'
  btGrid2 = '<a uib-tooltip="X Eliminar" tooltip-placement="right" class="btn btn-default btn-xs shiny icon-only danger" ng-click="grid.appScope.eliminar(row.entity)"><i class="fa fa-times "></i></a>'
  btGrid3 = "==profesores/botonContratar.tpl.html"
  btUsuario = "==directives/botonesResetPassword.tpl.html"
  btEditUsername = "==profesores/botonEditUsername.tpl.html"

  $scope.gridOptions =
    enableSorting: true,
    enableFiltering: true,
    exporterSuppressColumns: [ 'edicion' ],
    exporterCsvColumnSeparator: ';'
    exporterMenuPdf: false,
    exporterMenuExcel: false,
    exporterCsvFilename: "Todos los docentes - MyVC.csv",
    enableGridMenu: true,
    enebleGridColumnMenu: false,
    enableCellEditOnFocus: true,
    columnDefs: [
      { field: 'no', pinnedLeft:true, cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row) + 1}}</div>', width: 40, enableCellEdit: false }
      { name: 'contrato', pinnedLeft:true, displayName:'Contrato', width: 75, enableFiltering: false, cellTemplate: btGrid3, enableCellEdit: false}
      { field: 'nombres', enableHiding: false, minWidth: 150, pinnedLeft:true,
      filter: {
        condition: Acentos.buscarEnGrid
      }
      enableHiding: false, cellTemplate: '<div class="ui-grid-cell-contents" style="padding: 0px;"><img ng-src="{{grid.appScope.perfilPath + row.entity.foto_nombre}}" style="width: 35px" />{{row.entity.nombres}}</div>' }
      { field: 'apellidos', minWidth: 150 }
      { field: 'id', displayName:'Id', width: 50, enableFiltering: false, enableCellEdit: false}
      { name: 'edicion', displayName:'Edición', width: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGrid1 + btGrid2, enableCellEdit: false}
      { field: 'sexo', displayName: 'Sex', width: 40 }
      { field: 'num_doc', displayName: 'Documento', minWidth: 130, cellFilter: 'formatNumberDocumento' }
      { field: 'titulo', minWidth: 200 }
      { field: 'fecha_nac', displayName: 'Nacimiento', cellFilter: "date:mediumDate", type: 'date', minWidth: 100}
      { field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, editableCellTemplate: btEditUsername, minWidth: 135 }
      { field: 'email_usu', displayName:'Email', minWidth: 250  }
      { field: 'celular', minWidth: 100 }
      { field: 'direccion', minWidth: 200 }
    ]
    multiSelect: false,
    onRegisterApi: ( gridApi ) ->
      $scope.gridApi = gridApi
      gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

        if newValue != oldValue
          $http.put('::profesores/update/'+rowEntity.id, rowEntity).then((r)->
            toastr.success 'Profesor actualizado con éxito', 'Actualizado'
          , (r2)->
            toastr.error 'Cambio no guardado', 'Error'
          )
        $scope.$apply()
      )


  $http.get('::profesores').then((data)->
    $scope.gridOptions.data = data.data;
  )

  $scope.$on 'profesorcreado', (data, prof)->
    $scope.gridOptions.data.push prof

  $scope.quitarContrato = (contrato_id)->
    $http.delete('::contratos/destroy/' + contrato_id).then((r)->
      toastr.success 'Quitado de este año ' + $scope.USER.year

      $scope.gridCurrentOptions.data = $filter('filter')($scope.gridCurrentOptions.data, {contrato_id: '!'+contrato_id})

      actual = $filter('filter')($scope.gridOptions.data, {contrato_id: contrato_id})[0]
      actual.year_id = null
    , (r2)->
      toastr.error 'No se pudo agregar el profesor al presente año', 'Problema'
    )

  $scope.contratar = (row)->
    $http.post('::contratos', {profesor_id: row.id}).then((r)->
      toastr.success row.nombres + ' contratado para este año'
      r = r.data[0]
      $scope.gridCurrentOptions.data.push r

      actual = $filter('filter')($scope.gridOptions.data, {id: r.profesor_id})[0]

      actual.year_id = $scope.current_year
      actual.contrato_id = r.contrato_id
    , (r2)->

      if r2.data.contratado
        toastr.warning 'Este profesor ya está contratado'
      else
        toastr.error 'No se pudo agregar el profesor al presente año', 'Problema'
    )


  btGridQuitar = '<a uib-tooltip="Quitar de año actual" tooltip-placement="left" class="btn btn-default btn-xs shiny danger" ng-click="grid.appScope.quitarContrato(row.entity.contrato_id)"><i class="fa fa-times "></i></a>'


  $scope.gridCurrentOptions =
    enableSorting: true,
    enableFiltering: true,
    exporterSuppressColumns: [ 'edicion' ],
    exporterCsvColumnSeparator: ';'
    exporterMenuPdf: false,
    exporterMenuExcel: false,
    exporterCsvFilename: "Docentes contratados - MyVC.csv",
    enableGridMenu: true,
    enebleGridColumnMenu: false,
    enableCellEditOnFocus: true,
    columnDefs: [
      { field: 'no', pinnedLeft:true, cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row) + 1}}</div>', width: 40, enableCellEdit: false }
      { field: 'profesor_id', displayName:'Id', width: 50, enableFiltering: false, enableCellEdit: false}
      { name: 'edicion', displayName:'Edición', width: 50, enableSorting: false, enableFiltering: false, cellTemplate: btGridQuitar, enableCellEdit: false}
      { field: 'nombres', enableHiding: false, minWidth: 100 }
      { field: 'apellidos', minWidth: 100 }
      { field: 'sexo', displayName: 'Sex', width: 40 }
      { field: 'fecha_nac', displayName: 'Nacimiento', minWidth: 100  }
      { field: 'username', filter: { condition: uiGridConstants.filter.CONTAINS }, displayName: 'Usuario', cellTemplate: btUsuario, editableCellTemplate: btEditUsername, minWidth: 135 }
      { field: 'email_usu', displayName:'Email', minWidth: 250  }
      { field: 'celular', minWidth: 100 }
    ]
    multiSelect: false,
    onRegisterApi: ( gridApi ) ->
      $scope.gridApi = gridApi
      gridApi.edit.on.afterCellEdit($scope, (rowEntity, colDef, newValue, oldValue)->

        if newValue != oldValue
          $http.put('::profesores/update/'+rowEntity.profesor_id, rowEntity).then((r)->
            toastr.success 'Profesor actualizado con éxito', 'Actualizado'
          , (r2)->
            toastr.error 'Cambio no guardado', 'Error'
          )
        $scope.$apply()
      )

  $http.get('::contratos').then((r)->
    $scope.gridCurrentOptions.data = r.data
  , (r2)->
    toastr.error 'No se trajeron los profesores contratados'
  )


  $scope.cambiaUsernameCheck = (texto)->
    $scope.verificandoUsername = true
    return $http.put('::users/usernames-check', {texto: texto}).then((r)->
      $scope.username_match 		= r.data.usernames
      $scope.verificandoUsername 	= false
      return $scope.username_match.map((item)->
        return item.username
      )
    )

  $scope.resetPass = (row)->

    modalInstance = $uibModal.open({
      templateUrl: App.views + 'usuarios/resetPass.tpl.html'
      controller: 'ResetPassCtrl'
      resolve:
        usuario: ()->
          row
    })
    modalInstance.result.then( (user)->
      #console.log 'Resultado del modal: ', user
    )




  return
])

.controller('RemoveProfesorCtrl', ['$scope', '$uibModalInstance', 'profesor', '$http', 'toastr', ($scope, $modalInstance, profesor, $http, toastr)->
  $scope.profesor = profesor

  $scope.ok = ()->

    $http.delete('::profesores/destroy/'+profesor.id).then((r)->
      toastr.success 'Profesor enviado a la papelera.', 'Eliminado'
    , (r2)->
      toastr.warning 'No se pudo enviar a la papelera.', 'Problema'
    )
    $modalInstance.close(profesor)

  $scope.cancel = ()->
    $modalInstance.dismiss('cancel')

])


