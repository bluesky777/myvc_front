'use strict'

angular.module('myvcFrontApp')

.controller('DisciplinaCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$filter', 'App', 'AuthService', 'escalas', 'EscalasValorativasServ', 'ProfesoresServ', '$cookies', ($scope, toastr, $http, $modal, $state, $filter, App, AuthService, escalas, EscalasValorativasServ, ProfesoresServ, $cookies)->

  AuthService.verificar_acceso()

  $scope.perfilPath 	  	= App.images+'perfil/'
  $scope.views 		      	= App.views
  $scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
  $scope.escalas 					= escalas
  $scope.escala_maxima 		= EscalasValorativasServ.escala_maxima()
  $scope.config_infor 	  = {}
  $scope.datos 		      	= {
    grupo: ''
  }

  if $cookies.getObject 'config'
    $scope.config_infor = $cookies.getObject 'config'
  else
    $scope.config_infor.orientacion   = 'vertical'




  if localStorage.inmovible_activado
    $scope.inmovible_activado = (localStorage.inmovible_activado == 'true')
  else
    $scope.inmovible_activado = true


  $scope.toggleMostrarDetalle = (alumno, prop)->
    alumno[prop] = !alumno[prop]


  $scope.traerProceso = ()->
    grupo_id = $scope.datos.grupo.id

    $http.put('::disciplina/alumnos', {grupo_id: grupo_id}).then((r)->
      $scope.alumnos = r.data.alumnos
      for alumno in $scope.alumnos
        for unif in alumno.uniformes_per1
          unif.fecha_hora = new Date(unif.fecha_hora.replace(/-/g, '\/'))
        for unif in alumno.uniformes_per2
          unif.fecha_hora = new Date(unif.fecha_hora.replace(/-/g, '\/'))
        for unif in alumno.uniformes_per3
          unif.fecha_hora = new Date(unif.fecha_hora.replace(/-/g, '\/'))
        for unif in alumno.uniformes_per4
          unif.fecha_hora = new Date(unif.fecha_hora.replace(/-/g, '\/'))

    , (r2)->
      toastr.error('No se trajo los alumnos')
    )


  $scope.crearFalta = (alumno, periodo, per_num)->

    modalInstance = $modal.open({
      templateUrl: '==comportamiento/crearFaltaModal.tpl.html'
      controller: 'CrearFaltaCtrl'
      size: 'lg'
      scope: $scope
      resolve:
        alumno: ()->
          alumno
        per_num: ()->
          per_num
        periodos: ()->
          $scope.periodos
        config: ()->
          $scope.config
        profesores: ()->
          $scope.profesores
        ordinales: ()->
          $scope.ordinales
        creando: ()->
          true
    })
    modalInstance.result.then( (ficha)->
      #console.log($scope.alumnos)
    , ()->
      #console.log($scope.alumnos)
    )



  $scope.verFaltasModal = (alumno, periodo, per_num, tipo_falta_num)->
    periodo.editando = false

    modalInstance = $modal.open({
      templateUrl: '==comportamiento/crearFaltaModal.tpl.html'
      controller: 'CrearFaltaCtrl'
      size: 'lg'
      scope: $scope
      resolve:
        alumno: ()->
          alumno
        per_num: ()->
          per_num
        periodos: ()->
          $scope.periodos
        config: ()->
          $scope.config
        profesores: ()->
          $scope.profesores
        ordinales: ()->
          $scope.ordinales
        creando: ()->
          false
    })
    modalInstance.result.then( (ficha)->
      #console.log($scope.alumnos)
    , ()->
      #console.log($scope.alumnos)
    )



  $scope.verUniformesModal = (alumno, per_num)->

    modalInstance = $modal.open({
      templateUrl: '==comportamiento/uniformesAlumnoPeriodoModal.tpl.html'
      controller: 'verUniformesAlumnoPeriodoModal'
      size: 'lg'
      scope: $scope
      resolve:
        alumno: ()->
          alumno
        per_num: ()->
          per_num
        periodos: ()->
          $scope.periodos
        config: ()->
          $scope.config
        profesores: ()->
          $scope.profesores
    })
    modalInstance.result.then( (ficha)->
      #console.log($scope.alumnos)
    , ()->
      #console.log($scope.alumnos)
    )


  $scope.toggleInmovible = ()->
    $scope.inmovible_activado 			  = !$scope.inmovible_activado
    localStorage.inmovible_activado 	= $scope.inmovible_activado
    if !$scope.inmovible_activado
      $('td.fixed-cell').css( {'transform': 'translate(0, 0)'});




  $http.put('::grupos/con-disciplina').then((r)->

    matr_grupo = 0

    if localStorage.matr_grupo
      matr_grupo = parseInt(localStorage.matr_grupo)

    $scope.grupos 		              = r.data.grupos
    $scope.config 		              = r.data.config
    $scope.ordinales 	              = r.data.ordinales
    $scope.descripciones_typeahead 	= r.data.descripciones_typeahead
    $scope.year 	                  = r.data.year

    for grupo in $scope.grupos
      if grupo.id == matr_grupo
        $scope.datos.grupo = grupo
        grupo.active = true

    $scope.traerProceso()

  , ()->
    toastr.error('No se pudo traer los grupos y datos')
  )

  ProfesoresServ.contratos().then((r)->
    $scope.profesores = r
  , (r2)->
    toastr.error 'No se pudo traer los profesores.'
  )


  $scope.selectGrupo = (grupo)->
    localStorage.matr_grupo = grupo.id
    $scope.datos.grupo 		= grupo

    for grup in $scope.grupos
      grup.active = false

    grupo.active = true

    $scope.traerProceso()





  ################################
  ######## Informes ##############
  ################################

  $scope.$watch 'config_infor', (newVal, oldVal)->
    $cookies.putObject 'config', newVal
    $scope.$broadcast 'change_config'
  , true

  $scope.$broadcast 'change_config'

  $scope.verSituacionesPorGrupos = ()->
    $state.go 'panel.disciplina.ver-situaciones-por-grupos', {reload: true}




])


