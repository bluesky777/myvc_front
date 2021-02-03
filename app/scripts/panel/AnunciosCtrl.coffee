angular.module('myvcFrontApp')


.controller('AnunciosDirCtrl', ['$scope', '$uibModal', 'AuthService', '$http', 'toastr', '$filter', 'App', '$timeout', 'Upload', '$sce', 'uiCalendarConfig', '$compile', 'EscalasValorativasServ', ($scope, $modal, AuthService, $http, toastr, $filter, App, $timeout, $upload, $sce, uiCalendarConfig, $compile, EscalasValorativasServ)->

  $scope.hasRoleOrPerm          = AuthService.hasRoleOrPerm
  $scope.perfilPath             = App.images+'perfil/'
  $scope.views 			            = App.views
  $scope.srcCant 				        = $scope.views + 'informes2/verCantAlumnosPorGrupos.tpl.html'
  $scope.fileReaderSupported 	  = window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);
  $scope.imgFiles               = []
  $scope.imagen_subida          = true
  $scope.mostrar_publicaciones  = true
  $scope.guardando_publicacion  = false
  $scope.USER                   = $scope.USER
  $scope.profe_seleccionado     = false
  $scope.mostrando_edit_evento  = false
  $scope.actualizando_cumples   = false
  $scope.IS_PROF_ADMIN 		      = $scope.hasRoleOrPerm(['admin', 'profesor']);
  $scope.IS_ALUM_ACUD 		      = $scope.hasRoleOrPerm(['alumno', 'acudiente', 'psicólogo', 'enfermero']) || $scope.USER.tipo == 'Acudiente';


  $scope.new_publicacion  = {
    publi_para: 'publi_para_todos',
    para_alumnos: 1
  }

  $scope.evento_actual =
    title:  ''
    start:  null
    end:    null
    allDay: 1
    solo_profes: 0



  # CALENDARIO
  $scope.data = {} # Para el popup del Datapicker

  $scope.dateOptions =
    formatYear: 'yyyy'

  if localStorage.panel_tab_actual
    $scope.panel_tab_actual = localStorage.panel_tab_actual


  $scope.guardarEvento = (evento)->
    if evento.title.length==0 or !evento.start
      toastr.warning 'Escribe título y fecha inicio'
      return

    if !evento.allDay and !evento.end
      toastr.warning 'Escribe fecha fin o elige Todo el día'
      return

    evento.guardando = true

    if evento.editar
      $http.put('::calendario/guardar-evento', evento).then(()->
        toastr.success 'Guardado'
        evento.guardando  = false
        evento.editar     = false

        $scope.evento_actual =
          title:  ''
          start:  null
          end:    null
          allDay: 1
          solo_profes: 0
          id:     null

      , ()->
        toastr.error 'Error guardando'
        evento.guardando = false
      )
    else
      $http.put('::calendario/crear-evento', evento).then((r)->
        toastr.success 'Creado'
        evento.guardando  = false

        evento.id = r.data.evento_id
        $scope.eventos[0].push(evento)

        $scope.evento_actual =
          title:  ''
          start:  null
          end:    null
          allDay: 1
          solo_profes: 0
          id:     null

      , ()->
        toastr.error 'Error creando'
        evento.guardando = false
      )


  $scope.actualizarEventos = ()->
    $http.put('::calendario/this-year', { is_prof_admin: $scope.IS_PROF_ADMIN }).then((r)->
      $scope.eventos = null

      $timeout(()->
        for evento in r.data
          evento.start      = new Date(evento.start);
          evento.end        = if evento.end then new Date(evento.end) else null;
          if evento.solo_profes
            evento.className  = 'evento-solo-profes'
          else
            evento.className  = if evento.cumple_alumno_id or evento.cumple_profe_id then 'evento-cumpleanios' else null

        $scope.eventos = [
          r.data
        ];
        toastr.success 'Actualizado'
      , 500)

    , ()->
      toastr.error 'Error actualizando'
    )



  $scope.noMostrarEditEvento = ()->
    $scope.mostrando_edit_evento = false


  $scope.mostrarEditEvento = ()->
    $scope.mostrando_edit_evento = true


  $scope.cancelarEdicion = ()->
    $scope.evento_actual =
      title:  ''
      start:  null
      end:    null
      allDay: 1
      id:     null

  $scope.eliminarEvento = (evento)->
    console.log evento
    if evento.guardando
      return

    respu = confirm('¿Seguro que desea eliminar evento?')
    if !respu
      return

    evento.guardando = true

    if evento.editar
      $http.put('::calendario/eliminar-evento', evento).then(()->
        toastr.success 'Eliminado'
        evento.guardando  = false

        $scope.evento_actual =
          title:  ''
          start:  null
          end:    null
          solo_profes: 0
          allDay: 1

      , ()->
        toastr.error 'Error eliminando'
        evento.guardando = false
      )

  $scope.actualizarCumplesEnCalendario = ()->

    respu = confirm('Esto borrará y creará de nuevo los cumpleaños, ¿continuar?')
    if !respu
      return

    $scope.actualizando_cumples = true

    $http.put('::calendario/sincronizar-cumples').then(()->
      toastr.success 'Sincronizado', 'Actualice'
      $scope.actualizando_cumples = false
    , ()->
      toastr.error 'Error sincronizando'
      $scope.actualizando_cumples = false
    )


  $scope.fromEventoToActual = (date)->

    $scope.evento_actual =
      title:  date.title
      start:  if date.start then new Date(date.start) else null
      end:    if date.end then new Date(date.end) else null
      allDay: if date.allDay then 1 else 0
      solo_profes: date.solo_profes
      editar: true
      id:     date.id


  $scope.alertOnEventClick = ( date, jsEvent, view)->
    $scope.fromEventoToActual(date)
    $scope.mostrando_edit_evento = true


  $scope.alertOnDrop = (event, delta, revertFunc, jsEvent, ui, view)->
    $scope.fromEventoToActual(event)
    $scope.guardarEvento($scope.evento_actual)
    console.log('Event Droped to make dayDelta ' + delta, event);


  $scope.alertOnResize = (event, delta, revertFunc, jsEvent, ui, view )->
    $scope.fromEventoToActual(event)
    $scope.guardarEvento($scope.evento_actual)
    console.log('Event Resized to make dayDelta ' + delta, event);

  ###
  $scope.changeView = (view)->
    $timeout(()->
      uiCalendarConfig.calendars['myCalendar'].fullCalendar('changeView',view);
    , 100)
  ###

  $scope.eventRender = ( event, element, view)->
    element.attr({'uib-tooltip-html': "\'<p>" + event.title + "</p>Por: " + event.created_by_nombres + "\'", 'tooltip-append-to-body': true})
    $compile(element)($scope);



  $scope.uiConfig = {
    calendar:{
      height: 450,
      editable: if $scope.IS_PROF_ADMIN then true else false,
      eventRender: $scope.eventRender
      header:{
        left: 'month agendaWeek agendaDay',
        center: 'title',
        right: 'today prev,next'
      },
      eventDurationEditable: if $scope.IS_PROF_ADMIN then true else false
      eventClick: $scope.alertOnEventClick,
      eventDrop: $scope.alertOnDrop,
      eventResize: if $scope.IS_PROF_ADMIN then $scope.alertOnResize else null
      buttonText: {
        today:'Hoy',
        month: 'Mes',
        agendaWeek: 'Semana',
        agendaDay: 'Día'
      },
    }
  }


  $scope.selectTab = (tab)->
    $scope.panel_tab_actual = tab
    localStorage.panel_tab_actual = $scope.panel_tab_actual
    if tab == 'calendario'
      $scope.actualizarEventos();



  # **************************************
  # HORARIO
  $scope.UNIDAD 			  = $scope.USER.unidad_displayname
  $scope.GENERO_UNI 		= $scope.USER.genero_unidad
  $scope.SUBUNIDAD 		  = $scope.USER.subunidad_displayname
  $scope.GENERO_SUB 		= $scope.USER.genero_subunidad
  $scope.UNIDADES 		  = $scope.USER.unidades_displayname
  $scope.SUBUNIDADES 		= $scope.USER.subunidades_displayname
  $scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)


  EscalasValorativasServ.escalas().then((r)->
    $scope.escalas = r
    $scope.escala_maxima = EscalasValorativasServ.escala_maxima()
  , (r2)->
    console.log 'No se trajeron las escalas valorativas', r2
  )




  $scope.mostrarClasesDeHoy = ()->
    $scope.mostrandoHoy = true

  $scope.mostrarClasesDeManana = ()->
    $scope.mostrandoHoy = false


  $scope.seleccionarAsignatura = (asignatura)->
    if asignatura.unidades.length == 0 and !asignatura.seleccionada

      $http.get('::unidades/de-asignatura-periodo/'+asignatura.asignatura_id+'/'+$scope.USER.periodo_id).then((r)->
        if r.data.length > 0
          asignatura.unidades = r.data
      ,() ->
        toastr.error('Error comprobando notas de asignatura')
      )
    asignatura.seleccionada = !asignatura.seleccionada;


  $scope.cargarAlumnosAsistencia = (asignatura, grupo_id, asignatura_id)->
    $scope.subunidad_actual   = false
    $scope.asignatura_actual  = asignatura

    $http.put('::notas/subunidad', { grupo_id: grupo_id, asignatura_id: asignatura_id }).then((r)->
      $scope.alumnos_subunidad  = r.data.alumnos
      $scope.pasandoNotas       = true

      for alumno in $scope.alumnos_subunidad
        for uniforme in alumno.uniformes
          uniforme.fecha_hora = new Date(uniforme.fecha_hora.replace(/-/g, '\/'))
          
        $scope.verificarFallaHoy(alumno)

    ,() ->
      toastr.error('Error trayendo notas')
    )


  $scope.verificarFallaHoy = (alumno)->
    d = new Date()
    alumno.falla_hoy = ''
    alumno.uniforme_hoy = false

    for tardanza in alumno.tardanzas
      if tardanza.fecha_hora
        if tardanza.fecha_hora.replace
          tardanza.fecha_hora   = new Date(tardanza.fecha_hora.replace(/-/g, '\/'))

        if d.toDateString() == tardanza.fecha_hora.toDateString()
          alumno.falla_hoy = 'tardanza'

    for ausencia in alumno.ausencias
      if ausencia.fecha_hora
        if ausencia.fecha_hora.replace
          ausencia.fecha_hora   = new Date(ausencia.fecha_hora.replace(/-/g, '\/'))

        if d.toDateString() == ausencia.fecha_hora.toDateString()
          alumno.falla_hoy = 'ausencia'

    for uniforme in alumno.uniformes
      if uniforme.fecha_hora
        if uniforme.fecha_hora.replace
          uniforme.fecha_hora   = new Date(uniforme.fecha_hora.replace(/-/g, '\/'))

        if d.toDateString() == uniforme.fecha_hora.toDateString()
          alumno.uniforme_hoy = true



  $scope.cargarAlumnosSubunidad = (subunidad, asignatura, grupo_id, asignatura_id)->
    $scope.subunidad_actual   = subunidad
    $scope.asignatura_actual  = asignatura

    $http.put('::notas/subunidad', { subunidad: subunidad, grupo_id: grupo_id, asignatura_id: asignatura_id }).then((r)->
      $scope.alumnos_subunidad  = r.data.alumnos
      $scope.pasandoNotas       = true

      for alumno in $scope.alumnos_subunidad
        $scope.verificarFallaHoy(alumno)

    ,() ->
      toastr.error('Error trayendo notas')
    )

  $scope.cambiarNota = (alumno, nota)->
    modalInstance = $modal.open({
      templateUrl: '==panel/cambiarNotaModal.tpl.html'
      controller: 'CambiarNotaModalCtrl'
      animation: false
      resolve:
        alumno: ()->
          alumno
        subunidad: ()->
          $scope.subunidad_actual
        nota: ()->
          nota
    })
    modalInstance.result.then( (r)->
      console.log(r)
    , ()->
      # nada
    )

  $scope.quitarAusenciaHoy = (alumno, tipo)->
    if alumno.quitandoAusenciaHoy
      return
    alumno.quitandoAusenciaHoy = true
    d = new Date()
    d = d.toDateString()

    for ausencia in alumno.tardanzas
      if d == ausencia.fecha_hora.toDateString()
        $scope.eliminarAusencia(ausencia, alumno, true);

    for ausencia in alumno.ausencias
      if d == ausencia.fecha_hora.toDateString()
        $scope.eliminarAusencia(ausencia, alumno, true);

    $timeout(()->
      alumno.quitandoAusenciaHoy = false
      $scope.verificarFallaHoy(alumno)
    , 500)



  $scope.verTardanzasAusencias = (alumno)->
    alumno.mostrandoFallas = !alumno.mostrandoFallas
    return

  
  
  # Ver uniformes de alumno
  $scope.verUniformes = (alumno)->
    alumno.mostrandoUniformes = !alumno.mostrandoUniformes
    return

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
    alumno.new_uni.asignatura_id = $scope.asignatura_actual.asignatura_id
    alumno.new_uni.materia = $scope.asignatura_actual.materia
    alumno.new_uni.fecha_hora = alumno.new_uni.fecha_hora.yyyymmdd() + ' ' + window.fixHora(alumno.new_uni.fecha_hora);

    $http.put('::uniformes/agregar', alumno.new_uni ).then((r)->
      alumno.uniforme_hoy = true
      alumno.guardando_uniforme = false
      r.data.uniforme.fecha_hora = new Date(r.data.uniforme.fecha_hora.replace(/-/g, '\/'))
      alumno.uniformes.push(r.data.uniforme)
      alumno.uniformes_count++
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
    
    
    
  # Función no utilizada
  $scope.guardarValorUniforme = (uniforme, propiedad, valor, alumno)->

    datos =
      uniforme_id: uniforme.id
      fecha_hora: $filter('date')(uniforme.fecha_hora, 'yyyy-MM-dd HH:mm:ss')

    $http.put('::uniformes/guardar-cambios-uniforme', datos).then((r)->
      $scope.verificarFallaHoy(alumno);
    , (r2)->
      toastr.warning 'No se pudo cambiar.', 'Problema'
    )
    
    
  $scope.eliminarUniforme = (uniforme, alumno)->
    res = confirm('¿Seguro que deseas eliminar este registro de uniforme?')
    
    if res
      $http.put('::uniformes/eliminar', {uniforme_id: uniforme.id, alumno_id: alumno.alumno_id, asignatura_id: $scope.asignatura_actual.asignatura_id }).then((r)->
        alumno.uniformes = r.data.uniformes
        alumno.uniformes_count = r.data.uniformes_count
        $scope.verificarFallaHoy(alumno);
      , (r2)->
        toastr.warning 'No se pudo cambiar.', 'Problema'
      )


    
    



  $scope.volverClases = ()->
    $scope.pasandoNotas = false


  $scope.agregarTardanza = (alumno)->
    if alumno.guardando_falla
      return

    alumno.guardando_falla = true

    d = new Date();
    now = d.yyyymmdd() + ' ' + window.fixHora(d);

    $http.post('::ausencias/agregar-tardanza', { now: now, alumno_id: alumno.alumno_id, asignatura_id: $scope.asignatura_actual.asignatura_id }).then((r)->
      alumno.falla_hoy = 'tardanza'
      alumno.guardando_falla = false
      r.data.fecha_hora = new Date(r.data.fecha_hora.date.replace(/-/g, '\/'))
      alumno.tardanzas.push(r.data)
      alumno.tardanzas_count++
    ,() ->
      toastr.error('Error agregando tardanza')
      alumno.guardando_falla = false
    )


  $scope.agregarAusencia = (alumno)->
    if alumno.guardando_falla
      return

    alumno.guardando_falla = true

    d = new Date();
    now = d.yyyymmdd() + ' ' + window.fixHora(d);

    $http.post('::ausencias/agregar-ausencia', { now: now, alumno_id: alumno.alumno_id, asignatura_id: $scope.asignatura_actual.asignatura_id }).then((r)->
      alumno.falla_hoy = 'ausencia'
      alumno.guardando_falla = false
      r.data.fecha_hora   = new Date(r.data.fecha_hora.date.replace(/-/g, '\/'))
      alumno.ausencias.push(r.data)
      alumno.ausencias_count++
    ,() ->
      toastr.error('Error agregando ausencia')
      alumno.guardando_falla = false
    )



  $scope.cambiarTipo = (ausencia, new_tipo, alumno)->

    datos =
      ausencia_id: ausencia.id
      new_tipo: new_tipo

    $http.put('::ausencias/cambiar-tipo-ausencia', datos).then((r)->

      if new_tipo == 'tardanza'
        ausencia.tipo = 'tardanza'
        ausencia.cantidad_ausencia = ausencia.cantidad_tardanza
        ausencia.tardanzas_count++
        ausencia.ausencias_count--
        alumno.tardanzas.push(ausencia)
        alumno.ausencias = $filter('filter')(alumno.ausencias, { id: '!'+ausencia.id })

        d = new Date()
        if d.toDateString() == ausencia.fecha_hora.toDateString()
          alumno.falla_hoy = 'tardanza'

      if new_tipo == 'ausencia'
        ausencia.tipo = 'ausencia'
        ausencia.cantidad_tardanza = ausencia.cantidad_ausencia
        ausencia.tardanzas_count--
        ausencia.ausencias_count++
        alumno.ausencias.push(ausencia)
        alumno.tardanzas = $filter('filter')(alumno.tardanzas, { id: '!'+ausencia.id })


        d = new Date()
        if d.toDateString() == ausencia.fecha_hora.toDateString()
          alumno.falla_hoy = 'ausencia'

    , (r2)->
      toastr.warning 'No se pudo cambiar el tipo.', 'Problema'
    )


  $scope.guardarValorAusencia = (ausencia, propiedad, valor, alumno)->

    datos =
      ausencia_id: ausencia.id
      fecha_hora: $filter('date')(ausencia.fecha_hora, 'yyyy-MM-dd HH:mm:ss')

    $http.put('::ausencias/guardar-cambios-ausencia', datos).then((r)->
      $scope.verificarFallaHoy(alumno);
    , (r2)->
      toastr.warning 'No se pudo cambiar.', 'Problema'
    )



  $scope.eliminarAusencia = (ausencia, alumno, omitir_preg)->
    if ausencia.eliminando
      return
    ausencia.eliminando = true

    res = true
    if !omitir_preg
      res = confirm('¿Seguro que quiere eliminar?')

    if res
      $http.delete('::ausencias/destroy/' + ausencia.id).then((r)->
        r 		= r.data
        if ausencia.tipo == 'tardanza'
          alumno.tardanzas = $filter('filter')(alumno.tardanzas, { id: '!'+r.id })
          alumno.tardanzas_count--

        if ausencia.tipo == 'ausencia'
          alumno.ausencias = $filter('filter')(alumno.ausencias, { id: '!'+r.id })
          alumno.ausencias_count--

        if !omitir_preg
          $timeout(()->
            $scope.verificarFallaHoy(alumno)
          , 100)
        ausencia.isOpen = false
      , (r2)->
        toastr.warning 'No se pudo quitar ausencia.', 'Problema'
      )
    else
      ausencia.eliminando = false





  # ****************************************************
  # PUBLICACIONES
  $scope.editarPublicacion = (publicacion)->
    if publicacion.para_todos
      publicacion.publi_para = 'publi_para_todos'
    else
      publicacion.publi_para = 'publi_privada'

    publicacion.editar          = true
    $scope.new_publicacion      = publicacion
    $scope.creando_publicacion  = true




  $scope.verPublicacion = (publi, $index)->
    if $index > -1
      $scope.publicaciones_actuales   = [ publi ]

      if $scope.changes_asked.publicaciones.length > ($index + 1)
        $scope.publicaciones_actuales.push($scope.changes_asked.publicaciones[$index + 1])

      $scope.creando_publicacion      = false
    else
      $scope.publicacion_actual   = publi
      $scope.creando_publicacion  = false


  $scope.eliminarPublicacion = (publi)->
    $http.put('::publicaciones/delete', { publi_id: publi.id }).then((r)->

      toastr.success 'Eliminada.'
      publi.deleted_at = new Date().toString()

    , (r2)->
      toastr.error 'Error al eliminar', 'Problema'
      return {}
    )

  $scope.verPublicacionDetalle = (publica)->

    modalInstance = $modal.open({
      templateUrl: '==panel/VerPublicacionModal.tpl.html'
      controller: 'VerPublicacionModalCtrl'
      size: 'lg',
      windowClass: 'modal-publicacion'
      resolve:
        publicacion_actual: ()->
          publica
        USER: ()->
          $scope.USER
    })
    modalInstance.result.then( (imag)->
      console.log 'Cerrado'
    )


  $scope.restaurarPublicacion = (publi)->
    $http.put('::publicaciones/restaurar', { publi_id: publi.id }).then((r)->

      toastr.success 'Restaurada.'
      publi.deleted_at = null

    , (r2)->
      toastr.error 'Error al Restaur', 'Problema'
      return {}
    )


  $scope.crearPublicacion = (new_publicacion)->
    $scope.guardando_publicacion = true

    if new_publicacion.editar
      $http.put('::publicaciones/guardar-edicion', new_publicacion).then((r)->

        new_publicacion.id          		= r.data.publicacion_id
        new_publicacion.imagen_nombre 	= if $scope.new_publicacion.imagen then $scope.new_publicacion.imagen.nombre else null
        new_publicacion.contenido_tr 		= $sce.trustAsHtml(new_publicacion.contenido)
        new_publicacion.updated_at 			= $filter('date')(new Date(), 'short')

        $scope.imagen_temporal = undefined

        toastr.success 'Guardado. Recargue la página'

        $scope.new_publicacion  = {
          publi_para: 'publi_para_todos',
          para_alumnos: 1
        }
        $scope.creando_publicacion    = false
        $scope.guardando_publicacion  = false

      , (r2)->
        toastr.error 'Error al publicar', 'Problema'
        $scope.guardando_publicacion = false
        return {}
      )
    else
      $http.put('::publicaciones/store', new_publicacion).then((r)->

        new_publicacion.id          		= r.data.publicacion_id
        new_publicacion.imagen_nombre 	= if $scope.new_publicacion.imagen then $scope.new_publicacion.imagen.name else null
        new_publicacion.contenido_tr 		= $sce.trustAsHtml(new_publicacion.contenido)
        new_publicacion.updated_at 			= $filter('date')(new Date(), 'short')

        $scope.changes_asked.mis_publicaciones.unshift new_publicacion
        $scope.changes_asked.publicaciones.unshift new_publicacion

        $scope.imagen_temporal = undefined

        toastr.success 'Publicado con éxito'

        $scope.new_publicacion  = {
          publi_para: 'publi_para_todos',
          publi_para_alumnos: 1
        }
        $scope.creando_publicacion    = false
        $scope.guardando_publicacion  = false

      , (r2)->
        toastr.error 'Error al publicar', 'Problema'
        $scope.guardando_publicacion = false
        return {}
      )

  $scope.toggle_mis_publicaciones = (publi)->
    $scope.mostrar_publicaciones = false
    $scope.mostrar_mis_publicaciones = !$scope.mostrar_mis_publicaciones

  $scope.toggle_publicaciones = (publi)->
    $scope.mostrar_mis_publicaciones = false
    $scope.mostrar_publicaciones = !$scope.mostrar_publicaciones


  ###########################################################
  ############### 	SUBIDA DE IMÁGENES 		###############
  ###########################################################
  $scope.uploadFiles =  (files)->

    $scope.errorMsg       = ''

    if files and files.length

      for i in [0...files.length]
        file = files[i]
        $scope.imagen_temporal = file
        generateThumbAndUpload file


  generateThumbAndUpload = (file)->
    $scope.errorMsg = null
    uploadUsing$upload(file)
    $scope.generateThumb(file)

  $scope.generateThumb = (file)->
    console.log file
    if file != null
      if $scope.fileReaderSupported and file.type.indexOf('image') > -1
        $timeout ()->
          fileReader = new FileReader()
          fileReader.readAsDataURL(file)
          fileReader.onload = (e)->
            $timeout(()->
              file.dataUrl = e.target.result
              $scope.imgFiles.push file
            )

  uploadUsing$upload = (file)->

    $scope.imagen_subida  = false

    if file.size > 5000000
      $scope.errorMsg = 'Archivo excede los 5MB permitidos.'
      return

    $upload.upload({
      url: App.Server + 'myimages/store-intacta-privada',
      file: file
    }).progress( (evt)->
      progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
      file.porcentaje = progressPercentage
      #console.log('progress: ' + progressPercentage + '% ' + evt.config.file.name, evt.config)
    ).success( (data, status, headers, config)->
      $scope.new_publicacion.imagen = data
      $scope.imagen_subida          = true
    ).error((r2)->
      $scope.imagen_subida          = true
      console.log 'Falla uploading: ', r2
    )



  $scope.borrarImagen = (imagen_temp)->
    imagen = {}
    angular.copy(imagen_temp, imagen)

    if imagen.imagen_id
      imagen.id     = imagen.imagen_id
      imagen.nombre = imagen.imagen_nombre

    modalInstance = $modal.open({
      templateUrl: '==fileManager/removeImage.tpl.html'
      controller: 'RemoveImageCtrl'
      size: 'md',
      resolve:
        imagen: ()->
          imagen
        user_id: ()->
          $scope.USER.user_id
        datos_imagen: ()->

          codigos =
            imagen_id: if imagen.imagen_id then imagen.imagen_id else imagen.id
            user_id: $scope.USER.user_id

          $http.put('::myimages/datos-imagen', codigos).then((r)->
            return $scope.datos_imagen = r.data
          , (r2)->
            toastr.error 'Error al traer datos de imagen', 'Problema'
            return {}
          )

    })
    modalInstance.result.then( (imag)->
      $scope.new_publicacion.imagen 				= undefined
      $scope.new_publicacion.imagen_nombre 	= undefined
      $scope.new_publicacion.imagen_id 			= undefined
      $scope.imgFiles               				= []
    )







  $scope.seleccionar_profe = (profesor)->

    $http.put('::historiales/de-usuario', {user_id: profesor.user_id}).then((r)->
      $scope.profe_seleccionado = r.data
      $scope.profe_seleccionado.profesor = profesor
    , (r2)->
      console.log 'Error trayendo detalles', r2
    )

  $scope.mostrar_crear_publicacion = ()->
    $scope.creando_publicacion = true
    $timeout(()->
      $('#textarea-new-publicacion').focus()
    )

  # Editor options.
  $scope.options = {
    language: 'es',
    allowedContent: true,
    entities: false
  };

  # Called when the editor is completely ready.
  $scope.onReady = ()->
    console.log('Listo para editar')


  $scope.desseleccionar_profe = ()->
    $scope.profe_seleccionado = false



  $scope.verDetalles = (change_asked)->
    if change_asked.mostrando
      change_asked.mostrando = false
    else
      change_asked.mostrando = true

      if not change_asked.detalles
        datos = { asked_id: change_asked.asked_id,  }

        $http.put('::ChangesAsked/ver-detalles', datos).then((r)->
          change_asked.detalles = r.data.detalles
        , (r2)->
          console.log 'Error trayendo detalles', r2
        )



  $scope.traerCatAlumnosPorGrupos = ()->

    $http.put('::grupos/con-cantidad-alumnos').then((r)->
      $scope.grupos_cantidades  = r.data.grupos
      $scope.periodos_total     = r.data.periodos_total

      $scope.cant_total_alumnos = 0

      for grup in $scope.grupos_cantidades
        $scope.cant_total_alumnos = $scope.cant_total_alumnos + grup.cant_alumnos

    , (r2)->
      console.log 'Error trayendo cantidad de alumnos', r2
    )


  $scope.rechazarCambio = (asked, tipo)->

    modalInstance = $modal.open({
      templateUrl: '==panel/rechazarAsked.tpl.html'
      controller: 'RechazarAskedCtrl'
      resolve:
        asked: ()->
          asked
        tipo: ()->
          tipo
    })
    modalInstance.result.then( (r)->
      toastr.info 'Pedido rechazado.'
      asked.finalizado = r.finalizado

      if tipo == 'img_perfil' 	then asked.detalles.image_id_accepted = false
      if tipo == 'foto_oficial' 	then asked.detalles.foto_id_accepted = false
      if tipo == 'img_delete' 	then asked.detalles.image_to_delete_accepted = false
      if tipo == 'nombres' 	then asked.detalles.nombres_accepted = false
      if tipo == 'apellidos' 	then asked.detalles.apellidos_accepted = false
      if tipo == 'sexo' 	then asked.detalles.sexo_accepted = false
      if tipo == 'fecha_nac' 	then asked.detalles.fecha_nac_accepted = false
    )

  $scope.aprobarCambio = (asked, tipo, valor_nuevo)->

    modalInstance = $modal.open({
      templateUrl: '==panel/aceptarAsked.tpl.html'
      controller: 'AceptarAskedCtrl'
      resolve:
        asked: ()->
          asked
        tipo: ()->
          tipo
        valor_nuevo: ()->
          valor_nuevo
    })
    modalInstance.result.then( (r)->
      toastr.success 'Pedido aceptado.'
      asked.finalizado = r.finalizado

      if tipo == 'img_perfil' 	then asked.detalles.image_id_accepted = true
      if tipo == 'img_delete' 	then asked.detalles.image_to_delete_accepted = true
      if tipo == 'nombres' 	    then asked.detalles.nombres_accepted = true
      if tipo == 'apellidos' 	  then asked.detalles.apellidos_accepted = true
      if tipo == 'sexo' 	      then asked.detalles.sexo_accepted = true
      if tipo == 'fecha_nac' 	  then asked.detalles.fecha_nac_accepted = true
      if tipo == 'foto_oficial'
        asked.detalles.foto_id_accepted = true
        asked.foto_nombre 				= asked.detalles.foto_new_nombre

      if tipo == 'asignatura' then asked.finalizado = true

    )

  $scope.eliminarSolicitudes = (asked)->

    modalInstance = $modal.open({
      templateUrl: '==panel/eliminarAsked.tpl.html'
      controller: 'EliminarAskedCtrl'
      resolve:
        asked: ()->
          asked
    })
    modalInstance.result.then( (r)->
      toastr.success 'Pedido eliminado.'
      asked.finalizado = true
    )


  $scope.verDetalleDeMiSesion = (historial)->


    $http.put('::historiales/sesion', { historial_id: historial.id, tipo: historial.tipo }).then((r)->

      modalInstance = $modal.open({
        templateUrl: '==panel/modalDetallesSesion.tpl.html'
        controller: 'ModalDetallesSesionCtrl'
        resolve:
          historial: ()->
            r.data.historial
      })
      modalInstance.result.then( (r)->
        console.log historial
      )

    , (r2)->
      toastr.error 'No se pudo traer el detalle'
    )




  $scope.eliminarIntentoFallido = (intento)->
    res = false
    res = confirm('¿Está seguro de eliminar este registro?')

    if res

      $http.delete('::bitacoras/destroy/'+intento.id).then((r)->
          toastr.success 'Eliminado. Recargue para ver los cambios.'
          intento.eliminada = true
          $scope.changes_asked.intentos_fallidos = $filter('filter')($scope.changes_asked.intentos_fallidos, {id: '!'+intento.id}, true)
      , (r2)->
        toastr.error 'No se pudo eliminar'
      )



])



