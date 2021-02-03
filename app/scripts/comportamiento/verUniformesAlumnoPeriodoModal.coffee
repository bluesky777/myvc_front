angular.module('myvcFrontApp')


.controller('verUniformesAlumnoPeriodoModal', ['$scope', '$uibModalInstance', 'alumno', 'per_num', 'periodos', 'config', 'profesores', '$http', 'toastr', 'App', 'AuthService', ($scope, $modalInstance, alumno, per_num, periodos, config,  profesores, $http, toastr, App, AuthService)->
  $scope.alumno 		    = alumno
  $scope.datos          = {}
  $scope.config         = config
  $scope.periodos 		  = periodos
  $scope.profesores 	  = profesores
  $scope.perfilPath 	  = App.images+'perfil/'
  $scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm
  $scope.per_num        = per_num


  for peri in $scope.periodos
    peri.activo = false
    if peri.numero == per_num
      peri.activo 						= true
      peri.creando 						= false # creando
      $scope.datos.periodo 		= peri



  $scope.verAgregarUniforme = (alumno)->
    alumno.new_uni = {
      fecha_hora: new Date()
    }
    alumno.creandoUniforme = !alumno.creandoUniforme
    return

  $scope.cancelarGuardarUniforme = (alumno)->
    alumno.guardando_uniforme = false
    alumno.creandoUniforme = false


  # Crear uniforme en la nube
  $scope.guardarUniforme = (alumno)->
    if alumno.guardando_uniforme
      return

    alumno.guardando_uniforme = true

    alumno.new_uni.alumno_id = alumno.alumno_id
    alumno.new_uni.periodo_id = $scope.datos.periodo.id
    #alumno.new_uni.asignatura_id = $scope.asignatura_actual.asignatura_id
    #alumno.new_uni.materia = $scope.asignatura_actual.materia
    alumno.new_uni.fecha_hora = alumno.new_uni.fecha_hora.yyyymmdd() + ' ' + window.fixHora(alumno.new_uni.fecha_hora);

    $http.put('::uniformes/agregar', alumno.new_uni ).then((r)->
      console.log(alumno, per_num)
      alumno.guardando_uniforme = false
      r.data.uniforme.fecha_hora = new Date(r.data.uniforme.fecha_hora.replace(/-/g, '\/'))
      alumno['uniformes_per'+per_num].push(r.data.uniforme)
      alumno.creandoUniforme = false
    ,() ->
      toastr.error('Error agregando uniformes')
      alumno.guardando_uniforme = false
      alumno.creandoUniforme = false
    )
    return
    
    
  $scope.editarUniforme = (uniforme, alumno)->
    uniforme.editando = !uniforme.editando

    
  $scope.cancelarGuardarUniformeEditado = (uniforme)->
    uniforme.guardando = false
    uniforme.editando = false


  $scope.guardarUniformeEditado = (uniforme, alumno)->
    if uniforme.guardando
      return

    uniforme.guardando = true

    $http.put('::uniformes/actualizar', uniforme ).then((r)->
      uniforme.guardando = false
      toastr.success('Uniforme actualizado.')
      uniforme.editando = false
    ,() ->
      toastr.error('Error actualizado uniforme.')
      uniforme.guardando = false
    )
    return

  $scope.eliminarUniforme = (uniforme, alumno)->
    res = confirm('¿Seguro que deseas eliminar este registro de uniforme?')
    
    if res
      $http.put('::uniformes/eliminar', {uniforme_id: uniforme.id, alumno_id: alumno.alumno_id }).then((r)->
        alumno['uniformes_per'+per_num] = r.data.uniformes
      , (r2)->
        toastr.warning 'No se pudo cambiar.', 'Problema'
      )



  $scope.ok = ()->
    $modalInstance.close($scope.alumno)


])

