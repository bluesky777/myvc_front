angular.module('myvcFrontApp')

.controller('ActaEvaluacionPromocionCtrl',['$scope', '$interval', 'App', 'Perfil', 'datos', '$state', '$filter', '$uibModal', '$http', 'toastr', ($scope, $interval, App, Perfil, datos, $state, $filter, $modal, $http, toastr)->
  $scope.grupos       = datos.data.grupos
  $scope.year         = datos.data.year
  $scope.USER         = Perfil.User()
  $scope.perfilPath   = App.images+'perfil/'
  $scope.views 				= App.views
  $scope.dato         = {}

  $scope.dato.texto_acta_eval    = $scope.year.texto_acta_eval

  fecha = new Date();
  $scope.dato.hora_acta = fecha
  $scope.dato.dia_acta  = fecha


  $scope.cambia_texto_informativo = ()->

    $http.put('::actas-evaluacion/cambiar-descripcion', {texto_acta_eval: data.texto_acta_eval }).then((r)->
      toastr.success('Texto guardado')
    , (r2)->
      toastr.warning 'No se pudo guardar texto.', 'Problema'
    )


  $scope.calcularDatos = ()->

    if $scope.calcular_blocked
      return

    $scope.porcentaje   = 0
    $scope.calcular_blocked   = true

    $scope.grupo_temp_calculado = true
    $scope.grupo_temp_indce     = 0

    $scope.intervalo = $interval(()->

      if $scope.grupo_temp_calculado

        $scope.grupo_temp_calculado = false
        grupo 							= $scope.grupos[$scope.grupo_temp_indce]
        $scope.porcentaje 	= parseInt(($scope.grupo_temp_indce+1) * 100 / $scope.grupos.length)

        $http.put('::actas-evaluacion/calcular-datos', {grupo_id: grupo.id}).then((r)->
          toastr.success grupo.nombre + ' calculado con éxito'
          $scope.grupo_temp_calculado = true
          $scope.grupo_temp_indce     = $scope.grupo_temp_indce + 1
          if $scope.grupo_temp_indce == $scope.grupos.length
            $interval.cancel($scope.intervalo)

        , (r2)->
          $scope.grupo_temp_calculado = true
          toastr.warning 'No se pudo calcular ' + grupo.nombre + '. Intentaremos de nuevo.'
        )

    , 20)




  $scope.verAlumnos = (alumnos)->
    modalInstance = $modal.open({
      templateUrl: '==informes/verAlumnosActaModal.tpl.html'
      controller: 'VerAlumnosActaCtrl'
      size: 'lg'
      resolve:
        alumnos: ()->
          alumnos
    })
    modalInstance.result.then( (alum)->
      console.log('Editado')
    , ()->
      # nada
    )




  $scope.editarAlumno = (alumno)->
    modalInstance = $modal.open({
      templateUrl: '==informes/editarActaEvaluacionModal.tpl.html'
      controller: 'EditarActaEvaluacionCtrl'
      size: 'lg'
      resolve:
        alumno: ()->
          alumno
    })
    modalInstance.result.then( (alum)->
      console.log('Editado')
    , ()->
      # nada
    )


  $scope.$emit 'cambia_descripcion', 'Acta de evaluación y promoción ' + $scope.USER.year

])





.controller('VerAlumnosActaCtrl', ['$scope', '$uibModalInstance', 'alumnos', '$http', 'toastr', 'App', ($scope, $modalInstance, alumnos, $http, toastr, App)->

  $scope.perfilPath 	= App.images+'perfil/'
  $scope.views 				= App.views
  $scope.data         = {}
  $scope.alumnos      = alumnos


  for alumno in alumnos
    if alumno.fecha_nac
      alumno.fecha_nac = new Date(alumno.fecha_nac)

    if alumno.fecha_matricula
      alumno.fecha_matricula = new Date(alumno.fecha_matricula)

    if alumno.fecha_retiro
      alumno.fecha_retiro = new Date(alumno.fecha_retiro)

    $scope.alumno 		  = alumno




  $scope.guardarValor = (rowEntity, colDef, newValue, year_id)->
    datos = {}

    if colDef == "sexo"
      newValue = newValue.toUpperCase()
      if !(newValue == 'M' or newValue == 'F')
        toastr.warning 'Debe usar M o F'
        rowEntity.sexo = $scope.alum_copy['sexo']
        return

    if colDef == "estrato"
      if newValue < 0 or newValue > 9
        toastr.warning 'Valor no admitido'
        rowEntity.estrato = $scope.alum_copy['estrato']
        return


    datos.alumno_id = rowEntity.alumno_id
    datos.propiedad = colDef
    datos.valor 		= newValue
    datos.year_id 	= rowEntity.year_id

    if year_id
      datos.year_id = year_id

    $http.put('::alumnos/guardar-valor', datos ).then((r)->
      toastr.success 'Dato actualizado con éxito'
    , (r2)->
      rowEntity[colDef] = $scope.alum_copy[colDef]
      toastr.error 'Cambio no guardado', 'Error'
    )



  $scope.ok = ()->
    $modalInstance.close(alumno)

])



.controller('EditarActaEvaluacionCtrl', ['$scope', '$uibModalInstance', 'alumno', '$http', 'toastr', 'App', ($scope, $modalInstance, alumno, $http, toastr, App)->

  $scope.perfilPath 	= App.images+'perfil/'
  $scope.views 				= App.views
  $scope.data         = {}

  if alumno.fecha_nac
    alumno.fecha_nac = new Date(alumno.fecha_nac)

  if alumno.fecha_matricula
    alumno.fecha_matricula = new Date(alumno.fecha_matricula)

  if alumno.fecha_retiro
    alumno.fecha_retiro = new Date(alumno.fecha_retiro)

  $scope.alumno 		  = alumno

  $http.put('::actas-evaluacion/detalle', {alumno_id: alumno.alumno_id, grupo_id: alumno.grupo_id }).then((r)->
    $scope.alumnos      = r.data.alumnos
    $scope.matriculas   = r.data.matriculas
  , (r2)->
    toastr.warning 'No se pudo traer detalles.', 'Problema'
  )




  $scope.guardarValor = (rowEntity, colDef, newValue, year_id)->
    datos = {}

    if colDef == "sexo"
      newValue = newValue.toUpperCase()
      if !(newValue == 'M' or newValue == 'F')
        toastr.warning 'Debe usar M o F'
        rowEntity.sexo = $scope.alum_copy['sexo']
        return

    if colDef == "estrato"
      if newValue < 0 or newValue > 9
        toastr.warning 'Valor no admitido'
        rowEntity.estrato = $scope.alum_copy['estrato']
        return


    datos.alumno_id = rowEntity.alumno_id
    datos.propiedad = colDef
    datos.valor 		= newValue
    datos.year_id 	= rowEntity.year_id

    if year_id
      datos.year_id = year_id

    $http.put('::alumnos/guardar-valor', datos ).then((r)->
      toastr.success 'Dato actualizado con éxito'
    , (r2)->
      rowEntity[colDef] = $scope.alum_copy[colDef]
      toastr.error 'Cambio no guardado', 'Error'
    )



  $scope.ok = ()->
    $modalInstance.close(alumno)

])
