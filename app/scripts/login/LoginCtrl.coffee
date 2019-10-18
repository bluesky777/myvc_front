'use strict'

angular.module('myvcFrontApp')
.controller('LoginCtrl', ['$scope', '$rootScope', 'AUTH_EVENTS', 'AuthService', '$location', '$cookies', 'Perfil', 'App', '$http', 'toastr', '$sce', ($scope, $rootScope, AUTH_EVENTS, AuthService, $location, $cookies, Perfil, App, $http, toastr, $sce)->

  animation_speed         = 300
  $scope.logueando        = true
  $scope.recuperando      = false
  $scope.registrando      = false
  $scope.perfilPath       = App.images+'perfil/'


  # Si el colegio quiere que aparezca su imagen en el encabezado, puede hacerlo.
  $scope.logoPathDefault = 'images/Logo_MyVc_Header.gif'
  $scope.logoPath = 'images/Logo_Colegio_Header.gif'
  #$scope.paramuser = {'username': Perfil.User().username }


  $scope.verPublicacionDetalle = ()->
    toastr.info 'Debes loguearte para ver más detalles.'

  $http.get($scope.logoPath).then(()->
    console.log('imagen existe')
  , ()->
    #alert('image not exist')
    $scope.logoPath = $scope.logoPathDefault # set default image
  )


  $scope.abrirImagenBlank = (ruta)->
    window.open(ruta, '_blank');


  $scope.ir_prematricular = ()->
    $scope.mostrando_prematricular = !$scope.mostrando_prematricular
    if $scope.mostrando_prematricular
      $scope.estilo_login = 'height: 600px !important;';
    else
      $scope.estilo_login = '';



  $scope.guardar_prematricula = ()->
    $scope.guardando = true
    cre = $scope.credentials

    if cre.nombres.length and cre.apellidos.length and cre.celular.length and cre.documento.length

      cre.estado    = 'PREA'
      cre.nuevo     = 1
      cre.year      = $scope.year.year+1
      cre.grupo_id  = $scope.year.grupo_prematr.id

      $http.put('::login/crear-prematricula', cre).then((r)->
        toastr.success r.data.estado

        $scope.credentials =
          username: ''
          password: ''
          sexo: 'M'
          nombres: ''
          apellidos: ''
          celular: ''
          documento: ''

        $scope.ir_prematricular()

      , ()->
        #alert('image not exist')
        $scope.logoPath = $scope.logoPathDefault # set default image
      )


    else
      toastr.error 'Faltan datos, por favor escíbelos todos.'




  $http.put('::publicaciones/ultimas').then((r)->
    $scope.publicaciones  = r.data.publicaciones
    $scope.year           = r.data.year

    for publi in $scope.publicaciones
      publi.contenido = $sce.trustAsHtml(publi.contenido)
  , ()->
    #alert('image not exist')
    $scope.logoPath = $scope.logoPathDefault # set default image
  )


  $scope.credentials =
    username: ''
    password: ''
    sexo: 'M'
    nombres: ''
    apellidos: ''
    celular: ''
    documento: ''


  $scope.host = $location.host()

  $scope.login = (credentials)->
    $cookies.remove('xtoken')
    Perfil.deleteUser()

    AuthService.login_credentials(credentials).then((r)->

      AuthService.verificar().then((r2)->
        #if localStorage.getItem('logueando') == 'token_verificado'
        localStorage.removeItem('logueando')
      , (r3)->
        console.log('Falló en Verificar', r3)
      )
      return
    )


  $scope.enviarPass = (correo_electronico)->
    $http.post('::login/ver-pass', {email: correo_electronico, ruta: location.origin + location.pathname }).then((r)->
      alert('Ahora, verifica tu correo');
    , ()->
      alert('Parece que el correo no está registrado.');
    )


  $scope.to_recuperando = ->
    $scope.logueando = false
    $scope.recuperando = true
    $scope.registrando = false
  $scope.to_registrando = ->
    $scope.logueando = false
    $scope.recuperando = false
    $scope.registrando = true
  $scope.to_logueando = ->
    $scope.logueando = true
    $scope.recuperando = false
    $scope.registrando = false

  return

])




.controller('ResetPasswordCtrl', ['$scope', '$state', '$stateParams', '$cookies', 'Perfil', 'App', '$http', 'toastr', ($scope, $state, $stateParams, $cookies, Perfil, App, $http, toastr)->

  $scope.reseteando = false
  $scope.username   = $stateParams.username
  $scope.logoPath   = 'images/Logo_Colegio_Header.gif'

  if $stateParams.numero < 10000
    console.log 'Reseteo inválido, deja de intentarlo.'
    $state.go 'login'


  $scope.credentials =
    password1: ''
    password2: ''

  $scope.reset = (credentials)->
    $scope.reseteando = true

    if credentials.password1 != credentials.password2
      toastr.warning 'Las contraseñas no coinciden.'
      $scope.reseteando = false
      return
    if credentials.password1.length < 4
      toastr.warning 'Debe tener al menos 4 caracteres'
      $scope.reseteando = false
      return

    $http.put('::login/reset-password', {password1: credentials.password1, numero: $stateParams.numero, username: $stateParams.username }).then((r)->
      if r.data == 'Token inválido'
        toastr.warning 'Token inválido'
        $scope.reseteando = false
      else
        $state.go 'login'
    , (r2)->
      console.log('No se pudo resetear')
      $scope.reseteando = false
    )


  return

])
