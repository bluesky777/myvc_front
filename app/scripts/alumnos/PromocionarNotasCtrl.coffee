'use strict'

angular.module("myvcFrontApp")

.controller('PromocionarNotasCtrl', ['$scope', 'App', '$rootScope', '$state', '$timeout', 'uiGridConstants', 'uiGridEditConstants', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', 'EscalasValorativasServ', ($scope, App, $rootScope, $state, $timeout, uiGridConstants, uiGridEditConstants, $modal, $filter, AuthService, toastr, $http, EscalasValorativasServ)->

  AuthService.verificar_acceso()

  #$scope.$parent.bigLoader			= true
  $scope.dato 						= {}
  $scope.gridScope 					= $scope # Para getExternalScopes de ui-Grid
  $scope.views 						= App.views
  $scope.perfilPath 		  	      	= App.images+'perfil/'
  $scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm




  $scope.dato.grupo = ''
  $http.get('::grupos').then((r)->
    matr_grupo = 0

    if localStorage.matr_grupo
      matr_grupo = parseInt(localStorage.matr_grupo)

    $scope.grupos 		= r.data

    for grupo in $scope.grupos
      if parseInt(grupo.id) == parseInt(matr_grupo)
        $scope.dato.grupo = grupo
        $scope.selectGrupo($scope.dato.grupo)

  )


  EscalasValorativasServ.escalas().then((r)->
    $scope.escalas = r
    $scope.escala_maxima = EscalasValorativasServ.escala_maxima()
  , (r2)->
    console.log 'No se trajeron las escalas valorativas', r2
  )




  $scope.cambiaNotaComport = (nota, periodo, datos)->
    if $scope.dato.grupo.titular_id != $scope.USER.persona_id and !$scope.hasRoleOrPerm('admin')
      toastr.warning 'No eres el titular para cambiar comportamiento.'
      return

    if nota.id
      temp = nota.nota

      $http.put('::nota_comportamiento/update/'+nota.id, {nota: nota.nota}).then((r)->
        toastr.success 'Nota cambiada: ' + nota.nota
      , (r2)->
        toastr.error 'No pudimos guardar la nota ' + nota.nota
        nota.nota = temp
      )

    else
      temp              = {}
      temp.nota         = nota.nota
      temp.year_id      = periodo.year_id
      temp.alumno_id    = $scope[datos].alumno.id
      temp.periodo_id   = periodo.id

      $http.put('::nota_comportamiento/crear', temp).then((r)->
        nota_temp 	= r.data.nota_comport
        nota.id 				= nota_temp.id
        nota.year_id 		= nota_temp.year_id
        nota.nombres 		= nota_temp.nombres
        nota.apellidos 	= nota_temp.apellidos
        nota.alumno_id 	= nota_temp.alumno_id
        nota.foto_id 		= nota_temp.foto_id
        nota.foto_nombre 	= nota_temp.foto_nombre
        nota.sexo 			= nota_temp.sexo
        nota.periodo_id = nota_temp.periodo_id

        toastr.success 'Nota creada: ' + nota.nota
      , (r2)->
        toastr.error 'No pudimos guardar la nota ' + temp.nota
        nota = temp
      )




  $scope.selectGrupo = (grupo)->
    console.log($scope.dato);
    #$scope.dato               = {}
    localStorage.matr_grupo   = grupo.id
    $scope.dato.grupo 		    = grupo

    for grup in $scope.grupos
      grup.active = false

    grupo.active = true

    $http.put("::alumnos/de-grupo/"+grupo.id).then((r)->
      $scope.alumnos = r.data.alumnos

      alumno_seleccionado_id = 0

      if localStorage.matr_grupo
        alumno_seleccionado_id = parseInt(localStorage.alumno_seleccionado_id)

      for alum in $scope.alumnos
        if parseInt(alum.id) == alumno_seleccionado_id
          $scope.dato.selected_alumno = alum
          $scope.selectAlumno($scope.dato.selected_alumno)

    )

  $scope.selectAlumno = (alumno)->
    localStorage.alumno_seleccionado_id   = alumno.id
    $scope.dato.periodo_id = undefined

    $http.put("::alumnos/years-con-notas", {alumno_id: alumno.id}).then((r)->
      $scope.years_notas = r.data.years
      $scope.years_dest = r.data.years_dest
    )



  $scope.eligirPeriodoNotas = (grupo, periodo, num_year, panel_indice, alumno)->

    $scope.dato.periodo_id = periodo.id

    for peri in grupo.periodos
      if panel_indice == 1
        peri.seleccionado_origen = false
      else
        peri.seleccionado_destino = false

    if panel_indice == 1
      periodo.seleccionado_origen = true
    else
      periodo.seleccionado_destino = true


    $http.put("::notas/alumno-periodo-grupo", {alumno_id: $scope.dato.selected_alumno.id, periodo_id: periodo.id, grupo_id: grupo.grupo_id}).then((r)->
      if panel_indice == 1
        $scope.datos_origen = {grupo: grupo, periodo: periodo, num_year: num_year, alumno: alumno}
        $scope.notas_origen = r.data.notas
      else
        # Aquí, grupo es year en realidad con los datos del grupo
        $scope.datos_destino = {grupo: grupo, periodo: periodo, num_year: num_year, alumno: alumno}
        $scope.notas_destino = r.data.notas

        if !$.isArray($scope.notas_destino.asignaturas)
          $scope.notas_destino.asignaturas = [$scope.notas_destino.asignaturas[Object.keys($scope.notas_destino.asignaturas)[0]]]

    )


  $scope.pasarNota = (asignatura)->
    if $scope.pasando_nota
      return
    else
      $scope.pasando_nota = true

    found = 0

    for asignat in $scope.notas_destino.asignaturas
      if asignat.materia_id == asignatura.materia_id
        found = found + 1

        if asignat.nf_id
          $scope.asign_temp = asignatura

          $http.put('::definitivas_periodos/update', {nf_id: asignat.nf_id, nota: asignatura.nota_asignatura, num_periodo: $scope.datos_destino.periodo.numero }).then((r)->

            $scope.evento_definitiva_cambiada(false, asignatura)

          , (r2)->
            $scope.pasando_nota = false
            if r2.status == 400
              toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
            else
              toastr.error 'No pudimos guardar la nota ' + asignatura.nota_asignatura, '', {timeOut: 8000}
          )
        else
            $http.put('::definitivas_periodos/update', {alumno_id: $scope.dato.selected_alumno.id, nota: asignatura.nota_asignatura, asignatura_id: asignat.asignatura_id, num_periodo: $scope.datos_destino.periodo.numero }).then((r)->

              $scope.evento_definitiva_cambiada(true, asignatura, r.data[0])

            , (r2)->
              $scope.pasando_nota = false
              if r2.status == 400
                toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
              else
                toastr.error 'No pudimos guardar la nota ' + asignatura.nota_asignatura, '', {timeOut: 8000}
            )

    if found == 0
      toastr.warning 'No coincide con ninguna materia destino.'
      $scope.pasando_nota = false



  # Para cuando sea cambiada alguna definitiva
  $scope.evento_definitiva_cambiada = (is_new, asignatura, r)->
    if is_new

      toastr.success 'Creada: ' + asignatura.nota_asignatura

      for asignatu in $scope.notas_destino.asignaturas
        if asignatu.asignatura_id == r.asignatura_id
          asignatu.nf_id         					= r.id
          asignatu.nota_asignatura        = r.nota
          asignatu.manual 								= 1
          asignatu.recuperada 						= 0
          $scope.pasando_nota = false

          $timeout( ()->
            $scope.$apply()
          )

    else

      for asignatu in $scope.notas_destino.asignaturas
        if asignatu.materia_id == $scope.asign_temp.materia_id
          asignatu.nota_asignatura   = $scope.asign_temp.nota_asignatura
          asignatu.manual            = 1

          $timeout( ()->
            $scope.$apply()
          )

      toastr.success 'Cambiada: ' + asignatura.nota_asignatura
      $scope.pasando_nota = false



  $scope.cambiaNotaDef = (asignatura, nota, nf_id, num_periodo)->

    if nota > $scope.escala_maxima.porc_final or nota == 'undefined' or nota == undefined
      toastr.error 'No puede ser mayor de ' + $scope.escala_maxima.porc_final, 'NO guardada', {timeOut: 8000}
      return

    if nf_id
      $http.put('::definitivas_periodos/update', {nf_id: nf_id, nota: nota}).then((r)->
        if !asignatura.manual
          asignatura.manual = 1
        toastr.success 'Cambiada: ' + nota
      , (r2)->
        if r2.status == 400
          toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
        else
          toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
      )
    else
      $http.put('::definitivas_periodos/update', {alumno_id: $scope.alumno_traido.alumno_id, nota: nota, asignatura_id: asignatura.asignatura_id, num_periodo: num_periodo }).then((r)->
        toastr.success 'Creada: ' + nota
        r = r.data[0]
        asignatura.nf_id          = r.id
        asignatura.recuperada     = 0
        asignatura.manual         = 1
      , (r2)->
        if r2.status == 400
          toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
        else
          toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
      )


  $scope.toggleNotaFinalRecuperada = (alumno, recuperada, nf_id)->
    $http.put('::definitivas_periodos/toggle-recuperada', {nf_id: nf_id, recuperada: recuperada}).then((r)->

      if recuperada and !alumno.manual
        alumno.manual = 1
        toastr.success 'Indicará que es recuperada, así que también será manual.'
      else if recuperada
        toastr.success 'Recuperada'
      else
        toastr.success 'No recuperada'
    , (r2)->
      if r2.status == 400
        toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
      else
        toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
    )

  $scope.toggleNotaFinalManual = (alumno, manual, nf_id)->
    $http.put('::definitivas_periodos/toggle-manual', {nf_id: nf_id, manual: manual}).then((r)->

      if !manual and alumno.nota_final.recuperada
        alumno.nota_final.recuperada = false
        toastr.success 'Será automática y no recuperada.'
      else if manual
        toastr.success 'Nota manual.'
      else
        toastr.success 'Ahora la calculará el sistema.'
    , (r2)->
      if r2.status == 400
        toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
      else
        toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
    )


  $scope.verDetalleNota = (asignatura, alumno)->

    modalInstance = $modal.open({
      templateUrl: '==notas/notaFinalDetalleModal.tpl.html'
      controller: 'NotaFinalDetalleModalCtrl'
      resolve:
        alumno: ()->
          alumno
        asignatura: ()->
          asignatura
        USER: ()->
          $scope.USER
        escala_maxima: ()->
          $scope.escala_maxima
    })
    modalInstance.result.then( (r)->
      if r=='Eliminada'
        asignatura.eliminada = true
    , ()->
      # nada
    )
    return




  return
])












