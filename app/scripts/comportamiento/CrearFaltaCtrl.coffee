angular.module('myvcFrontApp')

.directive('faltasDeLasQueDerivaDir',['App', (App)->
  restrict: 'E'
  templateUrl: "#{App.views}comportamiento/faltasDeLasQueDerivaDir.tpl.html"
])
.directive('faltasDeLasQueDerivaNuevoDir',['App', (App)->
  restrict: 'E'
  templateUrl: "#{App.views}comportamiento/faltasDeLasQueDerivaNuevoDir.tpl.html"
])

.controller('CrearFaltaCtrl', ['$scope', '$uibModalInstance', 'alumno', 'per_num', 'periodos', 'config', 'ordinales', 'profesores', 'creando', '$http', 'toastr', 'App', 'AuthService', ($scope, $modalInstance, alumno, per_num, periodos, config, ordinales, profesores, creando, $http, toastr, App, AuthService)->
  $scope.alumno 		    = alumno
  $scope.datos          = {}
  $scope.config         = config
  $scope.periodos 		  = periodos
  $scope.profesores 	  = profesores
  $scope.ordinales 	    = ordinales
  $scope.perfilPath 	  = App.images+'perfil/'
  $scope.falta_new      = {}
  $scope.eliminando 	  = false
  $scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm


  for peri in $scope.periodos
    peri.activo = false
    if peri.numero == per_num
      peri.activo 						= true
      peri.creando 						= creando
      $scope.datos.periodo 		= peri



  $scope.toggleVerCrear = (periodo, estado)->
    periodo.creando = estado


  $scope.eliminarFalta = (periodo, falta)->
    if $scope.eliminando
      return

    res = confirm('¿Seguro desea eliminar esta falta?')

    if res
      $scope.eliminando = true

      $http.put('::disciplina/destroy', {proceso_id: falta.id, alumno_id: alumno.alumno_id}).then((r)->
        toastr.success 'Falta eliminada.'
        $scope.eliminando = false
        $scope.reemplazarAlumno(r.data, falta.descripcion, true)
      , (r2)->
        toastr.error 'No se pudo eliminar.', 'Problema'
        $scope.eliminando = false
      )


  $scope.editarFalta = (periodo, falta)->
    if falta.fecha_hora_aprox
      if falta.fecha_hora_aprox.replace
        falta.fecha_hora_aprox = new Date(falta.fecha_hora_aprox.replace(/-/g, '\/'))

    $scope.falta_edit = falta

    $scope.falta_edit.selected_ordinales = [];

    for proce_oridinal in falta.proceso_ordinales
      for ordinal_original in $scope.ordinales
        if proce_oridinal.id == ordinal_original.id
          $scope.falta_edit.selected_ordinales.push(ordinal_original)

    periodo.editando  = true


  $scope.cancelarEditarFalta = (periodo)->
    periodo.editando  = false


  $scope.seleccionandoOrdinal = ($item)->
    $item.proceso_id = $scope.falta_edit.id

    $http.post('::disciplina/asignar-ordinal', $item).then((r)->
      toastr.success 'Ordinal asignado.'
    , (r2)->
      toastr.error 'No se pudo asignar.', 'Problema'
    )

  $scope.quitandoOrdinal = ($item)->
    $item.proceso_id = $scope.falta_edit.id

    $http.put('::disciplina/quitar-ordinal', $item).then((r)->
      toastr.success 'Ordinal quitado.'
    , (r2)->
      toastr.error 'No se pudo quitar.', 'Problema'
    )


  $scope.reemplazarAlumno = (alumno, descripcion, eliminado)->
    $scope.alumno = alumno

    for original, index in $scope.alumnos
      if original
        if original.alumno_id == alumno.alumno_id
          $scope.alumnos.splice(index, 1)

    $scope.alumnos.push(alumno)


    if descripcion
      found = false
      for descrip, indice in $scope.descripciones_typeahead
        if descrip.descripcion==descripcion and eliminado!=true
          found = indice

      if found
        if eliminado
          $scope.descripciones_typeahead.splice(found, 1)
        else
          $scope.descripciones_typeahead.push({descripcion: descripcion})





  $scope.crear_falta = (periodo)->

    $scope.guardando_new  = true
    situaciones_depend    = []

    for situac in alumno.periodo1
      if situac.seleccionado
        situaciones_depend.push(situac)

    for situac in alumno.periodo2
      if situac.seleccionado
        situaciones_depend.push(situac)

    for situac in alumno.periodo3
      if situac.seleccionado
        situaciones_depend.push(situac)

    for situac in alumno.periodo4
      if situac.seleccionado
        situaciones_depend.push(situac)

    $scope.falta_new.dependencias 	= situaciones_depend
    $scope.falta_new.year_id 				= periodo.year_id
    $scope.falta_new.periodo_id 		= periodo.id
    $scope.falta_new.alumno_id 		  = $scope.alumno.alumno_id


    $http.post('::disciplina/store', $scope.falta_new).then((r)->
      toastr.success 'Falta creada.'
      $scope.guardando_new  = false
      periodo.creando       = false
      $scope.reemplazarAlumno(r.data, $scope.falta_new.descripcion)

      if creando
        $modalInstance.close(r.data)
    , (r2)->
      $scope.guardando_new  = false
      toastr.error 'No se pudo crear.', 'Problema'
    )




  $scope.clickSituacionDerivante = (situac)->
    console.log(situac, $scope.falta_edit)

    if situac.seleccionado
      situac.become_id = $scope.falta_edit.id
    else
      situac.become_id = null


    $http.put('::disciplina/cambiar-situacion-derivante', situac).then((r)->
      toastr.success 'Cambios guardados.'
    , (r2)->
      $scope.guardando_edit  = false
      toastr.error 'No se pudo guardar.', 'Problema'
    )





  $scope.guardar_falta = (periodo)->

    $scope.guardando_edit   = true
    situaciones_depend      = []

    for situac in alumno.periodo1
      if situac.seleccionado
        situaciones_depend.push(situac)

    for situac in alumno.periodo2
      if situac.seleccionado
        situaciones_depend.push(situac)

    for situac in alumno.periodo3
      if situac.seleccionado
        situaciones_depend.push(situac)

    for situac in alumno.periodo4
      if situac.seleccionado
        situaciones_depend.push(situac)

    $scope.falta_edit.alumno_id = $scope.alumno.alumno_id
    $scope.falta_edit.dependencias = situaciones_depend

    $http.put('::disciplina/update', $scope.falta_edit).then((r)->
      toastr.success 'Cambios guardados.'
      $scope.guardando_edit  	= false
      periodo.editando  			= false
      $scope.reemplazarAlumno(r.data, $scope.falta_edit.descripcion)
    , (r2)->
      $scope.guardando_edit  = false
      toastr.error 'No se pudo guardar.', 'Problema'
    )





  $scope.ok = ()->
    $modalInstance.close($scope.alumno)


])

