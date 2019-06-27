angular.module('myvcFrontApp')

.factory('AuthService', ['$state', '$http', '$cookies', 'Perfil', '$rootScope', 'AUTH_EVENTS', '$q', '$filter', 'toastr', ($state, $http, $cookies, Perfil, $rootScope, AUTH_EVENTS, $q, $filter, toastr)->
  authService = {}

  authService.verificar = ()->
    d = $q.defer();

    if Perfil.User().user_id
      d.resolve Perfil.User()
    else
      if $cookies.get('xtoken')
        if $cookies.get('xtoken') != undefined and $cookies.get('xtoken') != 'undefined'  and $cookies.get('xtoken') != '[object Object]'
          authService.login_from_token().then((usuario)->
            Perfil.setUser usuario
            d.resolve usuario
          , (r2)->
            console.log 'No se logueó from token'
            d.reject r2
          )
        else
          authService.borrarToken()
          d.reject 'Token mal estructurado.'
      else
        console.log 'No hay token'
        d.resolve 'No hay token.'
        #$state.go 'login'
        $rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
    return d.promise




  authService.verificar_acceso = ()->
    if !Perfil.User().user_id
      $state.go 'login'

    next = $state.current
    autorizado_perms = false
    autorizado_roles = false

    if next.data.needed_permissions
      needed_permissions = next.data.needed_permissions

      if (!authService.isAuthorized(needed_permissions))
        autorizado_perms = true


    if next.data.needed_roles
      needed_roles = next.data.needed_roles

      if (!authService.isAuthorized(false, needed_roles))
        autorizado_roles = true

    if autorizado_perms and autorizado_roles
      $rootScope.lastState = next.name
      if (authService.isAuthenticated())
        # user is not allowed
        $rootScope.$broadcast(AUTH_EVENTS.notAuthorized)
      else
        $state.transitionTo 'login'

    if !next.data.needed_roles and !next.data.needed_permissions
      return true




  authService.login_credentials = (credentials)->

    d = $q.defer();

    authService.borrarToken()

    $http.post('::login/credentials', credentials).then((r)->
      respuesta = r.data

      if respuesta.el_token
        $cookies.put('xtoken', respuesta.el_token)

        if respuesta.cambia_anio > 0
          localStorage.cambia_anio = respuesta.cambia_anio

        $http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')
        localStorage.logueando = 'token_verificado'

        d.resolve respuesta.el_token
      else
        #console.log 'No se trajo un token en el login.', user
        $rootScope.$broadcast AUTH_EVENTS.loginFailed
        d.reject 'Error en login'



    , (r2)->
      $rootScope.$broadcast AUTH_EVENTS.loginFailed

      console.log(r2)

      if r2
        if r2.status
          if r2.status == 400
            if r2.data.message == 'Usuario invalidado'
              toastr.error 'Te han desactivado', 'NO ACTIVO', {timeOut: 8000}
            else
              toastr.error 'Datos inválidos', '', {timeOut: 8000}
          else if r2.status == -1
            toastr.error 'No parece haber comunicación con el servidor', '', {timeOut: 8000}
          else if r2.status == 500
            toastr.error 'No parece haber comunicación con la Base de datos', '', {timeOut: 8000}

        else if r2.data
          if r2.data == 'user_inactivo'
            toastr.warning 'Usuario desactivado'

          if r2.data.error
            if r2.data.error == 'Token expirado' or r2.error == 'token_expired'
              toastr.warning 'La sesión ha expirado'
              if $state.current.name != 'login'
                $state.go 'login'

            else
              $rootScope.$broadcast AUTH_EVENTS.loginFailed
        else
          toastr.error 'No parece haber comunicación con el servidor'
      else
        toastr.error 'No parece haber comunicación con el servidor'
      d.reject 'Error en login'
    )
    return d.promise


  authService.login_from_token = ()->

    d = $q.defer();

    $http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.get('xtoken')

    login = $http.post('::login').then((r)->
      usuario = r.data
      $rootScope.$broadcast(AUTH_EVENTS.loginSuccess);
      d.resolve usuario

    , (r2)->

      if r2.data
        if r2.data.message == "user_inactivo"
          toastr.warning 'Usuario desactivado'

      d.reject 'Error en login con token.'
      #$rootScope.$broadcast AUTH_EVENTS.loginFailed
    )
    return d.promise


  authService.logout = ()->

    login = $http.put('::login/logout', {user_id: Perfil.User().user_id}).then((r)->
      console.log('Sesión cerrada');
    , (r2)->
      console.log 'No se registró el cierre de sesión.'
    )
    $rootScope.lastState = null
    $rootScope.lastStateParam = null
    Perfil.deleteUser()
    authService.borrarToken()
    delete localStorage.logueando
    $state.transitionTo 'login'

  authService.borrarToken = ()->
    $cookies.remove('xtoken')
    delete $http.defaults.headers.common['Authorization']

  authService.isAuthenticated = ()->
    return !!Perfil.User().user_id;

  authService.isAuthorized = (neededPermissions, neededRoles)->
    user = Perfil.User()
    if user.is_superuser
      return true

    newArr = []

    if neededPermissions
      if (!angular.isArray(neededPermissions))
        neededPermissions = [neededPermissions]

      if (!angular.isArray(user.perms))
        if neededPermissions.length > 0
          return false; # Hay permisos requeridos pero el usuario no tiene ninguno
        else
          return true; # El usuarios no tiene permisos pero no se requiere ninguno


      angular.forEach(neededPermissions, (elem)->
        if (user.perms.indexOf(elem)) != -1
          newArr.push elem
      )

    if neededRoles
      if (!angular.isArray(neededRoles))
        neededRoles = [neededRoles]

      if (!angular.isArray(user.roles))
        if neededRoles.length > 0
          return false; # Hay permisos requeridos pero el usuario no tiene ninguno
        else
          return true; # El usuarios no tiene permisos pero no se requiere ninguno


      angular.forEach(neededRoles, (elem)->
        for rol in user.roles
          if rol.name.toLocaleLowerCase() == elem.toLocaleLowerCase()
            newArr.push elem
      )

    return (authService.isAuthenticated() and (newArr.length > 0))



  authService.hasRoleOrPerm = (ReqRoles, RedPermis)->
    if (!angular.isArray(ReqRoles))
      if ReqRoles
        ReqRoles = [ReqRoles]
      else
        return false;

    rolesFound = []
    angular.forEach(ReqRoles, (elem)->
      rolesFoundTemp = []
      rolesFoundTemp = $filter('filter')(Perfil.User().roles, {name: elem})

      if rolesFoundTemp
        if rolesFoundTemp.length > 0
          rolesFound.push elem
    )

    return (rolesFound.length > 0)



  return authService;
])