.controller('NotaFinalDetalleModalCtrl', ['$scope', '$uibModalInstance', 'alumno', 'asignatura', 'AuthService', '$http', 'toastr', '$filter', 'USER', 'escala_maxima', ($scope, $modalInstance, alumno, asignatura, AuthService, $http, toastr, $filter, USER, escala_maxima)->
  $scope.alumno         = alumno
  $scope.nota           = asignatura
  $scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm
  $scope.escala_maxima  = escala_maxima

  $http.put('::historiales/nota-final-detalle', {nf_id: asignatura.nf_id}).then((r)->
    $scope.cambios        = r.data.cambios
    $scope.nota_detalle   = r.data.nota
  , (r2)->
    toastr.warning 'No se pudo traer el historial.', 'Problema'
  )



  $scope.eliminarNota = ()->

      $http.delete('::definitivas_periodos/destroy/' + asignatura.nf_id).then((r)->
        toastr.success 'Nota eliminada', 'Recarga para ver'
        $modalInstance.close('Eliminada')
      , (r2)->
        toastr.error 'No se pudo eliminar nota.', 'Problema'
      )


  $scope.ok = ()->
    $modalInstance.close(alumno)



  $scope.cambiaNotaDef = (asignatura, nota, nf_id, num_periodo)->

    if nota > $scope.escala_maxima.porc_final or nota == 'undefined' or nota == undefined
      toastr.error 'No puede ser mayor de ' + $scope.escala_maxima.porc_final, 'NO guardada', {timeOut: 8000}
      return

    if nf_id
      $http.put('::definitivas_periodos/update', {nf_id: nf_id, nota: nota}).then((r)->
        if !asignatura.manual
          asignatura.manual = 1
        toastr.success 'Cambiada: ' + nota
      , (r2)->
        if r2.status == 400
          toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
        else
          toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
      )
    else
      $http.put('::definitivas_periodos/update', {alumno_id: $scope.alumno_traido.alumno_id, nota: nota, asignatura_id: asignatura.asignatura_id, num_periodo: num_periodo }).then((r)->
        toastr.success 'Creada: ' + nota
        r = r.data[0]
        asignatura.nf_id          = r.id
        asignatura.recuperada     = 0
        asignatura.manual         = 1
      , (r2)->
        if r2.status == 400
          toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
        else
          toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
      )


  $scope.toggleNotaFinalRecuperada = (alumno, recuperada, nf_id)->
    $http.put('::definitivas_periodos/toggle-recuperada', {nf_id: nf_id, recuperada: recuperada}).then((r)->

      if recuperada and !alumno.manual
        alumno.manual = 1
        toastr.success 'Indicará que es recuperada, así que también será manual.'
      else if recuperada
        toastr.success 'Recuperada'
      else
        toastr.success 'No recuperada'
    , (r2)->
      if r2.status == 400
        toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
      else
        toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
    )

  $scope.toggleNotaFinalManual = (alumno, manual, nf_id)->
    $http.put('::definitivas_periodos/toggle-manual', {nf_id: nf_id, manual: manual}).then((r)->

      if !manual and alumno.nota_final.recuperada
        alumno.nota_final.recuperada = false
        toastr.success 'Será automática y no recuperada.'
      else if manual
        toastr.success 'Nota manual.'
      else
        toastr.success 'Ahora la calculará el sistema.'
    , (r2)->
      if r2.status == 400
        toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
      else
        toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
    )



])


