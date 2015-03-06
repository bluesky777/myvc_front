angular.module('myvcFrontApp')

.factory('AuthService', ['Restangular', '$state', '$http', '$cookies', 'Perfil', '$rootScope', 'AUTH_EVENTS', '$q', '$filter', 'toastr', (Restangular, $state, $http, $cookies, Perfil, $rootScope, AUTH_EVENTS, $q, $filter, toastr)->
	authService = {}

	authService.verificar = ()->
		d = $q.defer();

		if Perfil.User().user_id
			d.resolve Perfil.User()
		else
			if $cookies.xtoken
				if $cookies.xtoken != undefined and $cookies.xtoken != 'undefined'  and $cookies.xtoken != '[object Object]'
					authService.login_from_token().then((usuario)->
						Perfil.setUser usuario
						d.resolve usuario
					, (r2)->
						console.log 'No se logueó from token'
						d.reject r2
					)
				else
					console.log 'Token mal estructurado: ', $cookies.xtoken
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

		if next.data.needed_permissions
			needed_permissions = next.data.needed_permissions 

			if (!authService.isAuthorized(needed_permissions))
				#event.preventDefault()
				console.log 'No tiene permisos, y... '
				
				$rootScope.lastState = next.name
				if (authService.isAuthenticated())
					# user is not allowed
					$rootScope.$broadcast(AUTH_EVENTS.notAuthorized)
					console.log '...está Autenticado.'
				else
					# user is not logged in
					#$rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
					console.log '...NO está Autenticado.'
					$state.transitionTo 'login'
		else
			return true



	authService.login_credentials = (credentials)->

		d = $q.defer();

		authService.borrarToken()

		Restangular.one('login').post('', credentials).then((user)->
			#debugger
			if user.token
				$cookies.xtoken = user.token
				
				$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.xtoken

				Perfil.setUser user

				console.log 'Usuario traido: ', user
				
				$rootScope.$broadcast AUTH_EVENTS.loginSuccess
				d.resolve user
			else
				console.log 'No se trajo un token en el login.', user
				$rootScope.$broadcast AUTH_EVENTS.loginFailed
				d.reject 'Error en login'


		, (r2)->
			console.log 'No se pudo loguear. ', r2
			$rootScope.$broadcast AUTH_EVENTS.loginFailed
			d.reject 'Error en login'
		)
		return d.promise


	authService.login_from_token = ()->

		d = $q.defer();

		$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.xtoken

		login = Restangular.one('login').post().then((usuario)->

			$rootScope.$broadcast(AUTH_EVENTS.loginSuccess);
			d.resolve usuario

		, (r2)->
			console.log 'No se pudo loguear con token. ', r2
			d.reject 'Error en login con token.'
			#$rootScope.$broadcast AUTH_EVENTS.loginFailed
		)
		return d.promise


	authService.logout = (credentials)->
		#Restangular.one('logout').get();
		$rootScope.lastScope = null
		$rootScope.lastStateParam = null
		authService.borrarToken()
		Perfil.deleteUser()
		$state.transitionTo 'login'

	authService.borrarToken = ()->
		delete $cookies.xtoken
		delete $http.defaults.headers.common['Authorization']

	authService.isAuthenticated = ()->
		return !!Perfil.User().user_id;

	authService.isAuthorized = (neededPermissions)->

		user = Perfil.User()
		if user.is_superuser
			return true

		if (!angular.isArray(neededPermissions))
			neededPermissions = [neededPermissions]

		if (!angular.isArray(user.perms))
			if neededPermissions.length > 0
				return false; # Hay permisos requeridos pero el usuario no tiene ninguno
			else
				return true; # El usuarios no tiene permisos pero no se requiere ninguno

		newArr = []
		_.each(neededPermissions, (elem)->
			if (user.perms.indexOf(elem)) != -1
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
		
		_.each(ReqRoles, (elem)->
			rolesFoundTemp = []
			rolesFoundTemp = $filter('filter')(Perfil.User().roles, {name: elem})

			if rolesFoundTemp
				if rolesFoundTemp.length > 0
					rolesFound.push elem
		)
		return (rolesFound.length > 0)



	return authService;
])
